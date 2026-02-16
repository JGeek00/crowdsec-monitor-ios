import SwiftUI

@MainActor
@Observable
class AlertDetailsViewModel {
    public static let shared = AlertDetailsViewModel()
    
    var state: Enums.LoadingState<AlertDetailsResponse> = .loading
    
    func fetchData(alertId: Int, showLoader: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            if showLoader == true {
                state = .loading
            }
            let response = try await apiClient.alerts.fetchAlertDetails(alertId: alertId)
            state = .success(response.body)
        } catch {
            state = .failure(error)
        }
    }
}
