import SwiftUI
import CustomAlert

struct DecisionsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DecisionsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedDecisionId: Int?
    @State private var activeDecisionId: Int?
    @State private var showFiltersSheet = false
    @State private var showCreateDecisionSheet = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationSplitView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading...")
                case .success(let data):
                    content(data)
                case .failure:
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.circle",
                        description: Text("An error occured when fetching the data")
                    )
                }
            }
            .transition(.opacity)
            .navigationTitle("Decisions")
        } detail: {
            NavigationStack {
                if let decisionId = activeDecisionId {
                    DecisionDetailsView(decisionId: decisionId)
                } else {
                    // Prevent content unavailable from being shown momentarily when an alert is selected
                    if horizontalSizeClass == .regular {
                        ContentUnavailableView(
                            "Select a decision",
                            systemImage: "list.bullet",
                            description: Text("Choose a decision from the list to view its details")
                        )
                    }
                }
            }
        }
        .task {
            await viewModel.initialFetchDecisions()
        }
        .onChange(of: selectedDecisionId, initial: true) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // To prevent disposing details view before back transition ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    activeDecisionId = nil
                }
            }
            else {
                activeDecisionId = newValue
            }
        }
        .customAlert(isPresented: $viewModel.processingExpireDecision) {
            HStack {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.foreground)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func content(_ data: DecisionsListResponse) -> some View {
        Group {
            if data.items.isEmpty {
                if viewModel.requestParams.filters.onlyActive == true {
                    ContentUnavailableView("No active decisions", systemImage: "checkmark.shield", description: Text("Disable show only active decisions on filters to see all decisions"))
                }
                else {
                    ContentUnavailableView("No decisions to display", systemImage: "list.bullet", description: Text("Change the filtering criteria to see more decisions"))
                }
            }
            else {
                List(data.items, id: \.self, selection: $selectedDecisionId) { decision in
                    NavigationLink(value: decision.id) {
                        DecisionListItem(decision)
                    }
                    .onAppear {
                        if decision == data.items.last {
                            Task {
                                await viewModel.fetchMore()
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refreshDecisions()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFiltersSheet = true
                } label: {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateDecisionSheet = true
                } label: {
                    Label("Create decision", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateDecisionSheet, content: {
            CreateDecisionFormView {
                showCreateDecisionSheet = false
            }
            .interactiveDismissDisabled()
        })
        .sheet(isPresented: $showFiltersSheet) {
            DecisionsFilters {
                showFiltersSheet = false
            }
        }
        .onChange(of: showFiltersSheet) { _, newValue in
            if newValue == true {
                viewModel.resetFiltersPanelToAppliedOnes()
            }
        }
    }
}

fileprivate struct DecisionListItem: View {
    let decision: DecisionsListResponse_Item
    
    init(_ decision: DecisionsListResponse_Item) {
        self.decision = decision
    }
    
    @State private var errorDeleteDecision = false
    @State private var expireDecisionConfirmationAlert = false
    
    @Environment(DecisionsListViewModel.self) private var viewModel
    
    func handleDecisionDelete(_ decisionId: Int) {
        Task {
            let result = await viewModel.expireDecision(decisionId: decisionId)
            if result == false {
                errorDeleteDecision = true
            }
        }
    }
    
    var body: some View {
        DecisionItem(decisionId: decision.id, ipAddress: decision.source.value, expirationDate: decision.expiration.toDateFromISO8601(), countryCode: decision.source.cn, decisionType: decision.type)
            .contextMenu {
                Button(String(localized: "Expire decision"), systemImage: "clock.badge.checkmark", role: .destructive) {
                    expireDecisionConfirmationAlert = true
                }
            }
            .alert("Expire decision", isPresented: $expireDecisionConfirmationAlert) {
                Button(String(localized: "Cancel"), role: .cancel) {
                    expireDecisionConfirmationAlert = false
                }
                Button(String(localized: "Expire"), role: .destructive) {
                    handleDecisionDelete(decision.id)
                }
            } message: {
                Text("Are you sure you want to make this decision to expire now? This action cannot be undone.")
            }
            .alert("Error expiring decision", isPresented: $errorDeleteDecision) {
                Button("OK") {
                    errorDeleteDecision = false
                }
            } message: {
                Text("An error occurred while making the decision expired. Please try again.")
            }
    }
}
