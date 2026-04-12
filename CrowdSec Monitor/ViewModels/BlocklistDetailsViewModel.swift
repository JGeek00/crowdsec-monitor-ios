import SwiftUI

@MainActor
@Observable
class BlocklistDetailsViewModel {
    var blocklistId: String
    
    init(blocklistId: String) {
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
        guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
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
        } catch let error {
            print(error.localizedDescription)
            withAnimation {
                status = .failure(error)
            }
        }
    }
    
    func updateBlocklistId(_ newId: String) {
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
