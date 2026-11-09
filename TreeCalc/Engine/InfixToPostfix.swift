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

    static func sourceIndices(_ infix: [Token]) -> [Int] {
        var output: [Int] = []
        var operators: [YardMark] = []
        for (index, token) in infix.enumerated() {
            switch token {
            case .numberLiteral:
                output.append(index)
            case .operatorToken(let kind):
                while let top = operators.last {
                    if case .operatorIndex(let stackedIndex) = top,
                       case .operatorToken(let stacked) = infix[stackedIndex],
                       shouldPop(incoming: kind, stackTop: stacked) {
                        operators.removeLast()
                        output.append(stackedIndex)
                    } else {
                        break
                    }
                }
                operators.append(.operatorIndex(index))
            case .leftParen:
                operators.append(.paren)
            case .rightParen:
                var foundLeft = false
                while !operators.isEmpty {
                    let top = operators.removeLast()
                    if case .paren = top {
                        foundLeft = true
                        break
                    }
                    if case .operatorIndex(let stackedIndex) = top {
                        output.append(stackedIndex)
                    }
                }
                if !foundLeft {
                    return []
                }
            }
        }
        while !operators.isEmpty {
            let top = operators.removeLast()
            if case .paren = top {
                return []
            }
            if case .operatorIndex(let stackedIndex) = top {
                output.append(stackedIndex)
            }
        }
        return output
    }

    private enum YardMark {
        case operatorIndex(Int)
        case paren
    }

    private static func shouldPop(incoming: OperatorKind, stackTop: OperatorKind) -> Bool {
        if incoming.associativity == .right {
            return stackTop.precedence > incoming.precedence
        }
        return stackTop.precedence >= incoming.precedence
    }
}
