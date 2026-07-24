@testable import CrowdSec_Monitor
import XCTest

final class ScenarioStringTests: XCTestCase {
    func testParseScenarioWithAuthorAndName() {
        let result = parseScenario("crowdsec/ssh-bf")
        XCTAssertEqual(result.namespace, "crowdsec")
        XCTAssertEqual(result.name, "ssh-bf")
    }

    func testParseScenarioNoSeparator() {
        let result = parseScenario("just-namespace")
        XCTAssertEqual(result.namespace, "just-namespace")
        XCTAssertEqual(result.name, "")
    }

    func testParseScenarioEmptyString() {
        let result = parseScenario("")
        XCTAssertEqual(result.namespace, "")
        XCTAssertEqual(result.name, "")
    }

    func testParseScenarioMultipleSlashes() {
        let result = parseScenario("a/b/c")
        XCTAssertEqual(result.namespace, "a")
        XCTAssertEqual(result.name, "b")
    }
}
