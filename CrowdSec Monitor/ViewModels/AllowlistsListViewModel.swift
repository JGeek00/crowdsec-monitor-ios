import SwiftUI

@MainActor
@Observable
class AllowlistsListViewModel {
    static let shared = AllowlistsListViewModel()
    
    init() {}
    
    var state: Enums.LoadingState<AllowlistsListResponse> = .loading
    
    func reset() {
        state = .loading
    }
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            if showLoading == true {
                withAnimation {
                    state = .loading
                }
            }
            
            let response = try await apiClient.allowlists.fetchAllowlists()
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
