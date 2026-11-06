# Changelog

All times are local (UTC+1).

## [1.0.0] — 2026-11-06

### 2026-11-06 20:57

First iOS build. SwiftUI calculator, version 1.0.0, author László Kővári.

- Glossy keypad in the shape of the original iOS calculator. The flat blue keypad is not used.
- Expression tree and postfix playback. Play walks the existing tokens and highlights the matching branch. Reduce Motion advances one step per tap. There is no paper tape and no live tree while typing.
- Repeating decimals use parentheses, for example `0.(3)` and `0.1(6)`.
- English and Hungarian follow the device language.
- Help and About open as accordions. About links the original desktop repository, the original iOS calculator page, the privacy policy, and support mail.
- iPhone is portrait only and switches screens with a horizontal swipe. iPad regular size shows the calculator and the tree together.
- No permissions, no tracking, no account. Theme is the only `UserDefaults` value, reason `CA92.1`. `ITSAppUsesNonExemptEncryption` is false.
- The 2012 drawing bugs stay out: one gradient per key, no blue pressed title, hue and saturation applied once.

### 2026-11-06 21:44

- Postfix numbers are dark blue on a warm cream chip. Operators are dark burgundy on mint. The current step is peach.
- The app icon is an expression tree: operators in the nodes, numbers in the leaves.
- Help and About use pastel cards instead of black text on white.
- The expression field keeps a fixed height and scrolls sideways, so the Tst sample no longer pushes the keypad down.
- Digit keys and function keys share the same column width.
- Playback scrolls the highlighted tree node and the highlighted postfix token into view.
- Help describes repeating and infinite decimals, with examples (`1 ÷ 3 = 0.(3)`, `1 ÷ 6 = 0.1(6)`, `1 ÷ 7 = 0.(142857)`, `1 ÷ 8 = 0.125`) and the Tst sample.
- Addition, subtraction, multiplication, division, and integer powers stay exact fractions. `1 ÷ 3 + 1` is `1.(3)`.
- Pressing 2, 8, 10, or 16 rewrites the number being typed, the current result, and every number already in the expression. A radix point works in every base: decimal `0.5` is hexadecimal `0.8` and binary `0.1`.
- Help explains what a number base is and how conversion works.

### 2026-11-06 22:09

- The Help footer copyright is `László Kővári © 2005–2026`, the same line as About.
- The word TreeCalc is T-Mobile magenta `#E20074` on every screen.
- Help and About use a quieter card palette.
- The launch image and the app icon show operator nodes and number leaves.
- Dec/Deg, “Postfix notation”, and “Expression tree” stay readable in dark mode.
- The expression tree has a leading back button, the same `<` as Help and About. The swipe still works. The iPad split has no back button.
- Key columns stay equal and scale with the device. The keypad sits on the bottom edge.

### 2026-11-06 22:36

- Help and About follow the calculator theme in light and dark. Body text uses the screen ink of the current scheme.
- The launch image and the app icon put the root at the top. The branches point downward, and the number leaves sit at the bottom.
- The iOS privacy policy is English and Hungarian, titled “TreeCalc iOS version”. The source is `docs/treecalc-ios-privacy-policy.html`. About opens `https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html`.
- `docs/images/icon` holds the 1024×1024 App Store icon with no alpha channel.
- `docs/images/splash` holds the launch image at iPhone 6.9" size, 1320×2868.
- `docs/images/screenshots` holds the calculator and the expression tree, framed for the App Store at 1320×2868.
- `docs/images/feature-graphics` holds a montage of the calculator, the tree, and the main features, plus a 1024×500 graphic.

### 2026-11-06 22:48

- `docs/images/screenshots` also holds the Help and About screens, framed at 1320×2868.

### 2026-11-06 23:00

- Light-mode keys are redrawn. The fill follows the 2012 gradient, from the key color down to a quarter of its brightness. Dark mode keeps the shallower shine.

### 2026-11-06 23:06

- The inner left and top stroke is removed. It read as a hard stripe. The raised look is only the vertical gradient and the 3 pt shadow, as in the 2012 buttons.

### 2026-11-06 23:10

- `docs/images/screenshots/iphone-6.9-calculator.png` uses the light-mode calculator with the glossy keys.

### 2026-11-06 23:13

- The launch image is 320 pt wide, so the leaf 2 and the leaf 3 stay inside the phone. The splash picture in `docs/images/splash` uses the same inset.

### 2026-11-06 23:19

- The launch screen is `LaunchScreen.storyboard`. TreeCalc is a label at the top in `#E20074`. The tree image is at most 72% of the screen width and at least 36 pt from each side, so leaf 2 and leaf 3 stay on screen. The previous empty launch happened because the picture was stored under the name SplashMark while the screen looked for LaunchMark.

### 2026-11-06 23:35

- `docs/images/screenshots/iphone-6.9-splash.png` is the launch screen, framed at 1320×2868.
