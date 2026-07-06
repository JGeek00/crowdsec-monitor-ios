import SwiftUI

@MainActor
@Observable
class DecisionDetailsViewModel {
    var decisionId: Int
    
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    
    init(
        decisionId: Int,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository
    ) {
        self.decisionId = decisionId
        self.activeServerRepository = activeServerRepository
        
        Task {
            await fetchData()
        }
    }
    
    var state: Enums.LoadingState<DecisionItemResponse> = .loading
    var processingExpireDecision = false
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            if showLoading == true {
                withAnimation {
                    state = .loading
                }
            }
            
            let response = try await apiClient.decisions.fetchDecisionDetails(decisionId: decisionId)
            withAnimation {
                state = .success(response.body)
            }
        } catch {
            withAnimation {
                state = .failure(error)
            }
        }
    }
    
    func updateDecisionId(decisionId: Int) {
        self.decisionId = decisionId
        Task {
            await fetchData(showLoading: true)
        }
    }
    
    func expireDecision() {
        Task {
            processingExpireDecision = true
            NotificationCenter.default.post(name: .decisionShouldExpire, object: decisionId)
            try? await Task.sleep(nanoseconds: 500_000_000)
            await fetchData()
            processingExpireDecision = false
        }
    }
}
