import SwiftUI

struct FullListDashboardItemView: View {
    @State private var viewModel: FullListDashboardItemViewModel
    
    init(dashboardItem: Enums.DashboardItemType) {
        _viewModel = State(initialValue: FullListDashboardItemViewModel(dashboardItem: dashboardItem))
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        let title: String = {
            switch viewModel.dashboardItem {
            case .country:
                return String(localized: "Countries")
            case .ipOwner:
                return String(localized: "IP owners")
            case .scenary:
                return String(localized: "Scenarios")
            case .target:
                return String(localized: "Targets")
            }
        }()
        
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                if horizontalSizeClass == .regular {
                    contentRegular(data)
                } else {
                    contentCompact(data)
                }
            case .failure:
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.circle",
                    description: Text("An error occured when fetching the data")
                )
                
            }
        }
        .transition(.opacity)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func contentCompact(_ data: [FullItemDashboardItemDataForView]) -> some View {
        List {
            Section {
                HStack {
                    Spacer()
                    FullListDashboardPieChart(data: viewModel.chartData)
                    Spacer()
                }
            }
            
            Section {
                ForEach(data, id: \.self) { item in
                    switch viewModel.dashboardItem {
                    case .country:
                        DashboardItem(itemType: .country, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                    case .ipOwner:
                        DashboardItem(itemType: .ipOwner, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                    case .scenary:
                        DashboardItem(itemType: .scenary, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                    case .target:
                        DashboardItem(itemType: .target, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func contentRegular(_ data: [FullItemDashboardItemDataForView]) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width - 64
            ScrollView {
                HStack(alignment: .top, spacing: 32) {
                    StyledListContainer(
                        data: data,
                    ) { item in
                        switch viewModel.dashboardItem {
                        case .country:
                            DashboardItem(itemType: .country, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                        case .ipOwner:
                            DashboardItem(itemType: .ipOwner, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                        case .scenary:
                            DashboardItem(itemType: .scenary, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                        case .target:
                            DashboardItem(itemType: .target, label: item.item, amount: item.value, percentage: item.percentage, color: item.color)
                        }
                    }
                    .frame(width: width * 0.65)
                    
                    FullListDashboardPieChart(data: viewModel.chartData)
                        .frame(width: (width-32) * 0.35)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.listBackground)
        }
    }
}
