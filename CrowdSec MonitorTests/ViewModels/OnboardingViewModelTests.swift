@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: "showOnboarding")
        super.tearDown()
    }

    func testShowOnboardingDefaultFalse() {
        let sut = OnboardingViewModel(showOnboarding: false, selectedTab: 0)
        XCTAssertFalse(sut.showOnboarding)
    }

    func testFinishOnboardingSetsUserDefault() {
        let sut = OnboardingViewModel(showOnboarding: true, selectedTab: 0)
        sut.finishOnboarding()
        XCTAssertFalse(sut.showOnboarding)
    }

    func testOpenOnboardingSetsTrue() {
        let sut = OnboardingViewModel(showOnboarding: false, selectedTab: 0)
        sut.openOnboarding()
        XCTAssertTrue(sut.showOnboarding)
    }
}
