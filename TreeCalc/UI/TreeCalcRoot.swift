import SwiftUI

struct TreeCalcRoot: View {
    @State private var model = CalculatorModel()
    @State private var theme = ThemeStore()
    @State private var showTree = false
    @State private var path = NavigationPath()
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                if showTree {
                    TreeScreen(state: model.state)
                } else {
                    CalculatorScreen(model: model)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { CalcBackground() }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TreeCalcMark(
                        caption: showTree ? L10n.text("Expression tree", "Kifejezésfa") : "",
                        captionColor: screenInk(scheme)
                    )
                }
                if showTree {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showTree = false
                        } label: {
                            Image(systemName: "chevron.backward")
                                .font(.body.weight(.semibold))
                        }
                        .accessibilityIdentifier("tree.back")
                        .accessibilityLabel(L10n.text("Back", "Vissza"))
                    }
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showTree = true
                        } label: {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                                .font(.body.weight(.semibold))
                        }
                        .accessibilityIdentifier("tree.open")
                        .accessibilityLabel(L10n.text("Expression tree", "Kifejezésfa"))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(L10n.text("Help", "Súgó")) { path.append("help") }
                        Button(L10n.text("About", "Névjegy")) { path.append("about") }
                        Menu(L10n.text("Theme", "Téma")) {
                            themeButton(.auto, L10n.text("Auto", "Automatikus"))
                            themeButton(.light, L10n.text("Light", "Világos"))
                            themeButton(.dark, L10n.text("Dark", "Sötét"))
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityIdentifier("mainMenu")
                    .accessibilityLabel(L10n.text("More options", "További lehetőségek"))
                }
            }
            .modifier(PhoneSwipe(showTree: $showTree))
            .navigationDestination(for: String.self) { route in
                if route == "help" {
                    HelpScreen()
                } else {
                    AboutScreen()
                }
            }
        }
        .preferredColorScheme(theme.preferredScheme)
        .tint(CalcColor.title)
    }

    private func themeButton(_ choice: ThemeChoice, _ title: String) -> some View {
        Button {
            theme.mode = choice
        } label: {
            if theme.mode == choice {
                Label(title, systemImage: "checkmark")
            } else {
                Text(title)
            }
        }
    }
}

func shouldSwitchTree(width: CGFloat, height: CGFloat) -> Bool {
    abs(width) > 48 && abs(width) > abs(height) * 1.4
}

struct PhoneSwipe: ViewModifier {
    @Binding var showTree: Bool

    func body(content: Content) -> some View {
        content.gesture(
            DragGesture(minimumDistance: 48).onEnded { value in
                if shouldSwitchTree(width: value.translation.width, height: value.translation.height) {
                    showTree.toggle()
                }
            }
        )
    }
}
