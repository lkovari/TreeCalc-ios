import Foundation

enum StackAction: Equatable {
    case pushValue(String)
    case applyUnary(OperatorKind, operand: String, result: String)
    case applyBinary(OperatorKind, left: String, right: String, result: String)
}

struct EvaluationStep: Equatable {
    var action: StackAction
    var stack: [String]
}

func wrappedTraceOperand(_ label: String) -> String {
    if label.contains(" ") || label.contains("=") {
        return "(\(label))"
    }
    return label
}

func traceSentence(_ action: StackAction, hungarian: Bool) -> String {
    switch action {
    case .pushValue(let raw):
        return hungarian ? "betesz \(raw)" : "push \(raw)"
    case .applyUnary(let kind, let operand, let result):
        let wrapped = wrappedTraceOperand(operand)
        if hungarian {
            return "\(wrapped) \(kind.displaySymbol), eredmény \(result)"
        }
        return "\(wrapped) \(kind.displaySymbol), result \(result)"
    case .applyBinary(let kind, let left, let right, let result):
        let wrappedLeft = wrappedTraceOperand(left)
        let wrappedRight = wrappedTraceOperand(right)
        if hungarian {
            return "\(wrappedLeft) \(kind.displaySymbol) \(wrappedRight), eredmény \(result)"
        }
        return "\(wrappedLeft) \(kind.displaySymbol) \(wrappedRight), result \(result)"
    }
}

extension ExpressionNode {
    func evaluationSteps(base: NumericBase, angleMode: AngleMode) -> [EvaluationStep] {
        var stack: [ExpressionNode] = []
        var steps: [EvaluationStep] = []
        for node in postOrderNodes() {
            let action: StackAction
            switch node {
            case .value(_, let raw):
                stack.append(node)
                action = .pushValue(raw)
            case .unary(let kind, let operand):
                let operandLabel = operand.displayLabel(base: base, angleMode: angleMode)
                if !stack.isEmpty {
                    stack.removeLast()
                }
                stack.append(node)
                action = .applyUnary(kind, operand: operandLabel, result: node.displayLabel(base: base, angleMode: angleMode))
            case .binary(let kind, let left, let right):
                let leftLabel = left.displayLabel(base: base, angleMode: angleMode)
                let rightLabel = right.displayLabel(base: base, angleMode: angleMode)
                if !stack.isEmpty {
                    stack.removeLast()
                }
                if !stack.isEmpty {
                    stack.removeLast()
                }
                stack.append(node)
                action = .applyBinary(
                    kind,
                    left: leftLabel,
                    right: rightLabel,
                    result: node.displayLabel(base: base, angleMode: angleMode)
                )
            }
            steps.append(
                EvaluationStep(
                    action: action,
                    stack: stack.map { $0.displayLabel(base: base, angleMode: angleMode) }
                )
            )
        }
        return steps
    }
}
