@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ShowOnboardingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.shared.set(false, forKey: StorageKeys.onboardingCompleted)
    }

    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: StorageKeys.onboardingCompleted)
        super.tearDown()
    }

    func testShowOnboardingWhenNotCompletedAndNoServers() {
        // Given: onboarding not completed, no servers
        // The function posts .shouldShowOnboarding notification
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded()
        wait(for: [expectation], timeout: 1)
    }

    func testNoOnboardingWhenCompleted() {
        UserDefaults.shared.set(true, forKey: StorageKeys.onboardingCompleted)
        // Should not post notification
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        expectation.isInverted = true
        showOnboardingIfNeeded()
        wait(for: [expectation], timeout: 1)
    }

    func testShowOnboardingTwicePostsTwice() {
        // Call twice — function independently checks conditions each time
        let expectation1 = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded()
        wait(for: [expectation1], timeout: 1)

        let expectation2 = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded()
        wait(for: [expectation2], timeout: 1)
    }
}
