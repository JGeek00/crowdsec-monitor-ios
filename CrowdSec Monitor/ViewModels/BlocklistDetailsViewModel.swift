import SwiftUI

@MainActor
@Observable
class BlocklistDetailsViewModel {
    var blocklistId: String
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    @ObservationIgnored private let serviceStatusRepository: ServiceStatusRepository
    
    init(
        blocklistId: String,
        activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository,
        serviceStatusRepository: ServiceStatusRepository = RepositoriesContainer.shared.serviceStatusRepository
    ) {
        self.blocklistId = blocklistId
        self.activeServerRepository = activeServerRepository
        self.serviceStatusRepository = serviceStatusRepository
        
        Task {
            await fetchData()
        }
    }
    
    var status: Enums.LoadingState<BlocklistDataResponse> = .loading
    var ipsRound = 1
    
    var searchPresented = false
    var searchText = ""
    
    var activeProcess: APIStatusResponse_Process? {
        getBlocklistActiveProcess(data: serviceStatusRepository.state.data, blocklistId: blocklistId)
    }
    
    // MARK: - Mutation UI state
    
    var processingModal = false
    var errorDisableBlocklist = false
    var errorEnableBlocklist = false
    var errorDeleteBlocklist = false
    var errorRefreshBlocklist = false
    var blocklistDeletedSuccessfully = false
    
    func fetchData(showLoading: Bool = false) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            if showLoading {
                withAnimation {
                    status = .loading
                }
            }
            
            let response = try await apiClient.blocklists.fetchBlocklistData(blocklistId: blocklistId)
            withAnimation {
                status = .success(response.body)
            }
        } catch let error {
            withAnimation {
                status = .failure(error)
            }
        }
    }
    
    func updateBlocklistId(_ newId: String) {
        self.blocklistId = newId
        self.ipsRound = 1
        Task {
            await fetchData(showLoading: true)
        }
    }
    
    func incrementIpsRound() {
        ipsRound += 1
    }
    
    // MARK: - Mutations
    
    func enableDisableBlocklist(newStatus: Bool) async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            processingModal = true
            let params = ToggleBlocklistRequestParams(blocklistId: blocklistId)
            let body = ToggleBlocklistRequestBody(enabled: newStatus)
            _ = try await apiClient.blocklists.toggleBlocklist(params: params, body: body)
            processingModal = false
            await fetchData()
        } catch {
            processingModal = false
            if newStatus == true {
                errorEnableBlocklist = true
            } else {
                errorDisableBlocklist = true
            }
        }
    }
    
    func deleteBlocklist() async {
        guard let apiClient = activeServerRepository.apiClient else { return }
        do {
            processingModal = true
            let params = DeleteBlocklistRequestParams(blocklistId: blocklistId)
            _ = try await apiClient.blocklists.deleteBlocklist(params: params)
            processingModal = false
            blocklistDeletedSuccessfully = true
        } catch {
            processingModal = false
            errorDeleteBlocklist = true
        }
    }
    
    func refreshBlocklist() {
        guard let apiClient = activeServerRepository.apiClient else { return }
        Task {
            do {
                processingModal = true
                _ = try await apiClient.blocklists.refreshBlocklist(blocklistId: blocklistId)
                processingModal = false
                await fetchData()
            } catch {
                processingModal = false
                errorRefreshBlocklist = true
            }
        }
    }
}
