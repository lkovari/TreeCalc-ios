import SwiftUI

enum L10n {
    static var hungarian: Bool {
        Bundle.main.preferredLocalizations.first?.hasPrefix("hu") == true
    }

    static func text(_ en: String, _ hu: String) -> String {
        hungarian ? hu : en
    }
}

enum AppLinks {
    static let privacyPolicy = URL(string: "https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html")!
    static let originalDesktop = URL(string: "https://github.com/lkovari/Calculator")!
    static let originalIOS = URL(string: "https://lkovari.github.io/KLHome/#/ios-page/ios-page-content2")!
    static let supportMail = URL(string: "mailto:laszlo.kovary@gmail.com")!
}

enum ThemeChoice: String {
    case auto
    case light
    case dark
}

@MainActor
@Observable
final class ThemeStore {
    var mode: ThemeChoice {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: "themeMode")
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: "themeMode") ?? ThemeChoice.auto.rawValue
        mode = ThemeChoice(rawValue: stored) ?? .auto
    }

    var preferredScheme: ColorScheme? {
        switch mode {
        case .auto: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@MainActor
@Observable
final class CalculatorModel {
    private let engine = CalculatorEngine()
    private(set) var state: EvaluationResult

    init() {
        state = engine.snapshot()
    }

    func press(_ key: CalculatorKey) {
        engine.press(key)
        state = engine.snapshot()
    }

    func setBase(_ base: NumericBase) {
        engine.setBase(base)
        state = engine.snapshot()
    }
}

enum CalcColor {
    static let screen = Color(hue: 0.621, saturation: 0.154, brightness: 1)
    static let screenDark = Color(hue: 0.621, saturation: 0.28, brightness: 0.22)
    static let displayFill = Color(hue: 0.594, saturation: 0.122, brightness: 1)
    static let displayInk = Color(hue: 0.594, saturation: 0.45, brightness: 0.38)
    static let expressionFill = Color(hue: 0.301, saturation: 0.144, brightness: 1)
    static let expressionInk = Color(hue: 0.301, saturation: 0.45, brightness: 0.32)
    static let border = Color(hue: 0.611, saturation: 0.327, brightness: 0.394)
    static let magenta = Color(red: 0xE2 / 255, green: 0x00 / 255, blue: 0x74 / 255)
    static let title = magenta
    static let memory = Color.blue
    static let error = Color.red
    static let badge = Color(hue: 0.56, saturation: 0.35, brightness: 0.92)
    static let rootBadge = Color(hue: 0.35, saturation: 0.35, brightness: 0.88)
    static let operand = Color(hue: 0.62, saturation: 0.72, brightness: 0.22)
}

enum KeyVisual {
    case number
    case function
    case logic
    case operatorKey
    case equals
    case action
}

struct KeyPaint {
    var hue: Double
    var saturation: Double
    var brightness: Double
    var lightLabel: Bool

    func fill(scheme: ColorScheme, depth: Double) -> Color {
        let dark = scheme == .dark ? 0.62 : 1.0
        return Color(hue: hue, saturation: saturation, brightness: min(1, max(0, brightness * dark * depth)))
    }

    func label(scheme: ColorScheme) -> Color {
        if scheme == .dark || lightLabel {
            return Color(hue: 0.273, saturation: 0.001, brightness: 1)
        }
        return Color(hue: 0.003, saturation: 0.02, brightness: 0.16)
    }

    static func paint(_ visual: KeyVisual) -> KeyPaint {
        switch visual {
        case .number:
            return KeyPaint(hue: 0.003, saturation: 0.010, brightness: 0.318, lightLabel: true)
        case .function:
            return KeyPaint(hue: 0.447, saturation: 0.50, brightness: 0.90, lightLabel: true)
        case .logic:
            return KeyPaint(hue: 0.591, saturation: 0.50, brightness: 0.90, lightLabel: true)
        case .operatorKey, .equals:
            return KeyPaint(hue: 0.273, saturation: 0.001, brightness: 0.90, lightLabel: false)
        case .action:
            return KeyPaint(hue: 0.003, saturation: 0.50, brightness: 0.90, lightLabel: true)
        }
    }
}

struct CalcBackground: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        (scheme == .dark ? CalcColor.screenDark : CalcColor.screen)
            .ignoresSafeArea()
    }
}

enum Pastel {
    static let ink = Color(red: 0.23, green: 0.24, blue: 0.26)
    static let link = Color(red: 0.45, green: 0.18, blue: 0.32)
    static let nav = Color(red: 0.94, green: 0.93, blue: 0.91)
    static let page = Color(red: 0.93, green: 0.92, blue: 0.90)

    static func card(_ index: Int) -> Color {
        index % 2 == 0
            ? Color(red: 0.98, green: 0.97, blue: 0.96)
            : Color(red: 0.95, green: 0.94, blue: 0.92)
    }
}

struct PastelBackdrop: View {
    var body: some View {
        Pastel.page
    }
}

struct TreeCalcMark: View {
    var caption: String = ""
    var captionColor: Color = Pastel.ink

    var body: some View {
        VStack(spacing: 0) {
            Text("TreeCalc")
                .font(.headline.weight(.bold))
                .foregroundStyle(CalcColor.magenta)
            if !caption.isEmpty {
                Text(caption)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(captionColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

func branded(_ text: String, ink: Color = Pastel.ink) -> Text {
    let parts = text.components(separatedBy: "TreeCalc")
    var line = Text(parts[0]).foregroundStyle(ink)
    for part in parts.dropFirst() {
        line = line + Text("TreeCalc").foregroundStyle(CalcColor.magenta) + Text(part).foregroundStyle(ink)
    }
    return line
}

func screenInk(_ scheme: ColorScheme) -> Color {
    if scheme == .dark {
        return Color(hue: 0.58, saturation: 0.04, brightness: 0.96)
    }
    return CalcColor.displayInk
}

func resultFontSize(length: Int, width: CGFloat) -> CGFloat {
    var size: CGFloat = 48
    if length > 12 {
        size = 26
    } else if length > 9 {
        size = 36
    }
    if width < 340 {
        size = min(size, 30)
    } else if width < 460 {
        size = min(size, 40)
    }
    return size
}
