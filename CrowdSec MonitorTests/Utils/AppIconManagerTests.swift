@testable import CrowdSec_Monitor
import XCTest

final class AppIconManagerTests: XCTestCase {
    @MainActor
    func testInitSetsDefaultIcon() {
        // Fresh instance — should read the current icon
        let manager = AppIconManager()
        XCTAssertNotNil(manager.appIcon)
    }

    @MainActor
    func testSetAlternateAppIconSwitchesIcon() {
        let manager = AppIconManager()
        let original = manager.appIcon
        // Try setting a different icon
        let newIcon: AppIcon = original == .purple ? .purpleYellow : .purple
        manager.setAlternateAppIcon(icon: newIcon)
        XCTAssertEqual(manager.appIcon, newIcon)
    }
}
