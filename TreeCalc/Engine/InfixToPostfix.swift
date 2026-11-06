import Foundation

enum InfixToPostfix {
    static func convert(_ infix: [Token]) throws -> [Token] {
        var output: [Token] = []
        var operators: [Token] = []
        for token in infix {
            switch token {
            case .numberLiteral:
                output.append(token)
            case .operatorToken(let kind):
                while let top = operators.last {
                    if case .operatorToken(let stacked) = top, shouldPop(incoming: kind, stackTop: stacked) {
                        output.append(operators.removeLast())
                    } else {
                        break
                    }
                }
                operators.append(token)
            case .leftParen:
                operators.append(token)
            case .rightParen:
                var foundLeft = false
                while !operators.isEmpty {
                    let top = operators.removeLast()
                    if case .leftParen = top {
                        foundLeft = true
                        break
                    }
                    output.append(top)
                }
                if !foundLeft {
                    throw CalculatorException(kind: .unbalancedParentheses)
                }
            }
        }
        while !operators.isEmpty {
            let top = operators.removeLast()
            if case .leftParen = top {
                throw CalculatorException(kind: .unbalancedParentheses)
            }
            output.append(top)
        }
        return output
    }

    private static func shouldPop(incoming: OperatorKind, stackTop: OperatorKind) -> Bool {
        if incoming.associativity == .right {
            return stackTop.precedence > incoming.precedence
        }
        return stackTop.precedence >= incoming.precedence
    }
}
