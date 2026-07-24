@testable import CrowdSec_Monitor
import CoreData
import XCTest

final class BuildURLTests: XCTestCase {
    private var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = TestCoreData.makeContainer()
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    func testBuildUrlWithPortAndPath() {
        let server = TestCoreData.makeServer(in: container.viewContext)
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "https://api.example.com:8080/api/v1")
    }

    func testBuildUrlPortZero() {
        let server = TestCoreData.makeServer(in: container.viewContext, port: 0)
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "https://api.example.com/api/v1")
    }

    func testBuildUrlNilPath() {
        let server = TestCoreData.makeServer(in: container.viewContext, path: nil)
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "https://api.example.com:8080")
    }

    func testBuildUrlEmptyPath() {
        let server = TestCoreData.makeServer(in: container.viewContext, path: "")
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "https://api.example.com:8080")
    }

    func testBuildUrlPathWithoutLeadingSlash() {
        let server = TestCoreData.makeServer(in: container.viewContext, path: "api/v1")
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "https://api.example.com:8080/api/v1")
    }

    func testBuildUrlHttp() {
        let server = TestCoreData.makeServer(in: container.viewContext, http: "http")
        let result = buildUrl(server: server as! CSServer)
        XCTAssertEqual(result, "http://api.example.com:8080/api/v1")
    }
}
