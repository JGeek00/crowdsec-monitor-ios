@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class AddBlocklistFormViewModelTests: XCTestCase {
    func testDefaultValues() {
        let sut = AddBlocklistFormViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.url, "")
        XCTAssertFalse(sut.isSaving)
        XCTAssertFalse(sut.requiredFieldsError)
        XCTAssertFalse(sut.invalidUrlError)
    }

    func testCreateBlocklistFailsWithEmptyName() async {
        let sut = AddBlocklistFormViewModel(activeServerRepository: MockActiveServerRepository())
        sut.url = "http://example.com"
        await sut.createBlocklist(name: "", url: "http://example.com")
        XCTAssertTrue(sut.requiredFieldsError)
    }

    func testCreateBlocklistFailsWithInvalidUrl() async {
        let sut = AddBlocklistFormViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.createBlocklist(name: "test", url: "not-a-url")
        XCTAssertTrue(sut.invalidUrlError)
    }

    func testCreateBlocklistFailsWithEmptyUrl() async {
        let sut = AddBlocklistFormViewModel(activeServerRepository: MockActiveServerRepository())
        await sut.createBlocklist(name: "test", url: "")
        XCTAssertTrue(sut.requiredFieldsError)
    }
}
