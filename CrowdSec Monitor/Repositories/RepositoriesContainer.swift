import Foundation
import SwiftUI

class RepositoriesContainer {
    static var shared = RepositoriesContainer()

    let activeServerRepository: ActiveServerRepository = ActiveServerRepository()
    
    lazy var serversManagerRepository: ServersManagerRepository = {
        return ServersManagerRepository(activeServerRepository: activeServerRepository)
    }()
    
    lazy var serviceStatusRepository: ServiceStatusRepository = {
        serversManagerRepository.activateInitialServer()
        return ServiceStatusRepository(activeServerRepository: activeServerRepository)
    }()

    static func reset() {
        Self.shared = RepositoriesContainer()
        Task { @MainActor in
            NotificationCenter.default.post(name: .repositoriesDidReset, object: nil)
        }
    }
}
