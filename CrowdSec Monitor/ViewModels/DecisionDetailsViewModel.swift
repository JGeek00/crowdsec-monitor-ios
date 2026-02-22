import SwiftUI

@MainActor
@Observable
class DecisionDetailsViewModel {
    var decisionId: Int
    
    init(decisionId: Int) {
        self.decisionId = decisionId
        
        Task {
            await fetchData()
        }
    }
    
    var state: Enums.LoadingState<DecisionItemResponse> = .loading
    var processingExpireDecision = false
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
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
            let result = await DecisionsListViewModel.shared.expireDecision(decisionId: decisionId)
            await fetchData()
            processingExpireDecision = false
            return result
        }
    }
}
