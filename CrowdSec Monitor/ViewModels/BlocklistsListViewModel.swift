import SwiftUI

@MainActor
@Observable
class BlocklistsListViewModel {
    static let shared = BlocklistsListViewModel()
    
    init() {}
    
    var state: Enums.LoadingState<BlocklistsListResponse> = .loading
    var selectedListName: String? = nil
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            if showLoading == true {
                withAnimation {
                    state = .loading
                }
            }
            
            let response = try await apiClient.blocklists.fetchBlocklists()
            withAnimation {
                state = .success(response.body)
            }
        } catch {
            withAnimation {
                state = .failure(error)
            }
        }
    }
}
