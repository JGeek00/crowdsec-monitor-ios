import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    public static let shared = DashboardViewModel()
    
    var state: Enums.LoadingState<StatisticsResponse> = .loading
    
    func fetchDashboardData() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        let amountItems = UserDefaults.shared.object(forKey: StorageKeys.topItemsDashboard) as! Int? ?? Defaults.topItemsDashboard
        do {
            let result = try await apiClient.statistics.fetchStatistics(amount: amountItems)
            state = .success(result.body)
        } catch {
            state = .failure(error)
        }
    }
        
}
