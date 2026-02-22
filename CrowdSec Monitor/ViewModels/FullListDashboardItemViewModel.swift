import Foundation
import SwiftUI

struct FullItemDashboardItemData: Hashable {
    let item: String
    let value: Int
}

struct FullItemDashboardItemDataForView: Hashable {
    let item: String
    let value: Int
    let percentage: Double
    let color: Color
}

@MainActor
@Observable
class FullListDashboardItemViewModel {
    let dashboardItem: Enums.DashboardItemType
    
    init(dashboardItem: Enums.DashboardItemType) {
        self.dashboardItem = dashboardItem
    }
    
    var state: Enums.LoadingState<[FullItemDashboardItemDataForView]> = .loading
    
    var chartData: [FullItemDashboardItemDataForView] {
        guard case .success(let data) = state else { return [] }
        
        let maxColoredItems = colors.count
        guard data.count > maxColoredItems else { return data }
        
        var result = Array(data.prefix(maxColoredItems))
        
        let othersItems = data.suffix(from: maxColoredItems)
        let othersTotal = othersItems.reduce(0) { $0 + $1.value }
        let othersPercentage = othersItems.reduce(0.0) { $0 + $1.percentage }
        
        result.append(FullItemDashboardItemDataForView(
            item: "Otros",
            value: othersTotal,
            percentage: othersPercentage,
            color: .gray
        ))
        
        return result
    }
    
    private func generateViewData(_ value: [FullItemDashboardItemData]) -> [FullItemDashboardItemDataForView] {
        let totalAmount = value.reduce(0) { $0 + $1.value }
        return value.map { item in
            let index = value.firstIndex(of: item) ?? 0
            let percentage = totalAmount > 0 ? Double(item.value) / Double(totalAmount) : 0
            let color = {
                if index < colors.count {
                    return colors[index]
                } else {
                    return Color.gray
                }
            }()
            return FullItemDashboardItemDataForView(item: item.item, value: item.value, percentage: percentage, color: color)
        }
    }
    
    func fetchData() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            switch self.dashboardItem {
            case .country:
                let result = try await apiClient.statistics.countries.fetchCountriesStatistics()
                withAnimation {
                    state = .success(generateViewData(result.body.map { FullItemDashboardItemData(item: $0.countryCode, value: $0.amount) }))
                }
            case .ipOwner:
                let result = try await apiClient.statistics.ipOwners.fetchIpOwnersStatistics()
                withAnimation {
                    state = .success(generateViewData(result.body.map { FullItemDashboardItemData(item: $0.ipOwner, value: $0.amount) }))
                }
            case .scenary:
                let result = try await apiClient.statistics.scenarios.fetchScenariosStatistics()
                withAnimation {
                    state = .success(generateViewData(result.body.map { FullItemDashboardItemData(item: $0.scenario, value: $0.amount) }))
                }
            case .target:
                let result = try await apiClient.statistics.targets.fetchTargetsStatistics()
                withAnimation {
                    state = .success(generateViewData(result.body.map { FullItemDashboardItemData(item: $0.target, value: $0.amount) }))
                }
            }
        } catch {
            withAnimation {
                state = .failure(error)
            }
        }
    }
}
