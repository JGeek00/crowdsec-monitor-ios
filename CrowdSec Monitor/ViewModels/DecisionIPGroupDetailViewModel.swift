import SwiftUI

@MainActor
@Observable
class DecisionIPGroupDetailViewModel {
    let ip: String
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
