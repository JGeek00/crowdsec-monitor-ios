import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let serversManagerRepository: ServersManagerRepository
    private let serviceStatusRepository: ServiceStatusRepository

    var state: Enums.LoadingState<StatisticsResponse> = .loading

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository, serversManagerRepository: ServersManagerRepository = RepositoriesContainer.shared.serversManagerRepository, serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository) {
        self.activeServerRepository = activeServerRepository
        self.serversManagerRepository = serversManagerRepository
        self.serviceStatusRepository = serviceStatusRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reset()
            }
        }
    }
    
    var currentServer: CSServer? {
        activeServerRepository.currentServer
    }
    
    var servers: [CSServer] {
        serversManagerRepository.servers
    }
    
    var serviceStatusState: Enums.LoadingState<APIStatusResponse> {
        serviceStatusRepository.state
    }
    
    func changeCurrentServer(server: CSServer) {
        serversManagerRepository.changeCurrentServer(server: server)
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
        guard let apiClient = activeServerRepository.apiClient else { return }
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
