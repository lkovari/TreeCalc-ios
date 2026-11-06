import SwiftUI

struct TreeScreen: View {
    var state: EvaluationResult
    @State private var playback = PostfixPlayback()
    @State private var collapsed: Set<String> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.text("Postfix notation", "Postfix jelölés"))
                .font(.headline)
                .foregroundStyle(screenInk(scheme))
            postfix
            HStack {
                Text(L10n.text("Expression tree", "Kifejezésfa"))
                    .font(.headline)
                    .foregroundStyle(screenInk(scheme))
                Spacer()
                GlossKey(
                    title: playback.running ? L10n.text("Stop", "Állj") : L10n.text("Play", "Lejátszás"),
                    visual: .function,
                    enabled: !state.postfixTokens.isEmpty,
                    identifier: "tree.playback",
                    fontSize: 14,
                    action: { playback.toggle(count: state.postfixTokens.count, reduceMotion: reduceMotion) }
                )
                .frame(width: 120, height: 36)
            }
            tree
        }
        .padding(12)
        .onChange(of: state.postfix) { _, _ in
            playback = PostfixPlayback()
            collapsed = []
        }
        .onChange(of: playback.index) { _, index in
            expandToward(index)
        }
        .task(id: playback.running) {
            guard playback.running else { return }
            while !Task.isCancelled && playback.running {
                try? await Task.sleep(for: .milliseconds(700))
                if Task.isCancelled { return }
                playback.tick(count: state.postfixTokens.count)
            }
        }
    }

    private var postfix: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if state.tree == nil || state.postfixTokens.isEmpty {
                        Text("—")
                            .foregroundStyle(CalcColor.displayInk)
                    } else {
                        ForEach(Array(state.postfixTokens.enumerated()), id: \.offset) { index, token in
                            let selected = playback.index == index
                            let number = postfixIsNumber(token)
                            Button {
                                playback.select(index)
                            } label: {
                                Text(token)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(postfixInk(number: number, selected: selected))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(postfixFill(number: number, selected: selected), in: Capsule())
                                    .overlay {
                                        Capsule().strokeBorder(
                                            selected ? CalcColor.border : postfixInk(number: number, selected: false).opacity(0.35),
                                            lineWidth: selected ? 2 : 1
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
            .onChange(of: playback.index) { _, index in
                guard let index else { return }
                scroll(proxy, to: "postfix-\(index)")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .background(CalcColor.displayFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(CalcColor.border, lineWidth: 1)
        }
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
                        highlightedPath: highlightedPath,
                        collapsed: $collapsed
                    )
                    .padding(8)
                } else {
                    Text(L10n.text(
                        "Evaluate an expression with = to see postfix notation and the expression tree.",
                        "Értékelj ki egy kifejezést az = gombbal, hogy megjelenjen a postfix jelölés és a kifejezésfa."
                    ))
                    .foregroundStyle(CalcColor.displayInk)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onChange(of: playback.index) { _, index in
                guard let index, let path = state.tree?.pathForPostOrderIndex(index) else { return }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(80))
                    scroll(proxy, to: path)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(CalcColor.displayFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(CalcColor.border, lineWidth: 1)
        }
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

    private func postfixIsNumber(_ token: String) -> Bool {
        let symbols: Set<String> = ["+", "-", "−", "×", "÷", "^", "mod", "and", "or", "xor", "lsh", "not", "√", "1/", "sin", "cos", "tan", "ln", "log", "exp", "²", "³", "!"]
        return !symbols.contains(token)
    }

    private func postfixInk(number: Bool, selected: Bool) -> Color {
        if selected {
            return Color(hue: 0.02, saturation: 0.62, brightness: 0.18)
        }
        if number {
            return Color(hue: 0.58, saturation: 0.78, brightness: 0.24)
        }
        return Color(hue: 0.02, saturation: 0.7, brightness: 0.28)
    }

    private func postfixFill(number: Bool, selected: Bool) -> Color {
        if selected {
            return Color(hue: 0.10, saturation: 0.48, brightness: 0.90)
        }
        if number {
            return Color(hue: 0.12, saturation: 0.46, brightness: 0.97)
        }
        return Color(hue: 0.46, saturation: 0.34, brightness: 0.92)
    }

    private var highlightedPath: String? {
        guard let tree = state.tree, let index = playback.index else { return nil }
        return tree.pathForPostOrderIndex(index)
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
}

struct TreeNodeRow: View {
    var node: ExpressionNode
    var base: NumericBase
    var angleMode: AngleMode
    var path: String
    var depth: Int
    var highlightedPath: String?
    @Binding var collapsed: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if depth > 0 {
                    Color.clear.frame(width: CGFloat(depth) * 18, height: 1)
                }
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
                            .frame(width: 16, height: 16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(CalcColor.border, lineWidth: 1)
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
                    .fill(depth == 0 ? CalcColor.rootBadge : CalcColor.badge)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Circle().strokeBorder(CalcColor.border, lineWidth: 2)
                    }
                    .overlay {
                        Text(node.operatorKind?.displaySymbol ?? "")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(hue: 0.62, saturation: 0.55, brightness: 0.18))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                Text(node.displayLabel(base: base, angleMode: angleMode))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(node.operatorKind == nil ? CalcColor.operand : CalcColor.displayInk)
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .background(inSubtree ? CalcColor.badge.opacity(0.55) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
            .id(path)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(path == highlightedPath ? .isSelected : [])
            if node.childCount > 0 && !collapsed.contains(path) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<node.childCount, id: \.self) { index in
                        if let child = node.childAt(index) {
                            TreeNodeRow(
                                node: child,
                                base: base,
                                angleMode: angleMode,
                                path: "\(path)/\(index)",
                                depth: depth + 1,
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
        guard let highlightedPath else { return false }
        return path == highlightedPath || path.hasPrefix(highlightedPath + "/")
    }
}
