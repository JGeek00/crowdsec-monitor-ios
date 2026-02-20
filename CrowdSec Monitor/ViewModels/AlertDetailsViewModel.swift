import SwiftUI

@MainActor
@Observable
class AlertDetailsViewModel {
    var alertId: Int
    
    init(alertId: Int) {
        self.alertId = alertId
        
        Task {
            await fetchData()
        }
    }
    
    var state: Enums.LoadingState<AlertDetailsResponse> = .loading
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            if showLoading == true {
                state = .loading
            }
            
            let response = try await apiClient.alerts.fetchAlertDetails(alertId: alertId)
            state = .success(response.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func updateAlertId(alertId: Int) {
        self.alertId = alertId
        Task {
            await fetchData(showLoading: true)
        }
    }
    
    func handleDecisionExpire(decisionId: Int) async -> Bool {
        let decisionDeleted = await DecisionsListViewModel.shared.expireDecision(decisionId: decisionId)
        if decisionDeleted == true {
            await fetchData(showLoading: true)
            return true
        }
        else {
            return false
        }
    }
}
