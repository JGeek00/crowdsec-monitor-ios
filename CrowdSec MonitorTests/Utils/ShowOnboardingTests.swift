@testable import CrowdSec_Monitor
import XCTest

/// Hermetic tests for the onboarding decision.
///
/// They use the parameterized `showOnboardingIfNeeded(onboardingCompleted:hasServers:)`
/// overload so they never depend on the host app's persisted state: the app-group
/// UserDefaults and the CoreData store of the simulator they run on. Running the
/// zero-argument variant in a hosted test would read the real app state, which
/// differs per simulator (e.g. an already-configured app has servers, so the
/// "not completed + no servers" branch never fires and the tests fail).
@MainActor
final class ShowOnboardingTests: XCTestCase {
    private var onboardingCompletedExisted = false
    private var onboardingCompletedValue = false

    override func setUp() {
        super.setUp()
        // Preserve the host app's value (restored in tearDown) in case the
        // tests run against a real device instead of an ephemeral clone.
        onboardingCompletedExisted = UserDefaults.shared.object(forKey: StorageKeys.onboardingCompleted) != nil
        onboardingCompletedValue = UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted)
        UserDefaults.shared.set(false, forKey: StorageKeys.onboardingCompleted)
    }

    override func tearDown() {
        if onboardingCompletedExisted {
            UserDefaults.shared.set(onboardingCompletedValue, forKey: StorageKeys.onboardingCompleted)
        } else {
            UserDefaults.shared.removeObject(forKey: StorageKeys.onboardingCompleted)
        }
        super.tearDown()
    }

    func testShowOnboardingWhenNotCompletedAndNoServers() {
        // Given: onboarding not completed, no servers
        // The function posts .shouldShowOnboarding notification
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded(onboardingCompleted: false, hasServers: false)
        wait(for: [expectation], timeout: 1)
    }

    func testNoOnboardingWhenCompleted() {
        // Completed onboarding must not post the notification, regardless of servers
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        expectation.isInverted = true
        showOnboardingIfNeeded(onboardingCompleted: true, hasServers: false)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted))
    }

    func testCompletedAndServersExistDoesNothing() {
        // Completed onboarding with servers: no notification and no state change
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        expectation.isInverted = true
        showOnboardingIfNeeded(onboardingCompleted: true, hasServers: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted))
    }

    func testServersExistWithoutCompletionMarksOnboardingCompleted() {
        // Given: onboarding not completed but servers already exist (app
        // configured before the onboarding existed). No notification is posted
        // and onboarding is silently marked as completed.
        let expectation = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        expectation.isInverted = true
        showOnboardingIfNeeded(onboardingCompleted: false, hasServers: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(UserDefaults.shared.bool(forKey: StorageKeys.onboardingCompleted))
    }

    func testShowOnboardingTwicePostsTwice() {
        // Call twice — function independently checks conditions each time
        let expectation1 = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded(onboardingCompleted: false, hasServers: false)
        wait(for: [expectation1], timeout: 1)

        let expectation2 = expectation(forNotification: .shouldShowOnboarding, object: nil, handler: nil)
        showOnboardingIfNeeded(onboardingCompleted: false, hasServers: false)
        wait(for: [expectation2], timeout: 1)
    }
}
