import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var lapiOnlineAlertPresented: Bool = false
    @State private var lapiOfflineAlertPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading...")
                    
                case .success(let data):
                    if horizontalSizeClass == .regular {
                        dashboardContentRegular(data: data)
                    }
                    else {
                        dashboardContentCompact(data: data)
                    }
                    
                case .failure:
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.circle",
                        description: Text("An error occured when fetching the data")
                    )
                }
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.fetchDashboardData()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    switch serverStatusViewModel.status {
                    case .loading:
                        ProgressView()
                    case .success(let data):
                        if data.csLapi.lapiConnected == true {
                            Button {
                                lapiOnlineAlertPresented = true
                            } label: {
                                Label("CrowdSec LAPI is online", systemImage: "checkmark.circle")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.green)
                        }
                        else {
                            Button {
                                lapiOfflineAlertPresented = true
                            } label: {
                                Label("CrowdSec LAPI is online", systemImage: "exlamationmark.circle")
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.red)
                        }
                    case .failure:
                        Button {
                            lapiOfflineAlertPresented = true
                        } label: {
                            Label("CrowdSec LAPI is online", systemImage: "exlamationmark.circle")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.red)
                    }
                }
            }
            .task {
                await viewModel.fetchDashboardData()
            }
        }
        .alert("CrowdSec LAPI is online", isPresented: $lapiOnlineAlertPresented) {
            Button("OK", role: .cancel) {
                lapiOnlineAlertPresented = false
            }
        } message: {
            Text("The CrowdSec LAPI is online and the API is pulling data from it correctly.")
        }
        .alert("CrowdSec LAPI is offline", isPresented: $lapiOfflineAlertPresented) {
            Button("OK", role: .cancel) {
                lapiOfflineAlertPresented = false
            }
        } message: {
            Text("The CrowdSec LAPI is offline or the API is having trouble connecting to it. Some data may not be up to date or available.")
        }
    }
    
    @ViewBuilder
    private func dashboardContentRegular(data: StatisticsResponse) -> some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                HStack(spacing: 16) {
                    DashboardSummaryItem(type: .alerts, value: data.alertsLast24Hours)
                    DashboardSummaryItem(type: .decisions, value: data.activeDecisions)
                }
                .background(Color.listBackground)
                
                DashboardBarChart(activityHistory: data.activityHistory)
                    .listContainerStyling()
                
                let gridItems = [
                    GridItem(.flexible(), spacing: 24, alignment: .top),
                    GridItem(.flexible(), spacing: 24, alignment: .top)
                ]
                LazyVGrid(columns: gridItems, spacing: 32) {
                    if !data.topCountries.isEmpty {
                        let totalAmount = data.topCountries.reduce(0) { $0 + $1.amount }
                        StyledListContainerWithNavLink(
                            sectionTitle: String(localized: "Top countries"),
                            data: data.topCountries,
                            navLinkTitle: String(localized: "View all"),
                            navLinkDestination: {
                                FullListDashboardItemView(dashboardItem: .country)
                            }
                        ) { item in
                            DashboardItem(itemType: .country, label: item.countryCode, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                        }
                    }
                    
                    if !data.topIpOwners.isEmpty {
                        let totalAmount = data.topIpOwners.reduce(0) { $0 + $1.amount }
                        StyledListContainerWithNavLink(
                            sectionTitle: String(localized: "Top IP owners"),
                            data: data.topIpOwners,
                            navLinkTitle: String(localized: "View all"),
                            navLinkDestination: {
                                FullListDashboardItemView(dashboardItem: .ipOwner)
                            }
                        ) { item in
                            DashboardItem(itemType: .ipOwner, label: item.ipOwner, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                        }
                    }
                    
                    if !data.topScenarios.isEmpty {
                        let totalAmount = data.topScenarios.reduce(0) { $0 + $1.amount }
                        StyledListContainerWithNavLink(
                            sectionTitle: String(localized: "Top scenarios"),
                            data: data.topScenarios,
                            navLinkTitle: String(localized: "View all"),
                            navLinkDestination: {
                                FullListDashboardItemView(dashboardItem: .scenary)
                            }
                        ) { item in
                            DashboardItem(itemType: .scenary, label: item.scenario, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                        }
                    }
                    
                    if !data.topTargets.isEmpty {
                        let totalAmount = data.topTargets.reduce(0) { $0 + $1.amount }
                        StyledListContainerWithNavLink(
                            sectionTitle: String(localized: "Top targets"),
                            data: data.topTargets,
                            navLinkTitle: String(localized: "View all"),
                            navLinkDestination: {
                                FullListDashboardItemView(dashboardItem: .target)
                            }
                        ) { item in
                            DashboardItem(itemType: .target, label: item.target, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            Spacer()
                .frame(height: 16)
        }
        .background(Color.listBackground)
    }
    
    @ViewBuilder
    private func dashboardContentCompact(data: StatisticsResponse) -> some View {
        List {
            Section {} header: {
                HStack(spacing: 16) {
                    DashboardSummaryItem(type: .alerts, value: data.alertsLast24Hours)
                    DashboardSummaryItem(type: .decisions, value: data.activeDecisions)
                }
                .padding(.horizontal, -20)
            }
            
            Section {
                DashboardBarChart(activityHistory: data.activityHistory)
            }
            
            if !data.topCountries.isEmpty {
                let totalAmount = data.topCountries.reduce(0) { $0 + $1.amount }
                Section("Top countries") {
                    ForEach(data.topCountries, id: \.self) { item in
                        DashboardItem(itemType: .country, label: item.countryCode, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .country)
                    }
                }
            }
            
            if !data.topIpOwners.isEmpty {
                let totalAmount = data.topIpOwners.reduce(0) { $0 + $1.amount }
                Section("Top IP owners") {
                    ForEach(data.topIpOwners, id: \.self) { item in
                        DashboardItem(itemType: .ipOwner, label: item.ipOwner, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .ipOwner)
                    }
                }
            }
            
            if !data.topScenarios.isEmpty {
                let totalAmount = data.topScenarios.reduce(0) { $0 + $1.amount }
                Section("Top scenarios") {
                    ForEach(data.topScenarios, id: \.self) { item in
                        DashboardItem(itemType: .scenary, label: item.scenario, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .scenary)
                    }
                }
            }
            
            if !data.topTargets.isEmpty {
                let totalAmount = data.topTargets.reduce(0) { $0 + $1.amount }
                Section("Top targets") {
                    ForEach(data.topTargets, id: \.self) { item in
                        DashboardItem(itemType: .target, label: item.target, amount: item.amount, percentage: Double(item.amount) / Double(totalAmount))
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .target)
                    }
                }
            }
        }
    }
}

