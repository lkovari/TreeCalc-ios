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
                Text("László Kővári © 2005–2026")
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
                    "The calculator and the expression tree live side by side. The tree button at the top left of the calculator opens the expression tree, and the < button on the tree returns. Swiping left or right also switches between them, but scrolling the tree can take the swipe.\n\nTouch and hold the result to copy it. Very large and very small results use scientific notation, for example 1e20.",
                    "A számológép és a kifejezésfa egymás mellett él. A számológép bal felső fa gombja megnyitja a kifejezésfát, a fán a < gomb visszavisz. Balra vagy jobbra húzva is lehet váltani, de a fa görgetése elviheti a húzást.\n\nAz eredményt hosszan nyomva kimásolhatod. A nagyon nagy és nagyon kicsi eredmény tudományos alakban jelenik meg, például 1e20."
                )
            ),
            HelpTopic(
                id: "bases",
                title: L10n.text("Numerical systems", "Számrendszerek"),
                body: L10n.text(
                    "A numerical system says how many digits exist and how much one place is worth compared with the place on its right. In base 10 the digits are 0–9, and each step to the left is worth ten times more. In base 2 the only digits are 0 and 1, and each step is worth twice as much: 1010 in binary is 8+2, which is 10 in decimal. Base 8 uses 0–7. Base 16 uses 0–9 and A–F, where A is 10 and F is 15. Those letters can be pressed only in hexadecimal. Sine, logarithms, and π stay in decimal, because they are not digits of another base. The dot works in every base: the first hexadecimal place is sixteenths, the first octal place is eighths, and the first binary place is halves.",
                    "A számrendszer megmondja, hány számjegy van, és hogy egy helyiérték hányszorosa a tőle jobbra állónak. Tízesben a számjegyek 0–9, és minden lépés balra tízszeres. Kettesben csak 0 és 1 van, minden lépés kétszeres: az 1010 kettesben 8+2, vagyis tízesben 10. Nyolcasban a számjegyek 0–7. Tizenhatosban 0–9 és A–F, ahol A a 10 és F a 15. Ezek a betűk csak tizenhatos módban nyomhatók. A szinusz, a logaritmus és a π tízesben marad, mert nem egy másik számrendszer számjegyei. A tizedespont minden számrendszerben működik: az első tizenhatos jegy tizenhatod, az első nyolcas jegy nyolcad, az első kettes jegy fél."
                )
            ),
            HelpTopic(
                id: "convert",
                title: L10n.text("Converting numerical systems", "Számrendszerek átváltása"),
                body: L10n.text(
                    "Press 2, 8, 10, or 16 and the number you are typing is rewritten immediately. You do not have to press = first. The same happens to a finished result and to every number already in the expression. Decimal 10 becomes A in hexadecimal and 1010 in binary. Fractions move too. One hexadecimal place is one sixteenth, so decimal 0.5 is hexadecimal 0.8, because 8/16 = 1/2. Decimal 0.5 is binary 0.1, because that single place is one half. If the fraction does not end in the new base, parentheses mark the repeating block. Decimal 0.1 is hexadecimal 0.1(9), because 1/10 = 0.1999… in base 16. Switching back restores the same value.",
                    "A 2, 8, 10 vagy 16 gomb azonnal átírja a beírt számot. Előtte nem kell = jelet nyomni. Ugyanez történik a kész eredménnyel és a kifejezésben már bent lévő számokkal. A tízes 10 tizenhatosban A, kettesben 1010. A törtrész is átmegy. Egy tizenhatos törtjegy egy tizenhatod, ezért a tízes 0.5 tizenhatosban 0.8, mert 8/16 = 1/2. A tízes 0.5 kettesben 0.1, mert az az egy jegy éppen egy fél. Ha a tört az új számrendszerben nem ér véget, zárójel jelöli az ismétlődő szakaszt. A tízes 0.1 tizenhatosban 0.1(9), mert 1/10 = 0,1999… a 16-osban. Visszaváltáskor ugyanaz az érték jelenik meg."
                )
            ),
            HelpTopic(
                id: "equals",
                title: L10n.text("Equals and Tst", "Egyenlő és a Tst"),
                body: L10n.text(
                    "Press = to evaluate. Addition, subtraction, multiplication, division, and integer powers stay exact fractions, so 1 ÷ 3 + 1 is 4/3, shown as 1.(3), not a rounded binary approximation. The result appears on the calculator. Open the expression tree to inspect the postfix form. Tap a postfix token to jump to that step, and expand or collapse nodes.\n\nTst clears the current entry, switches to decimal, and types this sample as if you had pressed every key:\n888/(6×1.25+3×(7−4×1.5+(9÷3−1.2))×2)−11×(4.5÷2^3)÷(5−1.25)\nIt is a nested expression with parentheses, a power, multiplication, and division. Nothing is calculated until you press =. The tree and the postfix notation then show the structure of that sample. Press = again on a fresh calculator after Tst whenever you want to see how a long expression is parsed.",
                    "Az = gomb kiszámolja a kifejezést. Az összeadás, a kivonás, a szorzás, az osztás és az egész kitevő pontos tört marad, ezért az 1 ÷ 3 + 1 értéke 4/3, kijelzésben 1.(3), nem pedig kerekített kettes törtközelítés. Az eredmény a számológépen jelenik meg. Nyisd meg a kifejezésfát a postfix alakhoz. Egy postfix tokenre koppintva oda ugrasz, a csomópontokat ki lehet nyitni és be lehet csukni.\n\nA Tst törli az aktuális beírást, tízes számrendszerre vált, és ezt a mintát gépeli be, mintha minden billentyűt te nyomtál volna le:\n888/(6×1.25+3×(7−4×1.5+(9÷3−1.2))×2)−11×(4.5÷2^3)÷(5−1.25)\nEgymásba ágyazott zárójeles kifejezés, hatvánnyal, szorzással és osztással. Addig nem számol, amíg meg nem nyomod az = gombot. A fa és a postfix jelölés ezután ennek a mintának a szerkezetét mutatja. Ha hosszú kifejezés feldolgozását szeretnéd látni, nyomd meg a Tst gombot, utána az = gombot."
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
                    "Some results are finite, such as 1 ÷ 8 = 0.125. Others are infinite. A repeating infinite expansion is written with the repeating block in parentheses. An irrational result, such as a root or a logarithm, has no repeating block, so TreeCalc shows a rounded value.\n\nTry these and press =:\n1 ÷ 3 = 0.(3), because 1/3 = 0.333…\n1 ÷ 6 = 0.1(6), because 1/6 = 0.1666…\n1 ÷ 7 = 0.(142857)\n1 ÷ 12 = 0.08(3)\n1 ÷ 8 = 0.125, which ends, so there are no parentheses.\n\nDetection uses the exact fraction, not the binary floating-point value. The fraction is reduced, then the denominator is inspected. In base 10, if every prime factor is 2 or 5, the expansion ends. The number of places is the larger of the powers of 2 and 5. Any other prime makes the expansion repeat. Digits before the parenthesis are the non-repeating prefix. The length of the block is the smallest k such that 10^k leaves a remainder of 1 when divided by the denominator after the factors 2 and 5 have been removed. If the prefix and the block together need more than 12 digits, the display falls back to a 12-digit rounding. The same rule works in other bases: a place ends when the denominator’s primes all divide the base, otherwise the repeating block is shown, as in hexadecimal 0.1(9) for decimal 0.1. The radix point is always a dot.",
                    "Van eredmény, amely véges, például 1 ÷ 8 = 0.125. Van, amely végtelen. A szakaszos végtelen tizedest úgy írjuk, hogy az ismétlődő szakasz zárójelben van. Az irracionális eredménynek, például egy gyöknek vagy logaritmusnak, nincs ilyen szakasza, ezért a TreeCalc kerekített értéket mutat.\n\nPróbáld ki ezeket, majd nyomj = jelet:\n1 ÷ 3 = 0.(3), mert 1/3 = 0,333…\n1 ÷ 6 = 0.1(6), mert 1/6 = 0,1666…\n1 ÷ 7 = 0.(142857)\n1 ÷ 12 = 0.08(3)\n1 ÷ 8 = 0.125, ez véget ér, ezért nincs zárójel.\n\nA felismerés a pontos törtből indul, nem a kettes lebegőpontos értékből. A törtet egyszerűsítjük, majd a nevezőt vizsgáljuk. Tízesben, ha minden prímtényező 2 vagy 5, a tizedes véges. A jegyek száma a kettes és az ötös kitevő közül a nagyobb. Bármilyen más prím szakaszossá teszi. A zárójel előtti jegyek a nem ismétlődő előszakasz. A szakasz hossza az a legkisebb k, amelyre a 10^k 1 maradékot ad, miután a nevezőből kivettük a 2 és 5 tényezőket. Ha az előszakasz és a szakasz együtt 12 jegynél hosszabb, a kijelző 12 jegyre kerekít. Ugyanez a szabály működik a többi számrendszerben is: a törtjegy véges, ha a nevező prímei mind osztói az alapnak, különben zárójeles szakasz jelenik meg, például a tízes 0.1 tizenhatosban 0.1(9). A tizedesjel mindig pont."
                )
            ),
            HelpTopic(
                id: "playback",
                title: L10n.text("Postfix playback", "Postfix lejátszás"),
                body: L10n.text(
                    "On the expression tree, Play walks the postfix tokens in order and highlights the matching branch. Stop pauses on the current step. Tap a token to jump there yourself. When Reduce Motion is on, Play advances one step each time you tap it.",
                    "A kifejezésfán a Lejátszás sorban végigmegy a postfix tokeneken, és kiemeli a hozzájuk tartozó ágat. Az Állj a jelenlegi lépésnél megáll. Egy tokenre koppintva oda ugorhatsz. Ha a Mozgás csökkentése be van kapcsolva, a Lejátszás minden koppintásra egy lépést ugrik."
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
