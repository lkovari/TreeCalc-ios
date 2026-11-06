import Foundation

enum ExpressionTreeBuilder {
    static func build(_ postfix: [Token], base: NumericBase) throws -> ExpressionNode {
        var stack: [ExpressionNode] = []
        for token in postfix {
            switch token {
            case .numberLiteral(let raw):
                let value = try NumericText.parse(raw, base: base)
                stack.append(.value(value, raw))
            case .operatorToken(let kind):
                switch kind.arity {
                case .unary:
                    if stack.isEmpty {
                        throw CalculatorException(kind: .malformedExpression)
                    }
                    let operand = stack.removeLast()
                    stack.append(.unary(kind, operand))
                case .binary:
                    if stack.count < 2 {
                        throw CalculatorException(kind: .malformedExpression)
                    }
                    let right = stack.removeLast()
                    let left = stack.removeLast()
                    stack.append(.binary(kind, left, right))
                }
            case .leftParen, .rightParen:
                throw CalculatorException(kind: .malformedExpression)
            }
        }
        if stack.count != 1 {
            throw CalculatorException(kind: .malformedExpression)
        }
        return stack.removeLast()
    }
}
