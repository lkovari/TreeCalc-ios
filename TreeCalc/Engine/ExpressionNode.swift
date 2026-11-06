import Foundation

indirect enum ExpressionNode: Equatable {
    case value(Double, String)
    case unary(OperatorKind, ExpressionNode)
    case binary(OperatorKind, ExpressionNode, ExpressionNode)

    func evaluate(angleMode: AngleMode = .degrees) throws -> Double {
        switch self {
        case .value(let value, _):
            return value
        case .unary(let kind, let operand):
            return try Operations.executeUnary(try operand.evaluate(angleMode: angleMode), kind, angleMode: angleMode)
        case .binary(let kind, let left, let right):
            return try Operations.executeBinary(
                try left.evaluate(angleMode: angleMode),
                try right.evaluate(angleMode: angleMode),
                kind
            )
        }
    }

    var childCount: Int {
        switch self {
        case .value: 0
        case .unary: 1
        case .binary: 2
        }
    }

    func childAt(_ index: Int) -> ExpressionNode? {
        switch self {
        case .value:
            return nil
        case .unary(_, let operand):
            return index == 0 ? operand : nil
        case .binary(_, let left, let right):
            if index == 0 { return left }
            if index == 1 { return right }
            return nil
        }
    }

    var operatorKind: OperatorKind? {
        switch self {
        case .value:
            return nil
        case .unary(let kind, _):
            return kind
        case .binary(let kind, _, _):
            return kind
        }
    }

    var raw: String? {
        if case .value(_, let raw) = self {
            return raw
        }
        return nil
    }

    func displayLabel(base: NumericBase, angleMode: AngleMode = .degrees) -> String {
        switch self {
        case .value(_, let raw):
            return raw
        case .unary, .binary:
            let symbol = operatorKind?.treeLabel ?? ""
            guard let value = try? evaluate(angleMode: angleMode) else {
                return symbol
            }
            let text = DecimalDisplay.present(value: value, base: base, fraction: exactFraction(base: base))
            return "\(symbol) = \(text)"
        }
    }

    func postOrderNodes() -> [ExpressionNode] {
        var nodes: [ExpressionNode] = []
        collectPostOrder(&nodes)
        return nodes
    }

    func pathForPostOrderIndex(_ index: Int) -> String? {
        var paths: [String] = []
        collectPostOrderPaths("root", &paths)
        if index < 0 || index >= paths.count {
            return nil
        }
        return paths[index]
    }

    func exactFraction(base: NumericBase) -> Fraction? {
        switch self {
        case .value(_, let raw):
            return Fraction.fromLiteral(raw, radix: base.radix)
        case .unary(let kind, let operand):
            guard let value = operand.exactFraction(base: base) else { return nil }
            switch kind {
            case .neg:
                return value.negated()
            case .rec:
                return Fraction.reduced(1, 1)?.divided(value)
            case .sq:
                return value.raised(to: 2)
            case .cube:
                return value.raised(to: 3)
            default:
                return nil
            }
        case .binary(let kind, let left, let right):
            guard let lhs = left.exactFraction(base: base), let rhs = right.exactFraction(base: base) else { return nil }
            switch kind {
            case .add:
                return lhs.added(rhs)
            case .sub:
                return lhs.subtracted(rhs)
            case .mul:
                return lhs.multiplied(rhs)
            case .div:
                return lhs.divided(rhs)
            case .pow:
                guard rhs.den == 1, rhs.num >= -12, rhs.num <= 16 else { return nil }
                return lhs.raised(to: rhs.num)
            default:
                return nil
            }
        }
    }

    private func collectPostOrder(_ out: inout [ExpressionNode]) {
        var index = 0
        while index < childCount {
            if let child = childAt(index) {
                child.collectPostOrder(&out)
            }
            index += 1
        }
        out.append(self)
    }

    private func collectPostOrderPaths(_ path: String, _ out: inout [String]) {
        var index = 0
        while index < childCount {
            if let child = childAt(index) {
                child.collectPostOrderPaths("\(path)/\(index)", &out)
            }
            index += 1
        }
        out.append(path)
    }
}
