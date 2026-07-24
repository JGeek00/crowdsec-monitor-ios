@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class IPsCheckerViewModelTests: XCTestCase {
    func testDefaultValues() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        XCTAssertTrue(sut.ipsToCheck.isEmpty)
    }

    func testAddEntry() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.addEntry()
        XCTAssertEqual(sut.ipsToCheck.count, 1)
        XCTAssertEqual(sut.ipsToCheck[0].value, "")
    }

    func testRemoveEntry() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.addEntry()
        sut.addEntry()
        XCTAssertEqual(sut.ipsToCheck.count, 2)
        sut.removeEntry(at: IndexSet(integer: 0))
        XCTAssertEqual(sut.ipsToCheck.count, 1)
    }

    func testValidateIP() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.addEntry()
        sut.ipsToCheck[0].value = "192.168.1.1"
        sut.validateIP(0)
        XCTAssertFalse(sut.ipsToCheck[0].invalid)
    }

    func testValidateIPInvalid() {
        let sut = IPsCheckerViewModel(activeServerRepository: MockActiveServerRepository())
        sut.addEntry()
        sut.ipsToCheck[0].value = "not an ip"
        sut.validateIP(0)
        XCTAssertTrue(sut.ipsToCheck[0].invalid)
    }
}
