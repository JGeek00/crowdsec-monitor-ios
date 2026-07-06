import Foundation
import SwiftUI

@Observable
class ServerListItemViewModel {
    @ObservationIgnored private let serversManagerRepository: ServersManagerRepository
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    
    init(serversManagerRepository: ServersManagerRepository = RepositoriesContainer.shared.serversManagerRepository, activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.serversManagerRepository = serversManagerRepository
        self.activeServerRepository = activeServerRepository
    }
    
    var currentServer: CSServer? {
        activeServerRepository.currentServer
    }
    
    func changeCurrentServer(server: CSServer) {
        serversManagerRepository.changeCurrentServer(server: server)
    }
    
    func setDefaultServer(_ server: CSServer) -> Bool {
        serversManagerRepository.setDefaultServer(server)
    }
    
    func deleteServer(server: CSServer) -> Bool {
        serversManagerRepository.deleteServer(server: server)
    }
}
