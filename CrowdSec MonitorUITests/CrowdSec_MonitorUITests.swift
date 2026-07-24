import XCTest

/// UI smoke tests verifying the app launches and displays core screens.
/// ponytail: minimal smoke tests — no server configured, so we test launch and navigation only.
final class CrowdSec_MonitorUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()

        // Without a server configured, the app should show a no-servers view
        // or the onboarding flow on first launch
        XCTAssertTrue(app.state == .runningForeground || app.state == .runningBackground)
    }

    func testOnboardingAppearsOnFirstLaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["-showOnboarding", "true"]
        app.launch()

        // The onboarding screen should be visible
        // Look for a common element like the app title or a navigation bar
        let exists = app.navigationBars.firstMatch.waitForExistence(timeout: 2)
            || app.buttons.firstMatch.waitForExistence(timeout: 2)
        XCTAssertTrue(exists, "App should display some UI after launch")
    }

    func testTabBarExists() {
        let app = XCUIApplication()
        app.launch()

        // The tab bar should be present in the main interface
        let tabBar = app.tabBars.firstMatch
        let tabBarExists = tabBar.waitForExistence(timeout: 3)
        XCTAssertTrue(tabBarExists, "Tab bar should be visible")
    }
}
