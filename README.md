# TreeCalc

TreeCalc is a calculator that shows the expression tree behind the result. Version 1.0.0. Author: László Kővári.

The keys, operator precedence, errors, integer bases, memory, angle mode, and the `Tst` sample follow the original calculator. This app adds a glossy keypad, repeating-decimal display, and postfix playback. TreeCalc is an iPhone app; iPad is not a target.

## Build

Open `TreeCalc.xcodeproj` in Xcode 16 or later and run the `TreeCalc` scheme. The deployment target is iOS 17. There are no third-party packages.

```
xcodebuild -project TreeCalc.xcodeproj -scheme TreeCalc -destination 'platform=iOS Simulator,name=iPhone 17' test
```

That command builds the app and runs every test. To run only the tests, see [Tests](#tests).

Bundle id: `com.lkovari.mobile.apps.treecalc`. Marketing version `1.0.0`, build `1`.

## Tests

From `TreeCalc-ios`, this runs the unit tests and the UI tests and does not launch a separate scheme:

```
xcodebuild -project TreeCalc.xcodeproj -scheme TreeCalc -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TreeCalcTests -only-testing:TreeCalcUITests test
```

Unit tests only:

```
xcodebuild -project TreeCalc.xcodeproj -scheme TreeCalc -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TreeCalcTests test
```

UI tests only:

```
xcodebuild -project TreeCalc.xcodeproj -scheme TreeCalc -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:TreeCalcUITests test
```

The destination is the iPhone 17 simulator. There are 41 test methods: 37 in `TreeCalcTests` and 4 in `TreeCalcUITests`.

### EngineTests

The original calculator paths.

- `testMixedPrecedence` — `9+7×6` is 51, the root is addition, and the postfix order is `9, 7, 6, ×, +`.
- `testParenthesesPowerAndBases` — parentheses change the grouping, `2^3^2` is 512, and the same addition is `F`, `1011`, and `10` in hexadecimal, binary, and octal.
- `testLogicUnaryAndErrors` — xor, sign, pressing `=` again, replacing the result with a digit, division by zero, both parenthesis failures, and a later failure drops the previous tree.
- `testFunctionsMemoryAndDigits` — square root, reciprocal, square, memory add, recall, and clear, a left shift, and which digit keys each base enables.
- `testSampleAndNested` — `Tst` types the sample in decimal without evaluating, a base change does not rewrite that text, `=` builds the tree, and the nested `777` expression keeps its postfix and value.
- `testEditingMemoryAngleAndDomain` — empty `=`, memory surviving clear, backspace, a second dot, a leading dot, a leading operator, operator replacement, π, sign after `=`, a unary on the result, a missing operand, memory subtract, rewriting a finished result, keys rejected outside decimal, sine, cosine, log, bitwise not/and/or, and the domain, factorial, and bitwise errors.
- `testMathFixes` — a minus after an operator is unary, negate applies to a parenthesized group, unary minus binds looser than power, sine of 90° and of π/2, `0.1+0.2` is `0.3`, and `0/0` is undefined while `5/0` is division by zero.
- `testRepeatingDecimals` — `1/3`, `1/6`, `1/7`, `1/8`, and `1/12`, the classifier, one half in hexadecimal and binary, one tenth in hexadecimal, parsing those literals, rewriting a number that is still being typed, and continuing `1/3 + 1` from the exact fraction.
- `testInfixPostfixAndTree` — converter precedence, right-associative power, empty input, rejected parentheses, tree shape, labels, evaluation, post-order paths for distinct and repeated operands, and builder failures.
- `testOperationsAndFormatting` — each arithmetic, bitwise, and scientific operation, their domain failures, parsing, 12-digit rounding, integer and fraction formatting in every base, and the digit check.
- `testPlaybackSteps` — Play advances once per tick, Pause holds the current step and the next Play continues from it, a finished walk starts again at the first token, selecting a token stops the walk and selecting it again clears it, step-by-step mode moves one step without starting the timer and stays on the last step, and Stop clears the selection.

### EdgeCaseTests

Boundaries that the main paths do not pin down.

- `testExactFractionResults` — cancelling `1/3×3`, adding sixths, `0.1×10`, nested division, a 13-digit integer sum, reciprocal, square, and cube of a fraction, a chained root, and `3²!`.
- `testAssociativityAndPrecedence` — subtraction and division associate left, power associates right, modulo shares the multiplication level, factorial and shift bind tighter than addition, and postfix `not` binds tighter than `and`. `(1+2) lsh 3` is 24; without parentheses `1+2 lsh 3` is 17.
- `testPowerRootAndScientificBoundaries` — `0^0` and `5^0` are 1, a half power leaves the exact fraction, exponents 16 and −12 stay exact, 17 and −13 do not, `0^−1` and a negative square root are domain errors, and tangent of 90° stays a finite value because π/2 is not exact. Also sine, cosine, tangent, ln, log, exp, factorial of 0, 1, and 10, a negative factorial, negative cube, square, and reciprocal, plus factorial 170 and 171 and an overflowing exp.
- `testRepeatingLengthsAndOtherBases` — short periods `1/11`, `2/7`, `5/6`, and `−1/3`, the 16-digit period of `1/17` falling back to 12 digits, terminating expansions, and `1/3` shown as `0.(01)`, `0.(25)`, and `0.(5)` in bases 2, 8, and 16.
- `testFractionAndClassifierEdges` — a zero or `Int64.min` denominator, sign normalization, overflow, divide by zero, the `^0` and too-large exponent rules, rejected literals, `10.`, `.(3)`, a preperiod such as `0.1(6)` and `0.08(3)`, place values `0.4` octal, `0.1` binary, and `0.8` hexadecimal, terminating lengths, a period capped by `maxPeriod`, and a denominator of zero leaving the classifier.
- `testBaseSwitchAndDisabledKeys` — octal, binary, and hexadecimal fractions return to decimal 0.5, every number already in the expression is rewritten, a trailing dot and a minus sign survive, π stays π, the same base keeps an error and another base clears it, a disabled digit or scientific key does nothing, the full digit and scientific key matrix, `FF+1` is `100`, and binary `11111111` is decimal 255.
- `testMemoryExactnessAndRecall` — `1/3` minus `1/6` stays the exact `0.1(6)` and becomes hexadecimal `0.2(A)`, recall continues an open expression, `M+` stores the number being typed, `M+` on an empty calculator does not set memory, memory can go negative, `MC` keeps the display, an irrational sum leaves the fraction path, and `Tst` returns to decimal without clearing memory or the angle mode.
- `testEditingIncompleteAndErrors` — backspace walks back through an operator into the previous number and through π, a lone sign deletes, a dot after a sign is `−0.`, `--5` is 5, `5--3` is 8, `()`, `2(3+1)`, and a trailing operator are malformed, leading zeros collapse, a second `=` repeats a division-by-zero error, and a digit typed after that error is appended to the old expression.
- `testAngleShiftAndBitwiseEdges` — changing Deg/Rad does not recompute the result already on screen, cosine of π and tangent of π/4, shifts of 0, 31, 32, and −1, a negative value shifted left, fractional and negative modulo, `0 mod 0`, bitwise rejection of `1.5` and `1.2`, and `not` of −1.
- `testEvaluatorDisplayAndOperatorContract` — NaN and infinity formatting, trimmed and repeating literals, the 1e−9 whole-number tolerance, a failing root label with no value, a parenthesis left in postfix, sine and `2^17` leaving no exact fraction, division by zero on the tree, and the symbol, precedence, arity, and associativity of every operator.
- `testPlaybackBoundaries` — Play with no tokens does nothing, a tick while stopped does nothing, step-by-step Play stops on the last step instead of wrapping, the tick on the last token ends a running walk, Pause keeps the current index, and selecting the selected token clears it.
- `testPresentationRules` — result text size at 9, 10, 12, and 13 digits and at the 340 and 460 point widths, which keys use a dark label, the 25% and 78% gradient floors, the 48 point and 1.4 swipe rule, postfix numbers versus operator symbols, which tree row belongs to the highlighted branch, the base and angle captions, and the four About links.
- `testModelThemeAndMessages` — `CalculatorModel` follows the engine for `2+2` and a base change, the theme is read back from `themeMode` and an unknown value falls back to Auto, and every error has its English and Hungarian sentence.
- `testReviewCrashesAndOverflow` — `2^63` is shown as `9.22337203685e18` instead of crashing, `2^62` is still exact in hexadecimal, `10^10` in hexadecimal and switching `2^70` or a 20-digit decimal to another base report the overflow message and keep the base, and `9^99!` and `171!` are domain errors.
- `testReviewScientificDisplayAndLongLiterals` — `170!` is `7.25741561531e306`, values from 1e15 up and below 1e−9 use scientific notation, `10^16` stays exact, scientific, 20-digit, and 17-digit hexadecimal literals parse, `10^20` continues with `+1`, `exp(−30)` is not 0, and sine and tangent of 180° are exactly 0.
- `testReviewNegateAfterEqualsKeepsTree` — `+/−` after `9+7=` wraps the tree, the postfix, and the expression in a negation, a second `+/−` undoes it, the result continues, and the exact fraction survives a base change.
- `testReviewLocalizationIsDeclared` — the bundle declares `en` and `hu`, and the overflow error has its English and Hungarian sentence.

### EvaluationTraceTests

The stack trace behind the Operations list.

- `testMixedPrecedencePushesThenCombinesRightFirst` — `9+7×6` pushes 9, 7, and 6, multiplies to `× = 42`, then adds to `+ = 51`, with the stack after every step, the English sentence `9 + (× = 42), result + = 51`, and the Hungarian `betesz 9`.
- `testUnaryPopsOneOperand` — `9 √` pops one operand and leaves `√ = 3` alone on the stack.
- `testRightAssociativePowerKeepsTheBaseUnderTheInnerPower` — `2^3^2` keeps 2 on the stack while `3^2` becomes `^ = 9`, then finishes at `^ = 512`.

### ExpressionSpansTests

Which part of the expression line is highlighted for each postfix step.

- `testMultiplicationSpanSitsInsideTheSum` — `9 + 7 × 6` highlights `9`, `7`, `6`, `7 × 6`, then the whole sum.
- `testParenthesesWrapTheGroupedStep` — the addition step in `( 1 + 2 ) × 3` includes its parentheses.
- `testPrefixMinusCoversThePowerItNegates` — the negation step in `− 5 ^ 2` covers the whole power.
- `testPostfixSineCoversTheDivision` — the sine step in `π ÷ 2 sin` covers the division before it.
- `testEnginePublishesSpansOnlyAfterEquals` — the engine publishes spans after `=` and drops them once a new digit is typed, while the previous tree and postfix stay.
- `testUnbalancedParenthesesProduceNoSpans` — an unclosed parenthesis produces no spans.

### TreeCalcUITests

- `testAdditionHelpAndAbout` — `2+2` shows 4, the Expression tree playback Help topic opens and mentions Step by step, and About shows the original iOS link and the author.
- `testBaseErrorAndExpressionTree` — `M+` shows the memory mark, decimal 10 becomes `A` in base 16, a horizontal drag opens the expression tree for `9+7×6`, Back returns to the keypad, and `1÷0` shows the division-by-zero message.
- `testHungarianLanguageAndTreeButton` — launched in Hungarian, the keys read `És` and `Fok`, the tree button is labelled `Kifejezésfa`, opens the tree after `2+3=`, and Back returns.
- `testStepByStepPlayback` — after `9+7×6=` the tree opens with Play, turning on Step by step makes Play read Next and shows Stop, the first postfix chip and the first operation row are selected, Next selects the second chip, tapping a chip selects it, tapping it again clears it, and the button returns to Play without Stop.

## Architecture

```
keypad → CalculatorModel → CalculatorEngine
                              ├─ ExpressionTree → display and tree screen
                              └─ Fraction classifier → decimal display
tree screen → postfix playback ─┬─ expression line (ExpressionSpans)
                                 ├─ postfix chips
                                 ├─ Operations list (EvaluationTrace)
                                 └─ expression tree
```

- `TreeCalc/Engine` is pure Swift. Evaluation uses `Double`, integer bases, and 12-digit half-up decimal text. From 1e15 up and below 1e−9 the decimal display switches to 12 significant digits in scientific notation, such as `1e20`.
- A parallel fraction is kept only when the tree is rational: numbers, `+ − × ÷`, an integer power, sign, and parentheses. `classify` then chooses the display.
- `TreeCalc/UI` is SwiftUI. `CalculatorModel` is `@Observable` and `@MainActor`.
- `InfixToPostfix.sourceIndices` runs the same shunting-yard pass as the converter but returns the index of each infix token in postfix order. `expressionStepSpans` turns those indices into one character range of the expression text per postfix step, widened to the operands and to parentheses that enclose the step exactly. The engine publishes them as `EvaluationResult.expressionSpans` only after `=`, and only when there is one span per postfix token; otherwise the list is empty and the expression line has no highlight.
- `ExpressionNode.evaluationSteps` replays the tree in post-order as a stack: each step is a push or an applied operator, with the operand labels, the result label, and the stack after the step. `traceSentence` writes that step in English or Hungarian for the Operations list.
- The playback state (`TreeWalk`: playback position, the Step by step switch, and the collapsed nodes) lives in `TreeCalcRoot`, so it survives switching between the calculator and the tree. A new postfix resets the position and the collapsed nodes.
- English and Hungarian follow the device language. The bundle declares both in `CFBundleLocalizations` and in `en.lproj` and `hu.lproj`, otherwise iOS runs the app in English on a Hungarian device. `L10n` reads `Bundle.main.preferredLocalizations`. There is no in-app language picker. The decimal separator is always `.`.
- Theme Auto, Light, and Dark is stored in `UserDefaults`. Auto follows the system.

## Behavior

- Addition, subtraction, multiplication, division, and integer powers keep an exact fraction. `1 ÷ 3 + 1` stays `1.(3)`. Roots, trigonometry, logarithms, and factorial stay on `Double`.
- Repeating rationals that fit the display are written with the period in parentheses: `0.(3)`, `0.1(6)`, `0.08(3)`, `0.(142857)`. The non-repeating part plus the period must be at most 12 digits. A longer period or an irrational operation keeps the 12-digit string. The same parentheses are used in base 2, 8, and 16.
- Every base has a radix point. One hexadecimal place is a sixteenth, so decimal `0.5` is hexadecimal `0.8`. Pressing 2, 8, 10, or 16 rewrites the number being typed, the current result, and the numbers already in the expression. `=` is not required first.
- After `=`, the next operator continues from that exact fraction when one exists. Memory of those results stays exact too. Bitwise operations still use the `Double` value.
- A literal that does not fit an `Int64` fraction, such as a 20-digit number or a scientific result, is read as a `Double`, so a large result can be continued.
- Bases 2, 8, and 16 hold whole parts below 2^63. A larger result, or a base switch that would need one, shows “The number is too large for this numerical system.” and keeps the current base.
- `+/−` after `=` negates the result, the tree, the postfix, and the expression together.
- A sine, cosine, or tangent within 1e−12 of zero is 0, so `sin 180°` is 0.
- The result shrinks and wraps to fit the display. Touch and hold it to copy.
- iPhone is portrait only. The tree button at the top left of the calculator opens the expression tree, and `<` returns. A horizontal drag longer than 48 pt and longer than 1.4 times the vertical movement also switches between the calculator and the tree.
- Keys are glossy, following `buttonAddGradientEffect` in Calculator-ios. Corners are 8 pt. The border is 1.5 pt in hue 0.611, saturation 0.327, brightness 0.394. In light mode the fill runs from the key color at the top to 25% of that brightness at the bottom: the 2012 call `colorStartColorForGradientColor:percent:75 flavour:NO` subtracts 75% of the brightness. There is no extra inner stroke. The shadow is gray, offset 3 pt down and to the right, with a 3 pt blur, the same as the 2012 layer. Dark mode keeps a shallower shine, down to 78% brightness, because those fills already read as raised. Pressing darkens the key. Operator and equals labels are dark on the light gray keys so they stay readable.
- Parentheses share the green function color. Bitwise keys and the base switcher are a separate blue group, because the 2012 app did not have them. The selected base has a stronger border.
- The tree screen shows one evaluated expression in four places, top to bottom: the expression line, the postfix chips, the Operations list, and the expression tree. The current step is highlighted in all four. On the expression line that is a number, or an operation with its operands and its own parentheses. The line wraps, so the part that scrolls off the calculator display is visible. The Operations list has one short sentence per step, such as `9 + (× = 42), result + = 51`; tapping a row selects that step. The tree draws guide lines between parent and child nodes, and selecting a step expands its ancestors.
- Playback walks the existing tokens and does not evaluate again. With Step by step off, Play starts at the first token, or continues from the selected one, and moves every 700 ms; the button reads Pause while it runs, Pause holds the current step, and after the last token the walk stops, so the next Play starts over. With Step by step on, Play shows the first step and becomes Next; each Next moves one step, and on the last step Next is disabled instead of wrapping. Stop appears in step mode while a step is selected and clears the highlight. Turning Step by step on pauses a running walk. With Reduce Motion the switch is held on.
- Tapping a postfix chip or an operation row jumps to that step and stops a running walk. Tapping the selected chip again clears it.
- Help has a new Infix to Postfix topic. It explains how the keypad builds tokens, how the operator stack decides what is written out, the precedence levels and associativity, worked examples such as `2 ^ 3 ^ 2` and `−5 ^ 2`, and how the tree is built from the postfix list. The Switching screens, Numerical systems, Converting numerical systems, Equals and the tree, and Repeating decimals topics are shorter. The Postfix playback topic is now Expression tree playback and describes the four views and both playback modes. The Help copyright line uses the Hungarian name order in Hungarian.
- There is no paper-tape history and no live tree while typing.

## Old iOS drawing bugs that are not carried over

The 2012 Objective-C calculator is only a visual reference.

- `buttonAddGradientEffect` inserted the gradient twice. Each key gets one shine.
- The pressed title was forced to blue. The pressed state only darkens the fill.
- `ColorUtils` divided brightness by 255 twice, which washed the colors out. Hue, saturation, and brightness are applied once.

## App Store notes

The app asks for no permissions. `ITSAppUsesNonExemptEncryption` is false. `PrivacyInfo.xcprivacy` reports no tracking. `UserDefaults` is declared with reason `CA92.1` because the theme is stored there. There is no account, advertising, camera, location, or background mode. The iOS privacy policy is `https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html` (source: `docs/treecalc-ios-privacy-policy.html`). About also links the original desktop repository and the original iOS calculator page.

Screenshots should be taken from this build on iPhone. The PNGs in `docs/images/screenshots` are RGB without alpha. The launch screen picture is not uploaded, because App Review guideline 2.3.3 asks for the app in use. The expression tree, the number bases, and postfix playback are the parts that are specific to TreeCalc.

## License

MIT. Copyright (c) 2005 - 2026 László Kővári.
