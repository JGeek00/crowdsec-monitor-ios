import Foundation
import SwiftUI

struct FullItemDashboardItemData: Hashable {
    let item: String
    let value: Int
}

@MainActor
@Observable
class FullListDashboardItemViewModel {
    private let apiClient: CrowdSecAPIClient
    let dashboardItem: Enums.DashboardItemType
    
    init(_ apiClient: CrowdSecAPIClient, dashboardItem: Enums.DashboardItemType) {
        self.apiClient = apiClient
        self.dashboardItem = dashboardItem
    }
    
    var state: Enums.LoadingState<[FullItemDashboardItemData]> = .loading
    
    func fetchData() async {
        do {
            switch self.dashboardItem {
            case .country:
                let result = try await self.apiClient.statistics.countries.fetchCountriesStatistics()
                state = .success(result.body.map { FullItemDashboardItemData(item: $0.countryCode, value: $0.amount) })
            case .ipOwner:
                let result = try await self.apiClient.statistics.ipOwners.fetchIpOwnersStatistics()
                state = .success(result.body.map { FullItemDashboardItemData(item: $0.ipOwner, value: $0.amount) })
            case .scenary:
                let result = try await self.apiClient.statistics.scenaries.fetchScenariesStatistics()
                state = .success(result.body.map { FullItemDashboardItemData(item: $0.scenario, value: $0.amount) })
            case .target:
                let result = try await self.apiClient.statistics.targets.fetchTargetsStatistics()
                state = .success(result.body.map { FullItemDashboardItemData(item: $0.target, value: $0.amount) })
            }
        } catch {
            state = .failure(error)
        }
    }
}
