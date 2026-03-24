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
    
    var stateAllowlists: Enums.LoadingState<AllowlistsCheckIPsResponse> = .loading
    var stateBlocklists: Enums.LoadingState<BlocklistsCheckIPsResponse> = .loading
    
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
            switch selectedListType {
            case .allowlist:
                do {
                    withAnimation {
                        stateAllowlists = .loading
                    }
                    let map = ipsToCheck.map() { $0.value }
                    let body = AllowlistsCheckIPsRequest(ips: map)
                    let result = try await apiClient.allowlists.checkIps(body)
                    withAnimation {
                        stateAllowlists = .success(result.body)
                    }
                } catch {
                    withAnimation {
                        stateAllowlists = .failure(error)
                    }
                }
            case .blocklist:
                do {
                    withAnimation {
                        stateBlocklists = .loading
                    }
                    let map = ipsToCheck.map() { $0.value }
                    let body = BlocklistsCheckIPsRequest(ips: map)
                    let result = try await apiClient.blocklists.checkIps(body)
                    withAnimation {
                        stateBlocklists = .success(result.body)
                    }
                } catch {
                    withAnimation {
                        stateBlocklists = .failure(error)
                    }
                }
            }
        }
    }
}
