import Foundation
import SwiftUI

@MainActor
@Observable
class ServerSettingsViewModel {
    @ObservationIgnored private let serversManagerRepository: ServersManagerRepository
    
    init(serversManagerRepository: ServersManagerRepository = RepositoriesContainer.shared.serversManagerRepository) {
        self.serversManagerRepository = serversManagerRepository
    }
    
    var servers: [CSServer] {
        serversManagerRepository.servers
    }
}
