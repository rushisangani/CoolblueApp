import XCTest

// Runs against the saved API pages (see XCUIApplication+SavedResponses)
@MainActor
final class ProductSearchUITests: XCTestCase {
    private var app: XCUIApplication!

    // first products of the saved pages
    private let firstProduct = "Apple iPhone 6 32GB Grijs"
    private let firstProductOfPage2 = "Apple Lightning Digital AV Adapter"

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication.launchWithSavedResponses()
    }

    func testLaunchShowsSearchPrompt() {
        XCTAssertTrue(app.staticTexts["Search what you need"].waitForExistence(timeout: 5))
    }

    func testTypingShowsSuggestions() {
        search("ip")

        XCTAssertTrue(row(firstProduct).waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 4)
    }

    func testSearchingShowsResults() {
        search("ip")
        app.buttons["searchForButton"].tap()

        XCTAssertTrue(app.navigationBars["ip"].waitForExistence(timeout: 5))
        XCTAssertTrue(row(firstProduct).waitForExistence(timeout: 5))
    }

    func testScrollingLoadsTheNextPage() {
        search("ip")
        app.buttons["searchForButton"].tap()
        XCTAssertTrue(row(firstProduct).waitForExistence(timeout: 5))

        for _ in 0..<15 where !row(firstProductOfPage2).exists {
            app.swipeUp()
        }

        XCTAssertTrue(row(firstProductOfPage2).exists)
    }

    func testResultOpensDetailAndBackKeepsResults() {
        search("ip")
        app.buttons["searchForButton"].tap()
        row(firstProduct).waitAndTap()

        XCTAssertTrue(app.navigationBars[firstProduct].waitForExistence(timeout: 5))

        goBack()
        XCTAssertTrue(app.navigationBars["ip"].waitForExistence(timeout: 5))
        XCTAssertTrue(row(firstProduct).exists)
    }

    func testSuggestionOpensDetailAndBackKeepsSuggestions() {
        search("ip")
        row(firstProduct).waitAndTap()

        XCTAssertTrue(app.navigationBars[firstProduct].waitForExistence(timeout: 5))

        goBack()
        XCTAssertTrue(row(firstProduct).waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 4)
    }

    func testClearingTheSearchShowsThePromptAgain() {
        search("ip")
        XCTAssertTrue(row(firstProduct).waitForExistence(timeout: 5))

        app.searchFields.firstMatch.buttons["Clear text"].tap()

        XCTAssertTrue(app.staticTexts["Search what you need"].waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private var rows: XCUIElementQuery {
        app.buttons.matching(identifier: "productRow")
    }

    // the product row whose text includes `name`
    private func row(_ name: String) -> XCUIElement {
        rows.matching(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
    }

    private func search(_ text: String) {
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    private func goBack() {
        app.navigationBars.buttons.firstMatch.tap()
    }
}

private extension XCUIElement {
    func waitAndTap() {
        XCTAssertTrue(waitForExistence(timeout: 5))
        tap()
    }
}
