# TreeCalc — App Store kiadás

Az első iOS rekord létrehozása. A bináris később kerül fel, Xcode Organizerből. Expo és EAS ehhez a projekthez nem kell.

Két weboldal van, a kettő külön feladat:

| Oldal | Mire való |
| --- | --- |
| [developer.apple.com/account](https://developer.apple.com/account) | Tagság, Team ID, tanúsítvány, App ID |
| [appstoreconnect.apple.com](https://appstoreconnect.apple.com) | Szerződés, az app rekordja, szövegek, képek, TestFlight, review, kiadás |

Az áruházi szövegek, a korhatár részletes válaszai és a review-jegyzet: [docs/store-presence.md](docs/store-presence.md).

A név és a bundle azonosító a Connect-rekord mentése után nem cserélhető. A SKU és az elsődleges nyelv sem.

## Rögzített adatok

| Mező | Érték |
| --- | --- |
| Xcode-projekt | `TreeCalc.xcodeproj` |
| Scheme | `TreeCalc` |
| Áruházi név | TreeCalc |
| Kezdőképernyő neve | TreeCalc, angolul és magyarul |
| Bundle azonosító | `com.lkovari.mobile.apps.treecalc` |
| SKU | `treecalc-ios` |
| Apple ID a Connectben | `6831814667` |
| Elsődleges nyelv | English (U.S.) |
| Verzió | 1.0.0 |
| Build | 1 |
| Team ID | `2885GLR3V7` |
| Csapat a portálon | LÁSZLÓ LAJOS KŐVÁRI |
| Aláírás | automatikus, a projektben `DEVELOPMENT_TEAM` = `2885GLR3V7` |
| Minimum rendszer | iOS 17.0 |
| Készülék | csak iPhone (`TARGETED_DEVICE_FAMILY` = 1) |
| Elsődleges kategória | Utilities |
| Másodlagos kategória | Education |
| Kategória a binárisban | `public.app-category.utilities` |
| Ár | Free |
| Korhatár | 4+ |
| Titkosítás | `ITSAppUsesNonExemptEncryption` = hamis |
| Fiók, hirdetés, követés, vásárlás | nincs |
| Támogatási e-mail | `laszlo.kovary@gmail.com` |
| Copyright a Connectben | `2026 László Kővári` |
| Adatvédelmi és támogatási URL | `https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html` |
| A lap forrása | `docs/treecalc-ios-privacy-policy.html` |

## Hol tartunk

Utolsó állás: 2026. november 7., 00:48. Az 1–3. pont kész. A verzióoldal angol (U.S.) és magyar szövege mentve: Promotional Text, Description, Keywords, Support URL. A Marketing URL üres. A Header Asset üres. Az Add for Review még nem megy megnyomásra.

A projekt marketing verziója `1.0.0`. A Connect címsora `1.0`. Ha a verziószám szerkeszthető, `1.0.0` legyen, mert a feltöltött build `CFBundleShortVersionString` értéke ezzel egyezik.

A korhatár mentve, 2026. november 7., 01:00. Az eredmény: 4+ 172 országban, Brazília AL, Korea ALL, Vietnam 00+. Az Age Suitability URL üres. A régebbi rendszer globális besorolása 4+, regionális kivételekkel. Az App Encryption Documentation plusz gombját nem kell megnyomni: a projektben az `ITSAppUsesNonExemptEncryption` már hamis.

Az App Availability oldal, 2026. november 7., 01:14: 175 ország, mind Available on App Release. A Pre-Orders gomb megnyomás nélkül marad. A Pricing oldalon a terjesztés Public, a Remove App From Sale linket nem szabad megnyomni.

Az App Privacy összesítő, 2026. november 7., 01:26: a címke Data Not Collected, külön követéskérdés ezen a lapon nincs. A Privacy Policy URL angolul be van írva, a User Privacy Choices URL üres. A kék Publish még hátra van. A build feltöltése a Publish után jön. Az Add for Review csak a feldolgozott build, a képernyőképek és a review-adatok után.

## 1. App ID a fejlesztői portálon

A képernyő a Certificates, Identifiers & Profiles, bal oldalon az Identifiers van kijelölve. A jobb oldali szűrő már App IDs. Így maradjon.

1. Az **Identifiers** felirat melletti kék plusz. Ez a jó plusz. A táblázat soraira kattintani nem kell: a GTL sor és a wildcard maradjon érintetlen.
2. A Register a new identifier oldalon **App IDs**, majd Continue.
3. A típusnál **App**. Az App Clip üresen marad. Continue.
4. Description: `TreeCalc`.
5. Bundle ID: **Explicit**. Öt tag, a tagok között pont, szóköz sehol. Az utolsó karakter a `c`:

```text
com.lkovari.mobile.apps.treecalc
```

6. A Capabilities listában minden jelölő üresen marad. Push Notifications, Sign in with Apple, iCloud, Game Center, Associated Domains és a többi extra jogosultság ennél az appnál nincs. A helyháttér, a kamera és a mikrofon sincs az appban.
7. Continue, ellenőrizd a megerősítő oldalon a leírást és a bundle azonosítót, majd Register.

Utána az Identifiers táblázatban a harmadik sor a `com.lkovari.mobile.apps.treecalc`. A Description a portálon TreeCalc. Ha az Xcode később saját sort hozna létre `XC com lkovari mobile apps treecalc` néven, az ugyanaz az azonosító, második sort ne regisztrálj rá.

Ha a Register azt írja, hogy az azonosító foglalt, a lista frissítése kell: már létezik ennél a csapatnál, és a 2. pontra lehet lépni.

## 2. Vissza az alkalmazások listájára

Ezt a bundle azonosító regisztrációja után csináld. A Connectben a GPS Track Logger van nyitva: bal felül a neve, mellette Distribution, Analytics, TestFlight. A bal oszlopban az iOS App 1.0.2, Ready for Distribution, alatta az Add Platform. A fő területen a Product Page Information, a Header és a Search Results fülek.

Ezen az oldalon semmi nem a TreeCalcé.

- Az **iOS App** melletti kék plusz és az **Add Platform** a GPS Track Loggerhez adna másik platformot (macOS, tvOS, visionOS).
- A Header és a Search Results a GPS Track Logger termékoldala.
- A bal felső **GPS Track Logger** lenyíló menü csak a meglévő appok között vált.

Az új rekord az alkalmazások listájáról jön létre: [appstoreconnect.apple.com/apps](https://appstoreconnect.apple.com/apps).

Az Apps felirat melletti kék plusz a jó gomb. A GPS Track Logger oldalán lévő plusz nem az.

## 3. Az új alkalmazás a Connectben

1. Az Apps mellett a plusz.
2. **New App**.
3. A párbeszédablak mezői:

| Mező | Érték |
| --- | --- |
| Platforms | Csak iOS. A macOS, tvOS és visionOS jelölő üres |
| Name | `TreeCalc` |
| Primary language | English (U.S.) |
| Bundle ID | `com.lkovari.mobile.apps.treecalc` |
| SKU | `treecalc-ios` |
| User Access | Full Access |

4. Create.

A Name az áruházi név, legfeljebb 30 karakter. A TreeCalc 8 karakter. A Bundle ID a legördülőből jön. Ha a `com.lkovari.mobile.apps.treecalc` nincs a listában, az 1. pont App ID-ja még nem ezen a csapaton van. A SKU-t a vásárló nem látja. A User Access Full Access, ha egyedül vagy a fiókban: minden Admin és App Manager látja az appot.

Ha a Create a nevet foglaltnak jelzi, a rekordot ne mentsd más bundle azonosítóval. A név a sikeres mentés előtt még cserélhető, utána nem. A hiba szövegét ide kell beírni, és a tartalék név csak azután dől el.

Sikeres Create után a bal felső sarokban TreeCalc áll. A verzió 1.0.0, az állapot Prepare for Submission. Az Apple ID számot, amit a Connect a rekordhoz ad, ebbe a táblázatba kell beírni, amint megjelenik.

## 4. A létrehozás után, még build nélkül

A Distribution fül Product Page része (Header, Search Results, App Previews and Screenshots) üresen maradhat. Az ikont a Connect külön nem kéri: a későbbi build `AppIcon` készletéből jön.

### App Information

Bal oldalon **App Information**.

| Mező | Érték |
| --- | --- |
| Primary category | Utilities |
| Secondary category | Education |
| Content Rights | Nem. Az alkalmazás saját számológép, harmadik fél tartalmát nem jeleníti meg |
| License Agreement | Az Apple szokásos EULA-ja. Saját szöveg nem kell |

A bináris kategóriája `public.app-category.utilities`. Az elsődleges kategória ezzel egyezzen. A másodlagos Education a kifejezésfa bemutató szerepe miatt való.

A Content Rights kérdés azt kérdezi, hogy az app tartalmaz, mutat vagy elér-e olyan tartalmat, amelyhez harmadik féltől jog kell. A Névjegy linkjei a Safariban nyílnak, a saját tárolóra és a saját korábbi oldalra. A válasz Nem.

### Korhatár

Az űrlap az App Information, Age Rating alatt van. Minden gyakoriság None. Minden igen/nem képesség Nem. Az Apple a kérdéseket néha átnevezi; a tartalom szerint válaszolj. A várható eredmény 4+.

| Kérdés | Válasz |
| --- | --- |
| Parental Controls | Nem |
| Age Assurance | Nem |
| Unrestricted Web Access | Nem |
| User-Generated Content | Nem |
| Social Media | Nem |
| Messaging and Chat | Nem |
| Advertising | Nem |
| Profanity or Crude Humor | None |
| Horror/Fear Themes | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Medical or Treatment Information | None |
| Health or Wellness Topics | None |
| Mature or Suggestive Themes | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Guns or Other Weapons | None |
| Gambling | Nem |
| Simulated Gambling | None |
| Contests | None |
| Loot Boxes | Nem |

A Névjegy a tájékoztatót, a GitHub-tárolót és a korábbi iOS oldalt a Safarinak adja, a támogatást a Mailnek. Beépített böngésző, címmező és tetszőleges weboldal nincs, ezért a webes hozzáférés Nem. Egy Igen ide 16+-ra emelné a korhatárt.

A Kids kategória üresen marad. A 4+ korhatár és a Kids kategória két külön dolog.

Mentsd a kérdőívet. Ha az eredmény magasabb, mint 4+, nézd meg, melyik sor kapott gyakoriságot vagy Igen választ, és állítsd vissza a fenti értékre.

### Ár és elérhetőség

Pricing and Availability.

| Mező | Érték |
| --- | --- |
| Price | Free |
| Availability | Minden ország és régió |
| Pre-order | Ki |

Ingyenes apphoz ársávot nem választasz. Alkalmazáson belüli vásárlás nincs, ezért a Paid Apps szerződés, bankszámla és adóűrlap az ár miatt nem kell. A Business, Agreements, Tax, and Banking oldalon a Free Apps szerződés állapota Active legyen. Függő szerződésnél a beküldés nem végezhető el.

### App Privacy

Bal oldalon App Privacy, Get Started, vagy Edit, ha már van válasz. Az űrlap és a `TreeCalc/PrivacyInfo.xcprivacy` ugyanazt mondja. A manifestben a követés hamis, a gyűjtött adattípusok tömbje üres. A UserDefaults a témát tárolja (`CA92.1`), és az adat a készüléken marad.

| Kérdés | Érték |
| --- | --- |
| Data used to track you | Nem |
| Data collected | Nem. A címke szövege: Data Not Collected |

Precise Location, Contacts, Identifiers és a többi adattípus sor jelöletlen marad. Publish után a termékoldal címkéje Data Not Collected.

## Ami ezután jön

A verzióoldal angol és magyar szövegei, a Support URL, a Privacy Policy URL, a képernyőképek, a review-jegyzet és a build hozzárendelése a [docs/store-presence.md](docs/store-presence.md) szerint megy. A két URL mindkét nyelven:

```text
https://lkovari.github.io/KLHome/assets/bigfiles/treecalc-ios-privacy-policy.html
```

A magyar lokalizáció a verzióoldal tetején, a nyelv plusz gombjával jön létre: Hungarian. Az elsődleges nyelv English (U.S.) marad.

A build feltöltése, a tanúsítvány és az Organizer külön menet, azt akkor írjuk ide, amikor az 1–4. pont megvan.
