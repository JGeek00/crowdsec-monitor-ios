import SwiftUI

@MainActor
@Observable
class BlocklistDetailsViewModel {
    var blocklistId: Int
    
    init(blocklistId: Int) {
        self.blocklistId = blocklistId
        
        Task {
            await fetchData()
        }
    }
    
    var status: Enums.LoadingState<BlocklistDataResponse> = .loading
    var ipsRound = 1
    
    var searchPresented = false
    var searchText = ""
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            if showLoading {
                withAnimation {
                    status = .loading
                }
            }
            
            let response = try await apiClient.blocklists.fetchBlocklistData(blocklistId: blocklistId)
            withAnimation {
                status = .success(response.body)
            }
        } catch {
            withAnimation {
                status = .failure(error)
            }
        }
    }
    
    func updateBlocklistId(_ newId: Int) {
        self.blocklistId = newId
        self.ipsRound = 1
        Task {
            await fetchData(showLoading: true)
        }
    }
    
    func incrementIpsRound() {
        ipsRound += 1
    }
}
