import XCTest
import SwiftUI
@testable import TreeCalc

final class EdgeCaseTests: XCTestCase {
    func testExactFractionResults() throws {
        XCTAssertEqual(show("1/3*3"), "1")
        XCTAssertEqual(show("1/3-1/3"), "0")
        XCTAssertEqual(show("1/6+1/3"), "0.5")
        XCTAssertEqual(show("0.1*10"), "1")
        XCTAssertEqual(show("(1/2)/(1/4)"), "2")
        XCTAssertEqual(show("0/5"), "0")
        XCTAssertEqual(show("1/3-1"), "-0.(6)")
        XCTAssertEqual(show("1000000000000+1"), "1000000000001")
        let reciprocal = evaluated { engine in
            engine.press(.digit3)
            engine.press(.rec)
        }
        XCTAssertEqual(reciprocal.display, "0.(3)")
        let squared = evaluated { engine in
            pressAll(engine, "0.5")
            engine.press(.sq)
        }
        XCTAssertEqual(squared.display, "0.25")
        let cubed = evaluated { engine in
            pressAll(engine, "0.5")
            engine.press(.cube)
        }
        XCTAssertEqual(cubed.display, "0.125")
        let chained = evaluated { engine in
            pressAll(engine, "81")
            engine.press(.sqrt)
            engine.press(.sqrt)
        }
        XCTAssertEqual(chained.display, "3")
        let factored = evaluated { engine in
            engine.press(.digit3)
            engine.press(.sq)
            engine.press(.fact)
        }
        XCTAssertEqual(factored.display, "362880")
        XCTAssertEqual(factored.postfix, "3, ², !")
    }

    func testAssociativityAndPrecedence() {
        XCTAssertEqual(show("8-3-2"), "3")
        XCTAssertEqual(show("20/4/2"), "2.5")
        XCTAssertEqual(show("2^3^2"), "512")
        let modulo = evaluated { engine in
            engine.press(.digit8)
            engine.press(.mod)
            engine.press(.digit3)
            engine.press(.mul)
            engine.press(.digit2)
        }
        XCTAssertEqual(modulo.display, "4")
        XCTAssertEqual(modulo.postfix, "8, 3, mod, 2, ×")
        let mixed = evaluated { engine in
            pressAll(engine, "10+3")
            engine.press(.mod)
            engine.press(.digit4)
        }
        XCTAssertEqual(mixed.display, "13")
        XCTAssertEqual(mixed.postfix, "10, 3, 4, mod, +")
        let factorial = evaluated { engine in
            pressAll(engine, "3+4")
            engine.press(.fact)
        }
        XCTAssertEqual(factorial.display, "27")
        XCTAssertEqual(factorial.postfix, "3, 4, !, +")
        let shifted = evaluated { engine in
            pressAll(engine, "1+2")
            engine.press(.lsh)
            engine.press(.digit3)
        }
        XCTAssertEqual(shifted.display, "17")
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "(1+2)")
            engine.press(.lsh)
            engine.press(.digit3)
        }.display, "24")
        let rooted = evaluated { engine in
            engine.press(.digit9)
            engine.press(.sqrt)
            engine.press(.add)
            engine.press(.digit1)
        }
        XCTAssertEqual(rooted.display, "4")
        let bits = evaluated { engine in
            engine.press(.digit1)
            engine.press(.not)
            engine.press(.and)
            engine.press(.digit1)
        }
        XCTAssertEqual(bits.display, "0")
        XCTAssertEqual(bits.postfix, "1, not, 1, and")
    }

    func testPowerRootAndScientificBoundaries() throws {
        XCTAssertEqual(show("5^0"), "1")
        XCTAssertEqual(show("0^0"), "1")
        XCTAssertEqual(try XCTUnwrap(treeOf("0^0")).exactFraction(base: .decimal), Fraction.reduced(1, 1))
        XCTAssertEqual(show("4^0.5"), "2")
        XCTAssertNil(try XCTUnwrap(treeOf("4^0.5")).exactFraction(base: .decimal))
        XCTAssertEqual(show("2^16"), "65536")
        XCTAssertEqual(try XCTUnwrap(treeOf("2^16")).exactFraction(base: .decimal), Fraction.reduced(65536, 1))
        XCTAssertEqual(show("2^17"), "131072")
        XCTAssertNil(try XCTUnwrap(treeOf("2^17")).exactFraction(base: .decimal))
        let negativeTwelve = evaluated { engine in
            engine.press(.digit2)
            engine.press(.pow)
            engine.press(.negate)
            pressAll(engine, "12")
        }
        XCTAssertEqual(negativeTwelve.display, "0.000244140625")
        XCTAssertNotNil(negativeTwelve.tree?.exactFraction(base: .decimal))
        let negativeThirteen = evaluated { engine in
            engine.press(.digit2)
            engine.press(.pow)
            engine.press(.negate)
            pressAll(engine, "13")
        }
        XCTAssertNil(negativeThirteen.tree?.exactFraction(base: .decimal))
        XCTAssertFalse(negativeThirteen.display.contains("("))
        XCTAssertEqual(try NumericText.parse(negativeThirteen.display, base: .decimal), pow(2, -13), accuracy: 1e-12)
        let inverse = evaluated { engine in
            engine.press(.digit2)
            engine.press(.pow)
            engine.press(.negate)
            engine.press(.digit1)
        }
        XCTAssertEqual(inverse.display, "0.5")
        let grouped = evaluated { engine in
            engine.press(.leftParen)
            engine.press(.digit2)
            engine.press(.negate)
            engine.press(.rightParen)
            engine.press(.pow)
            engine.press(.digit3)
        }
        XCTAssertEqual(grouped.display, "-8")
        let negativeSquare = evaluated { engine in
            engine.press(.leftParen)
            engine.press(.digit2)
            engine.press(.negate)
            engine.press(.rightParen)
            engine.press(.pow)
            engine.press(.negate)
            engine.press(.digit2)
        }
        XCTAssertEqual(negativeSquare.display, "0.25")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit0)
            engine.press(.pow)
            engine.press(.negate)
            engine.press(.digit1)
        }.errorKind, .domain)
        XCTAssertEqual(evaluated { engine in
            engine.press(.leftParen)
            engine.press(.digit4)
            engine.press(.negate)
            engine.press(.rightParen)
            engine.press(.pow)
            pressAll(engine, "0.5")
        }.errorKind, .domain)
        let tangent = evaluated { engine in
            pressAll(engine, "90")
            engine.press(.tan)
        }
        let tangentValue = try XCTUnwrap(tangent.tree).evaluate()
        XCTAssertNil(tangent.errorKind)
        XCTAssertGreaterThan(abs(tangentValue), 1e15)
        XCTAssertEqual(tangent.display, try NumericText.format(tangentValue, base: .decimal))
        try assertNear("90", .cos, 0, "0")
        try assertNear("30", .sin, 0.5, "0.5")
        try assertNear("45", .tan, 1, "1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.ln)
        }.display, "0")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.log)
        }.display, "0")
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "1000")
            engine.press(.log)
        }.display, "3")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit0)
            engine.press(.exp)
        }.display, "1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit0)
            engine.press(.fact)
        }.display, "1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.fact)
        }.display, "1")
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "10")
            engine.press(.fact)
        }.display, "3628800")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.negate)
            engine.press(.fact)
        }.errorKind, .invalidFactorial)
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit2)
            engine.press(.negate)
            engine.press(.cube)
        }.display, "-8")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit3)
            engine.press(.negate)
            engine.press(.sq)
        }.display, "9")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit4)
            engine.press(.negate)
            engine.press(.rec)
        }.display, "-0.25")
        assertKind(.domain) { _ = try Operations.executeUnary(1000, .exp) }
        XCTAssertTrue(try Operations.executeUnary(170, .fact).isFinite)
        assertKind(.domain) { _ = try Operations.executeUnary(171, .fact) }
    }

    func testRepeatingLengthsAndOtherBases() throws {
        XCTAssertEqual(show("1/11"), "0.(09)")
        XCTAssertEqual(show("2/7"), "0.(285714)")
        XCTAssertEqual(show("5/6"), "0.8(3)")
        XCTAssertEqual(show("-1/3"), "-0.(3)")
        let seventeenth = show("1/17")
        XCTAssertFalse(seventeenth.contains("("))
        XCTAssertEqual(seventeenth, try NumericText.format(1.0 / 17.0, base: .decimal))
        let fraction = try XCTUnwrap(Fraction.reduced(1, 17))
        XCTAssertNil(DecimalDisplay.format(fraction))
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(1, 2))), "0.5")
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(1, 4))), "0.25")
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(1, 5))), "0.2")
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(1, 20))), "0.05")
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(-4, 2))), "-2")
        XCTAssertEqual(DecimalDisplay.format(try XCTUnwrap(Fraction.reduced(-1, 3))), "-0.(3)")
        let binary = fresh()
        pressAll(binary, "1/3")
        binary.press(.equals)
        binary.setBase(.binary)
        XCTAssertEqual(binary.snapshot().display, "0.(01)")
        binary.setBase(.octal)
        XCTAssertEqual(binary.snapshot().display, "0.(25)")
        binary.setBase(.hexadecimal)
        XCTAssertEqual(binary.snapshot().display, "0.(5)")
        binary.setBase(.decimal)
        XCTAssertEqual(binary.snapshot().display, "0.(3)")
        XCTAssertEqual(Fraction.fromLiteral("0.(01)", radix: 2), Fraction.reduced(1, 3))
        XCTAssertEqual(Fraction.fromLiteral("0.(25)", radix: 8), Fraction.reduced(1, 3))
        XCTAssertEqual(Fraction.fromLiteral("0.(5)", radix: 16), Fraction.reduced(1, 3))
        XCTAssertEqual(Fraction.fromLiteral("0.1(9)", radix: 16), Fraction.reduced(1, 10))
    }

    func testFractionAndClassifierEdges() throws {
        XCTAssertNil(Fraction.reduced(1, 0))
        XCTAssertNil(Fraction.reduced(Int64.min, -1))
        XCTAssertNil(Fraction.reduced(1, Int64.min))
        XCTAssertEqual(Fraction.reduced(1, -2), Fraction.reduced(-1, 2))
        XCTAssertEqual(Fraction.reduced(-4, -2), Fraction.reduced(2, 1))
        XCTAssertNil(Fraction(num: Int64.min, den: 1).negated())
        XCTAssertNil(Fraction(num: Int64.max, den: 1).added(Fraction(num: 1, den: 1)))
        XCTAssertNil(try XCTUnwrap(Fraction.reduced(1, 1)).divided(Fraction(num: 0, den: 1)))
        XCTAssertEqual(try XCTUnwrap(Fraction.reduced(0, 1)).raised(to: 0), Fraction.reduced(1, 1))
        XCTAssertNil(try XCTUnwrap(Fraction.reduced(2, 1)).raised(to: 17))
        XCTAssertNil(try XCTUnwrap(Fraction.reduced(2, 1)).raised(to: Int64.min))
        XCTAssertEqual(try XCTUnwrap(Fraction.reduced(2, 1)).raised(to: -1), Fraction.reduced(1, 2))
        XCTAssertEqual(Fraction.fromDecimalLiteral("0.5"), Fraction.reduced(1, 2))
        XCTAssertNil(Fraction.fromDecimalLiteral("1/2"))
        for raw in ["", "-", ".", "-.", "pi", "π", "1-2", "0.(3", "0.3)", "0.(3)1", "0.((3)", "0()", "0(3)", "1.2.3", "G", "2"] {
            XCTAssertNil(Fraction.fromLiteral(raw, radix: raw == "2" ? 2 : 10), raw)
        }
        XCTAssertNil(Fraction.fromLiteral("10", radix: 1))
        XCTAssertNil(Fraction.fromLiteral("10", radix: 17))
        XCTAssertEqual(Fraction.fromLiteral("10.", radix: 10), Fraction.reduced(10, 1))
        XCTAssertEqual(Fraction.fromLiteral("0.1(6)", radix: 10), Fraction.reduced(1, 6))
        XCTAssertEqual(Fraction.fromLiteral("0.08(3)", radix: 10), Fraction.reduced(1, 12))
        XCTAssertEqual(Fraction.fromLiteral(".(3)", radix: 10), Fraction.reduced(1, 3))
        XCTAssertEqual(Fraction.fromLiteral("0.4", radix: 8), Fraction.reduced(1, 2))
        XCTAssertEqual(Fraction.fromLiteral("0.1", radix: 2), Fraction.reduced(1, 2))
        XCTAssertEqual(Fraction.fromLiteral("0.8", radix: 16), Fraction.reduced(1, 2))
        XCTAssertEqual(classify(try XCTUnwrap(Fraction.reduced(1, 2))), .terminating(decimals: 1))
        XCTAssertEqual(classify(try XCTUnwrap(Fraction.reduced(1, 4))), .terminating(decimals: 2))
        XCTAssertEqual(classify(try XCTUnwrap(Fraction.reduced(1, 5))), .terminating(decimals: 1))
        XCTAssertEqual(classify(try XCTUnwrap(Fraction.reduced(1, 20))), .terminating(decimals: 2))
        guard case .repeating(let prefix, let period) = classify(try XCTUnwrap(Fraction.reduced(1, 7)), maxPeriod: 2) else {
            XCTFail("expected a period that does not fit")
            return
        }
        XCTAssertEqual(prefix, 0)
        XCTAssertNil(period)
        guard case .repeating(_, let rejected) = classify(try XCTUnwrap(Fraction.reduced(1, 3)), base: 1) else {
            XCTFail("expected an unknown period")
            return
        }
        XCTAssertNil(rejected)
        guard case .repeating(_, let zeroDen) = classify(Fraction(num: 1, den: 0)) else {
            XCTFail("expected the zero denominator to stop")
            return
        }
        XCTAssertNil(zeroDen)
    }

    func testBaseSwitchAndDisabledKeys() {
        let octal = fresh()
        octal.setBase(.octal)
        pressAll(octal, "0.4")
        octal.press(.equals)
        octal.setBase(.decimal)
        XCTAssertEqual(octal.snapshot().display, "0.5")
        let binary = fresh()
        binary.setBase(.binary)
        pressAll(binary, "0.1")
        binary.press(.equals)
        binary.setBase(.decimal)
        XCTAssertEqual(binary.snapshot().display, "0.5")
        let hex = fresh()
        hex.setBase(.hexadecimal)
        pressAll(hex, "0.8")
        hex.press(.equals)
        hex.setBase(.decimal)
        XCTAssertEqual(hex.snapshot().display, "0.5")
        let expression = fresh()
        pressAll(expression, "10+10")
        expression.setBase(.hexadecimal)
        XCTAssertEqual(expression.snapshot().expression, "A + A")
        XCTAssertEqual(expression.snapshot().display, "A")
        expression.press(.equals)
        XCTAssertEqual(expression.snapshot().display, "14")
        let dotted = fresh()
        pressAll(dotted, "12.")
        dotted.setBase(.hexadecimal)
        XCTAssertEqual(dotted.snapshot().display, "C.")
        let negative = fresh()
        pressAll(negative, "10")
        negative.press(.negate)
        negative.setBase(.hexadecimal)
        XCTAssertEqual(negative.snapshot().display, "-A")
        let constant = fresh()
        constant.press(.pi)
        constant.setBase(.hexadecimal)
        XCTAssertEqual(constant.snapshot().expression, "π")
        XCTAssertNil(constant.snapshot().errorKind)
        let same = fresh()
        pressAll(same, "1/0")
        same.press(.equals)
        same.setBase(.decimal)
        XCTAssertEqual(same.snapshot().errorKind, .divisionByZero)
        same.setBase(.binary)
        XCTAssertNil(same.snapshot().errorKind)
        XCTAssertEqual(same.snapshot().expression, "1 ÷ 0")
        let blocked = fresh()
        blocked.setBase(.binary)
        blocked.press(.digit2)
        XCTAssertEqual(blocked.snapshot().display, "0")
        XCTAssertNil(blocked.snapshot().errorKind)
        blocked.press(.digit1)
        blocked.press(.sin)
        blocked.press(.fact)
        XCTAssertEqual(blocked.snapshot().display, "1")
        blocked.press(.clear)
        XCTAssertEqual(blocked.snapshot().display, "0")
        for base in NumericBase.allCases {
            XCTAssertFalse(base.integerOnly)
            for key in CalculatorKey.allCases {
                if let digit = key.digitValue {
                    XCTAssertEqual(base.allowsKey(key), digit < base.radix)
                }
            }
        }
        for key in [CalculatorKey.pi, .sin, .cos, .tan, .ln, .log, .exp, .fact] {
            XCTAssertTrue(NumericBase.decimal.allowsKey(key))
            XCTAssertFalse(NumericBase.binary.allowsKey(key))
            XCTAssertFalse(NumericBase.octal.allowsKey(key))
            XCTAssertFalse(NumericBase.hexadecimal.allowsKey(key))
        }
        XCTAssertTrue(NumericBase.binary.allowsKey(.dot))
        XCTAssertTrue(NumericBase.hexadecimal.allowsKey(.and))
        XCTAssertFalse(NumericText.isValidDigit("8", base: .octal))
        XCTAssertFalse(NumericText.isValidDigit("A", base: .decimal))
        XCTAssertFalse(NumericText.isValidDigit(" ", base: .hexadecimal))
        let letters = fresh()
        letters.setBase(.hexadecimal)
        pressAll(letters, "FF+1")
        letters.press(.equals)
        XCTAssertEqual(letters.snapshot().display, "100")
        let byte = fresh()
        byte.setBase(.binary)
        pressAll(byte, "11111111")
        byte.setBase(.decimal)
        XCTAssertEqual(byte.snapshot().display, "255")
    }

    func testMemoryExactnessAndRecall() throws {
        let sum = fresh()
        pressAll(sum, "1/3")
        sum.press(.equals)
        sum.press(.memoryAdd)
        sum.press(.clear)
        pressAll(sum, "1/6")
        sum.press(.equals)
        sum.press(.memorySub)
        sum.press(.clear)
        sum.press(.memoryRecall)
        sum.press(.equals)
        XCTAssertNil(sum.snapshot().errorKind)
        XCTAssertEqual(sum.snapshot().display, "0.1(6)")
        sum.setBase(.hexadecimal)
        XCTAssertEqual(sum.snapshot().display, "0.2(A)")
        let partial = fresh()
        partial.press(.digit3)
        partial.press(.memoryAdd)
        partial.press(.clear)
        pressAll(partial, "8+")
        partial.press(.memoryRecall)
        partial.press(.equals)
        XCTAssertEqual(partial.snapshot().display, "11")
        let typed = fresh()
        pressAll(typed, "8+3")
        typed.press(.memoryAdd)
        typed.press(.clear)
        typed.press(.memoryRecall)
        typed.press(.equals)
        XCTAssertEqual(typed.snapshot().display, "3")
        let empty = fresh()
        empty.press(.memoryAdd)
        XCTAssertFalse(empty.snapshot().memorySet)
        let below = fresh()
        below.press(.digit5)
        below.press(.memoryAdd)
        below.press(.clear)
        below.press(.digit8)
        below.press(.memorySub)
        below.press(.clear)
        below.press(.memoryRecall)
        below.press(.equals)
        XCTAssertEqual(below.snapshot().display, "-3")
        let kept = fresh()
        kept.press(.digit8)
        kept.press(.memoryAdd)
        kept.press(.memoryClear)
        XCTAssertEqual(kept.snapshot().display, "8")
        XCTAssertFalse(kept.snapshot().memorySet)
        kept.press(.memoryRecall)
        kept.press(.equals)
        XCTAssertEqual(kept.snapshot().display, "0")
        let irrational = fresh()
        irrational.press(.digit2)
        irrational.press(.sqrt)
        irrational.press(.equals)
        irrational.press(.memoryAdd)
        irrational.press(.clear)
        irrational.press(.digit2)
        irrational.press(.sqrt)
        irrational.press(.equals)
        irrational.press(.memoryAdd)
        irrational.press(.clear)
        irrational.press(.memoryRecall)
        irrational.press(.equals)
        let root = try Operations.executeUnary(2, .sqrt)
        XCTAssertEqual(irrational.snapshot().display, try NumericText.format(root + root, base: .decimal))
        let sample = fresh()
        sample.press(.digit4)
        sample.press(.memoryAdd)
        sample.setBase(.hexadecimal)
        sample.press(.angleMode)
        sample.press(.test)
        XCTAssertEqual(sample.snapshot().base, .decimal)
        XCTAssertEqual(sample.snapshot().angleMode, .radians)
        XCTAssertTrue(sample.snapshot().memorySet)
        XCTAssertTrue(sample.snapshot().expression.contains("888"))
        XCTAssertNil(sample.snapshot().tree)
        sample.press(.clear)
        sample.press(.memoryRecall)
        sample.press(.equals)
        XCTAssertEqual(sample.snapshot().display, "4")
    }

    func testEditingIncompleteAndErrors() {
        let edited = fresh()
        pressAll(edited, "12+")
        edited.press(.backspace)
        XCTAssertEqual(edited.snapshot().expression, "12")
        XCTAssertEqual(edited.snapshot().display, "12")
        edited.press(.backspace)
        XCTAssertEqual(edited.snapshot().display, "1")
        edited.press(.backspace)
        edited.press(.backspace)
        XCTAssertEqual(edited.snapshot().display, "0")
        XCTAssertEqual(edited.snapshot().expression, "")
        let constant = fresh()
        constant.press(.pi)
        constant.press(.backspace)
        XCTAssertEqual(constant.snapshot().expression, "")
        XCTAssertEqual(constant.snapshot().display, "0")
        let sign = fresh()
        sign.press(.negate)
        XCTAssertEqual(sign.snapshot().display, "-")
        sign.press(.backspace)
        XCTAssertEqual(sign.snapshot().display, "0")
        sign.press(.negate)
        sign.press(.negate)
        XCTAssertEqual(sign.snapshot().display, "0")
        let dotted = fresh()
        dotted.press(.negate)
        dotted.press(.dot)
        XCTAssertEqual(dotted.snapshot().display, "-0.")
        dotted.press(.digit5)
        dotted.press(.equals)
        XCTAssertEqual(dotted.snapshot().display, "-0.5")
        XCTAssertEqual(evaluated { engine in
            engine.press(.sub)
            engine.press(.sub)
            engine.press(.digit5)
        }.display, "5")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit5)
            engine.press(.sub)
            engine.press(.sub)
            engine.press(.digit3)
        }.display, "8")
        XCTAssertEqual(evaluated { engine in
            engine.press(.leftParen)
            engine.press(.rightParen)
        }.errorKind, .malformedExpression)
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "2(3+1)")
        }.errorKind, .malformedExpression)
        XCTAssertEqual(evaluated { engine in
            engine.press(.add)
        }.errorKind, .malformedExpression)
        XCTAssertEqual(show("007"), "7")
        let failed = fresh()
        pressAll(failed, "1/0")
        failed.press(.equals)
        failed.press(.equals)
        XCTAssertEqual(failed.snapshot().errorKind, .divisionByZero)
        failed.press(.digit5)
        XCTAssertEqual(failed.snapshot().expression, "1 ÷ 0 5")
        failed.press(.equals)
        XCTAssertEqual(failed.snapshot().errorKind, .malformedExpression)
        let replaced = fresh()
        pressAll(replaced, "8+")
        replaced.press(.div)
        replaced.press(.mul)
        replaced.press(.digit2)
        replaced.press(.equals)
        XCTAssertEqual(replaced.snapshot().display, "16")
    }

    func testAngleShiftAndBitwiseEdges() throws {
        let sine = fresh()
        pressAll(sine, "90")
        sine.press(.sin)
        sine.press(.equals)
        sine.press(.angleMode)
        XCTAssertEqual(sine.snapshot().angleMode, .radians)
        XCTAssertEqual(sine.snapshot().display, "1")
        sine.press(.equals)
        XCTAssertEqual(sine.snapshot().display, "1")
        sine.press(.angleMode)
        XCTAssertEqual(sine.snapshot().angleMode, .degrees)
        let cosine = fresh()
        cosine.press(.angleMode)
        cosine.press(.pi)
        cosine.press(.cos)
        cosine.press(.equals)
        XCTAssertEqual(try XCTUnwrap(cosine.snapshot().tree).evaluate(angleMode: .radians), -1, accuracy: 1e-9)
        XCTAssertEqual(cosine.snapshot().display, "-1")
        let tangent = fresh()
        tangent.press(.angleMode)
        tangent.press(.pi)
        tangent.press(.div)
        tangent.press(.digit4)
        tangent.press(.tan)
        tangent.press(.equals)
        XCTAssertEqual(try XCTUnwrap(tangent.snapshot().tree).evaluate(angleMode: .radians), 1, accuracy: 1e-9)
        XCTAssertEqual(tangent.snapshot().display, "1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.lsh)
            engine.press(.digit0)
        }.display, "1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.lsh)
            pressAll(engine, "31")
        }.display, "-2147483648")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.lsh)
            pressAll(engine, "32")
        }.errorKind, .domain)
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.lsh)
            engine.press(.negate)
            engine.press(.digit1)
        }.errorKind, .domain)
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit2)
            engine.press(.negate)
            engine.press(.lsh)
            engine.press(.digit1)
        }.display, "-4")
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "5.5")
            engine.press(.mod)
            engine.press(.digit2)
        }.display, "1.5")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit7)
            engine.press(.negate)
            engine.press(.mod)
            engine.press(.digit3)
        }.display, "-1")
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit0)
            engine.press(.mod)
            engine.press(.digit0)
        }.errorKind, .divisionByZero)
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "1.5")
            engine.press(.not)
        }.errorKind, .bitwiseNonInteger)
        XCTAssertEqual(evaluated { engine in
            pressAll(engine, "1.2")
            engine.press(.and)
            engine.press(.digit1)
        }.errorKind, .bitwiseNonInteger)
        XCTAssertEqual(evaluated { engine in
            engine.press(.digit1)
            engine.press(.negate)
            engine.press(.not)
        }.display, "0")
        XCTAssertEqual(try Operations.executeBinary(0, 0, .pow), 1)
        XCTAssertEqual(try Operations.executeBinary(-2, 3, .pow), -8)
        assertKind(.domain) { _ = try Operations.executeBinary(-2, 0.5, .pow) }
        XCTAssertEqual(try Operations.executeBinary(-7, 3, .mod), -1)
        assertKind(.divisionByZero) { _ = try Operations.executeBinary(0, 0, .mod) }
        XCTAssertEqual(try Operations.executeUnary(-1, .not), 0)
        XCTAssertEqual(try Operations.executeBinary(1, 31, .lsh), -2147483648)
    }

    func testEvaluatorDisplayAndOperatorContract() throws {
        assertKind(.domain) { _ = try NumericText.format(Double.nan, base: .decimal) }
        assertKind(.domain) { _ = try NumericText.format(Double.infinity, base: .hexadecimal) }
        XCTAssertEqual(try NumericText.parse(" 12 ", base: .decimal), 12)
        XCTAssertEqual(try NumericText.parse("pi", base: .hexadecimal), Double.pi)
        XCTAssertEqual(try NumericText.parse("0.(3)", base: .decimal), 1.0 / 3.0, accuracy: 1e-12)
        XCTAssertEqual(try NumericText.parse("-0.(3)", base: .decimal), -1.0 / 3.0, accuracy: 1e-12)
        XCTAssertFalse(try NumericText.format(1e20, base: .decimal).isEmpty)
        XCTAssertTrue(NumericText.isWhole(4 + 5e-10))
        XCTAssertFalse(NumericText.isWhole(4 + 2e-9))
        let root = try ExpressionTreeBuilder.build([.numberLiteral("-1"), .operatorToken(.sqrt)], base: .decimal)
        XCTAssertEqual(root.displayLabel(base: .decimal), "√")
        XCTAssertEqual(root.childCount, 1)
        XCTAssertEqual(root.childAt(0)?.raw, "-1")
        XCTAssertNil(root.childAt(1))
        XCTAssertNil(root.childAt(-1))
        XCTAssertNil(root.exactFraction(base: .decimal))
        assertKind(.malformedExpression) {
            _ = try ExpressionTreeBuilder.build([.rightParen], base: .decimal)
        }
        let sine = try ExpressionTreeBuilder.build([.numberLiteral("0"), .operatorToken(.sin)], base: .decimal)
        XCTAssertNil(sine.exactFraction(base: .decimal))
        XCTAssertEqual(sine.displayLabel(base: .decimal), "sin = 0")
        let wide = try ExpressionTreeBuilder.build(
            [Token.numberLiteral("2"), Token.numberLiteral("17"), Token.operatorToken(OperatorKind.pow)],
            base: .decimal
        )
        XCTAssertNil(wide.exactFraction(base: .decimal))
        XCTAssertEqual(try wide.evaluate(), 131072)
        let divided = try ExpressionTreeBuilder.build(
            [.numberLiteral("1"), .numberLiteral("0"), .operatorToken(.div)],
            base: .decimal
        )
        XCTAssertNil(divided.exactFraction(base: .decimal))
        assertKind(.divisionByZero) { _ = try divided.evaluate() }
        let contracts: [(OperatorKind, String, String, Int, Bool, Bool)] = [
            (.add, "+", "+", 11, false, false),
            (.sub, "-", "-", 11, false, false),
            (.mul, "×", "×", 12, false, false),
            (.div, "÷", "÷", 12, false, false),
            (.mod, "mod", "mod", 12, false, false),
            (.pow, "^", "^", 99, false, true),
            (.and, "and", "and", 7, false, false),
            (.or, "or", "or", 5, false, false),
            (.xor, "xor", "xor", 6, false, false),
            (.lsh, "lsh", "lsh", 12, false, false),
            (.not, "not", "not", 14, true, false),
            (.neg, "−", "neg", 99, true, true),
            (.sqrt, "√", "√", 99, true, false),
            (.rec, "1/", "1/", 99, true, false),
            (.sin, "sin", "sin", 12, true, false),
            (.cos, "cos", "cos", 12, true, false),
            (.tan, "tan", "tan", 12, true, false),
            (.ln, "ln", "ln", 12, true, false),
            (.log, "log", "log", 12, true, false),
            (.exp, "exp", "exp", 12, true, false),
            (.sq, "²", "²", 99, true, false),
            (.cube, "³", "³", 99, true, false),
            (.fact, "!", "!", 99, true, false)
        ]
        XCTAssertEqual(contracts.count, 23)
        for (kind, symbol, label, precedence, unary, right) in contracts {
            XCTAssertTrue(operatorIsKnown(kind))
            XCTAssertEqual(kind.displaySymbol, symbol)
            XCTAssertEqual(kind.treeLabel, label)
            XCTAssertEqual(kind.precedence, precedence)
            switch kind.arity {
            case .unary:
                XCTAssertTrue(unary)
            case .binary:
                XCTAssertFalse(unary)
            }
            switch kind.associativity {
            case .right:
                XCTAssertTrue(right)
            case .left:
                XCTAssertFalse(right)
            }
        }
    }

    func testPlaybackBoundaries() {
        var idle = PostfixPlayback()
        idle.toggle(count: 0, reduceMotion: false)
        XCTAssertNil(idle.index)
        XCTAssertFalse(idle.running)
        idle.tick(count: 4)
        XCTAssertFalse(idle.running)
        var motion = PostfixPlayback()
        motion.toggle(count: 2, reduceMotion: true)
        XCTAssertEqual(motion.index, 0)
        motion.toggle(count: 2, reduceMotion: true)
        XCTAssertEqual(motion.index, 1)
        motion.toggle(count: 2, reduceMotion: true)
        XCTAssertEqual(motion.index, 0)
        XCTAssertFalse(motion.running)
        var running = PostfixPlayback()
        running.toggle(count: 4, reduceMotion: false)
        running.toggle(count: 4, reduceMotion: false)
        XCTAssertFalse(running.running)
        XCTAssertEqual(running.index, 0)
        running.select(2)
        XCTAssertEqual(running.index, 2)
        running.select(2)
        XCTAssertNil(running.index)
        running.select(1)
        running.tick(count: 0)
        XCTAssertEqual(running.index, 1)
        XCTAssertFalse(running.running)
    }

    func testPresentationRules() {
        XCTAssertEqual(resultFontSize(length: 9, width: 500), 48)
        XCTAssertEqual(resultFontSize(length: 10, width: 500), 36)
        XCTAssertEqual(resultFontSize(length: 12, width: 500), 36)
        XCTAssertEqual(resultFontSize(length: 13, width: 500), 26)
        XCTAssertEqual(resultFontSize(length: 5, width: 339), 30)
        XCTAssertEqual(resultFontSize(length: 5, width: 340), 40)
        XCTAssertEqual(resultFontSize(length: 5, width: 459), 40)
        XCTAssertEqual(resultFontSize(length: 5, width: 460), 48)
        XCTAssertEqual(resultFontSize(length: 13, width: 300), 26)
        XCTAssertEqual(resultFontSize(length: 10, width: 300), 30)
        for visual in [KeyVisual.number, .function, .logic, .action] {
            XCTAssertTrue(KeyPaint.paint(visual).lightLabel)
        }
        XCTAssertFalse(KeyPaint.paint(.operatorKey).lightLabel)
        XCTAssertFalse(KeyPaint.paint(.equals).lightLabel)
        XCTAssertEqual(KeyPaint.paint(.operatorKey).hue, KeyPaint.paint(.equals).hue)
        XCTAssertEqual(keyGradientEndDepth(dark: false), 0.25)
        XCTAssertEqual(keyGradientEndDepth(dark: true), 0.78)
        XCTAssertFalse(shouldSwitchTree(width: 48, height: 0))
        XCTAssertTrue(shouldSwitchTree(width: 49, height: 0))
        XCTAssertTrue(shouldSwitchTree(width: -70, height: 10))
        XCTAssertFalse(shouldSwitchTree(width: 49, height: 40))
        XCTAssertTrue(shouldSwitchTree(width: 70, height: 40))
        XCTAssertFalse(shouldSwitchTree(width: 70, height: 50))
        XCTAssertFalse(shouldSwitchTree(width: 10, height: 80))
        XCTAssertTrue(postfixTokenIsNumber("12"))
        XCTAssertTrue(postfixTokenIsNumber("0.(3)"))
        XCTAssertTrue(postfixTokenIsNumber("A"))
        for symbol in ["+", "-", "−", "×", "÷", "^", "mod", "and", "or", "xor", "lsh", "not", "√", "1/", "sin", "cos", "tan", "ln", "log", "exp", "²", "³", "!"] {
            XCTAssertFalse(postfixTokenIsNumber(symbol))
        }
        XCTAssertFalse(treeRowInHighlightedSubtree(path: "root", highlighted: nil))
        XCTAssertTrue(treeRowInHighlightedSubtree(path: "root", highlighted: "root"))
        XCTAssertTrue(treeRowInHighlightedSubtree(path: "root/1", highlighted: "root"))
        XCTAssertFalse(treeRowInHighlightedSubtree(path: "root", highlighted: "root/1"))
        XCTAssertFalse(treeRowInHighlightedSubtree(path: "root/1", highlighted: "root/1/0"))
        XCTAssertTrue(treeRowInHighlightedSubtree(path: "root/1/0", highlighted: "root/1"))
        XCTAssertEqual(baseLabel(.binary), "Bin")
        XCTAssertEqual(baseLabel(.decimal), "Dec")
        XCTAssertEqual(baseLabel(.hexadecimal), "Hex")
        XCTAssertTrue(baseLabel(.octal) == "Oct" || baseLabel(.octal) == "Okt")
        XCTAssertEqual(angleLabel(.radians), "Rad")
        XCTAssertTrue(angleLabel(.degrees) == "Deg" || angleLabel(.degrees) == "Fok")
        XCTAssertEqual(AppLinks.privacyPolicy.absoluteString, "https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html")
        XCTAssertEqual(AppLinks.originalDesktop.absoluteString, "https://github.com/lkovari/Calculator")
        XCTAssertEqual(AppLinks.originalIOS.absoluteString, "https://lkovari.github.io/KLHome/#/ios-page/ios-page-content2")
        XCTAssertEqual(AppLinks.supportMail.absoluteString, "mailto:laszlo.kovary@gmail.com")
    }

    @MainActor
    func testModelThemeAndMessages() {
        let model = CalculatorModel()
        model.press(.digit2)
        model.press(.add)
        model.press(.digit2)
        model.press(.equals)
        XCTAssertEqual(model.state.display, "4")
        model.press(.digit1)
        model.press(.digit0)
        model.setBase(.hexadecimal)
        XCTAssertEqual(model.state.display, "A")
        XCTAssertEqual(model.state.base, .hexadecimal)
        let previous = UserDefaults.standard.string(forKey: "themeMode")
        defer {
            if let previous {
                UserDefaults.standard.set(previous, forKey: "themeMode")
            } else {
                UserDefaults.standard.removeObject(forKey: "themeMode")
            }
        }
        UserDefaults.standard.set(ThemeChoice.dark.rawValue, forKey: "themeMode")
        let stored = ThemeStore()
        XCTAssertEqual(stored.mode, .dark)
        XCTAssertEqual(stored.preferredScheme, .dark)
        stored.mode = .light
        XCTAssertEqual(stored.preferredScheme, .light)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "themeMode"), "light")
        stored.mode = .auto
        XCTAssertNil(stored.preferredScheme)
        UserDefaults.standard.set("nope", forKey: "themeMode")
        XCTAssertEqual(ThemeStore().mode, .auto)
        XCTAssertNil(errorText(nil))
        expect(.emptyExpression, "Enter an expression first.", "Először adj meg egy kifejezést.")
        expect(.unbalancedParentheses, "Unbalanced parentheses.", "A zárójelek nincsenek párban.")
        expect(.divisionByZero, "Division by zero.", "Nullával osztás.")
        expect(.domain, "The value is outside the domain of this operation.", "Az érték kívül esik a művelet értelmezési tartományán.")
        expect(.bitwiseNonInteger, "Bitwise operations require whole numbers.", "A bitenkénti műveletekhez egész szám kell.")
        expect(.invalidDigit, "That digit is not valid in this numerical system.", "Ez a számjegy ebben a számrendszerben érvénytelen.")
        expect(.malformedExpression, "The expression is not complete.", "A kifejezés nem teljes.")
        expect(.invalidFactorial, "Factorial needs a non-negative whole number.", "A faktoriálishoz nemnegatív egész szám kell.")
        expect(.undefined, "Undefined.", "Nem definiált.")
    }

    private func operatorIsKnown(_ kind: OperatorKind) -> Bool {
        switch kind {
        case .add, .sub, .mul, .div, .mod, .pow, .and, .or, .xor, .lsh, .not, .neg, .sqrt, .rec, .sin, .cos, .tan, .ln, .log, .exp, .sq, .cube, .fact:
            return true
        }
    }

    private func expect(_ kind: ErrorKind, _ en: String, _ hu: String, file: StaticString = #filePath, line: UInt = #line) {
        let actual = errorText(kind)
        XCTAssertTrue(actual == en || actual == hu, file: file, line: line)
        XCTAssertFalse(actual?.isEmpty ?? true, file: file, line: line)
    }

    private func show(_ expression: String) -> String {
        let engine = CalculatorEngine()
        pressAll(engine, expression)
        engine.press(.equals)
        return engine.snapshot().display
    }

    private func treeOf(_ expression: String) -> ExpressionNode? {
        let engine = CalculatorEngine()
        pressAll(engine, expression)
        engine.press(.equals)
        return engine.snapshot().tree
    }

    private func evaluated(_ body: (CalculatorEngine) -> Void) -> EvaluationResult {
        let engine = CalculatorEngine()
        body(engine)
        engine.press(.equals)
        return engine.snapshot()
    }

    private func fresh() -> CalculatorEngine {
        CalculatorEngine()
    }

    private func assertNear(_ digits: String, _ key: CalculatorKey, _ value: Double, _ display: String) throws {
        let result = evaluated { engine in
            pressAll(engine, digits)
            engine.press(key)
        }
        XCTAssertEqual(try XCTUnwrap(result.tree).evaluate(), value, accuracy: 1e-9)
        XCTAssertEqual(result.display, display)
    }
}
