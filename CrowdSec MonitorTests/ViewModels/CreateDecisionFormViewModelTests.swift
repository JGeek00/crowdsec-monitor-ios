@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class CreateDecisionFormViewModelTests: XCTestCase {
    func testDefaultValues() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.ipAddress, "")
        XCTAssertEqual(sut.durationDays, 0)
        XCTAssertEqual(sut.durationHours, 4)
        XCTAssertEqual(sut.durationMinutes, 0)
        XCTAssertFalse(sut.creatingDecision)
    }

    func testDurationString() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        sut.durationDays = 1
        sut.durationHours = 2
        sut.durationMinutes = 30
        XCTAssertEqual(sut.durationString, "1d2h30m")
    }

    func testDurationStringZero() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.durationString, "4h")
    }

    func testValidateValuesFailsWithEmptyIP() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        let valid = sut.validateValues()
        XCTAssertFalse(valid)
        XCTAssertTrue(sut.invalidFieldsAlert)
    }

    func testValidateValuesFailsWithEmptyReason() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        sut.ipAddress = "10.0.0.1"
        sut.reason = ""
        let valid = sut.validateValues()
        XCTAssertFalse(valid)
        XCTAssertTrue(sut.invalidFieldsAlert)
    }

    func testValidateValuesSucceeds() {
        let sut = CreateDecisionFormViewModel(activeServerRepository: MockActiveServerRepository())
        sut.ipAddress = "10.0.0.1"
        sut.reason = "testing"
        let valid = sut.validateValues()
        XCTAssertTrue(valid)
        XCTAssertFalse(sut.invalidFieldsAlert)
    }
}
