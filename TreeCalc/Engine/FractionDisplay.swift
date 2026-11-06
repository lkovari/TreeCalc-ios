import Foundation

struct Fraction: Equatable {
    var num: Int64
    var den: Int64

    static func reduced(_ num: Int64, _ den: Int64) -> Fraction? {
        if den == 0 { return nil }
        var n = num
        var d = den
        if d < 0 {
            if n == Int64.min || d == Int64.min { return nil }
            n = -n
            d = -d
        }
        let divisor = gcd(n, d)
        if divisor == 0 { return nil }
        return Fraction(num: n / divisor, den: d / divisor)
    }

    static func fromDecimalLiteral(_ raw: String) -> Fraction? {
        fromLiteral(raw, radix: 10)
    }

    static func fromLiteral(_ raw: String, radix: Int) -> Fraction? {
        if radix < 2 || radix > 16 { return nil }
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text == NumericText.piSymbol || text.lowercased() == "pi" {
            return nil
        }
        if text.isEmpty || text == "-" || text == "." || text == "-." {
            return nil
        }
        let negative = text.hasPrefix("-")
        let body = negative ? String(text.dropFirst()) : text
        if body.isEmpty || body.contains("-") { return nil }
        let open = body.firstIndex(of: "(")
        let close = body.lastIndex(of: ")")
        var main = body
        var period = ""
        if let open, let close {
            if close != body.index(before: body.endIndex) || open >= close { return nil }
            if body.contains("(") && body[body.index(after: open)...].contains("(") { return nil }
            period = String(body[body.index(after: open)..<close])
            main = String(body[..<open])
            if period.isEmpty || !main.contains(".") { return nil }
        } else if body.contains("(") || body.contains(")") {
            return nil
        }
        let parts = main.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count > 2 { return nil }
        let whole = parts[0]
        let frac = parts.count == 2 ? String(parts[1]) : ""
        guard let wholeN = parseDigits(whole, radix: radix),
              let fracN = parseDigits(frac, radix: radix),
              let periodN = parseDigits(period, radix: radix),
              let scale = power(Int64(radix), frac.count),
              var value = reduced(wholeN, 1)?.added(reduced(fracN, scale) ?? Fraction(num: 0, den: 1))
        else { return nil }
        if !period.isEmpty {
            guard let cycle = power(Int64(radix), period.count), cycle > 1 else { return nil }
            let repeatDen = cycle - 1
            guard let repeatPart = reduced(periodN, repeatDen)?.divided(reduced(scale, 1) ?? Fraction(num: 1, den: 1)),
                  let combined = value.added(repeatPart)
            else { return nil }
            value = combined
        }
        if whole.isEmpty && frac.isEmpty && period.isEmpty { return nil }
        if negative {
            return value.negated()
        }
        return value
    }

    func negated() -> Fraction? {
        if num == Int64.min { return nil }
        return Fraction.reduced(-num, den)
    }

    func added(_ other: Fraction) -> Fraction? {
        guard let left = mul(num, other.den), let right = mul(other.num, den), let sum = add(left, right), let bottom = mul(den, other.den) else {
            return nil
        }
        return Fraction.reduced(sum, bottom)
    }

    func subtracted(_ other: Fraction) -> Fraction? {
        guard let flipped = other.negated() else { return nil }
        return added(flipped)
    }

    func multiplied(_ other: Fraction) -> Fraction? {
        guard let top = mul(num, other.num), let bottom = mul(den, other.den) else { return nil }
        return Fraction.reduced(top, bottom)
    }

    func divided(_ other: Fraction) -> Fraction? {
        if other.num == 0 { return nil }
        guard let top = mul(num, other.den), let bottom = mul(den, other.num) else { return nil }
        return Fraction.reduced(top, bottom)
    }

    func raised(to exponent: Int64) -> Fraction? {
        if exponent < 0 {
            if exponent == Int64.min { return nil }
            guard let positive = raised(to: -exponent), positive.num != 0 else { return nil }
            return Fraction.reduced(positive.den, positive.num)
        }
        if exponent == 0 {
            return Fraction.reduced(1, 1)
        }
        if exponent > 16 { return nil }
        var result = Fraction(num: 1, den: 1)
        for _ in 0..<exponent {
            guard let next = result.multiplied(self) else { return nil }
            result = next
        }
        return result
    }
}

enum DecimalKind: Equatable {
    case terminating(decimals: Int)
    case repeating(preperiod: Int, period: Int?)
}

func classify(_ fraction: Fraction, base: Int = 10, maxPeriod: Int = 64) -> DecimalKind {
    let reduced = Fraction.reduced(fraction.num, fraction.den) ?? fraction
    let radix = Int64(base)
    var q = reduced.den
    var pre = 0
    while true {
        let shared = gcd(q, radix)
        if shared <= 1 { break }
        q /= shared
        pre += 1
        if pre > 128 {
            return .repeating(preperiod: pre, period: nil)
        }
    }
    if q == 1 {
        return .terminating(decimals: pre)
    }
    if radix <= 1 || q > Int64.max / radix {
        return .repeating(preperiod: pre, period: nil)
    }
    var power = radix % q
    if power == 0 {
        return .terminating(decimals: pre)
    }
    var k = 1
    while power != 1 {
        if k >= maxPeriod {
            return .repeating(preperiod: pre, period: nil)
        }
        let next = power.multipliedReportingOverflow(by: radix)
        if next.overflow { return .repeating(preperiod: pre, period: nil) }
        power = next.partialValue % q
        k += 1
    }
    return .repeating(preperiod: pre, period: k)
}

enum DecimalDisplay {
    static let alphabet = Array("0123456789ABCDEF")

    static func format(_ fraction: Fraction, base: NumericBase = .decimal, maxFractionDigits: Int = 12) -> String? {
        guard let reduced = Fraction.reduced(fraction.num, fraction.den) else { return nil }
        switch classify(reduced, base: base.radix) {
        case .terminating(let decimals):
            return digits(reduced, base: base.radix, preperiod: decimals, period: 0, repeating: false)
        case .repeating(let preperiod, let period?):
            if preperiod + period > maxFractionDigits { return nil }
            return digits(reduced, base: base.radix, preperiod: preperiod, period: period, repeating: true)
        case .repeating:
            return nil
        }
    }

    static func present(value: Double, base: NumericBase, fraction: Fraction?) -> String {
        if let fraction, let pretty = format(fraction, base: base) {
            return pretty
        }
        return (try? NumericText.format(value, base: base)) ?? "0"
    }

    private static func digits(_ fraction: Fraction, base: Int, preperiod: Int, period: Int, repeating: Bool) -> String? {
        if fraction.num == Int64.min || fraction.den <= 0 || base < 2 || base > 16 { return nil }
        let negative = fraction.num < 0
        let absNum = negative ? -fraction.num : fraction.num
        let den = fraction.den
        let integer = absNum / den
        var remainder = absNum % den
        var fractional = ""
        let count = repeating ? preperiod + period : preperiod
        let radix = Int64(base)
        for _ in 0..<count {
            let step = remainder.multipliedReportingOverflow(by: radix)
            if step.overflow { return nil }
            let digit = step.partialValue / den
            if digit < 0 || digit >= radix { return nil }
            fractional.append(alphabet[Int(digit)])
            remainder = step.partialValue % den
        }
        if !repeating {
            while fractional.last == "0" {
                fractional.removeLast()
            }
        }
        let sign = negative ? "-" : ""
        let whole = String(integer, radix: base).uppercased()
        if fractional.isEmpty {
            return sign + whole
        }
        if repeating && period > 0 {
            let prefix = String(fractional.prefix(preperiod))
            let cycle = String(fractional.suffix(period))
            return "\(sign)\(whole).\(prefix)(\(cycle))"
        }
        return "\(sign)\(whole).\(fractional)"
    }
}

private func parseDigits(_ text: String.SubSequence, radix: Int) -> Int64? {
    parseDigits(String(text), radix: radix)
}

private func parseDigits(_ text: String, radix: Int) -> Int64? {
    if text.isEmpty { return 0 }
    var value: Int64 = 0
    for character in text {
        guard let digit = digitValue(character), digit < radix else { return nil }
        let scaled = value.multipliedReportingOverflow(by: Int64(radix))
        if scaled.overflow { return nil }
        let added = scaled.partialValue.addingReportingOverflow(Int64(digit))
        if added.overflow { return nil }
        value = added.partialValue
    }
    return value
}

private func digitValue(_ character: Character) -> Int? {
    guard let scalar = character.asciiValue else { return nil }
    if scalar >= 48 && scalar <= 57 {
        return Int(scalar - 48)
    }
    if scalar >= 65 && scalar <= 70 {
        return Int(scalar - 65 + 10)
    }
    if scalar >= 97 && scalar <= 102 {
        return Int(scalar - 97 + 10)
    }
    return nil
}

private func power(_ base: Int64, _ exponent: Int) -> Int64? {
    if exponent < 0 { return nil }
    var result: Int64 = 1
    for _ in 0..<exponent {
        let scaled = result.multipliedReportingOverflow(by: base)
        if scaled.overflow { return nil }
        result = scaled.partialValue
    }
    return result
}

private func gcd(_ a: Int64, _ b: Int64) -> Int64 {
    var x = a.magnitude
    var y = b.magnitude
    while y != 0 {
        let next = x % y
        x = y
        y = next
    }
    if x > UInt64(Int64.max) { return 0 }
    return Int64(x)
}

private func mul(_ a: Int64, _ b: Int64) -> Int64? {
    let product = a.multipliedReportingOverflow(by: b)
    if product.overflow { return nil }
    return product.partialValue
}

private func add(_ a: Int64, _ b: Int64) -> Int64? {
    let sum = a.addingReportingOverflow(b)
    if sum.overflow { return nil }
    return sum.partialValue
}
