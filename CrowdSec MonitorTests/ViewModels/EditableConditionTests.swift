@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class EditableConditionTests: XCTestCase {
    func testLeafValidation() {
        XCTAssertFalse(EditableLeaf(field: .scenario, op: .equals, values: []).isValid)
        XCTAssertFalse(EditableLeaf(field: .scenario, op: .equals, values: [""]).isValid)
        XCTAssertTrue(EditableLeaf(field: .country, op: .in, values: ["ES", "FR"]).isValid)
    }

    func testGroupRequiresNonEmptyValidChildren() {
        XCTAssertFalse(EditableCondition.and([]).isValid)
        XCTAssertFalse(EditableCondition.or([.leaf(.empty)]).isValid)
        XCTAssertTrue(
            EditableCondition.and([.leaf(EditableLeaf(field: .scenario, op: .equals, values: ["x"]))]).isValid
        )
    }

    func testLeafCount() {
        let tree = EditableCondition.and([
            .or([.leaf(.empty), .leaf(.empty)]),
            .not(.leaf(.empty)),
        ])
        XCTAssertEqual(tree.leafCount, 3)
    }

    func testFromAPIRoundTrip() {
        let api = NotificationConditionNode.and([
            .or([
                .leaf(field: "scenario", op: "equals", value: .single("a")),
                .leaf(field: "country", op: "in", value: .multiple(["ES", "FR"])),
            ]),
            .not(.leaf(field: "target", op: "contains", value: .single("x"))),
        ])
        let editable = EditableCondition(api: api)
        XCTAssertTrue(editable.isValid)
        XCTAssertEqual(editable.toAPI(), api)
    }

    func testFromAPIUnknownFieldDefaults() {
        let editable = EditableCondition(api: .leaf(field: "nope", op: "nope", value: .single("x")))
        if case .leaf(let leaf) = editable {
            XCTAssertEqual(leaf.field, .scenario)
            XCTAssertEqual(leaf.op, .equals)
        } else {
            XCTFail("Expected leaf")
        }
    }

    func testSingleVsMultipleEncoding() {
        let single = EditableCondition.leaf(EditableLeaf(field: .scenario, op: .equals, values: ["a"]))
        if case .leaf(_, _, let value) = single.toAPI() {
            XCTAssertEqual(value, .single("a"))
        } else {
            XCTFail("Expected leaf")
        }
        let multi = EditableCondition.leaf(EditableLeaf(field: .scenario, op: .in, values: ["a", "b"]))
        if case .leaf(_, _, let value) = multi.toAPI() {
            XCTAssertEqual(value, .multiple(["a", "b"]))
        } else {
            XCTFail("Expected leaf")
        }
    }
}
