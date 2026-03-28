import SwiftUI

@MainActor
@Observable
class ServerStatusViewModel {
    public static let shared = ServerStatusViewModel()
    
    init() {
        if AuthViewModel.shared.apiClient != nil {
            Task {
                await fetchStatus()
            }
        }
    }
        
    var status: Enums.LoadingState<ApiStatusResponse> = .loading
    
    func reset() {
        status = .loading
    }
    
    func fetchStatus() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            let response = try await apiClient.checkApiStatus()
            status = .success(response.body)
        } catch {
            status = .failure(error)
        }
    }
}
