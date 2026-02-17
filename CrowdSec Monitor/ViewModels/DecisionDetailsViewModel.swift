import SwiftUI

@MainActor
@Observable
class DecisionDetailsViewModel {
    var decisionId: Int
    
    init(decisionId: Int) {
        self.decisionId = decisionId
    }
    
    var state: Enums.LoadingState<DecisionItemResponse> = .loading
    
    func fetchData() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            let response = try await apiClient.decisions.fetchDecisionDetails(decisionId: decisionId)
            state = .success(response.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func updateDecisionId(decisionId: Int) {
        self.decisionId = decisionId
        Task {
            await fetchData()
        }
    }
}
