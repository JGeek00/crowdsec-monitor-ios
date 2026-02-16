import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading...")
                    
                case .success(let data):
                    dashboardContent(data: data)
                    
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
            .task {
                await viewModel.fetchDashboardData()
            }
        }
    }
    
    @ViewBuilder
    private func dashboardContent(data: StatisticsResponse) -> some View {
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
                Section("Top Countries") {
                    ForEach(data.topCountries, id: \.self) { item in
                        DashboardItem(itemType: .country, label: item.countryCode, amount: item.amount)
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .country)
                    }
                }
            }
            
            if !data.topIpOwners.isEmpty {
                Section("Top IP owners") {
                    ForEach(data.topIpOwners, id: \.self) { item in
                        DashboardItem(itemType: .ipOwner, label: item.ipOwner, amount: item.amount)
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .ipOwner)
                    }
                }
            }
            
            if !data.topScenarios.isEmpty {
                Section("Top scenarios") {
                    ForEach(data.topScenarios, id: \.self) { item in
                        DashboardItem(itemType: .scenary, label: item.scenario, amount: item.amount)
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .scenary)
                    }
                }
            }
            
            if !data.topTargets.isEmpty {
                Section("Top targets") {
                    ForEach(data.topTargets, id: \.self) { item in
                        DashboardItem(itemType: .target, label: item.target, amount: item.amount)
                    }
                    NavigationLink("View all") {
                        FullListDashboardItemView(dashboardItem: .target)
                    }
                }
            }
        }
    }
}

