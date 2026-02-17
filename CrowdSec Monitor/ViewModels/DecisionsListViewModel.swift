import Foundation
import SwiftUI

fileprivate var defaultRequest = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: Defaults.showDefaultActiveDecisions), pagination: DecisionsRequestPagination(offset: 0, limit: Config.alertsAmoutBatch))

@MainActor
@Observable
class DecisionsListViewModel {
    public static let shared = DecisionsListViewModel()
        
    var requestParams: DecisionsRequest
    
    init() {
        let defaultOnlyActive = UserDefaults.shared.object(forKey: StorageKeys.showDefaultActiveDecisions) as! Bool? ?? Defaults.showDefaultActiveDecisions
        defaultRequest.filters.onlyActive = defaultOnlyActive
        self.requestParams = defaultRequest
    }
    
    var state: Enums.LoadingState<DecisionsListResponse> = .loading
    
    func initialFetchDecisions(force: Bool = false) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        if state.data != nil && !force {
            return
        }
        
        do {
            let result = try await apiClient.decisions.fetchDecisions(requestParams: requestParams)
            state = .success(result.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func refreshDecisions() async {
        await initialFetchDecisions(force: true)
    }

    func fetchMore() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        if let data = state.data {
            if (data.pagination.page * Config.alertsAmoutBatch) >= data.pagination.total {
                return
            }
            
            let previousItems = data.items
            let newOffset = data.pagination.page * Config.alertsAmoutBatch
            requestParams.pagination.offset = newOffset

            do {
                let result = try await apiClient.decisions.fetchDecisions(requestParams: requestParams)
                
                let existingIDs = Set(previousItems.map { $0.id })
                let uniqueNewItems = result.body.items.filter { !existingIDs.contains($0.id) }
                
                let newItems = previousItems + uniqueNewItems
                let newResponse = DecisionsListResponse(filtering: result.body.filtering, items: newItems, pagination: result.body.pagination)
                state = .success(newResponse)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func updateFilters(_ filters: DecisionsRequestFilters) {
        requestParams.filters = filters
    }
}
