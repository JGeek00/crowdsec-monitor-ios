@testable import CrowdSec_Monitor
import XCTest

@MainActor
final class ChannelFormViewModelTests: XCTestCase {
    private func makeSUT(editing: UserNotificationChannel? = nil) -> (ChannelFormViewModel, MockHttpClient) {
        let (mockHttp, _, activeRepo) = TestViewModelFactory.makeStack()
        return (ChannelFormViewModel(editing: editing, activeServerRepository: activeRepo), mockHttp)
    }

    private func makeChannel() -> UserNotificationChannel {
        UserNotificationChannel(
            id: 5, name: "phone", type: .ntfy,
            config: NotificationChannelConfig(topic: "alerts"),
            createdAt: nil, updatedAt: nil
        )
    }

    func testProviderRequired() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.providerValid())
        sut.provider = .ntfy
        XCTAssertFalse(sut.providerValid())
        sut.ntfyTopic = "my-topic"
        XCTAssertTrue(sut.providerValid())
    }

    func testEmailValidation() {
        let (sut, _) = makeSUT()
        sut.provider = .email
        XCTAssertFalse(sut.providerValid())
        sut.emailHost = "smtp.example.com"
        sut.emailFrom = "a@b.c"
        sut.emailTo = "d@e.f"
        XCTAssertTrue(sut.providerValid())
        XCTAssertEqual(sut.buildConfig()?.port, 587)
    }

    func testEditPrefills() {
        let (sut, _) = makeSUT(editing: makeChannel())
        XCTAssertTrue(sut.isEditing)
        XCTAssertEqual(sut.provider, .ntfy)
        XCTAssertEqual(sut.name, "phone")
        XCTAssertEqual(sut.ntfyTopic, "alerts")
    }

    func testSaveCreate() async {
        let (sut, mockHttp) = makeSUT()
        sut.provider = .email
        sut.name = "ops"
        sut.emailHost = "h"
        sut.emailFrom = "a@b.c"
        sut.emailTo = "d@e.f"
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels"] = TestViewModelFactory.encode(
            NotificationChannelDetailResponse(data: makeChannel())
        )
        let saved = await sut.save()
        XCTAssertNotNil(saved)
        XCTAssertEqual(mockHttp.capturedEndpoint, "/api/v1/notification-channels")
    }

    func testInlineTestSuccess() async {
        let (sut, mockHttp) = makeSUT()
        sut.provider = .ntfy
        sut.name = "phone"
        sut.ntfyTopic = "t"
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/test"] = TestViewModelFactory.encode(
            ChannelTestResponse(data: ChannelTestResult(channelId: nil, ok: true, detail: nil))
        )
        await sut.test()
        XCTAssertEqual(sut.testState, .success)
    }

    func testInlineTestFailureDetail() async {
        let (sut, mockHttp) = makeSUT()
        sut.provider = .ntfy
        sut.name = "phone"
        sut.ntfyTopic = "t"
        mockHttp.stubbedResponsesByEndpoint["/api/v1/notification-channels/test"] = TestViewModelFactory.encode(
            ChannelTestResponse(data: ChannelTestResult(channelId: nil, ok: false, detail: "boom"))
        )
        await sut.test()
        XCTAssertEqual(sut.testState, .failure("boom"))
    }
}
