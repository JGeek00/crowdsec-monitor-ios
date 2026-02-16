import SwiftUI

@MainActor
@Observable
class AlertDetailsViewModel {
    var alertId: Int
    
    init(alertId: Int) {
        self.alertId = alertId
    }
    
    var state: Enums.LoadingState<AlertDetailsResponse> = .loading
    
    func fetchData() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            let response = try await apiClient.alerts.fetchAlertDetails(alertId: alertId)
            state = .success(response.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func updateAlertId(alertId: Int) {
        self.alertId = alertId
        Task {
            await fetchData()
        }
    }
}
