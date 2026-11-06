import SwiftUI

struct GlossKey: View {
    var title: String
    var visual: KeyVisual
    var enabled: Bool = true
    var selected: Bool = false
    var identifier: String
    var fontSize: CGFloat = 16
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold))
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(GlossButtonStyle(visual: visual, selected: selected))
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.38)
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
    }
}

struct GlossButtonStyle: ButtonStyle {
    var visual: KeyVisual
    var selected: Bool
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        let paint = KeyPaint.paint(visual)
        let pressed = configuration.isPressed
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let push = pressed ? 0.82 : 1.0
        configuration.label
            .foregroundStyle(paint.label(scheme: scheme))
            .background {
                shape
                    .fill(
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
                        if scheme == .dark {
                            shape.fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(pressed ? 0.12 : 0.38), Color.white.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                        }
                    }
                    .overlay {
                        shape.strokeBorder(selected ? Color.white : CalcColor.border, lineWidth: selected ? 2.5 : 1.5)
                    }
            }
            .clipShape(shape)
            .shadow(color: Color.gray.opacity(scheme == .dark ? 0.45 : 1), radius: 3, x: 3, y: 3)
    }

    private var endDepth: Double {
        scheme == .dark ? 0.78 : 0.25
    }
}

