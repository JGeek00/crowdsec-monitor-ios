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
            Group {
                if let selectedAlertId = selectedAlertId {
                    AlertDetailsView(alertId: selectedAlertId, apiClient: authViewModel.apiClient!)
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
            .id(selectedAlertId ?? -1)  // Ensures recreation of the view when a new alert is selected
        }
        .task {
            await viewModel.initialFetchAlerts()
        }
    }
    
    @ViewBuilder
    func content(_ data: AlertsResponse) -> some View {
        List(data.items, id: \.id, selection: $selectedAlertId) { alert in
            let scenarioSplit = alert.scenario.split(separator: "/")
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenarioSplit[0])
                        .foregroundStyle(Color.gray)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                    Text(scenarioSplit[1])
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                    CountryFlag(countryCode: alert.source.cn)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                        .fontWeight(.semibold)
                        
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let date = alert.crowdsecCreatedAt.toDateFromISO8601() {
                        Text(date.toRelativeDayString())
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.gray)
                        Text(date.toTimeString())
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                    }
                }
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
