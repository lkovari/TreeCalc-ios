import Foundation

private let sampleExpression = "888/(6*1.25+3*(7-4*1.5+(9/3-1.2))*2)-11*(4.5/2^3)/(5-1.25)"

final class CalculatorEngine {
    private var base: NumericBase = .decimal
    private var infix: [Token] = []
    private var currentInput = ""
    private var afterEquals = false
    private var lastResult: Double?
    private var lastFraction: Fraction?
    private var lastTree: ExpressionNode?
    private var lastPostfix: [Token] = []
    private var savedInfix: [Token] = []
    private var lastExpressionText = ""
    private var liveDisplay = "0"
    private var errorKind: ErrorKind?
    private var memory = 0.0
    private var memoryFraction: Fraction?
    private var memorySet = false
    private var angleMode: AngleMode = .degrees

    func snapshot() -> EvaluationResult {
        let expression = afterEquals ? lastExpressionText : formatExpression(infix, currentInput)
        let tokens = lastTree == nil ? [] : lastPostfix.map(tokenText)
        return EvaluationResult(
            display: liveDisplay,
            expression: expression,
            postfix: formatPostfix(lastPostfix),
            postfixTokens: tokens,
            tree: lastTree,
            base: base,
            errorKind: errorKind,
            memorySet: memorySet,
            afterEquals: afterEquals,
            angleMode: angleMode,
            expressionSpans: publishedSpans(tokenCount: tokens.count)
        )
    }

    func setBase(_ newBase: NumericBase) {
        if newBase == base { return }
        if !valuesFit(newBase) {
            errorKind = .overflow
            return
        }
        let previous = base
        base = newBase
        infix = infix.map { convertToken($0, from: previous, to: newBase) }
        savedInfix = savedInfix.map { convertToken($0, from: previous, to: newBase) }
        if afterEquals {
            lastExpressionText = formatExpression(savedInfix, "")
        }
        if !currentInput.isEmpty {
            currentInput = convertLiteral(currentInput, from: previous, to: newBase)
            liveDisplay = currentInput
        } else if afterEquals, let result = lastResult {
            liveDisplay = displayText(result, fraction: lastFraction)
        } else {
            liveDisplay = convertLiteral(liveDisplay, from: previous, to: newBase)
        }
        errorKind = nil
    }

    func isKeyEnabled(_ key: CalculatorKey) -> Bool {
        base.allowsKey(key)
    }

    func press(_ key: CalculatorKey) {
        if !isKeyEnabled(key) && key != .clear {
            return
        }
        switch key {
        case .clear:
            clear()
        case .equals:
            evaluate()
        case .backspace:
            backspace()
        case .dot:
            enterDot()
        case .pi:
            enterPi()
        case .angleMode:
            toggleAngleMode()
        case .negate:
            negate()
        case .leftParen:
            enterParen(left: true)
        case .rightParen:
            enterParen(left: false)
        case .memoryAdd:
            memoryAdd()
        case .memorySub:
            memorySubtract()
        case .memoryRecall:
            memoryRecall()
        case .memoryClear:
            memoryClear()
        case .test:
            loadSampleExpression()
        case .digit0, .digit1, .digit2, .digit3, .digit4, .digit5, .digit6, .digit7, .digit8, .digit9,
             .digitA, .digitB, .digitC, .digitD, .digitE, .digitF:
            enterDigit(digitChar(key))
        case .add, .sub, .mul, .div, .mod, .pow, .and, .or, .xor, .lsh:
            enterBinary(operatorKind(key))
        case .not, .sqrt, .rec, .sin, .cos, .tan, .ln, .log, .exp, .sq, .cube, .fact:
            enterUnary(operatorKind(key))
        }
    }

    private func loadSampleExpression() {
        clear()
        base = .decimal
        for character in sampleExpression {
            switch character {
            case "(": enterParen(left: true)
            case ")": enterParen(left: false)
            case "+": enterBinary(.add)
            case "-": enterBinary(.sub)
            case "*": enterBinary(.mul)
            case "/": enterBinary(.div)
            case "^": enterBinary(.pow)
            case ".": enterDot()
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                enterDigit(character)
            default:
                break
            }
        }
    }

    private func clear() {
        infix.removeAll()
        currentInput = ""
        afterEquals = false
        lastResult = nil
        lastFraction = nil
        lastTree = nil
        lastPostfix = []
        savedInfix = []
        lastExpressionText = ""
        liveDisplay = (try? NumericText.format(0, base: base)) ?? "0"
        errorKind = nil
    }

    private func evaluate() {
        flushInput()
        if infix.isEmpty {
            if let result = lastResult {
                afterEquals = true
                liveDisplay = displayText(result, fraction: lastFraction)
                errorKind = nil
            } else {
                errorKind = .emptyExpression
            }
            return
        }
        do {
            let postfix = try InfixToPostfix.convert(infix)
            let tree = try ExpressionTreeBuilder.build(postfix, base: base)
            let value = try tree.evaluate(angleMode: angleMode)
            if !NumericText.fits(value, base: base) {
                throw CalculatorException(kind: .overflow)
            }
            let fraction = tree.exactFraction(base: base)
            if let fraction {
                lastResult = Double(fraction.num) / Double(fraction.den)
            } else {
                lastResult = value
            }
            lastFraction = fraction
            lastTree = tree
            lastPostfix = postfix
            savedInfix = infix
            lastExpressionText = formatExpression(infix, "")
            afterEquals = true
            infix.removeAll()
            currentInput = ""
            liveDisplay = displayText(value, fraction: fraction)
            errorKind = nil
        } catch let exception as CalculatorException {
            lastTree = nil
            lastPostfix = []
            lastFraction = nil
            errorKind = exception.kind
        } catch {
            lastTree = nil
            lastPostfix = []
            lastFraction = nil
            errorKind = .malformedExpression
        }
    }

    private func enterDigit(_ character: Character) {
        beginNewInputIfNeeded()
        if !NumericText.isValidDigit(character, base: base) {
            errorKind = .invalidDigit
            return
        }
        let upper = String(character).uppercased()
        if currentInput == "0" {
            currentInput = ""
        } else if currentInput == "-0" {
            currentInput = "-"
        }
        currentInput.append(upper)
        liveDisplay = currentInput
        errorKind = nil
    }

    private func enterDot() {
        beginNewInputIfNeeded()
        if currentInput.contains(".") {
            currentInput.append(".")
            liveDisplay = currentInput
            errorKind = .malformedExpression
            return
        }
        if currentInput.isEmpty || currentInput == "-" {
            currentInput.append("0.")
        } else {
            currentInput.append(".")
        }
        liveDisplay = currentInput
        errorKind = nil
    }

    private func enterPi() {
        beginNewInputIfNeeded()
        flushInput()
        infix.append(.numberLiteral(NumericText.piSymbol))
        liveDisplay = (try? NumericText.format(Double.pi, base: base)) ?? NumericText.piSymbol
        errorKind = nil
    }

    private func enterBinary(_ kind: OperatorKind) {
        if afterEquals {
            let result = lastResult
            infix.removeAll()
            currentInput = ""
            afterEquals = false
            lastExpressionText = ""
            if let result {
                addNumberToken(displayText(result, fraction: lastFraction))
            }
        }
        flushInput()
        if kind == .sub && isPrefixUnaryPosition() {
            infix.append(.operatorToken(.neg))
            errorKind = nil
            return
        }
        if infix.isEmpty {
            infix.append(.numberLiteral((try? NumericText.format(0, base: base)) ?? "0"))
        }
        if case .operatorToken(let last) = infix.last, last.arity == .binary {
            infix.removeLast()
        }
        infix.append(.operatorToken(kind))
        errorKind = nil
    }

    private func enterUnary(_ kind: OperatorKind) {
        if afterEquals {
            let result = lastResult
            infix.removeAll()
            currentInput = ""
            afterEquals = false
            lastExpressionText = ""
            if let result {
                addNumberToken(displayText(result, fraction: lastFraction))
            }
        }
        flushInput()
        if infix.isEmpty {
            errorKind = .malformedExpression
            return
        }
        infix.append(.operatorToken(kind))
        errorKind = nil
    }

    private func enterParen(left: Bool) {
        beginNewInputIfNeeded()
        flushInput()
        infix.append(left ? .leftParen : .rightParen)
        errorKind = nil
    }

    private func negate() {
        if afterEquals {
            if let result = lastResult {
                lastResult = -result
                if let fraction = lastFraction {
                    lastFraction = fraction.negated()
                }
                if let tree = lastTree {
                    lastTree = .unary(.neg, tree)
                    lastPostfix.append(.operatorToken(.neg))
                    savedInfix = [.operatorToken(.neg), .leftParen] + savedInfix + [.rightParen]
                    lastExpressionText = formatExpression(savedInfix, "")
                }
                liveDisplay = displayText(lastResult ?? result, fraction: lastFraction)
                currentInput = ""
                infix.removeAll()
            }
            return
        }
        if currentInput.isEmpty {
            currentInput = "-"
            liveDisplay = currentInput
            return
        }
        if currentInput.hasPrefix("-") {
            currentInput.removeFirst()
        } else {
            currentInput = "-" + currentInput
        }
        liveDisplay = currentInput.isEmpty ? ((try? NumericText.format(0, base: base)) ?? "0") : currentInput
    }

    private func backspace() {
        if afterEquals { return }
        if !currentInput.isEmpty {
            currentInput.removeLast()
            liveDisplay = currentInput.isEmpty ? ((try? NumericText.format(0, base: base)) ?? "0") : currentInput
            return
        }
        if infix.isEmpty { return }
        let removed = infix.removeLast()
        if case .numberLiteral(let raw) = removed {
            if raw.count > 1 {
                currentInput = String(raw.dropLast())
                liveDisplay = currentInput
            } else {
                liveDisplay = (try? NumericText.format(0, base: base)) ?? "0"
            }
        }
    }

    private func memoryAdd() {
        guard let value = currentNumericValue() else { return }
        absorbMemory(value, adding: true)
        memorySet = true
    }

    private func memorySubtract() {
        guard let value = currentNumericValue() else { return }
        absorbMemory(value, adding: false)
        memorySet = true
    }

    private func memoryRecall() {
        beginNewInputIfNeeded()
        let formatted: String
        if let memoryFraction, let exact = DecimalDisplay.format(memoryFraction, base: base) {
            formatted = exact
        } else if let text = try? NumericText.format(memory, base: base) {
            formatted = text
        } else {
            errorKind = .overflow
            return
        }
        currentInput = formatted
        liveDisplay = formatted
        errorKind = nil
    }

    private func memoryClear() {
        memory = 0
        memoryFraction = nil
        memorySet = false
    }

    private func absorbMemory(_ value: Double, adding: Bool) {
        let piece = currentFraction()
        let approximate = memoryFraction == nil && memorySet && memory != 0
        if !approximate, let piece, let stored = memoryFraction ?? Fraction.reduced(0, 1) {
            let combined = adding ? stored.added(piece) : stored.subtracted(piece)
            if let combined {
                memoryFraction = combined
                memory = Double(combined.num) / Double(combined.den)
                return
            }
        }
        memoryFraction = nil
        memory = adding ? memory + value : memory - value
    }

    private func beginNewInputIfNeeded() {
        if afterEquals {
            infix.removeAll()
            currentInput = ""
            afterEquals = false
            lastExpressionText = ""
        }
    }

    private func flushInput() {
        let text = currentInput
        if text.isEmpty || text == "." || text == "-." {
            currentInput = ""
            return
        }
        addNumberToken(text)
        currentInput = ""
    }

    private func addNumberToken(_ raw: String) {
        if raw == "-" {
            infix.append(.operatorToken(.neg))
            return
        }
        if raw.hasPrefix("-") && raw != NumericText.piSymbol {
            infix.append(.operatorToken(.neg))
            infix.append(.numberLiteral(String(raw.dropFirst())))
            return
        }
        infix.append(.numberLiteral(raw))
    }

    private func isPrefixUnaryPosition() -> Bool {
        guard let last = infix.last else { return true }
        switch last {
        case .leftParen:
            return true
        case .operatorToken(let kind):
            return kind.arity == .binary || kind == .neg
        default:
            return false
        }
    }

    private func toggleAngleMode() {
        angleMode = angleMode == .degrees ? .radians : .degrees
        errorKind = nil
    }

    private func currentFraction() -> Fraction? {
        let text = currentInput
        if !text.isEmpty && text != "-" && text != "." && text != "-." {
            return Fraction.fromLiteral(text, radix: base.radix)
        }
        if afterEquals {
            return lastFraction
        }
        if case .numberLiteral(let raw) = infix.last {
            return Fraction.fromLiteral(raw, radix: base.radix)
        }
        return nil
    }

    private func convertToken(_ token: Token, from: NumericBase, to: NumericBase) -> Token {
        guard case .numberLiteral(let raw) = token else { return token }
        return .numberLiteral(convertLiteral(raw, from: from, to: to))
    }

    private func convertLiteral(_ raw: String, from: NumericBase, to: NumericBase) -> String {
        if raw == NumericText.piSymbol || raw.lowercased() == "pi" {
            return raw
        }
        let trailingDot = raw.hasSuffix(".") && raw.filter { $0 == "." }.count == 1 && !raw.contains("(")
        let core = trailingDot ? String(raw.dropLast()) : raw
        if core.isEmpty || core == "-" {
            return raw
        }
        let pretty: String
        if let fraction = Fraction.fromLiteral(core, radix: from.radix) {
            pretty = DecimalDisplay.format(fraction, base: to)
                ?? (try? NumericText.format(Double(fraction.num) / Double(fraction.den), base: to))
                ?? raw
        } else if let value = try? NumericText.parse(core, base: from), let text = try? NumericText.format(value, base: to) {
            pretty = text
        } else {
            return raw
        }
        if trailingDot && !pretty.contains(".") && !pretty.contains("(") {
            return pretty + "."
        }
        return pretty
    }

    private func valuesFit(_ target: NumericBase) -> Bool {
        var literals = (infix + savedInfix).compactMap { token -> String? in
            if case .numberLiteral(let raw) = token { return raw }
            return nil
        }
        literals.append(currentInput)
        for raw in literals {
            if let value = try? NumericText.parse(raw, base: base), !NumericText.fits(value, base: target) {
                return false
            }
        }
        if afterEquals, let result = lastResult, !NumericText.fits(result, base: target) {
            return false
        }
        return true
    }

    private func currentNumericValue() -> Double? {
        let text = currentInput
        if !text.isEmpty && text != "-" && text != "." && text != "-." {
            return try? NumericText.parse(text, base: base)
        }
        if let result = lastResult, afterEquals || infix.isEmpty {
            return result
        }
        if case .numberLiteral(let raw) = infix.last {
            return try? NumericText.parse(raw, base: base)
        }
        return nil
    }

    private func digitChar(_ key: CalculatorKey) -> Character {
        switch key {
        case .digit0: "0"
        case .digit1: "1"
        case .digit2: "2"
        case .digit3: "3"
        case .digit4: "4"
        case .digit5: "5"
        case .digit6: "6"
        case .digit7: "7"
        case .digit8: "8"
        case .digit9: "9"
        case .digitA: "A"
        case .digitB: "B"
        case .digitC: "C"
        case .digitD: "D"
        case .digitE: "E"
        case .digitF: "F"
        default: "0"
        }
    }

    private func operatorKind(_ key: CalculatorKey) -> OperatorKind {
        switch key {
        case .add: .add
        case .sub: .sub
        case .mul: .mul
        case .div: .div
        case .mod: .mod
        case .pow: .pow
        case .and: .and
        case .or: .or
        case .xor: .xor
        case .lsh: .lsh
        case .not: .not
        case .sqrt: .sqrt
        case .rec: .rec
        case .sin: .sin
        case .cos: .cos
        case .tan: .tan
        case .ln: .ln
        case .log: .log
        case .exp: .exp
        case .sq: .sq
        case .cube: .cube
        case .fact: .fact
        default: .add
        }
    }

    private func publishedSpans(tokenCount: Int) -> [ClosedRange<Int>] {
        guard afterEquals, lastTree != nil, tokenCount > 0 else { return [] }
        let spans = expressionStepSpans(savedInfix)
        if spans.count != tokenCount {
            return []
        }
        return spans
    }

    private func displayText(_ value: Double, fraction: Fraction?) -> String {
        DecimalDisplay.present(value: value, base: base, fraction: fraction)
    }

    private func formatExpression(_ tokens: [Token], _ current: String) -> String {
        var parts = tokens.map(tokenText)
        if !current.isEmpty {
            parts.append(current)
        }
        return parts.joined(separator: " ")
    }

    private func formatPostfix(_ tokens: [Token]) -> String {
        tokens.map(tokenText).joined(separator: ", ")
    }

    private func tokenText(_ token: Token) -> String {
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
}
