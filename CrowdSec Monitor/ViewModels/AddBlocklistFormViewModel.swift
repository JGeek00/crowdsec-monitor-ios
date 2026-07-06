import Foundation
import SwiftUI

@MainActor
@Observable
class AddBlocklistFormViewModel {
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    
    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.activeServerRepository = activeServerRepository
    }
    
    var name: String = ""
    var url: String = ""
    var isSaving: Bool = false
    var requiredFieldsError: Bool = false
    var invalidUrlError: Bool = false
    var error: Bool = false
    
    func createBlocklist(name: String, url: String) async {
        if url.isEmpty || name.isEmpty {
            requiredFieldsError = true
            return
        }
        
        if NSPredicate(format: "SELF MATCHES %@", RegExps.url).evaluate(with: url) == false {
            invalidUrlError = true
            return
        }
        
        guard let apiClient = activeServerRepository.apiClient else { return }
        
        isSaving = true
        
        do {
            let body = AddBlocklistRequestBody(name: name, url: url)
            _ = try await apiClient.blocklists.addBlocklist(body: body)
            self.isSaving = false
        } catch {
            self.error = true
            self.isSaving = false
        }
    }
}
