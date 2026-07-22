import Foundation
import SwiftUI

fileprivate var defaultRequest = DecisionsRequest(filters: DecisionsRequestFilters(onlyActive: Defaults.showDefaultActiveDecisions, groupByIP: Defaults.showDefaultDecisionsGroupedByIP), pagination: DecisionsRequestPagination(offset: 0, limit: Config.alertsAmoutBatch))

@MainActor
@Observable
class DecisionsListViewModel {
    @ObservationIgnored private let activeServerRepository: ActiveServerRepository

    var requestParams: DecisionsRequest
    var filters: DecisionsRequestFilters

    @ObservationIgnored private var isFetching = false

    init(activeServerRepository: ActiveServerRepository = RepositoriesContainer.shared.activeServerRepository) {
        let defaultOnlyActive = UserDefaults.shared.object(forKey: StorageKeys.showDefaultActiveDecisions) as! Bool? ?? Defaults.showDefaultActiveDecisions
        defaultRequest.filters.onlyActive = defaultOnlyActive

        let defaultGroupByIP = UserDefaults.shared.object(forKey: StorageKeys.showDefaultDecisionsGroupedByIP) as! Bool? ?? Defaults.showDefaultDecisionsGroupedByIP
        defaultRequest.filters.groupByIP = defaultGroupByIP

        self.requestParams = defaultRequest
        self.filters = defaultRequest.filters
        self.activeServerRepository = activeServerRepository
        NotificationCenter.default.addObserver(forName: .serverDidChange, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reset()
            }
        }
        NotificationCenter.default.addObserver(forName: .decisionsShouldRefresh, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refreshDecisions()
            }
        }
        NotificationCenter.default.addObserver(forName: .decisionShouldExpire, object: nil, queue: .main) { [weak self] notification in
            if let decisionId = notification.object as? Int {
                Task { @MainActor [weak self] in
                    await self?.expireDecision(decisionId: decisionId)
                }
            }
        }
    }
    
    var state: Enums.LoadingState<DecisionsListResponse> = .loading
    var stateByIP: Enums.LoadingState<DecisionsByIPResponse> = .loading
    var processingExpireDecision = false

    var isGroupedByIP: Bool {
        requestParams.filters.groupByIP ?? false
    }

    func reset() {
        state = .loading
        stateByIP = .loading
        requestParams = defaultRequest
        filters = defaultRequest.filters
        processingExpireDecision = false
        isFetching = false
    }
    
    private func fetchDecisions(showLoading: Bool = false, params: DecisionsRequest? = nil) async {
        guard let apiClient = activeServerRepository.apiClient else { return }

        let useParams = params ?? requestParams
        let grouped = useParams.filters.groupByIP ?? false

        if showLoading == true {
            withAnimation {
                if grouped {
                    stateByIP = .loading
                } else {
                    state = .loading
                }
            }
        }
       
        do {
            if grouped {
                let result = try await apiClient.decisions.fetchDecisionsByIP(requestParams: useParams)
                withAnimation {
                    stateByIP = .success(result.body)
                }
            } else {
                let result = try await apiClient.decisions.fetchDecisions(requestParams: useParams)
                withAnimation {
                    state = .success(result.body)
                }
            }
        } catch {
            guard !(error is CancellationError) else { return }
            withAnimation {
                if grouped {
                    stateByIP = .failure(error)
                } else {
                    state = .failure(error)
                }
            }
        }
    }
    
    func initialFetchDecisions() async {
        let grouped = requestParams.filters.groupByIP ?? false
        if grouped ? stateByIP.data == nil : state.data == nil {
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
        activeServerRepository.task {
            await self.fetchDecisions(showLoading: true, params: req)
        }
    }

    func fetchMore() async {
        guard let apiClient = activeServerRepository.apiClient else { return }

        if requestParams.filters.groupByIP ?? false {
            await fetchMoreByIP(apiClient: apiClient)
        } else {
            await fetchMoreDecisions(apiClient: apiClient)
        }
    }

    private func fetchMoreByIP(apiClient: CrowdSecAPIClient) async {
        guard let data = stateByIP.data else { return }
        if (data.pagination.page * Config.alertsAmoutBatch) >= data.pagination.total { return }

        let previousGroups = data.groups
        let newOffset = data.pagination.page * Config.alertsAmoutBatch
        requestParams.pagination.offset = newOffset

        do {
            let result = try await apiClient.decisions.fetchDecisionsByIP(requestParams: requestParams)

            let existingIPs = Set(previousGroups.map { $0.ip })
            let uniqueNewGroups = result.body.groups.filter { !existingIPs.contains($0.ip) }

            let newGroups = previousGroups + uniqueNewGroups
            let newResponse = DecisionsByIPResponse(filtering: result.body.filtering, groups: newGroups, pagination: result.body.pagination)
            stateByIP = .success(newResponse)
        } catch {
            guard !(error is CancellationError) else { return }
            stateByIP = .failure(error)
        }
    }

    private func fetchMoreDecisions(apiClient: CrowdSecAPIClient) async {
        guard let data = state.data else { return }
        if (data.pagination.page * Config.alertsAmoutBatch) >= data.pagination.total { return }
        
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
            guard !(error is CancellationError) else { return }
            state = .failure(error)
        }
    }
    
    func resetFilters() {
        self.filters = defaultRequest.filters
        self.requestParams.filters = defaultRequest.filters
        activeServerRepository.task {
            await self.fetchDecisions(showLoading: true, params: defaultRequest)
        }
    }
    
    func resetFiltersPanelToAppliedOnes() {
        filters = requestParams.filters
    }
    
    func expireDecision(decisionId: Int) async -> Bool {
        guard let apiClient = activeServerRepository.apiClient else { return false }
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
