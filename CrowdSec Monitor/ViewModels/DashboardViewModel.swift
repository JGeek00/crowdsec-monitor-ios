import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    private let apiClient: CrowdSecAPIClient
    
    init(_ apiClient: CrowdSecAPIClient) {
        self.apiClient = apiClient
    }
    
    var state: Enums.LoadingState<StatisticsResponse> = .loading
    
    func fetchDashboardData() async {
        let amountItems = UserDefaults.shared.object(forKey: StorageKeys.topItemsDashboard) as! Int? ?? Defaults.topItemsDashboard
        do {
            let result = try await apiClient.statistics.fetchStatistics(amount: amountItems)
            state = .success(result.body)
        } catch {
            print(error)
            state = .failure(error)
        }
    }
        
}
