import Foundation

enum NumericText {
    static let piSymbol = "π"

    static func parse(_ raw: String, base: NumericBase) throws -> Double {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == piSymbol || trimmed.lowercased() == "pi" {
            return Double.pi
        }
        if trimmed.isEmpty || trimmed == "-" || trimmed == "." || trimmed == "-." {
            throw CalculatorException(kind: .malformedExpression)
        }
        guard let fraction = Fraction.fromLiteral(trimmed, radix: base.radix) else {
            throw CalculatorException(kind: .malformedExpression)
        }
        return Double(fraction.num) / Double(fraction.den)
    }

    static func format(_ value: Double, base: NumericBase) throws -> String {
        if value.isNaN || value.isInfinite {
            throw CalculatorException(kind: .domain)
        }
        if base == .decimal {
            if isWhole(value), abs(value) <= Double(Int64.max) {
                return String(Int64(value.rounded()))
            }
            return plainScale12(value)
        }
        if isWhole(value), abs(value) <= Double(Int64.max) {
            return String(Int64(value.rounded()), radix: base.radix).uppercased()
        }
        return approximate(value, base: base)
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
