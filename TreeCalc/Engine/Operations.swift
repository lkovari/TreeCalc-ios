import Foundation

enum Operations {
    static func executeBinary(_ left: Double, _ right: Double, _ kind: OperatorKind) throws -> Double {
        switch kind {
        case .add:
            return left + right
        case .sub:
            return left - right
        case .mul:
            return left * right
        case .div:
            if right == 0 {
                if left == 0 {
                    throw CalculatorException(kind: .undefined)
                }
                throw CalculatorException(kind: .divisionByZero)
            }
            return left / right
        case .mod:
            if right == 0 {
                throw CalculatorException(kind: .divisionByZero)
            }
            return left.truncatingRemainder(dividingBy: right)
        case .pow:
            return try finite(Foundation.pow(left, right))
        case .and:
            return Double(try toInt32(left) & toInt32(right))
        case .or:
            return Double(try toInt32(left) | toInt32(right))
        case .xor:
            return Double(try toInt32(left) ^ toInt32(right))
        case .lsh:
            let shift = try toInt32(right)
            if shift < 0 || shift > 31 {
                throw CalculatorException(kind: .domain)
            }
            let bits = UInt32(bitPattern: try toInt32(left)) << UInt32(shift)
            return Double(Int32(bitPattern: bits))
        case .not, .neg, .sqrt, .rec, .sin, .cos, .tan, .ln, .log, .exp, .sq, .cube, .fact:
            throw CalculatorException(kind: .malformedExpression)
        }
    }

    static func executeUnary(
        _ operand: Double,
        _ kind: OperatorKind,
        angleMode: AngleMode = .degrees
    ) throws -> Double {
        switch kind {
        case .neg:
            return -operand
        case .not:
            let bits = ~UInt32(bitPattern: try toInt32(operand))
            return Double(Int32(bitPattern: bits))
        case .sqrt:
            if operand < 0 {
                throw CalculatorException(kind: .domain)
            }
            return Foundation.sqrt(operand)
        case .rec:
            if operand == 0 {
                throw CalculatorException(kind: .divisionByZero)
            }
            return 1 / operand
        case .sin:
            return Foundation.sin(toRadians(operand, angleMode))
        case .cos:
            return Foundation.cos(toRadians(operand, angleMode))
        case .tan:
            return try finite(Foundation.tan(toRadians(operand, angleMode)))
        case .ln:
            if operand <= 0 {
                throw CalculatorException(kind: .domain)
            }
            return Foundation.log(operand)
        case .log:
            if operand <= 0 {
                throw CalculatorException(kind: .domain)
            }
            return Foundation.log10(operand)
        case .exp:
            return try finite(Foundation.exp(operand))
        case .sq:
            return operand * operand
        case .cube:
            return operand * operand * operand
        case .fact:
            return try factorial(operand)
        case .add, .sub, .mul, .div, .mod, .pow, .and, .or, .xor, .lsh:
            throw CalculatorException(kind: .malformedExpression)
        }
    }

    private static func toRadians(_ operand: Double, _ angleMode: AngleMode) -> Double {
        if angleMode == .degrees {
            return operand * Double.pi / 180
        }
        return operand
    }

    private static func finite(_ value: Double) throws -> Double {
        if value.isNaN || value.isInfinite {
            throw CalculatorException(kind: .domain)
        }
        return value
    }

    private static func toInt32(_ value: Double) throws -> Int32 {
        if !NumericText.isWhole(value) {
            throw CalculatorException(kind: .bitwiseNonInteger)
        }
        if value > Double(Int32.max) || value < Double(Int32.min) {
            throw CalculatorException(kind: .domain)
        }
        return Int32(value.rounded())
    }

    private static func factorial(_ value: Double) throws -> Double {
        if value < 0 || !NumericText.isWhole(value) {
            throw CalculatorException(kind: .invalidFactorial)
        }
        let n = Int(value.rounded())
        if n > 170 {
            throw CalculatorException(kind: .domain)
        }
        var result = 1.0
        if n >= 2 {
            for i in 2...n {
                result *= Double(i)
            }
        }
        return result
    }
}
