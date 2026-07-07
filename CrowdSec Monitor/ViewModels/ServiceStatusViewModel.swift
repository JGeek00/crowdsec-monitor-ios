import Foundation
import SwiftUI

@MainActor
@Observable
class ServiceStatusViewModel {
    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository

    init(serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository) {
        self.serviceStatusRepository = serviceStatusRepository
    }

    var state: Enums.LoadingState<APIStatusResponse> {
        serviceStatusRepository.state
    }
}
