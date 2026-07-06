import Foundation
import SwiftUI

@MainActor
@Observable
class AllowlistsListViewModel {
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        self.activeServerRepository = activeServerRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.reset()
        }
    }
    
    var state: Enums.LoadingState<AllowlistsListResponse> = .loading
    
    func reset() {
        state = .loading
    }
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
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
