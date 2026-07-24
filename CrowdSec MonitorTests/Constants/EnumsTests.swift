@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class EnumsTests: XCTestCase {
    // MARK: - LoadingState

    func testLoadingStateLoading() {
        let state: Enums.LoadingState<Int> = .loading
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertNil(state.error)
    }

    func testLoadingStateSuccess() {
        let state: Enums.LoadingState<Int> = .success(42)
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.data, 42)
        XCTAssertNil(state.error)
    }

    func testLoadingStateFailure() {
        let error = NSError(domain: "test", code: 1)
        let state: Enums.LoadingState<Int> = .failure(error)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.data)
        XCTAssertEqual(state.error as? NSError, error)
    }

    func testLoadingStateEquatable() {
        let loading1: Enums.LoadingState<Int> = .loading
        let loading2: Enums.LoadingState<Int> = .loading
        XCTAssertEqual(loading1, loading2)

        let success1: Enums.LoadingState<Int> = .success(1)
        let success2: Enums.LoadingState<Int> = .success(1)
        XCTAssertEqual(success1, success2)

        let success3: Enums.LoadingState<Int> = .success(2)
        XCTAssertNotEqual(success1, success3)

        let fail1: Enums.LoadingState<Int> = .failure(NSError(domain: "a", code: 1))
        let fail2: Enums.LoadingState<Int> = .failure(NSError(domain: "b", code: 2))
        XCTAssertEqual(fail1, fail2) // Any error → equal per spec
    }

    // MARK: - DecisionDuration

    func testDecisionDurationDisplayName() {
        for duration: Enums.DecisionDuration in [.oneHour, .fourHours, .twelveHours, .oneDay, .threeDays, .oneWeek, .oneMonth] {
            XCTAssertFalse(duration.displayName.isEmpty)
        }
    }

    // MARK: - Raw values

    func testDecisionTypeRawValues() {
        XCTAssertEqual(Enums.DecisionType.ban.rawValue, "ban")
        XCTAssertEqual(Enums.DecisionType.captcha.rawValue, "captcha")
    }

    func testConnectionMethodRawValues() {
        XCTAssertEqual(Enums.ConnectionMethod.http.rawValue, "http")
        XCTAssertEqual(Enums.ConnectionMethod.https.rawValue, "https")
    }

    func testAuthMethodRawValues() {
        XCTAssertEqual(Enums.AuthMethod.none.rawValue, "none")
        XCTAssertEqual(Enums.AuthMethod.basic.rawValue, "basic")
        XCTAssertEqual(Enums.AuthMethod.bearer.rawValue, "bearer")
    }

    func testThemeRawValues() {
        XCTAssertEqual(Enums.Theme.system.rawValue, "system")
        XCTAssertEqual(Enums.Theme.light.rawValue, "light")
        XCTAssertEqual(Enums.Theme.dark.rawValue, "dark")
    }
}
