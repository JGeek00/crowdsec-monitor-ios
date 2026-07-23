import SwiftUI

@MainActor
@Observable
class DecisionIPGroupDetailViewModel {
    var ip: String
    let onlyActive: Bool

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    init(
        ip: String,
        onlyActive: Bool,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository
    ) {
        self.ip = ip
        self.onlyActive = onlyActive
        self.activeServerRepository = activeServerRepository

        Task {
            await fetchData()
        }
    }

    var state: Enums.LoadingState<DecisionsByIPDetailResponse> = .loading
    var processingExpireDecision = false

    func updateIP(ip: String) {
        self.ip = ip
        Task {
            await fetchData(showLoading: true)
        }
    }

    func expireDecision(decisionId: Int) async -> Bool {
        guard let apiClient = activeServerRepository.apiClient else { return false }
        do {
            processingExpireDecision = true
            _ = try await apiClient.decisions.deleteDecision(decisionId: decisionId)
            NotificationCenter.default.post(name: .decisionShouldExpire, object: decisionId)
            try? await Task.sleep(nanoseconds: 500_000_000)
            await fetchData()
            processingExpireDecision = false
            return true
        } catch {
            processingExpireDecision = false
            return false
        }
    }

    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else {
            return
        }
        do {
            if showLoading {
                withAnimation { state = .loading }
            }

            let response = try await apiClient.decisions.fetchDecisionsByIPDetail(ip: ip, onlyActive: onlyActive)
            withAnimation { state = .success(response.body) }
        } catch {
            withAnimation { state = .failure(error) }
        }
    }
}
