@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ConnectionFormViewModelTests: XCTestCase {
    func testFormInvalidByDefault() {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ConnectionFormViewModel(serversManagerRepository: repo)
        XCTAssertFalse(sut.isFormValid)
        XCTAssertFalse(sut.connecting)
    }

    func testCheckValuesFailsWithEmptyName() {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ConnectionFormViewModel(serversManagerRepository: repo)
        sut.ipDomain = "10.0.0.1"
        let valid = sut.checkValues()
        XCTAssertFalse(valid)
        XCTAssertTrue(sut.invalidValuesAlert)
    }

    func testCheckValuesFailsWithEmptyIP() {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ConnectionFormViewModel(serversManagerRepository: repo)
        sut.name = "Test"
        let valid = sut.checkValues()
        XCTAssertFalse(valid)
        XCTAssertTrue(sut.invalidValuesAlert)
    }

    func testIsFormValidWithRequiredFields() {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ConnectionFormViewModel(serversManagerRepository: repo)
        sut.name = "Test"
        sut.ipDomain = "10.0.0.1"
        XCTAssertTrue(sut.isFormValid)
    }

    func testConnectFailsWithoutServer() async {
        let repo = ServersManagerRepository(activeServerRepository: MockActiveServerRepository())
        let sut = ConnectionFormViewModel(serversManagerRepository: repo)
        sut.name = "Test"
        sut.ipDomain = "10.0.0.1"
        let result = await sut.connect()
        XCTAssertFalse(result)
    }
}
