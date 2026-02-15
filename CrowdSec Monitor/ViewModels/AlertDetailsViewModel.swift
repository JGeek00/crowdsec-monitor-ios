import Foundation
import SwiftUI

@MainActor
@Observable
class AlertDetailsViewModel {
    private let apiClient: CrowdSecAPIClient
    let alertId: Int
    
    init(_ apiClient: CrowdSecAPIClient, alertId: Int) {
        self.apiClient = apiClient
        self.alertId = alertId
    }
    
    var state: Enums.LoadingState<AlertDetailsResponse> = .loading
    
    func fetchData() async {
        do {
            let response = try await apiClient.alerts.fetchAlertDetails(alertId: alertId)
            state = .success(response.body)
        } catch {
            state = .failure(error)
        }
    }
}
