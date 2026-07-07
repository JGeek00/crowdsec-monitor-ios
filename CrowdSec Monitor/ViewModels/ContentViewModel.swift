import Foundation
import SwiftUI

@MainActor
@Observable
class ContentViewModel {
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository, serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository) {
        self.activeServerRepository = activeServerRepository
        self.serviceStatusRepository = serviceStatusRepository
    }

    var hasServerConfigured: Bool {
        activeServerRepository.hasServerConfigured
    }

    var hasNewVersion: Bool {
        serviceStatusRepository.state.data?.csMonitorAPI.newVersionAvailable != nil
    }

    func closeWebSocket() {
        serviceStatusRepository.closeWebSocket()
    }

    func openWebSocket() {
        serviceStatusRepository.openWebSocket()
    }
}
