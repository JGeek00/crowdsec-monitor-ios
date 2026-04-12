import SwiftUI

@MainActor
@Observable
class AllowlistsListViewModel: Resettable {
    static let shared = AllowlistsListViewModel()
    
    init() {
        ActiveServerViewModel.shared.register(self)
    }
    
    var state: Enums.LoadingState<AllowlistsListResponse> = .loading
    
    func reset() {
        state = .loading
    }
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = ActiveServerViewModel.shared.apiClient else { return }
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
            guard !(error is CancellationError) else { return }
            withAnimation {
                state = .failure(error)
            }
        }
    }
}
