import SwiftUI
import Network

struct IPField: Equatable {
    var value: String
    var invalid: Bool
    
    init() {
        self.value = ""
        self.invalid = false
    }
    
    init(value: String, invalid: Bool = false) {
        self.value = value
        self.invalid = invalid
    }
    
    static func == (lhs: IPField, rhs: IPField) -> Bool {
        lhs.value == rhs.value && lhs.invalid == rhs.invalid
    }
}

@MainActor
@Observable
class IPsCheckerViewModel {
    init() {}
    
    var ipsToCheck: [IPField] = []
    var selectedListType: Enums.ListType = .blocklist
    
    var state: Enums.LoadingState<CheckIPsResponse> = .loading
    
    func validateIP(_ index: Int) {
        let ip = ipsToCheck[index]
        ipsToCheck[index].invalid = IPv4Address(ip.value) == nil && IPv6Address(ip.value) == nil
    }
    
    func addEntry() {
        ipsToCheck.append(IPField())
    }
    
    func removeEntry(at indexSet: IndexSet) {
        ipsToCheck.remove(atOffsets: indexSet)
    }
    
    func validateIps() {
        Task {
            guard let apiClient = AuthViewModel.shared.apiClient else { return }
            withAnimation {
                state = .loading
            }
            do {
                let map = ipsToCheck.map() { $0.value }
                let body = CheckIPsRequest(ips: map)
                
                let result = try await {
                    switch self.selectedListType {
                    case .blocklist:
                        return try await apiClient.blocklists.checkIps(body)
                    case .allowlist:
                        return try await apiClient.allowlists.checkIps(body)
                    }
                }()
                
                withAnimation {
                    state = .success(result.body)
                }
            } catch {
                withAnimation {
                    state = .failure(error)
                }
            }
        }
    }
}
