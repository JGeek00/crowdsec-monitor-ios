import Foundation
import SwiftUI

fileprivate let defaultRequest = AlertsRequest(filters: AlertsRequestFilters(countries: nil, scenarios: nil, ipOwners: nil, targets: nil), pagination: AlertsRequestPagination(offset: 0, limit: Config.alertsAmoutBatch))

@MainActor
@Observable
class AlertsListViewModel {
    private let apiClient: CrowdSecAPIClient
    
    var requestParams: AlertsRequest
    
    init(_ apiClient: CrowdSecAPIClient) {
        self.apiClient = apiClient
        self.requestParams = defaultRequest
    }
    
    var state: Enums.LoadingState<AlertsResponse> = .loading
    
    func initialFetchAlerts(force: Bool = false) async {
        if state.data != nil && !force {
            return
        }
        
        do {
            let result = try await apiClient.alerts.fetchAlerts(requestParams: defaultRequest)
            state = .success(result.body)
        } catch {
            state = .failure(error)
        }
    }
    
    func refreshAlerts() async {
        await initialFetchAlerts(force: true)
    }

    func fetchMore() async {
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
                let newResponse = AlertsResponse(filtering: result.body.filtering, items: newItems, pagination: result.body.pagination)
                state = .success(newResponse)
            } catch {
                state = .failure(error)
            }
        }
    }
}
