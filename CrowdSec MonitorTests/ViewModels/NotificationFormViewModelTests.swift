@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class NotificationFormViewModelTests: XCTestCase {
    private func makeSUT(editing: UserNotification? = nil) -> (NotificationFormViewModel, MockHttpClient) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        return (NotificationFormViewModel(editing: editing, activeServerRepository: activeRepo), mockHttp)
    }

    func testStepZeroRequiresName() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.canProceed(step: 0))
        sut.name = "alerts"
        XCTAssertTrue(sut.canProceed(step: 0))
    }

    func testStepOneRequiresValidCondition() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.canProceed(step: 1))
        XCTAssertEqual(sut.validationIssue(step: 1), .empty)
        sut.rules = [.empty]
        XCTAssertEqual(sut.validationIssue(step: 1), .incomplete)
        sut.rules = [EditableLeaf(field: .country, op: .equals, values: ["ES"])]
        XCTAssertTrue(sut.canProceed(step: 1))
        XCTAssertNil(sut.validationIssue(step: 1))
    }

    func testEmptyRulesMessage() {
        let (sut, _) = makeSUT()
        sut.rules = []
        XCTAssertEqual(sut.validationIssue(step: 1), .empty)
    }

    func testOrSameFieldMergesIntoOneRule() {
        let notification = UserNotification(
            id: 1, name: "n", description: nil, enabled: true,
            condition: .or([
                .leaf(field: "scenario", op: "equals", value: .single("a")),
                .leaf(field: "scenario", op: "equals", value: .single("b")),
            ]),
            threshold: nil, message: "m", channelIds: [], createdAt: nil, updatedAt: nil
        )
        let (sut, _) = makeSUT(editing: notification)
        XCTAssertNil(sut.advancedCondition)
        XCTAssertEqual(sut.rules.count, 1)
        XCTAssertEqual(sut.rules.first?.op, .in)
        XCTAssertEqual(sut.rules.first?.values, ["a", "b"])
        XCTAssertTrue(sut.canProceed(step: 1))
    }

    func testCrossFieldOrIsAdvanced() {
        let notification = UserNotification(
            id: 1, name: "n", description: nil, enabled: true,
            condition: .or([
                .leaf(field: "scenario", op: "equals", value: .single("a")),
                .leaf(field: "country", op: "equals", value: .single("ES")),
            ]),
            threshold: nil, message: "m", channelIds: [], createdAt: nil, updatedAt: nil
        )
        let (sut, _) = makeSUT(editing: notification)
        XCTAssertNotNil(sut.advancedCondition)
        XCTAssertFalse(sut.canProceed(step: 1))
        XCTAssertEqual(sut.validationIssue(step: 1), .advanced)
        sut.replaceWithSimpleRules()
        XCTAssertNil(sut.advancedCondition)
        XCTAssertTrue(sut.rules.isEmpty)
    }

    func testDefaultsThreeInTenSeconds() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(sut.windowSecondsText, "10")
        XCTAssertEqual(sut.cooldownSeconds, Defaults.notificationCooldownSeconds)
        XCTAssertTrue(sut.windowValid)
        XCTAssertFalse(sut.noCondition)
        XCTAssertTrue(sut.rules.isEmpty)
        XCTAssertEqual(sut.validationIssue(step: 1), .empty)
        if case .and(let items) = sut.buildCondition() {
            XCTAssertTrue(items.isEmpty)
        } else {
            XCTFail("Expected and")
        }
    }

    func testNewDraftPrefillsFirstScenario() {
        let (sut, _) = makeSUT()
        sut.filterOptions = NotificationFilterOptions(scenarios: ["b", "a"], countries: [], targets: [], ipOwners: [])
        let draft = sut.newDraft()
        XCTAssertEqual(draft.field, .scenario)
        XCTAssertEqual(draft.op, .equals)
        XCTAssertEqual(draft.values, ["b"])
        XCTAssertTrue(draft.isValid)
    }

    func testNewDraftEmptyWithoutOptions() {
        let (sut, _) = makeSUT()
        let draft = sut.newDraft()
        XCTAssertTrue(draft.values.isEmpty)
        XCTAssertFalse(draft.isValid)
    }

    func testWindowBoundaries() {
        let (sut, _) = makeSUT()
        sut.rules = [EditableLeaf(field: .scenario, op: .equals, values: ["x"])]
        sut.windowSecondsText = "9"
        XCTAssertFalse(sut.windowValid)
        XCTAssertEqual(sut.validationIssue(step: 1), .invalidWindow)
        XCTAssertFalse(sut.canProceed(step: 1))
        sut.windowSecondsText = "10"
        XCTAssertTrue(sut.canProceed(step: 1))
        sut.windowSecondsText = "86400"
        XCTAssertTrue(sut.canProceed(step: 1))
        sut.windowSecondsText = "86401"
        XCTAssertFalse(sut.canProceed(step: 1))
        sut.windowSecondsText = "abc"
        XCTAssertFalse(sut.canProceed(step: 1))
    }

    func testNoConditionPrefillAndBuild() {
        let notification = UserNotification(
            id: 2, name: "any", description: nil, enabled: true,
            condition: .and([]),
            threshold: NotificationThreshold(count: 3, windowSeconds: 10),
            message: "m", channelIds: [], createdAt: nil, updatedAt: nil
        )
        let (sut, _) = makeSUT(editing: notification)
        XCTAssertTrue(sut.noCondition)
        XCTAssertNil(sut.advancedCondition)
        XCTAssertTrue(sut.canProceed(step: 1))
        XCTAssertEqual(sut.buildCondition(), .and([]))
    }

    func testNoConditionSkipsRulesValidation() {
        let (sut, _) = makeSUT()
        sut.noCondition = true
        sut.rules = []
        XCTAssertTrue(sut.canProceed(step: 1))
        XCTAssertNil(sut.validationIssue(step: 1))
    }

    func testBuildConditionAlwaysAnd() {
        let (sut, _) = makeSUT()
        sut.rules = [
            EditableLeaf(field: .scenario, op: .equals, values: ["a"]),
            EditableLeaf(field: .country, op: .equals, values: ["ES"]),
        ]
        if case .and(let items) = sut.buildCondition() {
            XCTAssertEqual(items.count, 2)
        } else {
            XCTFail("Expected and")
        }
    }

    func testStepsTwoAndThree() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.canProceed(step: 2))
        sut.message = "hello"
        XCTAssertTrue(sut.canProceed(step: 2))
        XCTAssertFalse(sut.canProceed(step: 3))
        sut.selectedChannelIds = [4]
        XCTAssertTrue(sut.canProceed(step: 3))
    }

    func testEditPrefills() {
        let notification = UserNotification(
            id: 9, name: "orig", description: "d", enabled: true,
            condition: .or([.leaf(field: "country", op: "equals", value: .single("ES"))]),
            threshold: NotificationThreshold(count: 4, windowSeconds: 60, cooldownSeconds: 300),
            message: "m", channelIds: [3], createdAt: nil, updatedAt: nil
        )
        let (sut, _) = makeSUT(editing: notification)
        XCTAssertTrue(sut.isEditing)
        XCTAssertEqual(sut.name, "orig")
        XCTAssertEqual(sut.rules.count, 1)
        XCTAssertEqual(sut.rules.first?.field, .country)
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.windowSecondsText, "60")
        XCTAssertEqual(sut.cooldownSeconds, 300)

        let legacy = UserNotification(
            id: 10, name: "legacy", description: nil, enabled: true,
            condition: .and([]),
            threshold: NotificationThreshold(count: 2, windowSeconds: 30),
            message: "m", channelIds: [3], createdAt: nil, updatedAt: nil
        )
        let (sutLegacy, _) = makeSUT(editing: legacy)
        XCTAssertEqual(sutLegacy.cooldownSeconds, Defaults.notificationCooldownSeconds)
        XCTAssertTrue(sut.windowValid)
        XCTAssertEqual(sut.selectedChannelIds, [3])
        XCTAssertTrue(sut.canProceed(step: 0))
        XCTAssertTrue(sut.canProceed(step: 1))
    }

    func testSaveCreate() async {
        let (sut, mockHttp) = makeSUT()
        sut.name = "n"
        sut.rules = [EditableLeaf(field: .scenario, op: .equals, values: ["x"])]
        sut.message = "m"
        sut.selectedChannelIds = [1]
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notifications"] = TestViewModelFactory.encode(
            NotificationDetailResponse(data: UserNotification(
                id: 1, name: "n", description: nil, enabled: true,
                condition: .leaf(field: "scenario", op: "equals", value: .single("x")),
                threshold: nil, message: "m", channelIds: [1], createdAt: nil, updatedAt: nil
            ))
        )
        let saved = await sut.save()
        XCTAssertNotNil(saved)
        XCTAssertFalse(sut.saveError)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notifications")
        let body = mockHttp.capturedBody as? CreateNotificationRequest
        XCTAssertEqual(body?.threshold?.count, 3)
        XCTAssertEqual(body?.threshold?.windowSeconds, 10)
        XCTAssertEqual(body?.threshold?.cooldownSeconds, Defaults.notificationCooldownSeconds)
    }

    func testSaveSendsPickedCooldown() async {
        let (sut, mockHttp) = makeSUT()
        sut.name = "n"
        sut.rules = [EditableLeaf(field: .scenario, op: .equals, values: ["x"])]
        sut.cooldownSeconds = 120
        sut.message = "m"
        sut.selectedChannelIds = [1]
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notifications"] = TestViewModelFactory.encode(
            NotificationDetailResponse(data: UserNotification(
                id: 1, name: "n", description: nil, enabled: true,
                condition: .leaf(field: "scenario", op: "equals", value: .single("x")),
                threshold: nil, message: "m", channelIds: [1], createdAt: nil, updatedAt: nil
            ))
        )
        let saved = await sut.save()
        XCTAssertNotNil(saved)
        let body = mockHttp.capturedBody as? CreateNotificationRequest
        XCTAssertEqual(body?.threshold?.cooldownSeconds, 120)
    }

    func testSaveErrorFlag() async {
        let (sut, mockHttp) = makeSUT()
        sut.name = "n"
        sut.rules = [EditableLeaf(field: .scenario, op: .equals, values: ["x"])]
        sut.message = "m"
        sut.selectedChannelIds = [1]
        mockHttp.stubbedErrorsByEndpoint["/api/v1/notifications"] = HttpClientError.httpError(statusCode: 500)
        let saved = await sut.save()
        XCTAssertNil(saved)
        XCTAssertTrue(sut.saveError)
    }
}
