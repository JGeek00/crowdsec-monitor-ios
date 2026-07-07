import Foundation
import SwiftUI

@MainActor
@Observable
class SettingsViewModel {
    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository

    init(serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository) {
        self.serviceStatusRepository = serviceStatusRepository
    }

    var hasNewVersion: Bool {
        serviceStatusRepository.state.data?.csMonitorAPI.newVersionAvailable != nil
    }
}
