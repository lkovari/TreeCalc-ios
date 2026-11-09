import XCTest
@testable import TreeCalc

final class ExpressionSpansTests: XCTestCase {
    func testMultiplicationSpanSitsInsideTheSum() {
        let infix: [Token] = [
            .numberLiteral("9"),
            .operatorToken(.add),
            .numberLiteral("7"),
            .operatorToken(.mul),
            .numberLiteral("6")
        ]
        XCTAssertEqual(slices(infix), ["9", "7", "6", "7 × 6", "9 + 7 × 6"])
    }

    func testParenthesesWrapTheGroupedStep() {
        let infix: [Token] = [
            .leftParen,
            .numberLiteral("1"),
            .operatorToken(.add),
            .numberLiteral("2"),
            .rightParen,
            .operatorToken(.mul),
            .numberLiteral("3")
        ]
        XCTAssertEqual(slices(infix), ["1", "2", "( 1 + 2 )", "3", "( 1 + 2 ) × 3"])
    }

    func testPrefixMinusCoversThePowerItNegates() {
        let infix: [Token] = [
            .operatorToken(.neg),
            .numberLiteral("5"),
            .operatorToken(.pow),
            .numberLiteral("2")
        ]
        XCTAssertEqual(slices(infix), ["5", "2", "5 ^ 2", "− 5 ^ 2"])
    }

    func testPostfixSineCoversTheDivision() {
        let infix: [Token] = [
            .numberLiteral("π"),
            .operatorToken(.div),
            .numberLiteral("2"),
            .operatorToken(.sin)
        ]
        XCTAssertEqual(slices(infix), ["π", "2", "π ÷ 2", "π ÷ 2 sin"])
    }

    func testEnginePublishesSpansOnlyAfterEquals() {
        let engine = CalculatorEngine()
        pressAll(engine, "9+7*6")
        engine.press(.equals)
        let evaluated = engine.snapshot()
        XCTAssertEqual(spanSlices(evaluated.expression, evaluated.expressionSpans), ["9", "7", "6", "7 × 6", "9 + 7 × 6"])
        engine.press(.digit1)
        let typing = engine.snapshot()
        XCTAssertTrue(typing.expressionSpans.isEmpty)
        XCTAssertNotNil(typing.tree)
        XCTAssertEqual(typing.postfixTokens, evaluated.postfixTokens)
    }

    func testUnbalancedParenthesesProduceNoSpans() {
        let infix: [Token] = [.leftParen, .numberLiteral("1")]
        XCTAssertEqual(slices(infix), [])
    }

    private func slices(_ infix: [Token]) -> [String] {
        let text = infix.map(tokenExpressionText).joined(separator: " ")
        return spanSlices(text, expressionStepSpans(infix))
    }

    private func spanSlices(_ text: String, _ spans: [ClosedRange<Int>]) -> [String] {
        spans.map { range in
            let start = text.index(text.startIndex, offsetBy: range.lowerBound)
            let end = text.index(text.startIndex, offsetBy: range.upperBound + 1)
            return String(text[start..<end])
        }
    }
}
