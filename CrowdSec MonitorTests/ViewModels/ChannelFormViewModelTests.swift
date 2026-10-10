@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ChannelFormViewModelTests: XCTestCase {
    private func field(
        _ key: String,
        type: String,
        section: String? = nil,
        required: Bool = false,
        secret: Bool? = nil,
        default defaultValue: JSONValue? = nil,
        regex: String? = nil,
        integer: Bool? = nil,
        min: Double? = nil,
        max: Double? = nil,
        options: [String]? = nil,
        requiredIf: ProviderFieldCondition? = nil,
        exclusiveWith: [String]? = nil,
        visibleIf: ProviderFieldCondition? = nil
    ) -> ProviderField {
        ProviderField(
            key: key, section: section, labelKey: "field_\(key)", placeholderKey: nil, type: type, list: nil,
            required: required, secret: secret, defaultValue: defaultValue, regex: regex,
            minLength: nil, maxLength: nil, min: min, max: max, integer: integer,
            options: options?.map { ProviderFieldOption(value: $0, labelKey: "opt_\($0)") },
            requiredIf: requiredIf, exclusiveWith: exclusiveWith, visibleIf: visibleIf
        )
    }

    private func ntfyProvider() -> NotificationProvider {
        NotificationProvider(
            type: "ntfy", descriptionKey: nil, icon: "ntfy", labelKey: "provider_ntfy",
            supportsTest: true, supportsAlertInfo: false, sections: [],
            fields: [
                field("topic", type: "text", required: true, regex: "^[-_A-Za-z0-9]{1,64}$"),
                field("server", type: "url", default: .string("https://ntfy.sh")),
                field("username", type: "text"),
                field(
                    "password", type: "password", secret: true,
                    requiredIf: ProviderFieldCondition(field: "username", equals: nil, present: true),
                    visibleIf: ProviderFieldCondition(field: "username", equals: nil, present: true)
                ),
                field(
                    "accessToken", type: "password", secret: true,
                    exclusiveWith: ["username", "password"]
                ),
                field("priority", type: "select", default: .string("default")),
            ]
        )
    }

    private func emailProvider() -> NotificationProvider {
        NotificationProvider(
            type: "email", descriptionKey: nil, icon: "email", labelKey: "provider_email",
            supportsTest: true, supportsAlertInfo: false, sections: [],
            fields: [
                field("host", type: "text", required: true),
                field("port", type: "number", default: .int(587), integer: true, min: 1, max: 65535),
                field("secure", type: "boolean", default: .bool(false)),
                field("from", type: "email", required: true),
                field("to", type: "email", required: true),
            ]
        )
    }

    private func makeProvider(fields: [ProviderField], sections: [ProviderSection] = []) -> NotificationProvider {
        NotificationProvider(
            type: "t", descriptionKey: nil, icon: "t", labelKey: "p",
            supportsTest: true, supportsAlertInfo: false, sections: sections, fields: fields
        )

    }

    private func sectionedField(_ key: String, section: String?) -> ProviderField {
        ProviderField(
            key: key, section: section, labelKey: "l_\(key)", placeholderKey: nil,
            type: "text", list: nil, required: nil, secret: nil, defaultValue: nil,
            regex: nil, minLength: nil, maxLength: nil, min: nil, max: nil,
            integer: nil, options: nil, requiredIf: nil, exclusiveWith: nil, visibleIf: nil
        )
    }

    func testGroupedFields() {
        let (sut, _) = makeSUT()
        sut.providers = [makeProvider(
            fields: [
                sectionedField("ungrouped", section: nil),
                sectionedField("b1", section: "s2"),
                sectionedField("a1", section: "s1"),
                sectionedField("weird", section: "nope"),
            ],
            sections: [ProviderSection(key: "s1", labelKey: "ls1"), ProviderSection(key: "s2", labelKey: "ls2")]
        )]
        sut.providerType = "t"
        let groups = sut.groupedFields()
        XCTAssertEqual(groups.map { $0.section?.key }, ["s1", "s2", nil])
        XCTAssertEqual(groups[0].fields.map { $0.key }, ["a1"])
        XCTAssertEqual(groups[1].fields.map { $0.key }, ["b1"])
        XCTAssertEqual(groups[2].fields.map { $0.key }, ["ungrouped", "weird"])
    }

    private func makeSUT(editing: UserNotificationChannel? = nil) -> (ChannelFormViewModel, MockHttpClient) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        let sut = ChannelFormViewModel(editing: editing, activeServerRepository: activeRepo)
        sut.providers = [ntfyProvider(), emailProvider()]
        return (sut, mockHttp)
    }

    private func makeChannel() -> UserNotificationChannel {
        UserNotificationChannel(
            id: 5, name: "phone", type: .ntfy,
            supportsAlertInfo: false, config: ["topic": .string("alerts")],
            createdAt: nil, updatedAt: nil
        )
    }

    func testVisibleFieldsRespectVisibleIf() {
        let (sut, _) = makeSUT()
        sut.providerType = "ntfy"
        XCTAssertFalse(sut.visibleFields().map { $0.key }.contains("password"))
        sut.values["username"] = .string("u")
        XCTAssertTrue(sut.visibleFields().map { $0.key }.contains("password"))
    }

    func testNtfyValidation() {
        let (sut, _) = makeSUT()
        sut.providerType = "ntfy"
        XCTAssertFalse(sut.providerValid())
        sut.values["topic"] = .string("bad topic!")
        XCTAssertFalse(sut.providerValid())
        sut.values["topic"] = .string("good-topic")
        XCTAssertTrue(sut.providerValid())
        sut.values["username"] = .string("u")
        XCTAssertFalse(sut.providerValid())
        sut.values["password"] = .string("p")
        XCTAssertTrue(sut.providerValid())
        sut.values["accessToken"] = .string("t")
        XCTAssertFalse(sut.providerValid())
    }

    func testEmailValidationAndCoercion() {
        let (sut, _) = makeSUT()
        sut.providerType = "email"
        XCTAssertFalse(sut.providerValid())
        sut.values["host"] = .string("smtp.example.com")
        sut.values["from"] = .string("nope")
        sut.values["to"] = .string("d@e.f")
        XCTAssertFalse(sut.providerValid())
        sut.values["from"] = .string("a@b.c")
        XCTAssertTrue(sut.providerValid())
        sut.values["port"] = .string("not-a-number")
        XCTAssertFalse(sut.providerValid())
        sut.values["port"] = .string("465")
        XCTAssertTrue(sut.providerValid())
        let payload = sut.buildPayload()
        XCTAssertEqual(payload?["port"], .int(465))
        XCTAssertNil(payload?["username"])
    }

    func testSelectProviderAppliesDefaults() {
        let (sut, _) = makeSUT()
        sut.providers = [ntfyProvider()]
        sut.selectProvider("ntfy")
        XCTAssertEqual(sut.values["priority"], .string("default"))
        XCTAssertFalse(sut.providerValid())
        sut.values["topic"] = .string("t")
        XCTAssertTrue(sut.providerValid())
    }

    func testNumberAcceptsIntValues() {
        let (sut, _) = makeSUT()
        sut.providers = [emailProvider()]
        sut.providerType = "email"
        sut.values["host"] = .string("h")
        sut.values["from"] = .string("a@b.c")
        sut.values["to"] = .string("d@e.f")
        sut.values["port"] = .int(465)
        XCTAssertTrue(sut.providerValid())
        XCTAssertEqual(sut.buildPayload()?["port"], .int(465))
    }

    func testEditPrefills() {
        let (sut, _) = makeSUT(editing: makeChannel())
        XCTAssertTrue(sut.isEditing)
        XCTAssertEqual(sut.providerType, "ntfy")
        XCTAssertEqual(sut.name, "phone")
        XCTAssertEqual(sut.values["topic"], .string("alerts"))
        XCTAssertTrue(sut.providerValid())
    }

    func testLoadProviders() async {
        let (sut, mockHttp) = makeSUT()
        sut.providers = []
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/providers"] =
            TestViewModelFactory.encode(ProvidersListResponse(version: 1, providers: [ntfyProvider()]))
        await sut.loadProviders()
        XCTAssertEqual(sut.providers.count, 1)
        XCTAssertFalse(sut.loadError)
    }

    func testSaveCreate() async {
        let (sut, mockHttp) = makeSUT()
        sut.providerType = "email"
        sut.name = "ops"
        sut.values["host"] = .string("h")
        sut.values["from"] = .string("a@b.c")
        sut.values["to"] = .string("d@e.f")
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels"] = TestViewModelFactory.encode(
            NotificationChannelDetailResponse(data: makeChannel())
        )
        let saved = await sut.save()
        XCTAssertNotNil(saved)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels")
        let body = mockHttp.capturedBody as? CreateChannelRequest
        XCTAssertEqual(body?.type, "email")
    }

    func testInlineTestSuccess() async {
        let (sut, mockHttp) = makeSUT()
        sut.providerType = "ntfy"
        sut.name = "phone"
        sut.values["topic"] = .string("t")
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/test"] = TestViewModelFactory.encode(
            ChannelTestResponse(data: ChannelTestResult(channelId: nil, ok: true, detail: nil))
        )
        await sut.test()
        XCTAssertEqual(sut.testState, .success)
    }

    func testInlineTestFailureDetail() async {
        let (sut, mockHttp) = makeSUT()
        sut.providerType = "ntfy"
        sut.name = "phone"
        sut.values["topic"] = .string("t")
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/test"] = TestViewModelFactory.encode(
            ChannelTestResponse(data: ChannelTestResult(channelId: nil, ok: false, detail: "boom"))
        )
        await sut.test()
        XCTAssertEqual(sut.testState, .failure("boom"))
    }
}
