import SwiftUI

struct TreeWalk {
    var playback = PostfixPlayback()
    var userStep = false
    var collapsed: Set<String> = []
}

struct TreeScreen: View {
    var state: EvaluationResult
    @Binding var playback: PostfixPlayback
    @Binding var userStep: Bool
    @Binding var collapsed: Set<String>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !state.expression.isEmpty {
                expressionLine
            }
            Text(L10n.text("Postfix notation", "Postfix jelölés"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(chrome.ink)
            controls
            postfix
            Text(L10n.text("Operations", "Műveletsor"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(chrome.ink)
            operations
            Text(L10n.text("Expression tree", "Kifejezésfa"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(chrome.ink)
            tree
        }
        .padding(12)
        .onChange(of: playback.index) { _, index in
            expandToward(index)
        }
        .task(id: playbackClock) {
            if stepped {
                if playback.running {
                    playback.running = false
                }
                return
            }
            guard playback.running else { return }
            do {
                try await Task.sleep(for: .milliseconds(700))
            } catch {
                return
            }
            guard !Task.isCancelled, playback.running, !stepped else { return }
            playback.tick(count: state.postfixTokens.count)
        }
    }

    private var expressionLine: some View {
        let slice = highlightedSlice
        return Text(highlightedExpression)
            .font(.system(size: 13, weight: .medium))
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("tree.expression")
            .accessibilityLabel(slice.map { value in
                L10n.text("Expression highlight: \(value)", "Kifejezés kiemelés: \(value)")
            } ?? state.expression)
    }

    private var controls: some View {
        HStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                Toggle(isOn: stepBinding) {}
                    .labelsHidden()
                    .controlSize(.small)
                    .disabled(!switchEnabled)
                    .accessibilityIdentifier("tree.step")
                    .accessibilityLabel(L10n.text("Step by step", "Lépésenként"))
                Text(L10n.text("Step by step", "Lépésenként"))
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(chrome.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if showStop {
                playbackKey(
                    title: L10n.text("Stop", "Megállítás"),
                    enabled: true,
                    identifier: "tree.playback.stop"
                ) {
                    playback.stop()
                }
            }
            playbackKey(
                title: playbackLabel,
                enabled: playbackEnabled,
                identifier: "tree.playback"
            ) {
                if stepped {
                    playback.step(count: tokenCount)
                } else {
                    playback.toggle(count: tokenCount, stepByStep: false)
                }
            }
        }
    }

    private var postfix: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if state.tree == nil || state.postfixTokens.isEmpty {
                        Text("—")
                            .foregroundStyle(chrome.ink)
                    } else {
                        ForEach(Array(state.postfixTokens.enumerated()), id: \.offset) { index, token in
                            let selected = playback.index == index
                            Button {
                                playback.select(index)
                            } label: {
                                Text(token)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(selected ? chrome.selectedInk : chrome.ink)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .frame(height: 34)
                                    .background(selected ? chrome.selectedFill : chrome.chipFill, in: Capsule())
                                    .overlay {
                                        Capsule().strokeBorder(
                                            selected ? chrome.selectedLine : chrome.chipLine,
                                            lineWidth: selected ? 1.5 : 1
                                        )
                                    }
                            }
                            .buttonStyle(.plain)
                            .id("postfix-\(index)")
                            .accessibilityIdentifier("postfix.\(index)")
                            .accessibilityLabel(L10n.text("Postfix step: \(token)", "Postfix lépés: \(token)"))
                            .accessibilityAddTraits(selected ? .isSelected : [])
                        }
                    }
                }
                .padding(8)
            }
            .task(id: playback.index) {
                guard let index = playback.index else { return }
                scroll(proxy, to: "postfix-\(index)")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .modifier(WellChrome())
    }

    private var operations: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if steps.isEmpty {
                    Text("—")
                        .foregroundStyle(chrome.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                } else {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(steps.indices, id: \.self) { index in
                            let sentence = traceSentence(steps[index].action, hungarian: L10n.hungarian)
                            let selected = playback.index == index
                            Button {
                                playback.select(index)
                            } label: {
                                Text(sentence)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(selected ? chrome.selectedInk : chrome.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        selected ? chrome.selectedFill : chrome.chipFill,
                                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .strokeBorder(
                                                selected ? chrome.selectedLine : chrome.chipLine,
                                                lineWidth: 1
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                            .id("operation-\(index)")
                            .accessibilityIdentifier("operation.\(index)")
                            .accessibilityLabel(L10n.text("Operation: \(sentence)", "Művelet: \(sentence)"))
                            .accessibilityAddTraits(selected ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
            }
            .task(id: playback.index) {
                guard let index = playback.index else { return }
                scroll(proxy, to: "operation-\(index)")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 108, alignment: .topLeading)
        .modifier(WellChrome())
    }

    @ViewBuilder
    private var tree: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                if let node = state.tree {
                    TreeNodeRow(
                        node: node,
                        base: state.base,
                        angleMode: state.angleMode,
                        path: "root",
                        depth: 0,
                        isLastSibling: true,
                        ancestorContinues: [],
                        highlightedPath: highlightedPath,
                        collapsed: $collapsed
                    )
                    .padding(8)
                } else {
                    Text(L10n.text(
                        "Evaluate an expression with = to see postfix notation and the expression tree.",
                        "Értékelj ki egy kifejezést az = gombbal, hogy megjelenjen a postfix jelölés és a kifejezésfa."
                    ))
                    .foregroundStyle(chrome.ink)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .task(id: playback.index) {
                guard let index = playback.index, let path = state.tree?.pathForPostOrderIndex(index) else { return }
                do {
                    try await Task.sleep(for: .milliseconds(80))
                } catch {
                    return
                }
                guard !Task.isCancelled else { return }
                scroll(proxy, to: path)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(WellChrome())
    }

    private func playbackKey(
        title: String,
        enabled: Bool,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(PlaybackKeyStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.38)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
    }

    private func scroll(_ proxy: ScrollViewProxy, to id: String) {
        if reduceMotion {
            proxy.scrollTo(id, anchor: .center)
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }

    private func expandToward(_ index: Int?) {
        guard let index, let path = state.tree?.pathForPostOrderIndex(index) else { return }
        var prefix = "root"
        collapsed.remove(prefix)
        let parts = path.split(separator: "/").dropFirst()
        for part in parts {
            prefix += "/\(part)"
            collapsed.remove(prefix)
        }
    }

    private var tokenCount: Int {
        state.postfixTokens.count
    }

    private var stepped: Bool {
        reduceMotion || userStep
    }

    private var switchEnabled: Bool {
        !reduceMotion
    }

    private var stepBinding: Binding<Bool> {
        Binding(
            get: { stepped },
            set: { checked in
                guard switchEnabled else { return }
                userStep = checked
                if checked {
                    playback.running = false
                }
            }
        )
    }

    private var onLastStep: Bool {
        guard stepped, let index = playback.index, tokenCount > 0 else { return false }
        return index == tokenCount - 1
    }

    private var playbackEnabled: Bool {
        tokenCount > 0 && !onLastStep
    }

    private var showStop: Bool {
        stepped && playback.index != nil
    }

    private var playbackLabel: String {
        if !stepped && playback.running {
            return L10n.text("Pause", "Szünet")
        }
        if stepped, playback.index != nil {
            return L10n.text("Next", "Következő")
        }
        return L10n.text("Play", "Lejátszás")
    }

    private var playbackClock: String {
        "\(playback.running)-\(playback.index ?? -1)-\(stepped)"
    }

    private var steps: [EvaluationStep] {
        guard let tree = state.tree else { return [] }
        return tree.evaluationSteps(base: state.base, angleMode: state.angleMode)
    }

    private var highlightedPath: String? {
        guard let tree = state.tree, let index = playback.index else { return nil }
        return tree.pathForPostOrderIndex(index)
    }

    private var activeSpan: ClosedRange<Int>? {
        guard let index = playback.index, state.expressionSpans.indices.contains(index) else { return nil }
        return state.expressionSpans[index]
    }

    private var highlightedSlice: String? {
        guard let span = activeSpan else { return nil }
        let expression = state.expression
        guard span.lowerBound >= 0, span.upperBound < expression.count else { return nil }
        let start = expression.index(expression.startIndex, offsetBy: span.lowerBound)
        let end = expression.index(start, offsetBy: span.upperBound - span.lowerBound + 1)
        return String(expression[start..<end])
    }

    private var highlightedExpression: AttributedString {
        var text = AttributedString(state.expression)
        text.foregroundColor = chrome.muted
        guard let span = activeSpan, let slice = highlightedSlice, !slice.isEmpty else { return text }
        let start = text.index(text.startIndex, offsetByCharacters: span.lowerBound)
        let end = text.index(start, offsetByCharacters: slice.count)
        text[start..<end].backgroundColor = chrome.selectedFill
        text[start..<end].foregroundColor = chrome.selectedInk
        return text
    }

    private var chrome: TreeChrome {
        TreeChrome.make(scheme)
    }
}

private struct PlaybackKeyStyle: ButtonStyle {
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        let paint = KeyPaint.paint(.action)
        let pressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let push = pressed ? 0.82 : 1.0
        let endDepth = keyGradientEndDepth(dark: scheme == .dark)
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .minimumScaleFactor(0.55)
            .lineLimit(1)
            .foregroundStyle(paint.label(scheme: scheme))
            .frame(width: 72, height: 24)
            .background {
                shape.fill(
                    LinearGradient(
                        colors: [
                            paint.fill(scheme: scheme, depth: push),
                            paint.fill(scheme: scheme, depth: endDepth * push)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    shape.strokeBorder(Color.white.opacity(scheme == .dark ? 0.28 : 0.55), lineWidth: 1)
                }
            }
            .clipShape(shape)
            .shadow(color: Color.black.opacity(scheme == .dark ? 0.35 : 0.16), radius: 3, x: 0, y: 2)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }
}

private struct WellChrome: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        let chrome = TreeChrome.make(scheme)
        content
            .background(chrome.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(chrome.line, lineWidth: 1)
            }
            .shadow(color: chrome.shadow, radius: scheme == .dark ? 0 : 8, y: scheme == .dark ? 0 : 3)
    }
}

func postfixTokenIsNumber(_ token: String) -> Bool {
    let symbols: Set<String> = ["+", "-", "−", "×", "÷", "^", "mod", "and", "or", "xor", "lsh", "not", "√", "1/", "sin", "cos", "tan", "ln", "log", "exp", "²", "³", "!"]
    return !symbols.contains(token)
}

func treeRowInHighlightedSubtree(path: String, highlighted: String?) -> Bool {
    guard let highlighted else { return false }
    return path == highlighted || path.hasPrefix(highlighted + "/")
}

struct TreeNodeRow: View {
    var node: ExpressionNode
    var base: NumericBase
    var angleMode: AngleMode
    var path: String
    var depth: Int
    var isLastSibling: Bool
    var ancestorContinues: [Bool]
    var highlightedPath: String?
    @Binding var collapsed: Set<String>
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                TreeGuides(
                    ancestorContinues: ancestorContinues,
                    drawElbow: depth > 0,
                    verticalThrough: depth > 0 && !isLastSibling,
                    color: chrome.guide
                )
                if node.childCount > 0 {
                    Button {
                        if collapsed.contains(path) {
                            collapsed.remove(path)
                        } else {
                            collapsed.insert(path)
                        }
                    } label: {
                        Image(systemName: collapsed.contains(path) ? "plus" : "minus")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(chrome.ink)
                            .frame(width: 16, height: 16)
                            .background(chrome.chipFill, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .strokeBorder(chrome.chipLine, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(collapsed.contains(path)
                        ? L10n.text("Expand", "Kibontás")
                        : L10n.text("Collapse", "Összecsukás"))
                } else {
                    Color.clear.frame(width: 16, height: 16)
                }
                Circle()
                    .fill(depth == 0 ? chrome.rootFill : chrome.nodeFill)
                    .frame(width: 34, height: 34)
                    .overlay {
                        Circle().strokeBorder(depth == 0 ? chrome.rootRing : chrome.nodeRing, lineWidth: 2)
                    }
                    .overlay {
                        Text(node.operatorKind?.displaySymbol ?? "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(chrome.glyph)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                    }
                Text(node.displayLabel(base: base, angleMode: angleMode))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(node.operatorKind == nil ? chrome.operand : chrome.ink)
                    .lineLimit(1)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 4)
            .background(inSubtree ? chrome.selectedFill.opacity(scheme == .dark ? 0.38 : 0.28) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
            .id(path)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(inSubtree ? .isSelected : [])
            if node.childCount > 0 && !collapsed.contains(path) {
                let childContinues = childAncestorContinues(
                    depth: depth,
                    ancestors: ancestorContinues,
                    isLastSibling: isLastSibling
                )
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<node.childCount, id: \.self) { index in
                        if let child = node.childAt(index) {
                            TreeNodeRow(
                                node: child,
                                base: base,
                                angleMode: angleMode,
                                path: "\(path)/\(index)",
                                depth: depth + 1,
                                isLastSibling: index == node.childCount - 1,
                                ancestorContinues: childContinues,
                                highlightedPath: highlightedPath,
                                collapsed: $collapsed
                            )
                        }
                    }
                }
            }
        }
    }

    private var inSubtree: Bool {
        treeRowInHighlightedSubtree(path: path, highlighted: highlightedPath)
    }

    private var chrome: TreeChrome {
        TreeChrome.make(scheme)
    }
}

private func childAncestorContinues(depth: Int, ancestors: [Bool], isLastSibling: Bool) -> [Bool] {
    if depth == 0 {
        return ancestors
    }
    return ancestors + [!isLastSibling]
}

private struct TreeGuides: View {
    var ancestorContinues: [Bool]
    var drawElbow: Bool
    var verticalThrough: Bool
    var color: Color

    var body: some View {
        Canvas { context, size in
            let gutter: CGFloat = 18
            let midY = size.height / 2
            let style = StrokeStyle(lineWidth: 1.25, lineCap: .round, dash: [2.5, 3.5])
            for (index, continues) in ancestorContinues.enumerated() where continues {
                let x = gutter * CGFloat(index) + gutter / 2
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(color), style: style)
            }
            if drawElbow {
                let x = gutter * CGFloat(ancestorContinues.count) + gutter / 2
                var vertical = Path()
                vertical.move(to: CGPoint(x: x, y: 0))
                vertical.addLine(to: CGPoint(x: x, y: verticalThrough ? size.height : midY))
                context.stroke(vertical, with: .color(color), style: style)
                var horizontal = Path()
                horizontal.move(to: CGPoint(x: x, y: midY))
                horizontal.addLine(to: CGPoint(x: x + gutter / 2, y: midY))
                context.stroke(horizontal, with: .color(color), style: style)
            }
        }
        .frame(width: 18 * CGFloat(ancestorContinues.count + (drawElbow ? 1 : 0)))
        .allowsHitTesting(false)
    }
}

struct TreeChrome {
    var surface: Color
    var ink: Color
    var muted: Color
    var line: Color
    var chipFill: Color
    var chipLine: Color
    var selectedFill: Color
    var selectedInk: Color
    var selectedLine: Color
    var rootFill: Color
    var rootRing: Color
    var nodeFill: Color
    var nodeRing: Color
    var glyph: Color
    var operand: Color
    var guide: Color
    var shadow: Color

    static func make(_ scheme: ColorScheme) -> TreeChrome {
        if scheme == .dark {
            return TreeChrome(
                surface: Color(red: 0.227, green: 0.200, blue: 0.251),
                ink: Color(red: 0.957, green: 0.925, blue: 0.937),
                muted: Color(red: 0.831, green: 0.769, blue: 0.800),
                line: Color(red: 0.478, green: 0.420, blue: 0.455),
                chipFill: Color(red: 0.310, green: 0.275, blue: 0.345),
                chipLine: Color(red: 0.620, green: 0.545, blue: 0.588),
                selectedFill: Color(red: 0.180, green: 0.490, blue: 0.710),
                selectedInk: Color.white,
                selectedLine: Color(red: 0.620, green: 0.860, blue: 0.980),
                rootFill: Color(red: 0.180, green: 0.520, blue: 0.360),
                rootRing: Color(red: 0.650, green: 0.920, blue: 0.760),
                nodeFill: Color(red: 0.145, green: 0.400, blue: 0.620),
                nodeRing: Color(red: 0.620, green: 0.860, blue: 0.980),
                glyph: Color.white,
                operand: Color(red: 0.790, green: 0.850, blue: 0.950),
                guide: Color(red: 0.690, green: 0.610, blue: 0.650),
                shadow: Color.clear
            )
        }
        return TreeChrome(
            surface: Color(red: 1, green: 0.984, blue: 0.990),
            ink: Color(red: 0.227, green: 0.165, blue: 0.196),
            muted: Color(red: 0.478, green: 0.353, blue: 0.400),
            line: Color(red: 0.890, green: 0.760, blue: 0.810),
            chipFill: Color(red: 0.910, green: 0.962, blue: 0.992),
            chipLine: Color(red: 0.300, green: 0.620, blue: 0.820),
            selectedFill: Color(red: 0.165, green: 0.520, blue: 0.760),
            selectedInk: Color.white,
            selectedLine: Color(red: 0.090, green: 0.360, blue: 0.560),
            rootFill: Color(red: 0.455, green: 0.820, blue: 0.620),
            rootRing: Color(red: 0.150, green: 0.480, blue: 0.310),
            nodeFill: Color(red: 0.500, green: 0.780, blue: 0.940),
            nodeRing: Color(red: 0.120, green: 0.400, blue: 0.640),
            glyph: Color(red: 0.070, green: 0.170, blue: 0.250),
            operand: Color(red: 0.180, green: 0.310, blue: 0.500),
            guide: Color(red: 0.730, green: 0.480, blue: 0.570),
            shadow: Color(red: 0.45, green: 0.22, blue: 0.32).opacity(0.14)
        )
    }
}
