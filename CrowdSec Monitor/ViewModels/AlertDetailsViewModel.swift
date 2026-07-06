import SwiftUI

@MainActor
@Observable
class AlertDetailsViewModel {
    var alertId: Int
    
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    
    init(
        alertId: Int,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository
    ) {
        self.alertId = alertId
        self.activeServerRepository = activeServerRepository
        
        Task {
            await fetchData()
        }
    }
    
    var state: Enums.LoadingState<AlertDetailsResponse> = .loading
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
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
