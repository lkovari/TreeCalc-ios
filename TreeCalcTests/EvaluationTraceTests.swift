import XCTest
@testable import TreeCalc

final class EvaluationTraceTests: XCTestCase {
    func testMixedPrecedencePushesThenCombinesRightFirst() {
        let tree: ExpressionNode = .binary(
            .add,
            .value(9, "9"),
            .binary(.mul, .value(7, "7"), .value(6, "6"))
        )
        let steps = tree.evaluationSteps(base: .decimal, angleMode: .degrees)
        XCTAssertEqual(steps.count, 5)
        assertPush(steps[0], "9", ["9"])
        assertPush(steps[1], "7", ["9", "7"])
        assertPush(steps[2], "6", ["9", "7", "6"])
        assertBinary(steps[3], .mul, left: "7", right: "6", result: "× = 42", stack: ["9", "× = 42"])
        assertBinary(steps[4], .add, left: "9", right: "× = 42", result: "+ = 51", stack: ["+ = 51"])
        XCTAssertEqual(
            traceSentence(steps[4].action, hungarian: false),
            "9 + (× = 42), result + = 51"
        )
        XCTAssertEqual(
            traceSentence(steps[0].action, hungarian: true),
            "betesz 9"
        )
    }

    func testUnaryPopsOneOperand() {
        let tree: ExpressionNode = .unary(.sqrt, .value(9, "9"))
        let steps = tree.evaluationSteps(base: .decimal, angleMode: .degrees)
        XCTAssertEqual(steps.count, 2)
        assertPush(steps[0], "9", ["9"])
        guard case .applyUnary(let kind, let operand, let result) = steps[1].action else {
            XCTFail("expected unary")
            return
        }
        XCTAssertEqual(kind, .sqrt)
        XCTAssertEqual(operand, "9")
        XCTAssertEqual(result, "√ = 3")
        XCTAssertEqual(steps[1].stack, ["√ = 3"])
    }

    func testRightAssociativePowerKeepsTheBaseUnderTheInnerPower() {
        let tree: ExpressionNode = .binary(
            .pow,
            .value(2, "2"),
            .binary(.pow, .value(3, "3"), .value(2, "2"))
        )
        let steps = tree.evaluationSteps(base: .decimal, angleMode: .degrees)
        XCTAssertEqual(steps.count, 5)
        assertBinary(steps[3], .pow, left: "3", right: "2", result: "^ = 9", stack: ["2", "^ = 9"])
        assertBinary(steps[4], .pow, left: "2", right: "^ = 9", result: "^ = 512", stack: ["^ = 512"])
    }

    private func assertPush(_ step: EvaluationStep, _ raw: String, _ stack: [String]) {
        guard case .pushValue(let value) = step.action else {
            XCTFail("expected push")
            return
        }
        XCTAssertEqual(value, raw)
        XCTAssertEqual(step.stack, stack)
    }

    private func assertBinary(
        _ step: EvaluationStep,
        _ kind: OperatorKind,
        left: String,
        right: String,
        result: String,
        stack: [String]
    ) {
        guard case .applyBinary(let operatorKind, let gotLeft, let gotRight, let gotResult) = step.action else {
            XCTFail("expected binary")
            return
        }
        XCTAssertEqual(operatorKind, kind)
        XCTAssertEqual(gotLeft, left)
        XCTAssertEqual(gotRight, right)
        XCTAssertEqual(gotResult, result)
        XCTAssertEqual(step.stack, stack)
        XCTAssertFalse(step.stack.isEmpty)
    }
}
