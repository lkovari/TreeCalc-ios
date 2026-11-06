import SwiftUI

struct KeySpec: Identifiable {
    var key: CalculatorKey
    var title: String
    var visual: KeyVisual
    var id: String { "\(key)" }
}

struct CalculatorScreen: View {
    var model: CalculatorModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                display(width: proxy.size.width - 16)
                Keypad(
                    base: model.state.base,
                    angleMode: model.state.angleMode,
                    onKey: { model.press($0) },
                    onBase: { model.setBase($0) }
                )
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
    }

    private func display(width: CGFloat) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Text(baseLabel(model.state.base))
                Text(angleLabel(model.state.angleMode))
                Spacer()
                if model.state.memorySet {
                    Text("M")
                        .foregroundStyle(CalcColor.memory)
                        .accessibilityIdentifier("display.memory")
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(screenInk(scheme))
            Text(model.state.display)
                .font(.system(size: resultFontSize(length: model.state.display.count, width: width), weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(CalcColor.displayInk)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .trailing)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(CalcColor.displayFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(CalcColor.border, lineWidth: 1)
                }
                .accessibilityIdentifier("display.result")
            expressionWell
            if let error = errorText(model.state.errorKind) {
                Text(error)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(CalcColor.error)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("display.error")
            }
        }
    }

    private var expressionWell: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(model.state.expression.isEmpty ? " " : model.state.expression)
                        .font(.body)
                        .foregroundStyle(CalcColor.expressionInk)
                        .lineLimit(1)
                        .frame(minWidth: geo.size.width - 20, minHeight: 36, alignment: .trailing)
                        .padding(.horizontal, 10)
                        .id("expression-end")
                }
                .onChange(of: model.state.expression) { _, _ in
                    proxy.scrollTo("expression-end", anchor: .trailing)
                }
            }
        }
        .frame(height: 36)
        .background(CalcColor.expressionFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(CalcColor.border, lineWidth: 1)
        }
        .accessibilityIdentifier("display.expression")
    }
}

struct Keypad: View {
    var base: NumericBase
    var angleMode: AngleMode
    var onKey: (CalculatorKey) -> Void
    var onBase: (NumericBase) -> Void

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = proxy.size.height < 560 ? 3 : 5
            let keyWidth = max(1, floor((proxy.size.width - spacing * 4) / 5))
            let rowWidth = keyWidth * 5 + spacing * 4
            let baseWidth = (rowWidth - spacing * 3) / 4
            let available = max(0, proxy.size.height - spacing * 11)
            let compactBand = floor(min(min(44, keyWidth * 0.78), available * 0.42 / 7))
            let numberBand = floor(min(min(92, keyWidth), available * 0.58 / 5))
            let compactFont = min(15, max(10, compactBand * 0.4))
            let numberFont = min(22, max(13, numberBand * 0.38))
            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    baseKey(.binary, "2", baseWidth, compactBand)
                    baseKey(.octal, "8", baseWidth, compactBand)
                    baseKey(.decimal, "10", baseWidth, compactBand)
                    baseKey(.hexadecimal, "16", baseWidth, compactBand)
                }
                .frame(width: rowWidth, height: compactBand)
                ForEach(compactRows, id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(0..<row.count, id: \.self) { index in
                            if let spec = row[index] {
                                keyButton(spec, width: keyWidth, height: compactBand, font: compactFont)
                            } else {
                                Color.clear.frame(width: keyWidth, height: compactBand)
                            }
                        }
                    }
                    .frame(width: rowWidth, height: compactBand)
                }
                ForEach(squareRows, id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(0..<row.count, id: \.self) { index in
                            if let spec = row[index] {
                                keyButton(spec, width: keyWidth, height: numberBand, font: numberFont)
                            } else {
                                Color.clear.frame(width: keyWidth, height: numberBand)
                            }
                        }
                    }
                    .frame(width: rowWidth, height: numberBand)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func baseKey(_ numericBase: NumericBase, _ title: String, _ width: CGFloat, _ height: CGFloat) -> some View {
        GlossKey(
            title: title,
            visual: .logic,
            selected: base == numericBase,
            identifier: "base.\(numericBase.radix)",
            fontSize: 15,
            action: { onBase(numericBase) }
        )
        .frame(width: width, height: height)
    }

    private func keyButton(_ spec: KeySpec, width: CGFloat, height: CGFloat, font: CGFloat) -> some View {
        GlossKey(
            title: spec.title,
            visual: spec.visual,
            enabled: base.allowsKey(spec.key),
            identifier: "key.\(spec.id)",
            fontSize: font,
            action: { onKey(spec.key) }
        )
        .frame(width: width, height: height)
    }

    private var compactRows: [(offset: Int, element: [KeySpec?])] {
        Array([
            specs([
                (.pi, "π", .function),
                (.sqrt, "√", .function),
                (.sq, "x²", .function),
                (.cube, "x³", .function),
                (.pow, "xʸ", .function)
            ]),
            specs([
                (.sin, "sin", .function),
                (.cos, "cos", .function),
                (.tan, "tan", .function),
                (.ln, "ln", .function),
                (.log, "log", .function)
            ]),
            specs([
                (.exp, "exp", .function),
                (.rec, "1/x", .function),
                (.fact, "n!", .function),
                (.leftParen, "(", .function),
                (.rightParen, ")", .function)
            ]),
            specs([
                (.memoryClear, "MC", .function),
                (.memoryRecall, "MR", .function),
                (.memoryAdd, "M+", .function),
                (.memorySub, "M−", .function),
                (.test, "Tst", .action)
            ]),
            specs([
                (.and, L10n.text("And", "És"), .logic),
                (.or, L10n.text("Or", "Vagy"), .logic),
                (.xor, "Xor", .logic),
                (.not, L10n.text("Not", "Nem"), .logic),
                (.lsh, "Lsh", .logic)
            ]),
            [
                KeySpec(key: .mod, title: "Mod", visual: .logic),
                KeySpec(key: .angleMode, title: angleMode == .degrees ? L10n.text("Deg", "Fok") : "Rad", visual: .function),
                nil, nil, nil
            ]
        ].enumerated())
    }

    private var squareRows: [(offset: Int, element: [KeySpec?])] {
        Array([
            specs([
                (.digitF, "F", .number),
                (.digitE, "E", .number),
                (.digitD, "D", .number),
                (.digitC, "C", .number),
                (.digitB, "B", .number)
            ]),
            specs([
                (.digitA, "A", .number),
                (.digit9, "9", .number),
                (.digit8, "8", .number),
                (.digit7, "7", .number),
                (.clear, "C", .action)
            ]),
            specs([
                (.digit6, "6", .number),
                (.digit5, "5", .number),
                (.digit4, "4", .number),
                (.digit3, "3", .number),
                (.backspace, "⌫", .action)
            ]),
            specs([
                (.digit2, "2", .number),
                (.digit1, "1", .number),
                (.digit0, "0", .number),
                (.dot, ".", .number),
                (.negate, "+/−", .action)
            ]),
            specs([
                (.add, "+", .operatorKey),
                (.sub, "−", .operatorKey),
                (.mul, "×", .operatorKey),
                (.div, "÷", .operatorKey),
                (.equals, "=", .equals)
            ])
        ].enumerated())
    }

    private func specs(_ rows: [(CalculatorKey, String, KeyVisual)]) -> [KeySpec?] {
        rows.map { KeySpec(key: $0.0, title: $0.1, visual: $0.2) }
    }
}

func baseLabel(_ base: NumericBase) -> String {
    switch base {
    case .binary: "Bin"
    case .octal: L10n.text("Oct", "Okt")
    case .decimal: "Dec"
    case .hexadecimal: "Hex"
    }
}

func angleLabel(_ mode: AngleMode) -> String {
    mode == .degrees ? L10n.text("Deg", "Fok") : "Rad"
}

func errorText(_ kind: ErrorKind?) -> String? {
    switch kind {
    case .emptyExpression:
        L10n.text("Enter an expression first.", "Először adj meg egy kifejezést.")
    case .unbalancedParentheses:
        L10n.text("Unbalanced parentheses.", "A zárójelek nincsenek párban.")
    case .divisionByZero:
        L10n.text("Division by zero.", "Nullával osztás.")
    case .domain:
        L10n.text("The value is outside the domain of this operation.", "Az érték kívül esik a művelet értelmezési tartományán.")
    case .bitwiseNonInteger:
        L10n.text("Bitwise operations require whole numbers.", "A bitenkénti műveletekhez egész szám kell.")
    case .invalidDigit:
        L10n.text("That digit is not valid in this numerical system.", "Ez a számjegy ebben a számrendszerben érvénytelen.")
    case .malformedExpression:
        L10n.text("The expression is not complete.", "A kifejezés nem teljes.")
    case .invalidFactorial:
        L10n.text("Factorial needs a non-negative whole number.", "A faktoriálishoz nemnegatív egész szám kell.")
    case .undefined:
        L10n.text("Undefined.", "Nem definiált.")
    case nil:
        nil
    }
}
