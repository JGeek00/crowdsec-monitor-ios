import Foundation
import SwiftUI

@MainActor
@Observable
class BlocklistsListViewModel {

    var requestParams: BlocklistsRequest

    @ObservationIgnored private let activeServerRepository: ActiveServerRepository
    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository

    init(
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository,
        serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository
    ) {
        self.requestParams = BlocklistsRequest(offset: 0, limit: Config.blocklistsAmountBatch)
        self.activeServerRepository = activeServerRepository
        self.serviceStatusRepository = serviceStatusRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.reset()
        }
    }

    var state: Enums.LoadingState<BlocklistsListResponse> = .loading
    var selectedListName: String? = nil
    
    var processingModal = false
    var errorDisableBlocklist = false
    var errorEnableBlocklist = false
    var errorDeleteBlocklist = false
    var errorRefreshBlocklist = false
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
        guard let apiClient = activeServerRepository.apiClient else { return }
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
            guard !(error is CancellationError) else { return }
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
        guard let apiClient = activeServerRepository.apiClient else { return }
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
            guard !(error is CancellationError) else { return }
                state = .failure(error)
            }
        }
    }
    
    func enableDisableBlocklist(blocklistId: String, newStatus: Bool) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
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
        guard let apiClient = activeServerRepository.apiClient else { return }
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
    
    func refreshBlocklists(blocklistId: String? = nil) {
        guard let apiClient = activeServerRepository.apiClient else { return }
        Task {
            do {
                processingModal = true
                if let blocklistId = blocklistId {
                    _ = try await apiClient.blocklists.refreshBlocklist(blocklistId: blocklistId)
                }
                else {
                    _ = try await apiClient.blocklists.refreshAllBlocklists()
                }
                processingModal = false
            } catch {
                processingModal = false
                errorRefreshBlocklist = true
            }
        }
    }
    
    /// Returns the active process for a given blocklist, or nil if none.
    func activeProcess(for blocklistId: String) -> APIStatusResponse_Process? {
        getBlocklistActiveProcess(data: serviceStatusRepository.state.data, blocklistId: blocklistId)
    }
}
