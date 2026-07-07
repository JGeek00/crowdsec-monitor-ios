import Foundation
import SwiftUI

@MainActor
@Observable
class InformationSectionViewModel {
    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    init(serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository, activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.serviceStatusRepository = serviceStatusRepository
        self.activeServerRepository = activeServerRepository
    }

    var hasServerConfigured: Bool {
        activeServerRepository.hasServerConfigured
    }

    var state: Enums.LoadingState<APIStatusResponse> {
        serviceStatusRepository.state
    }
}
