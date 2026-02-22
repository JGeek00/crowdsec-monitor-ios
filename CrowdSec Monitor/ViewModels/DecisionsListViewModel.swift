import Foundation
import SwiftUI

fileprivate var defaultRequest = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: Defaults.showDefaultActiveDecisions), pagination: DecisionsRequestPagination(offset: 0, limit: Config.alertsAmoutBatch))

@MainActor
@Observable
class DecisionsListViewModel {
    public static let shared = DecisionsListViewModel()
        
    // This params are persisted to be sent to the request
    var requestParams: DecisionsRequest
    
    // This are the params that are currently being edited on the filters sheet and haven't been persisted yet to be sent to the request
    var filters: DecisionsRequestFilters
    
    private var isFetching = false
    
    init() {
        let defaultOnlyActive = UserDefaults.shared.object(forKey: StorageKeys.showDefaultActiveDecisions) as! Bool? ?? Defaults.showDefaultActiveDecisions
        defaultRequest.filters.onlyActive = defaultOnlyActive
        
        self.requestParams = defaultRequest
        self.filters = defaultRequest.filters
    }
    
    var state: Enums.LoadingState<DecisionsListResponse> = .loading
    var processingExpireDecision = false

    private func fetchDecisions(showLoading: Bool = false, params: DecisionsRequest? = nil) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }

        if showLoading == true {
            withAnimation {
                state = .loading
            }
        }
       
        do {
            let result = try await apiClient.decisions.fetchDecisions(requestParams: params ?? requestParams)
            withAnimation {
                state = .success(result.body)
            }
        } catch {
            withAnimation {
                state = .failure(error)
            }
        }
    }
    
    func initialFetchDecisions() async {
        if state.data == nil {
            await fetchDecisions(showLoading: true)
        }
    }
    
    func refreshDecisions() async {
        var req = requestParams
        req.pagination = defaultRequest.pagination
        requestParams = req
        await fetchDecisions(params: req)
    }
    
    func applyFilters() {
        var req = requestParams
        req.pagination = defaultRequest.pagination
        req.filters = filters
        requestParams = req
        Task {
            await fetchDecisions(showLoading: true, params: req)
        }
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
    
    func resetFilters() {
        self.filters = defaultRequest.filters
        self.requestParams.filters = defaultRequest.filters
        Task {
            await fetchDecisions(showLoading: true, params: defaultRequest)
        }
    }
    
    func resetFiltersPanelToAppliedOnes() {
        filters = requestParams.filters
    }
    
    func expireDecision(decisionId: Int) async -> Bool {
        guard let apiClient = AuthViewModel.shared.apiClient else { return false }
        do {
            processingExpireDecision = true
            _ = try await apiClient.decisions.deleteDecision(decisionId: decisionId)
            await refreshDecisions()
            processingExpireDecision = false
            return true
        } catch {
            processingExpireDecision = false
            return false
        }
    }
}
