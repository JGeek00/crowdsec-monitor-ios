import SwiftUI
import CustomAlert

struct BlocklistsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(BlocklistsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var selectedBlocklist: String?
    
    @State private var activeBlocklistId: String?
    
    var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .success(let data):
                content(data)
            case .failure:
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.circle",
                    description: Text("An error occured when fetching the data")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .transition(.opacity)
        .onChange(of: selectedBlocklist, initial: true) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // To prevent disposing details view before back transition ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    activeBlocklistId = nil
                }
            }
            else {
                activeBlocklistId = newValue
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
    
    @ViewBuilder
    func content(_ data: BlocklistsListResponse) -> some View {
        @Bindable var viewModel = viewModel
        Group {
            if data.data.isEmpty {
                ContentUnavailableView("No blocklists to display", systemImage: "list.bullet", description: Text("There are no blocklists on CrowdSec"))
            }
            else {
                List(data.data, id: \.name, selection: $selectedBlocklist) { blocklist in
                    NavigationLink(value: blocklist.name) {
                        BlocklistListItem(blocklist)
                    }
                }
                .animation(.default, value: data.data)
            }
        }
        .refreshable {
            await viewModel.fetchData()
        }
    }
}

fileprivate struct BlocklistListItem: View {
    let blocklist: BlocklistsListResponse_Blocklist
    
    init(_ blocklist: BlocklistsListResponse_Blocklist) {
        self.blocklist = blocklist
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: blocklist.name)
            Text("\(blocklist.countIPS) blocked IP addresses")
                .font(.subheadline)
                .foregroundStyle(Color.gray)
        }
        .padding(.vertical, 4)
    }
}
