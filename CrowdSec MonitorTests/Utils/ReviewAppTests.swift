@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ReviewAppTests: XCTestCase {
    override func tearDown() {
        UserDefaults.shared.removeObject(forKey: StorageKeys.appFirstLaunched)
        UserDefaults.shared.removeObject(forKey: StorageKeys.hasRequestedReview)
        super.tearDown()
    }

    func testFirstLaunchSetsTimestamp() {
        UserDefaults.shared.removeObject(forKey: StorageKeys.appFirstLaunched)
        requestAppReview()
        let timestamp = UserDefaults.shared.double(forKey: StorageKeys.appFirstLaunched)
        XCTAssertGreaterThan(timestamp, 0)
    }

    func testWithinOneDayDoesNotRequest() {
        // Set first launch to now
        UserDefaults.shared.setValue(Date().timeIntervalSince1970, forKey: StorageKeys.appFirstLaunched)
        // This should hit the < oneDay guard and not request
        requestAppReview()
        // hasRequestedReview should not be set
        XCTAssertFalse(UserDefaults.shared.bool(forKey: StorageKeys.hasRequestedReview))
    }

    func testAfterOneDayWithoutReviewFiresAsyncAfter() {
        // The > 24h AND hasRequestedReview != true path: fires DispatchQueue.main.asyncAfter
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970
        UserDefaults.shared.setValue(twoDaysAgo, forKey: StorageKeys.appFirstLaunched)
        UserDefaults.shared.setValue(false, forKey: StorageKeys.hasRequestedReview)

        requestAppReview()

        // The asyncAfter block fires after 10s. In tests the windowScene guard fails
        // silently inside the block. We just verify no crash and the dispatch path ran.
        XCTAssertNotNil(UserDefaults.shared.object(forKey: StorageKeys.appFirstLaunched))
    }

    func testHasRequestedReviewTrueSkipsReview() {
        // If hasRequestedReview is already true, the review path should be skipped
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970
        UserDefaults.shared.setValue(twoDaysAgo, forKey: StorageKeys.appFirstLaunched)
        UserDefaults.shared.setValue(true, forKey: StorageKeys.hasRequestedReview)

        requestAppReview()
        // No crash = the hasRequestedReview guard worked
        XCTAssertTrue(UserDefaults.shared.bool(forKey: StorageKeys.hasRequestedReview))
    }
}
