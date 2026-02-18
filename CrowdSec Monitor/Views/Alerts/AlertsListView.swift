import SwiftUI

struct AlertsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AlertsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedAlertId: Int?
    
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
            .navigationTitle("Alerts")
        } detail: {
            NavigationStack {
                if let selectedAlertId = selectedAlertId {
                    AlertDetailsView(alertId: selectedAlertId)
                } else {
                    // Prevent content unavailable from being shown momentarily when an alert is selected
                    if horizontalSizeClass == .regular {
                        ContentUnavailableView(
                            "Select an alert",
                            systemImage: "list.bullet",
                            description: Text("Choose an alert from the list to view its details")
                        )
                    }
                }
            }
        }
        .task {
            await viewModel.initialFetchAlerts()
        }
    }
    
    @ViewBuilder
    func content(_ data: AlertsListResponse) -> some View {
        List(data.items, id: \.id, selection: $selectedAlertId) { alert in
            NavigationLink(value: alert.id) {
                AlertItem(scenario: alert.scenario, countryCode: alert.source.cn, creationDate: alert.crowdsecCreatedAt.toDateFromISO8601())
            }
            .onAppear {
                if alert == data.items.last {
                    Task {
                        await viewModel.fetchMore()
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refreshAlerts()
        }
    }
}
