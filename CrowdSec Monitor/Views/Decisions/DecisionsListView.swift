import SwiftUI

struct DecisionsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DecisionsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedDecisionId: Int?
    @State private var showFiltersSheet = false
    
    var body: some View {
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
            .navigationTitle("Decisions")
        } detail: {
            NavigationStack {
                if let selectedDecisionId = selectedDecisionId {
                    DecisionDetailsView(decisionId: selectedDecisionId)
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
                        DecisionItem(decisionId: decision.id, ipAddress: decision.source.ip, expirationDate: decision.expiration.toDateFromISO8601(), countryCode: decision.source.cn, decisionType: decision.type)
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
        }
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
