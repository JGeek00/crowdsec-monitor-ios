import SwiftUI

struct DecisionsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(DecisionsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedDecisionId: Int?
    
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
        List(data.items, id: \.id, selection: $selectedDecisionId) { decision in
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
        .refreshable {
            await viewModel.refreshDecisions()
        }
    }
}
