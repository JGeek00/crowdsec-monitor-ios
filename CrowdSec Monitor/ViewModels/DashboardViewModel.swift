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
        do {
            let result = try await apiClient.statistics.fetchStatistics()
            state = .success(result.body)
        } catch {
            print(error)
            state = .failure(error)
        }
    }
        
}
