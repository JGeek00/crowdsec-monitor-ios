import SwiftUI
import CustomAlert

struct AllowlistsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AllowlistsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var activeAllowlistName: String?
    
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
            .transition(.opacity)
            .navigationTitle("Allowlists")
        } detail: {
            NavigationStack {
                if let allowlistName = activeAllowlistName {
                    AllowlistDetailsView(allowlistName: allowlistName)
                } else {
                    // Prevent content unavailable from being shown momentarily when an allowlist is selected
                    if horizontalSizeClass == .regular {
                        ContentUnavailableView(
                            "Select an allowlist",
                            systemImage: "list.bullet",
                            description: Text("Choose an allowlist to see the list of IPs")
                        )
                    }
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .onChange(of: viewModel.selectedAllowlistName, initial: true) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // To prevent disposing details view before back transition ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    activeAllowlistName = nil
                }
            }
            else {
                activeAllowlistName = newValue
            }
        }
    }
    
    @ViewBuilder
    func content(_ data: AllowlistsListResponse) -> some View {
        @Bindable var viewModel = viewModel
        Group {
            if data.data.isEmpty {
                ContentUnavailableView("No allowlists to display", systemImage: "list.bullet", description: Text("There are no allowlists on CrowdSec"))
            }
            else {
                List(data.data, id: \.name, selection: $viewModel.selectedAllowlistName) { allowlist in
                    NavigationLink(value: allowlist.name) {
                        AllowlistListItem(allowlist)
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

fileprivate struct AllowlistListItem: View {
    let allowlist: AllowlistsListResponse_Allowlist
    
    init(_ allowlist: AllowlistsListResponse_Allowlist) {
        self.allowlist = allowlist
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(allowlist.name)
                .fontWeight(.medium)
            
            if !allowlist.description.isEmpty {
                Text(allowlist.description)
                    .fontWeight(.medium)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "number")
                    Text("\(allowlist.items.count) IPs addresses")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                if let updated = allowlist.updatedAt.toDateFromISO8601() {
                    Spacer()
                    Text("Updated: \(updated.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
