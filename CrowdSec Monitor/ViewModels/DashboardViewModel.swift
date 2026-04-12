import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel: Resettable {
    public static let shared = DashboardViewModel()
    
    var state: Enums.LoadingState<StatisticsResponse> = .loading
    
    private init() {
        ActiveServerViewModel.shared.register(self)
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
    
    func reset() {
        state = .loading
    }
    
    func fetchDashboardData() async {
        guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
        let amountItems = UserDefaults.shared.object(forKey: StorageKeys.topItemsDashboard) as! Int? ?? Defaults.topItemsDashboard
        do {
            let result = try await apiClient.statistics.fetchStatistics(amount: amountItems)
            withAnimation {
                state = .success(result.body)
            }
        } catch {
            guard !(error is CancellationError) else { return }
            withAnimation {
                state = .failure(error)
            }
        }
    }
        
}
