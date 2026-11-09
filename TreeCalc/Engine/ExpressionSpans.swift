import Foundation

func tokenExpressionText(_ token: Token) -> String {
    switch token {
    case .numberLiteral(let raw):
        return raw
    case .operatorToken(let kind):
        return kind.displaySymbol
    case .leftParen:
        return "("
    case .rightParen:
        return ")"
    }
}

func expressionStepSpans(_ infix: [Token]) -> [ClosedRange<Int>] {
    if infix.isEmpty {
        return []
    }
    let ranges = tokenRanges(infix)
    if ranges.count != infix.count {
        return []
    }
    let sources = InfixToPostfix.sourceIndices(infix)
    var stack: [StepSpan] = []
    var steps: [ClosedRange<Int>] = []
    for source in sources {
        if source < 0 || source >= infix.count {
            return []
        }
        let token = infix[source]
        let tokenRange = ranges[source]
        let span: StepSpan
        switch token {
        case .numberLiteral:
            span = StepSpan(start: tokenRange.lowerBound, end: tokenRange.upperBound)
        case .operatorToken(let kind):
            switch kind.arity {
            case .unary:
                guard let operand = stack.popLast() else { return [] }
                span = merged(tokenRange, operand)
            case .binary:
                guard let right = stack.popLast(), let left = stack.popLast() else { return [] }
                span = merged(tokenRange, left, right)
            }
        case .leftParen, .rightParen:
            return []
        }
        let enclosed = encloseParentheses(span, infix: infix, ranges: ranges)
        stack.append(enclosed)
        steps.append(enclosed.start...enclosed.end)
    }
    if stack.count != 1 {
        return []
    }
    return steps
}

private struct StepSpan {
    var start: Int
    var end: Int
}

private func tokenRanges(_ infix: [Token]) -> [ClosedRange<Int>] {
    var ranges: [ClosedRange<Int>] = []
    var cursor = 0
    for (index, token) in infix.enumerated() {
        if index > 0 {
            cursor += 1
        }
        let text = tokenExpressionText(token)
        if text.isEmpty {
            return []
        }
        let start = cursor
        let end = cursor + text.count - 1
        ranges.append(start...end)
        cursor = end + 1
    }
    return ranges
}

private func merged(_ token: ClosedRange<Int>, _ nodes: StepSpan...) -> StepSpan {
    var start = token.lowerBound
    var end = token.upperBound
    for node in nodes {
        if node.start < start {
            start = node.start
        }
        if node.end > end {
            end = node.end
        }
    }
    return StepSpan(start: start, end: end)
}

private func encloseParentheses(_ span: StepSpan, infix: [Token], ranges: [ClosedRange<Int>]) -> StepSpan {
    var start = span.start
    var end = span.end
    while true {
        var left = -1
        var right = -1
        for (index, range) in ranges.enumerated() {
            if range.upperBound < start {
                left = index
            }
            if right < 0 && range.lowerBound > end {
                right = index
            }
        }
        if left < 0 || right < 0 {
            break
        }
        let leftTouches = ranges[left].upperBound + 2 == start
        let rightTouches = ranges[right].lowerBound == end + 2
        if case .leftParen = infix[left], case .rightParen = infix[right], leftTouches, rightTouches {
            start = ranges[left].lowerBound
            end = ranges[right].upperBound
        } else {
            break
        }
    }
    return StepSpan(start: start, end: end)
}
