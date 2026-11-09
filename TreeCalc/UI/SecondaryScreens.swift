import SwiftUI

struct HelpTopic: Identifiable {
    var id: String
    var title: String
    var body: String
}

struct HelpScreen: View {
    @State private var expanded = "swipe"
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                    AccordionCard(title: topic.title, index: index, expanded: expanded == topic.id) {
                        expanded = expanded == topic.id ? "" : topic.id
                    } content: {
                        branded(topic.body, ink: screenInk(scheme))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                (branded("TreeCalc", ink: screenInk(scheme)) + Text(" v\(appVersion)").foregroundStyle(screenInk(scheme)))
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                Text(L10n.text("László Kővári © 2005–2026", "Kővári László © 2005–2026"))
                    .font(.footnote)
                    .foregroundStyle(screenInk(scheme))
            }
            .padding(16)
        }
        .background { CalcBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TreeCalcMark(caption: L10n.text("Help", "Súgó"), captionColor: screenInk(scheme))
            }
        }
        .toolbarBackground(scheme == .dark ? CalcColor.screenDark : CalcColor.screen, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var appVersion: String {
        let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        if let value {
            return String(describing: value)
        }
        return "1.0.0"
    }

    private var topics: [HelpTopic] {
        [
            HelpTopic(
                id: "swipe",
                title: L10n.text("Switching screens", "Képernyők váltása"),
                body: L10n.text(
                    "The calculator and the expression tree live side by side. From either screen, swipe left or swipe right to show the other. It does not matter which screen you are on — a swipe in either direction always opens the other view.",
                    "A számológép és a kifejezésfa egymás mellett él. Bármelyik képernyőn állsz, balra vagy jobbra húzva a másik jelenik meg. Mindegy, merre húzol — mindig a másik nézet nyílik meg."
                )
            ),
            HelpTopic(
                id: "bases",
                title: L10n.text("Numerical systems", "Számrendszerek"),
                body: L10n.text(
                    "Choose base 2, 8, 10, or 16. The point works in every base, so a fraction stays exact when you switch. Letters A–F are available in hexadecimal only. Sine, cosine, tangent, logarithms, exp, factorial, and π stay in decimal.",
                    "Választhatsz 2-es, 8-as, 10-es vagy 16-os számrendszert. A tizedespont minden számrendszerben működik, ezért a tört váltáskor is pontos marad. Az A–F betűk csak hexadecimális módban érhetők el. A szinusz, koszinusz, tangens, a logaritmusok, az exp, a faktoriális és a π tízesben marad."
                )
            ),
            HelpTopic(
                id: "convert",
                title: L10n.text("Converting numerical systems", "Számrendszerek átváltása"),
                body: L10n.text(
                    "The 2, 8, 10, and 16 keys rewrite the number you are typing, the result, and the numbers already in the expression. Decimal 10 becomes A in hexadecimal and 1010 in binary. Decimal 0.5 becomes 0.8 in hexadecimal and 0.1 in binary. Decimal 0.1 becomes 0.1(9) in hexadecimal.",
                    "A 2, 8, 10 és 16 gomb átírja a beírt számot, az eredményt és a kifejezésben már szereplő számokat. A tízes 10 hexadecimálisan A, kettesben 1010. A 0,5 hexadecimálisan 0.8, kettesben 0.1. A tízes 0,1 hexadecimálisan 0.1(9)."
                )
            ),
            HelpTopic(
                id: "equals",
                title: L10n.text("Equals and the tree", "Egyenlő és a fa"),
                body: L10n.text(
                    "Press = to evaluate. Addition, subtraction, multiplication, division, and integer powers stay exact, so 1 ÷ 3 + 1 is 1.(3). Swipe to the expression tree to inspect postfix notation. Tap a postfix token to jump to that step, and expand or collapse nodes. Press Tst to fill in a nested sample, then press =.",
                    "Az = gomb kiértékeli a kifejezést. Az összeadás, kivonás, szorzás, osztás és az egész kitevős hatvány pontos marad, ezért 1 ÷ 3 + 1 eredménye 1.(3). Húzd el a képernyőt a kifejezésfához a postfix alakhoz. Koppints egy tokenre, hogy a megfelelő lépésre ugorj, és nyisd vagy csukd a csomópontokat. A Tst begépeli a mintakifejezést, utána nyomd meg az = gombot."
                )
            ),
            HelpTopic(
                id: "angle",
                title: L10n.text("Angle units", "Szögegység"),
                body: L10n.text(
                    "Sine, cosine, and tangent use degrees by default, so sin(90) is 1. Press Deg/Rad to switch to radians when you need sin(π/2). The current unit is shown next to the numerical system.",
                    "A szinusz, koszinusz és tangens alapból fokban számol, ezért a sin(90) értéke 1. A Fok/Rad gombbal válthatsz radiánra, ha sin(π/2) kell. Az aktuális egység a számrendszer mellett látszik."
                )
            ),
            HelpTopic(
                id: "repeating",
                title: L10n.text("Repeating decimals", "Szakaszos tizedesek"),
                body: L10n.text(
                    "When the simplified denominator has a factor other than the factors of the current base, the fraction repeats. The repeating block is written in parentheses: 1 ÷ 3 is 0.(3), 1 ÷ 6 is 0.1(6), and 1 ÷ 7 is 0.(142857). If that block does not fit in 12 digits, the display shows a rounded value without parentheses.",
                    "Ha az egyszerűsített nevezőnek van olyan tényezője, amely nem tényezője az aktuális számrendszernek, a tört szakaszos. A szakasz zárójelben áll: 1 ÷ 3 értéke 0.(3), 1 ÷ 6 értéke 0.1(6), 1 ÷ 7 értéke 0.(142857). Ha a szakasz nem fér ki 12 jegybe, a kijelző kerekített értéket mutat, zárójel nélkül."
                )
            ),
            HelpTopic(
                id: "playback",
                title: L10n.text("Expression tree playback", "Kifejezésfa lejátszás"),
                body: L10n.text(
                    "This screen plays back one evaluated expression. The same step is shown in four places, so you can see what the calculator is doing.\n\nFrom top to bottom:\n\nThe expression line is the full infix formula, in small type. It wraps onto the next line when it does not fit, including the part that scrolling hides on the calculator. The current step is highlighted there: a number on its own, or an operation together with its operands and the parentheses that belong to it.\n\nStep by step is the switch under that line. It only chooses how Play advances. It does not calculate a new result. Turning it on during a walk pauses at the current step. Turning it off does not start playback by itself.\n\nPostfix notation is the tokens in evaluation order. For 9 + 7 × 6 the chips are 9, 7, 6, ×, and +. The highlighted chip is the current step.\n\nOperations is one row per step, written as a short sentence. The current row is highlighted. Tap a row to go to that step.\n\nThe expression tree draws those steps as nested nodes. The current node and the nodes under it are highlighted. Tap + or − on a node to open or close it. Selecting a step opens the ancestors so that node stays in view.\n\nWith Step by step off, Play is a continuous walk. It starts at the first token, or continues from the token already selected. The current step is shown at once. About every 0.7 seconds the highlight moves to the next token, and the button reads Pause. Pause holds the step you are on. Play then keeps that step briefly and moves on. After the last token the walk stops. The next Play starts again at the first token.\n\nWith Step by step on, playback moves one step at a time. Play shows the first step and the button becomes Next. Each Next moves one step and then stops. On the last step Next stays there and does not wrap around. Stop appears only while a step is selected. Stop clears every highlight, and the button returns to Play.\n\nIf Reduce Motion is on, the switch is held on and cannot be turned off, so playback stays one step at a time.\n\nTap a postfix chip or an operation row to jump there and stop a running walk. Tap the same chip again to clear the selection. A new = starts a fresh expression and clears the walk.",
                    "Ez a képernyő egy már kiértékelt kifejezést játszik vissza. Ugyanaz a lépés négy helyen látszik, ezért követhető, mit csinál a számológép.\n\nFentről lefelé:\n\nA kifejezéssor a teljes infix képlet, kis betűkkel. Ha nem fér el, a következő sorban folytatódik, a számológép görgetése miatt rejtett résszel együtt. Az aktuális lépés itt ki van emelve: egy szám önmagában, vagy egy művelet az operandusaival és a hozzá tartozó zárójelekkel.\n\nA Lépésenként a sor alatti kapcsoló. Csak azt választja meg, hogyan halad a Lejátszás. Új eredményt nem számol. Ha menet közben bekapcsolod, az aktuális lépésnél megáll. Kikapcsolása magától nem indítja el a lejátszást.\n\nA Postfix jelölés a tokenek a kiértékelés sorrendjében. A 9 + 7 × 6 chipek: 9, 7, 6, × és +. A kiemelt chip az aktuális lépés.\n\nA Műveletsor minden lépéshez egy rövid mondatot ír. Az aktuális sor ki van emelve. Koppintásra oda ugrik a lejátszás.\n\nA kifejezésfa ugyanezeket a lépéseket egymásba ágyazott csomópontokként rajzolja. Az aktuális csomópont és az alatta lévők kiemelve vannak. A csomóponton a + vagy a − nyitja és csukja az ágat. A kiválasztott lépés kinyitja a fölötte lévő csomópontokat, hogy a lépés látható maradjon.\n\nKikapcsolt Lépésenként mellett a Lejátszás folyamatos. Az első tokennél indul, vagy a már kiválasztott tokentől megy tovább. Az aktuális lépés azonnal látszik. Körülbelül 0,7 másodpercenként a kiemelés a következő tokenre lép, a gomb felirata pedig Szünet. A Szünet megtartja azt a lépést, ahol éppen tartasz. A Lejátszás ezután röviden még ott marad, majd továbbmegy. Az utolsó token után a séta megáll. A következő Lejátszás újra az első tokennél indul.\n\nBekapcsolt Lépésenként mellett a lejátszás egyszerre egy lépést megy. A Lejátszás az első lépést mutatja, és a gomb Következőre vált. Minden Következő egy lépést halad, majd megáll. Az utolsó lépésen a Következő ott marad, és nem ugrik vissza az elejére. A Megállítás csak akkor látszik, ha van kiválasztott lépés. A Megállítás minden kiemelést töröl, és a gomb újra Lejátszás lesz.\n\nHa a Mozgás csökkentése be van kapcsolva, a kapcsoló bekapcsolva marad, és nem kapcsolható ki, ezért a lejátszás lépésenkénti marad.\n\nPostfix chipre vagy műveletsorra koppintva oda ugrik a bemutató, és a futó séta megáll. Ugyanarra a chipre újra koppintva a kijelölés törlődik. Az új = friss kifejezést kezd, és törli a sétát."
                )
            ),
            HelpTopic(
                id: "infix",
                title: L10n.text("Infix to Postfix", "Infixből postfix"),
                body: L10n.text(
                    "Pressing = closes the number you are still typing, then walks the token list from left to right. The converter does not split the display text again. It reads the tokens the keypad already built.\n\nA number keeps the text you typed, such as 9, 1.33, A, or π. An operator carries its precedence, how many operands it takes, and whether it associates left or right. A left parenthesis and a right parenthesis are only markers for grouping.\n\nDigits stay in a buffer until an operator, a parenthesis, π, or =. A leading minus is not a negative number: it becomes the unary neg operator followed by a positive number. On screen neg is − and binary subtraction is -. Square root, square, cube, factorial, reciprocal, sin, cos, tan, ln, log, exp, and not are written after their operand, so 9 √ is already the tokens 9, √. A binary operator at the very start inserts a 0 in front, except a prefix minus. Two binary operators in a row: the new one replaces the previous one.\n\nConversion uses two lists. The output only grows, and its order is the postfix. The operator stack holds operators that are still waiting, plus left parentheses. The top of the stack is the operator added last.\n\nA number goes straight to the output. An operator first moves waiting operators to the output while they should be written out, then goes onto the stack itself. A left parenthesis is a wall on the stack: operators above it stay inside the group. A right parenthesis writes those operators out until the matching left parenthesis, then throws both parentheses away. At the end of the list, whatever remains on the stack is written top first. A missing parenthesis is an error, and no tree is built. Parentheses never appear in the postfix.\n\nWhether the top operator is written out depends on the operator that just arrived. For a left-associative operator, which is almost every one, the top is written while its precedence is greater than or equal to the new one. For a right-associative operator, ^ and neg, the top is written only while its precedence is strictly greater. That is why 9 − 3 − 1 is (9 − 3) − 1, and 2 ^ 3 ^ 2 is 2 ^ (3 ^ 2), which is 512 rather than 64.\n\nA higher precedence binds tighter and is written earlier, so it sits deeper in the tree. The levels are: 99 for ^, neg, √, 1/, square, cube, and factorial; 14 for not; 12 for ×, ÷, mod, lsh, and for sin, cos, tan, ln, log, and exp; 11 for + and binary minus; 7 for and; 6 for xor; 5 for or. Among the 99s, ^ and neg associate right, while √, 1/, square, cube, and factorial associate left.\n\n9 + 7 × 6 becomes 9, 7, 6, ×, +. Multiplication is 12 and addition is 11, so × is written before +. (1 + 2) × 3 becomes 1, 2, +, 3, ×, because the parenthesis wall writes + out before × is even seen. 2 ^ 3 ^ 2 becomes 2, 3, 2, ^, ^. −5 ^ 2 becomes 5, 2, ^, −, which is −(5 ^ 2). 1 or 2 and 3 becomes 1, 2, 3, and, or, which is 1 or (2 and 3).\n\nThe tree is built only from this postfix list. A number is pushed. A unary operator takes the top node. A binary operator takes the right operand first, then the left, and pushes the combined node. The screen shows the same list as postfix chips and as the comma-separated postfix line.",
                    "Az = lezárja a még gépelt számot, majd balról jobbra végigmegy a tokenlistán. A konverter nem vágja fel újra a kijelző szövegét. Azt a tokenlistát olvassa, amelyet a billentyűzet már összeállított.\n\nA szám a begépelt szöveget őrzi, például 9, 1.33, A vagy π. Az operátor hordozza a precedenciáját, az operandusai számát, és hogy balra vagy jobbra köt-e. A bal és a jobb zárójel csak a csoportosítás jelzője.\n\nA számjegyek pufferben maradnak, amíg operátor, zárójel, π vagy = nem jön. A vezető mínusz nem negatív szám: unáris neg operátor lesz, utána egy pozitív szám. A képernyőn a neg jele −, a bináris kivonás jele -. A négyzetgyök, a négyzet, a köb, a faktoriális, a reciprok, a sin, a cos, a tan, az ln, a log, az exp és a not az operandusa után áll, ezért a 9 √ tokenjei már 9, √. A kifejezés elején a bináris operátor elé egy 0 kerül, a prefix mínusz kivételével. Két bináris operátor egymás után: az új felülírja az előzőt.\n\nA konverzió két listát használ. A kimenet csak növekszik, és a sorrendje a postfix. Az operátorverem a még várakozó operátorokat és a bal zárójeleket tartja. A verem teteje a legutóbb felrakott operátor.\n\nA szám azonnal a kimenetre kerül. Az operátor előbb a kimenetre írja azokat a várakozó operátorokat, amelyeket ki kell írni, majd maga is a veremre kerül. A bal zárójel fal a vermen: a fölé tett operátorok a csoporton belül maradnak. A jobb zárójel kiírja ezeket az operátorokat a párjáig, majd mindkét zárójelet eldobja. A lista végén, ami a vermen maradt, tetővel előre kiíródik. A hiányzó zárójel hiba, és fa nem készül. A zárójel a postfixben sosem jelenik meg.\n\nAz, hogy a tető kikerül-e, a most érkező operátortól függ. Balasszociatív operátornál, és majdnem mindegyik ilyen, a tető addig íródik ki, amíg a precedenciája nagyobb vagy egyenlő az újénál. Jobbasszociatív operátornál, a ^ és a neg ilyen, a tető csak akkor íródik ki, ha a precedenciája szigorúan nagyobb. Ezért a 9 − 3 − 1 alakja (9 − 3) − 1, a 2 ^ 3 ^ 2 pedig 2 ^ (3 ^ 2), ami 512, nem 64.\n\nA nagyobb precedencia szorosabban köt, és hamarabb íródik ki, ezért a fában mélyebbre kerül. A szintek: 99 a ^, a neg, a √, az 1/, a négyzet, a köb és a faktoriális; 14 a not; 12 a ×, a ÷, a mod, az lsh, valamint a sin, a cos, a tan, az ln, a log és az exp; 11 a + és a bináris mínusz; 7 az and; 6 a xor; 5 az or. A 99-esek közül a ^ és a neg jobbra köt, a √, az 1/, a négyzet, a köb és a faktoriális balra.\n\nA 9 + 7 × 6 postfixe 9, 7, 6, ×, +. A szorzás 12, az összeadás 11, ezért a × a + előtt íródik ki. Az (1 + 2) × 3 postfixe 1, 2, +, 3, ×, mert a zárójelfal a + jelet még a × érkezése előtt kiírja. A 2 ^ 3 ^ 2 postfixe 2, 3, 2, ^, ^. A −5 ^ 2 postfixe 5, 2, ^, −, vagyis −(5 ^ 2). Az 1 or 2 and 3 postfixe 1, 2, 3, and, or, vagyis 1 or (2 and 3).\n\nA fa csak ebből a postfix listából épül. A szám a veremre kerül. Az unáris operátor a tető csomópontot veszi le. A bináris operátor előbb a jobb operandust, utána a balt, és az összevont csomópontot teszi vissza. A képernyő ugyanezt a listát mutatja postfix chipekként és vesszővel tagolt postfix sorként."
                )
            )
        ]
    }
}

struct AboutScreen: View {
    @State private var expanded = "app"
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                card(L10n.text("What TreeCalc does", "Mit csinál a TreeCalc"), id: "app") {
                    branded(L10n.text(
                        "TreeCalc is a calculator that turns a typed infix expression into postfix (Reverse Polish) notation and an expression tree, then evaluates that tree.",
                        "A TreeCalc számológép a begépelt infix kifejezést postfix (fordított lengyel) jelöléssé és kifejezésfává alakítja, majd a fát kiértékeli."
                    ), ink: screenInk(scheme))
                }
                card(L10n.text("Why the tree", "Miért a fa"), id: "goal") {
                    branded(L10n.text(
                        "The goal is to display the expression tree for demonstration purposes — so you can see how operators nest, not only the final number.",
                        "A cél a kifejezésfa megjelenítése bemutatás céljából — hogy látható legyen, hogyan ágyazódnak egymásba a műveletek, ne csak a végeredmény."
                    ), ink: screenInk(scheme))
                }
                card(L10n.text("Original desktop repository", "Eredeti asztali tároló"), id: "desktop") {
                    VStack(alignment: .leading, spacing: 8) {
                        branded(L10n.text(
                            "The original desktop implementation, which I created for my sons in 2005, can be found in the repository below.",
                            "Az eredeti asztali megvalósítás, amelyet 2005-ben a fiaimnak készítettem, az alábbi tárolóban található."
                        ), ink: screenInk(scheme))
                        Link(AppLinks.originalDesktop.absoluteString, destination: AppLinks.originalDesktop)
                            .foregroundStyle(CalcColor.magenta)
                    }
                }
                card(L10n.text("Original iOS calculator", "Eredeti iOS számológép"), id: "ios") {
                    VStack(alignment: .leading, spacing: 8) {
                        branded(L10n.text(
                            "The earlier iOS calculator, written before the AI era.",
                            "A korábbi iOS számológép, az AI-korszak előtt."
                        ), ink: screenInk(scheme))
                        Link(AppLinks.originalIOS.absoluteString, destination: AppLinks.originalIOS)
                            .foregroundStyle(CalcColor.magenta)
                            .accessibilityIdentifier("about.originalIOS")
                    }
                }
                card(L10n.text("Privacy policy", "Adatvédelmi tájékoztató"), id: "privacy") {
                    Link(L10n.text("Privacy policy", "Adatvédelmi tájékoztató"), destination: AppLinks.privacyPolicy)
                        .foregroundStyle(CalcColor.magenta)
                }
                card(L10n.text("Support", "Támogatás"), id: "mail") {
                    Link("laszlo.kovary@gmail.com", destination: AppLinks.supportMail)
                        .foregroundStyle(CalcColor.magenta)
                }
                card(L10n.text("Copyright", "Szerzői jog"), id: "copyright") {
                    Text("László Kővári © 2005–2026")
                        .foregroundStyle(screenInk(scheme))
                        .accessibilityIdentifier("about.author")
                }
            }
            .padding(16)
        }
        .background { CalcBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TreeCalcMark(caption: L10n.text("About", "Névjegy"), captionColor: screenInk(scheme))
            }
        }
        .toolbarBackground(scheme == .dark ? CalcColor.screenDark : CalcColor.screen, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func card<Content: View>(_ title: String, id: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        let index = ["app", "goal", "desktop", "ios", "privacy", "mail", "copyright"].firstIndex(of: id) ?? 0
        return AccordionCard(title: title, index: index, expanded: expanded == id) {
            expanded = expanded == id ? "" : id
        } content: {
            content()
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AccordionCard<Content: View>: View {
    var title: String
    var index: Int
    var expanded: Bool
    var onToggle: () -> Void
    @ViewBuilder var content: () -> Content
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onToggle) {
                HStack {
                    branded(title, ink: screenInk(scheme))
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(CalcColor.magenta)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("topic.\(title)")
            if expanded {
                content()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(CalcColor.border.opacity(scheme == .dark ? 0.55 : 0.85), lineWidth: 1)
        }
    }

    private var cardFill: Color {
        if scheme == .dark {
            return index % 2 == 0
                ? Color(hue: 0.62, saturation: 0.22, brightness: 0.30)
                : Color(hue: 0.60, saturation: 0.16, brightness: 0.24)
        }
        return index % 2 == 0
            ? Color.white.opacity(0.9)
            : Color(hue: 0.60, saturation: 0.08, brightness: 1)
    }
}
