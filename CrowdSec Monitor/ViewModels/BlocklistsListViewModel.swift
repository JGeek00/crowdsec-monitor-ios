import SwiftUI

@MainActor
@Observable
class BlocklistsListViewModel {
    static let shared = BlocklistsListViewModel()
    
    var requestParams: BlocklistsRequest
    
    init() {
        self.requestParams = BlocklistsRequest(offset: 0, limit: Config.blocklistsAmountBatch)
    }

    var state: Enums.LoadingState<BlocklistsListResponse> = .loading
    var selectedListName: String? = nil
    
    var processingModal = false
    var errorDisableBlocklist = false
    var errorEnableBlocklist = false
    var errorDeleteBlocklist = false
    var blocklistDeletedSuccessfully = false
    
    func reset() {
        state = .loading
        requestParams = BlocklistsRequest(offset: 0, limit: Config.blocklistsAmountBatch)
        selectedListName = nil
        processingModal = false
        errorDisableBlocklist = false
        errorEnableBlocklist = false
        errorDeleteBlocklist = false
        blocklistDeletedSuccessfully = false
    }
    
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
    
    func initialFetch() async {
        if state.data == nil {
            await fetchData(showLoading: true)
        }
    }
    
    func refresh() async {
        await fetchData()
    }
    
    func fetchMore() async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        if let data = state.data {
            if (data.pagination.page * Config.alertsAmoutBatch) >= data.pagination.total {
                return
            }
            
            let previousItems = data.items
            let newOffset = data.pagination.page * Config.alertsAmoutBatch
            requestParams.offset = newOffset

            do {
                let result = try await apiClient.blocklists.fetchBlocklists(requestParams: requestParams)
                
                let existingIDs = Set(previousItems.map { $0.id })
                let uniqueNewItems = result.body.items.filter { !existingIDs.contains($0.id) }
                
                let newItems = previousItems + uniqueNewItems
                let newResponse = BlocklistsListResponse(items: newItems, pagination: result.body.pagination)
                state = .success(newResponse)
            } catch {
                state = .failure(error)
            }
        }
    }
    
    func enableDisableBlocklist(blocklistId: String, newStatus: Bool) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            processingModal = true
            let params = ToggleBlocklistRequestParams(blocklistId: blocklistId)
            let body = ToggleBlocklistRequestBody(enabled: newStatus)
            _ = try await apiClient.blocklists.toggleBlocklist(params: params, body: body)
            processingModal = false
            await refresh()
        } catch {
            processingModal = false
            if newStatus == true {
                errorEnableBlocklist = true
            }
            else {
                errorDisableBlocklist = true
            }
        }
    }
    
    func deleteBlocklist(blocklistId: String) async {
        guard let apiClient = AuthViewModel.shared.apiClient else { return }
        do {
            processingModal = true
            let params = DeleteBlocklistRequestParams(blocklistId: blocklistId)
            _ = try await apiClient.blocklists.deleteBlocklist(params: params)
            processingModal = false
            await refresh()
            blocklistDeletedSuccessfully = true
        } catch {
            processingModal = false
            errorDeleteBlocklist = true
        }
    }
}
