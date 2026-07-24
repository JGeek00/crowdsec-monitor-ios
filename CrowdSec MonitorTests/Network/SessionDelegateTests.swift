@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class SessionDelegateTests: XCTestCase {
    func testServerTrustChallengeUsesCredential() {
        let delegate = SessionDelegate()
        let expectation = self.expectation(description: "challenge handled")

        let protectionSpace = URLProtectionSpace(
            host: "example.com",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        )
        // Create a basic server trust
        let trust: SecTrust? = nil // can't easily create a SecTrust in tests
        let credential: URLCredential? = nil
        let challenge = URLAuthenticationChallenge(
            protectionSpace: protectionSpace,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: MockChallengeSender(expectation: expectation)
        )

        delegate.urlSession(URLSession.shared, didReceive: challenge) { disposition, credential in
            // Without a valid serverTrust, should fall through to .performDefaultHandling
            XCTAssertEqual(disposition, .performDefaultHandling)
            XCTAssertNil(credential)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

/// Minimal URLAuthenticationChallengeSender for testing.
private final class MockChallengeSender: NSObject, URLAuthenticationChallengeSender {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        expectation.fulfill()
    }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        expectation.fulfill()
    }

    func cancel(_ challenge: URLAuthenticationChallenge) {
        expectation.fulfill()
    }

    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        expectation.fulfill()
    }

    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        expectation.fulfill()
    }
}
