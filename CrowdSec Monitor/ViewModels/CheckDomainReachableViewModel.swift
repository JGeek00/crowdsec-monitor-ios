import SwiftUI
import Network

@MainActor
@Observable
class CheckDomainReachableViewModel {
    init() {}
    
    var domain: String = ""
    var invalidDomainAlert = false
    
    var data: BlocklistsCheckDomainResponse? = nil
    var error = false
    var domainNotResolvable = false
    var loading = false
    
    func checkDomain() {
        if (try? RegExps.domain.wholeMatch(in: domain)) == nil {
            invalidDomainAlert = true
            return
        }
        
        Task {
            guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
            withAnimation {
                self.loading = true
            }
            do {
                let body = BlocklistsCheckDomainRequest(domain: domain)
                
                let result = try await apiClient.blocklists.checkDomain(body)
                
                withAnimation {
                    self.data = result.body
                    self.loading = false
                    self.error = false
                    self.domainNotResolvable = false
                }
            } catch HttpClientError.httpErrorWithMessage(let statusCode, _) where statusCode == 422 {
                withAnimation {
                    self.data = nil
                    self.error = false
                    self.domainNotResolvable = true
                    self.loading = false
                }
            } catch {
                withAnimation {
                    self.data = nil
                    self.error = true
                    self.domainNotResolvable = false
                    self.loading = false
                }
            }
        }
    }
}
