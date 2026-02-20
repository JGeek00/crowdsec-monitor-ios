import Foundation
import SwiftUI

fileprivate let defaultRequest = AlertsRequest(filters: AlertsRequestFilters(countries: [], scenarios: [], ipOwners: [], targets: []), pagination: AlertsRequestPagination(offset: 0, limit: Config.alertsAmoutBatch))

@MainActor
@Observable
class AlertsListViewModel {
    public static let shared = AlertsListViewModel()
        
    var requestParams: AlertsRequest
    var filters: AlertsRequestFilters
    
    init() {
        self.requestParams = defaultRequest
        self.filters = defaultRequest.filters
    }
    
    var state: Enums.LoadingState<AlertsListResponse> = .loading
    var deletingAlertProcess: Bool = false
    
    private func fetchAlerts(showLoading: Bool = false, params: AlertsRequest? = nil) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }

        if showLoading == true {
            state = .loading
        }
       
        do {
            let result = try await apiClient.alerts.fetchAlerts(requestParams: params ?? requestParams)
            state = .success(result.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func initialFetchAlerts() async {
        if state.data == nil {
            await fetchAlerts(showLoading: true)
        }
    }
    
    func refreshAlerts() async {
        var req = requestParams
        req.pagination = defaultRequest.pagination
        requestParams = req
        await fetchAlerts(params: req)
    }
    
    func applyFilters() {
        var req = requestParams
        req.pagination = defaultRequest.pagination
        req.filters = filters
        requestParams = req
        Task {
            await fetchAlerts(showLoading: true, params: req)
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
                let result = try await apiClient.alerts.fetchAlerts(requestParams: requestParams)
                
                let existingIDs = Set(previousItems.map { $0.id })
                let uniqueNewItems = result.body.items.filter { !existingIDs.contains($0.id) }
                
                let newItems = previousItems + uniqueNewItems
                let newResponse = AlertsListResponse(filtering: result.body.filtering, items: newItems, pagination: result.body.pagination)
                state = .success(newResponse)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func updateFilters(_ filters: AlertsRequestFilters) {
        self.filters = filters
    }
    
    func resetFilters() {
        self.filters = defaultRequest.filters
        self.requestParams.filters = defaultRequest.filters
        Task {
            await fetchAlerts(showLoading: true, params: defaultRequest)
        }
    }
    
    func resetFiltersPanelToAppliedOnes() {
        filters = requestParams.filters
    }
    
    func deleteAlert(alertId: Int) async -> Bool {
        guard let apiClient = AuthViewModel.shared.apiClient else { return false }
        do {
            deletingAlertProcess = true
            _ = try await apiClient.alerts.deleteAlert(alertId: alertId)
            await refreshAlerts()
            deletingAlertProcess = false
            return true
        } catch {
            deletingAlertProcess = false
            return false
        }
    }
}
