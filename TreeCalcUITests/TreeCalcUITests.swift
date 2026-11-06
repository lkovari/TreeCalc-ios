import XCTest

final class TreeCalcUITests: XCTestCase {
    func testAdditionHelpAndAbout() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["key.digit2"].tap()
        app.buttons["key.add"].tap()
        app.buttons["key.digit2"].tap()
        app.buttons["key.equals"].tap()
        let display = app.descendants(matching: .any)["display.result"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        XCTAssertTrue(display.label.contains("4"))
        app.buttons["mainMenu"].tap()
        let help = app.buttons["Help"]
        let helpHu = app.buttons["Súgó"]
        if help.waitForExistence(timeout: 3) {
            help.tap()
        } else {
            helpHu.tap()
        }
        let topic = app.buttons["topic.Postfix playback"]
        let topicHu = app.buttons["topic.Postfix lejátszás"]
        if topic.waitForExistence(timeout: 3) {
            topic.tap()
        } else {
            topicHu.tap()
        }
        let opened = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Reduce Motion")).firstMatch
        let openedHu = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Mozgás csökkentése")).firstMatch
        XCTAssertTrue(opened.waitForExistence(timeout: 3) || openedHu.exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["mainMenu"].tap()
        let about = app.buttons["About"]
        let aboutHu = app.buttons["Névjegy"]
        if about.waitForExistence(timeout: 3) {
            about.tap()
        } else {
            aboutHu.tap()
        }
        let original = app.buttons["topic.Original iOS calculator"]
        let originalHu = app.buttons["topic.Eredeti iOS számológép"]
        if original.waitForExistence(timeout: 3) {
            original.tap()
        } else {
            originalHu.tap()
        }
        let link = app.links["https://lkovari.github.io/KLHome/#/ios-page/ios-page-content2"]
        XCTAssertTrue(link.waitForExistence(timeout: 3))
        let copyright = app.buttons["topic.Copyright"]
        let copyrightHu = app.buttons["topic.Szerzői jog"]
        if !copyright.waitForExistence(timeout: 2) && !copyrightHu.exists {
            app.swipeUp()
        }
        if copyright.exists {
            copyright.tap()
        } else {
            copyrightHu.tap()
        }
        XCTAssertTrue(app.descendants(matching: .any)["about.author"].waitForExistence(timeout: 3))
    }

    func testBaseErrorAndExpressionTree() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["key.digit8"].tap()
        app.buttons["key.memoryAdd"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["display.memory"].waitForExistence(timeout: 3))
        app.buttons["key.clear"].tap()
        app.buttons["key.digit1"].tap()
        app.buttons["key.digit0"].tap()
        app.buttons["base.16"].tap()
        let display = app.descendants(matching: .any)["display.result"]
        XCTAssertTrue(display.waitForExistence(timeout: 5))
        XCTAssertTrue(display.label.contains("A"))
        app.buttons["key.clear"].tap()
        app.buttons["base.10"].tap()
        app.buttons["key.digit9"].tap()
        app.buttons["key.add"].tap()
        app.buttons["key.digit7"].tap()
        app.buttons["key.mul"].tap()
        app.buttons["key.digit6"].tap()
        app.buttons["key.equals"].tap()
        XCTAssertTrue(display.label.contains("51"))
        let start = display.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end = display.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(app.buttons["tree.playback"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["postfix.0"].waitForExistence(timeout: 3))
        app.buttons["tree.back"].tap()
        XCTAssertTrue(app.buttons["key.equals"].waitForExistence(timeout: 3))
        app.buttons["key.clear"].tap()
        app.buttons["key.digit1"].tap()
        app.buttons["key.div"].tap()
        app.buttons["key.digit0"].tap()
        app.buttons["key.equals"].tap()
        let error = app.descendants(matching: .any)["display.error"]
        XCTAssertTrue(error.waitForExistence(timeout: 3))
        XCTAssertTrue(error.label.contains("Division by zero") || error.label.contains("Nullával osztás"))
    }
}
