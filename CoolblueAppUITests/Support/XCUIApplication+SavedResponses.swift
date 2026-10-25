import XCTest

extension XCUIApplication {
    // Launches the app with the saved search pages from this bundle, so it never calls the real API.
    // The keys must match LaunchEnvironmentNetworkClient in the app.
    @MainActor
    static func launchWithSavedResponses() -> XCUIApplication {
        let app = XCUIApplication()
        // UI tests look for English text, whatever language the simulator is set to.
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_NL"]
        for page in 1...2 {
            app.launchEnvironment["UITEST_SEARCH_PAGE_\(page)"] = savedPage(page)
        }
        app.launch()
        return app
    }

    private static func savedPage(_ page: Int) -> String {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: "search-page-\(page)", withExtension: "json"),
              let json = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("search-page-\(page).json is missing from the UI test bundle")
        }
        return json
    }
}

// Finds this test bundle, which holds the saved JSON pages.
private final class BundleToken {}
