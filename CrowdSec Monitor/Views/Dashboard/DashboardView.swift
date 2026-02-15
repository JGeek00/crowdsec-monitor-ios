import SwiftUI

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    
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
            
            if !data.topCountries.isEmpty {
                Section("Top Countries") {
                    ForEach(data.topCountries, id: \.self) { item in
                        HStack {
                            CountryFlag(countryCode: item.countryCode)
                            Spacer()
                            Text("\(item.amount)")
                        }
                    }
                }
            }
            
            if !data.topIpOwners.isEmpty {
                Section("Top IP owners") {
                    ForEach(data.topIpOwners, id: \.self) { item in
                        HStack {
                            Text(verbatim: item.ipOwner)
                            Spacer()
                            Text("\(item.amount)")
                        }
                    }
                }
            }
            
            if !data.topScenarios.isEmpty {
                Section("Top scenarios") {
                    ForEach(data.topScenarios, id: \.self) { item in
                        let splitted = item.scenario.split(separator: "/")
                        HStack {
                            VStack(alignment: .leading) {
                                Text(verbatim: String(splitted[0]))
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.gray)
                                Text(verbatim: String(splitted[1]))
                            }
                            Spacer()
                            Text("\(item.amount)")
                        }
                    }
                }
            }
            
            if !data.topTargets.isEmpty {
                Section("Top targets") {
                    ForEach(data.topTargets, id: \.self) { item in
                        HStack {
                            Text(verbatim: item.target)
                            Spacer()
                            Text("\(item.amount)")
                        }
                    }
                }
            }
        }
    }
}

