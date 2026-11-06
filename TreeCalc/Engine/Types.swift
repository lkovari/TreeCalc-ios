import Foundation

enum ErrorKind: Equatable {
    case emptyExpression
    case unbalancedParentheses
    case divisionByZero
    case undefined
    case domain
    case bitwiseNonInteger
    case invalidDigit
    case malformedExpression
    case invalidFactorial
}

struct CalculatorException: Error, Equatable {
    var kind: ErrorKind
}

enum AngleMode: Equatable {
    case degrees
    case radians
}

enum NumericBase: Equatable, CaseIterable {
    case binary
    case octal
    case decimal
    case hexadecimal

    var radix: Int {
        switch self {
        case .binary: 2
        case .octal: 8
        case .decimal: 10
        case .hexadecimal: 16
        }
    }

    var integerOnly: Bool {
        false
    }

    func allowsKey(_ key: CalculatorKey) -> Bool {
        if let digit = key.digitValue {
            return digit < radix
        }
        switch key {
        case .pi, .sin, .cos, .tan, .ln, .log, .exp, .fact:
            return self == .decimal
        default:
            return true
        }
    }
}

enum CalculatorKey: Equatable, CaseIterable {
    case digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9
    case digitA, digitB, digitC, digitD, digitE, digitF
    case dot
    case add, sub, mul, div, mod, pow
    case and, or, xor, not, lsh
    case negate, sqrt, rec
    case sin, cos, tan, ln, log, exp, sq, cube, fact
    case pi, angleMode
    case leftParen, rightParen
    case equals, clear, backspace
    case memoryAdd, memorySub, memoryRecall, memoryClear
    case test

    var digitValue: Int? {
        switch self {
        case .digit0: 0
        case .digit1: 1
        case .digit2: 2
        case .digit3: 3
        case .digit4: 4
        case .digit5: 5
        case .digit6: 6
        case .digit7: 7
        case .digit8: 8
        case .digit9: 9
        case .digitA: 10
        case .digitB: 11
        case .digitC: 12
        case .digitD: 13
        case .digitE: 14
        case .digitF: 15
        default: nil
        }
    }
}

enum OperatorArity {
    case unary
    case binary
}

enum Associativity {
    case left
    case right
}

enum OperatorKind: Equatable {
    case add, sub, mul, div, mod, pow
    case and, or, xor, lsh
    case not, neg, sqrt, rec
    case sin, cos, tan, ln, log, exp
    case sq, cube, fact

    var displaySymbol: String {
        switch self {
        case .add: "+"
        case .sub: "-"
        case .mul: "×"
        case .div: "÷"
        case .mod: "mod"
        case .pow: "^"
        case .and: "and"
        case .or: "or"
        case .xor: "xor"
        case .lsh: "lsh"
        case .not: "not"
        case .neg: "−"
        case .sqrt: "√"
        case .rec: "1/"
        case .sin: "sin"
        case .cos: "cos"
        case .tan: "tan"
        case .ln: "ln"
        case .log: "log"
        case .exp: "exp"
        case .sq: "²"
        case .cube: "³"
        case .fact: "!"
        }
    }

    var treeLabel: String {
        switch self {
        case .neg: "neg"
        default: displaySymbol
        }
    }

    var precedence: Int {
        switch self {
        case .or: 5
        case .xor: 6
        case .and: 7
        case .add, .sub: 11
        case .mul, .div, .mod, .lsh, .sin, .cos, .tan, .ln, .log, .exp: 12
        case .not: 14
        case .pow, .neg, .sqrt, .rec, .sq, .cube, .fact: 99
        }
    }

    var arity: OperatorArity {
        switch self {
        case .not, .neg, .sqrt, .rec, .sin, .cos, .tan, .ln, .log, .exp, .sq, .cube, .fact:
            .unary
        default:
            .binary
        }
    }

    var associativity: Associativity {
        switch self {
        case .pow, .neg: .right
        default: .left
        }
    }
}

enum Token: Equatable {
    case numberLiteral(String)
    case operatorToken(OperatorKind)
    case leftParen
    case rightParen
}

struct EvaluationResult: Equatable {
    var display: String
    var expression: String
    var postfix: String
    var postfixTokens: [String]
    var tree: ExpressionNode?
    var base: NumericBase
    var errorKind: ErrorKind?
    var memorySet: Bool
    var afterEquals: Bool
    var angleMode: AngleMode
}
