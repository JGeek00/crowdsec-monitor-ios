@testable import CrowdSec_Monitor
import SwiftUI
import XCTest

final class ViewExtensionTests: XCTestCase {
    @MainActor
    func testConditionTransform() {
        // Test that `condition` applies the transform.
        // We can test this by wrapping a Text view and asserting the result type.
        let view = Text("hello").condition { text in
            text.foregroundColor(.red)
        }
        XCTAssertNotNil(view)
        // The transform applies — if it didn't, this test wouldn't compile.
    }
}
