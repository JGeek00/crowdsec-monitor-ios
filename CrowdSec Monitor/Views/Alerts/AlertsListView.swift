import SwiftUI
import CustomAlert

struct AlertsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AlertsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var activeAlertId: Int?
    @State private var showFiltersSheet: Bool = false
    
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
            .navigationTitle("Alerts")
        } detail: {
            NavigationStack {
                if let alertId = activeAlertId {
                    AlertDetailsView(alertId: alertId)
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
        .onChange(of: viewModel.selectedAlert, initial: true) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // To prevent disposing details view before back transition ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    activeAlertId = nil
                }
            }
            else {
                activeAlertId = newValue
            }
        }
        .customAlert(isPresented: $viewModel.deletingAlertProcess) {
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
    func content(_ data: AlertsListResponse) -> some View {
        @Bindable var viewModel = viewModel
        Group {
            if data.items.isEmpty {
                ContentUnavailableView("No alerts to display", systemImage: "list.bullet", description: Text("Change the filtering criteria to see more alerts"))
            }
            else {
                List(data.items, id: \.id, selection: $viewModel.selectedAlert) { alert in
                    NavigationLink(value: alert.id) {
                        AlertListItem(alert)
                    }
                    .onAppear {
                        if alert == data.items.last {
                            Task {
                                await viewModel.fetchMore()
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refreshAlerts()
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
            AlertsFilters {
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

fileprivate struct AlertListItem: View {
    let alert: AlertsListResponse_Alert
    
    init(_ alert: AlertsListResponse_Alert) {
        self.alert = alert
    }
    
    @Environment(AlertsListViewModel.self) private var viewModel
    
    @State var errorDeleteAlert: Bool = false
    @State var confirmationDeletePresented: Bool = false
    
    func handleDeleteAlert(_ alertId: Int) {
        Task {
            let result = await viewModel.deleteAlert(alertId: alertId)
            if result == false {
                errorDeleteAlert = true
            }
        }
    }
    
    var body: some View {
        AlertItem(scenario: alert.scenario, countryCode: alert.source.cn, creationDate: alert.crowdsecCreatedAt.toDateFromISO8601())
            .contextMenu {
                Button(String(localized: "Delete alert"), systemImage: "trash", role: .destructive) {
                    confirmationDeletePresented = true
                }
            }
            .alert("Delete alert", isPresented: $confirmationDeletePresented) {
                Button(String(localized: "Cancel"), role: .cancel) {
                    confirmationDeletePresented = false
                }
                Button(String(localized: "Delete"), role: .destructive) {
                    handleDeleteAlert(alert.id)
                }
            } message: {
                Text("Are you sure you want to delete this alert? This action cannot be undone.")
            }
            .alert("Error delete alert", isPresented: $errorDeleteAlert) {
                Button("OK", role: .cancel) {
                    errorDeleteAlert = false
                }
            } message: {
                Text("An error occured when trying to delete the alert. Please try again.")
            }
    }
}
