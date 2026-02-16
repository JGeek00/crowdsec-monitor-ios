import SwiftUI

struct FullListDashboardItemView: View {
    @State private var viewModel: FullListDashboardItemViewModel
    
    init(dashboardItem: Enums.DashboardItemType) {
        _viewModel = State(initialValue: FullListDashboardItemViewModel(dashboardItem: dashboardItem))
    }
    
    var body: some View {
        let title: String = {
            switch viewModel.dashboardItem {
            case .country:
                return String(localized: "Countries")
            case .ipOwner:
                return String(localized: "IP owners")
            case .scenary:
                return String(localized: "Scenaries")
            case .target:
                return String(localized: "Targets")
            }
        }()
        
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
        .navigationTitle(title)
        .task {
            await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func content(_ data: [FullItemDashboardItemData]) -> some View {
        List(data, id: \.self) { item in
            switch viewModel.dashboardItem {
            case .country:
                DashboardItem(itemType: .country, label: item.item, amount: item.value)
            case .ipOwner:
                DashboardItem(itemType: .ipOwner, label: item.item, amount: item.value)
            case .scenary:
                DashboardItem(itemType: .scenary, label: item.item, amount: item.value)
            case .target:
                DashboardItem(itemType: .target, label: item.item, amount: item.value)
            }
        }
    }
}
