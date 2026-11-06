# TreeCalc

TreeCalc is a calculator that shows the expression tree behind the result. Version 1.0.0. Author: László Kővári.

The keys, operator precedence, errors, integer bases, memory, angle mode, and the `Tst` sample follow the original calculator. This app adds a glossy keypad, repeating-decimal display, an iPad split layout, and postfix playback.

## Build

Open `TreeCalc.xcodeproj` in Xcode 16 or later and run the `TreeCalc` scheme. The deployment target is iOS 17. There are no third-party packages.

```
xcodebuild -project TreeCalc.xcodeproj -scheme TreeCalc -destination 'platform=iOS Simulator,name=iPhone 17' test
```

`TreeCalcTests` covers the engine cases plus `1/8`, `1/6`, `1/7`, and one postfix playback step. `TreeCalcUITests` checks `2+2=4`, opening a Help topic, and the original iOS link on About.

Bundle id: `com.lkovari.mobile.apps.treecalc`. Marketing version `1.0.0`, build `1`.

## Architecture

```
keypad → CalculatorModel → CalculatorEngine
                              ├─ ExpressionTree → display and tree screen
                              └─ Fraction classifier → decimal display
tree screen → postfix playback
```

- `TreeCalc/Engine` is pure Swift. Evaluation uses `Double`, integer bases, and 12-digit half-up decimal text.
- A parallel fraction is kept only when the tree is rational: numbers, `+ − × ÷`, an integer power, sign, and parentheses. `classify` then chooses the display.
- `TreeCalc/UI` is SwiftUI. `CalculatorModel` is `@Observable` and `@MainActor`.
- English and Hungarian follow the device language. There is no in-app language picker. The decimal separator is always `.`.
- Theme Auto, Light, and Dark is stored in `UserDefaults`. Auto follows the system.

## Behavior

- Addition, subtraction, multiplication, division, and integer powers keep an exact fraction. `1 ÷ 3 + 1` stays `1.(3)`. Roots, trigonometry, logarithms, and factorial stay on `Double`.
- Repeating rationals that fit the display are written with the period in parentheses: `0.(3)`, `0.1(6)`, `0.08(3)`, `0.(142857)`. The non-repeating part plus the period must be at most 12 digits. A longer period or an irrational operation keeps the 12-digit string. The same parentheses are used in base 2, 8, and 16.
- Every base has a radix point. One hexadecimal place is a sixteenth, so decimal `0.5` is hexadecimal `0.8`. Pressing 2, 8, 10, or 16 rewrites the number being typed, the current result, and the numbers already in the expression. `=` is not required first.
- After `=`, the next operator continues from that exact fraction when one exists. Memory of those results stays exact too. Bitwise operations still use the `Double` value.
- iPhone is portrait only. A horizontal drag longer than 48 pt and longer than 1.4 times the vertical movement switches between the calculator and the tree. iPad regular width and height show both at once, with no swipe.
- Keys are glossy, following `buttonAddGradientEffect` in Calculator-ios. Corners are 8 pt. The border is 1.5 pt in hue 0.611, saturation 0.327, brightness 0.394. In light mode the fill runs from the key color at the top to 25% of that brightness at the bottom: the 2012 call `colorStartColorForGradientColor:percent:75 flavour:NO` subtracts 75% of the brightness. There is no extra inner stroke. The shadow is gray, offset 3 pt down and to the right, with a 3 pt blur, the same as the 2012 layer. Dark mode keeps a shallower shine, down to 78% brightness, because those fills already read as raised. Pressing darkens the key. Operator and equals labels are dark on the light gray keys so they stay readable.
- Parentheses share the green function color. Bitwise keys and the base switcher are a separate blue group, because the 2012 app did not have them. The selected base has a stronger border.
- Postfix playback walks the existing tokens and highlights the same branch as a tap. It does not evaluate again. With Reduce Motion, Play advances one step per tap. Otherwise each step waits 700 ms.
- There is no paper-tape history and no live tree while typing.

## Old iOS drawing bugs that are not carried over

The 2012 Objective-C calculator is only a visual reference.

- `buttonAddGradientEffect` inserted the gradient twice. Each key gets one shine.
- The pressed title was forced to blue. The pressed state only darkens the fill.
- `ColorUtils` divided brightness by 255 twice, which washed the colors out. Hue, saturation, and brightness are applied once.

## App Store notes

The app asks for no permissions. `ITSAppUsesNonExemptEncryption` is false. `PrivacyInfo.xcprivacy` reports no tracking. `UserDefaults` is declared with reason `CA92.1` because the theme is stored there. There is no account, advertising, camera, location, or background mode. The iOS privacy policy is `https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html` (source: `docs/treecalc-ios-privacy-policy.html`). About also links the original desktop repository and the original iOS calculator page.

Screenshots should be taken from this build on iPhone and iPad. The expression tree, the number bases, and postfix playback are the parts that are specific to TreeCalc.

## License

MIT. Copyright (c) 2005 - 2026 László Kővári.
