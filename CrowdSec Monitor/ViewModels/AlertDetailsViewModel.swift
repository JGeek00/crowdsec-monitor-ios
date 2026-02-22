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
                withAnimation {
                    state = .loading
                }
            }
            
            let response = try await apiClient.alerts.fetchAlertDetails(alertId: alertId)
            withAnimation {
                state = .success(response.body)
            }
        } catch {
            withAnimation {
                state = .failure(error)
            }
        }
    }
    
    func updateAlertId(alertId: Int) {
        self.alertId = alertId
        Task {
            await fetchData(showLoading: true)
        }
    }
}
