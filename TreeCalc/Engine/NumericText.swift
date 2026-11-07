import Foundation

enum NumericText {
    static let piSymbol = "π"
    static let scientificUpper = 1e15
    static let scientificLower = 1e-9
    private static let int64Limit = 0x1p63

    static func parse(_ raw: String, base: NumericBase) throws -> Double {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == piSymbol || trimmed.lowercased() == "pi" {
            return Double.pi
        }
        if trimmed.isEmpty || trimmed == "-" || trimmed == "." || trimmed == "-." {
            throw CalculatorException(kind: .malformedExpression)
        }
        if let fraction = Fraction.fromLiteral(trimmed, radix: base.radix) {
            return Double(fraction.num) / Double(fraction.den)
        }
        guard let value = approximateLiteral(trimmed, base: base), value.isFinite else {
            throw CalculatorException(kind: .malformedExpression)
        }
        return value
    }

    static func format(_ value: Double, base: NumericBase) throws -> String {
        if value.isNaN || value.isInfinite {
            throw CalculatorException(kind: .domain)
        }
        if base == .decimal {
            let magnitude = abs(value)
            if magnitude >= scientificUpper || (magnitude > 0 && magnitude < scientificLower) {
                return scientific(value)
            }
            if isWhole(value), let whole = Int64(exactly: value.rounded()) {
                return String(whole)
            }
            return plainScale12(value)
        }
        if !fits(value, base: base) {
            throw CalculatorException(kind: .overflow)
        }
        if isWhole(value), let whole = Int64(exactly: value.rounded()) {
            return String(whole, radix: base.radix).uppercased()
        }
        return approximate(value, base: base)
    }

    static func fits(_ value: Double, base: NumericBase) -> Bool {
        base == .decimal || abs(value) < int64Limit
    }

    private static func scientific(_ value: Double) -> String {
        let text = String(format: "%.11e", locale: Locale(identifier: "en_US_POSIX"), value).lowercased()
        let parts = text.split(separator: "e")
        guard parts.count == 2, let exponent = Int(parts[1]) else { return text }
        var mantissa = String(parts[0])
        if mantissa.contains(".") {
            while mantissa.last == "0" { mantissa.removeLast() }
            if mantissa.last == "." { mantissa.removeLast() }
        }
        return "\(mantissa)e\(exponent)"
    }

    private static func approximateLiteral(_ text: String, base: NumericBase) -> Double? {
        if base == .decimal && text.lowercased().contains("e") {
            return Double(text.lowercased())
        }
        let negative = text.hasPrefix("-")
        let body = negative ? text.dropFirst() : Substring(text)
        let parts = body.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count > 2 || body.isEmpty { return nil }
        let radix = Double(base.radix)
        var value = 0.0
        for character in parts[0] {
            guard let digit = character.hexDigitValue, digit < base.radix else { return nil }
            value = value * radix + Double(digit)
        }
        if parts.count == 2 {
            var scale = 1.0
            for character in parts[1] {
                guard let digit = character.hexDigitValue, digit < base.radix else { return nil }
                scale /= radix
                value += Double(digit) * scale
            }
        }
        return negative ? -value : value
    }

    private static func approximate(_ value: Double, base: NumericBase) -> String {
        let negative = value < 0
        let magnitude = abs(value)
        let whole = Int64(magnitude.rounded(.towardZero))
        var remainder = magnitude - Double(whole)
        var fractional = ""
        for _ in 0..<12 {
            remainder *= Double(base.radix)
            var digit = Int(remainder.rounded(.towardZero))
            var next = remainder - Double(digit)
            if next > 1 - 1e-9 {
                digit += 1
                next = 0
            }
            if digit >= base.radix {
                digit = base.radix - 1
                next = 0
            }
            if digit < 0 { digit = 0 }
            fractional.append(DecimalDisplay.alphabet[digit])
            remainder = next
            if remainder < 1e-10 { break }
        }
        while fractional.last == "0" {
            fractional.removeLast()
        }
        let sign = negative ? "-" : ""
        let head = String(whole, radix: base.radix).uppercased()
        if fractional.isEmpty {
            return sign + head
        }
        return "\(sign)\(head).\(fractional)"
    }

    static func isValidDigit(_ character: Character, base: NumericBase) -> Bool {
        let upper = String(character).uppercased()
        guard let scalar = upper.unicodeScalars.first else { return false }
        switch base {
        case .binary:
            return scalar >= "0" && scalar <= "1"
        case .octal:
            return scalar >= "0" && scalar <= "7"
        case .decimal:
            return scalar >= "0" && scalar <= "9"
        case .hexadecimal:
            return (scalar >= "0" && scalar <= "9") || (scalar >= "A" && scalar <= "F")
        }
    }

    static func isWhole(_ value: Double) -> Bool {
        abs(value - value.rounded()) < 1e-9
    }

    private static func plainScale12(_ value: Double) -> String {
        var working = Decimal(value)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &working, 12, .plain)
        let formatter = Foundation.NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 12
        formatter.decimalSeparator = "."
        let text = formatter.string(from: NSDecimalNumber(decimal: rounded)) ?? "0"
        if text == "-0" {
            return "0"
        }
        return text
    }
}
