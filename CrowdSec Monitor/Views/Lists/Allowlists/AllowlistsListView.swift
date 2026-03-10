import SwiftUI
import CustomAlert

struct AllowlistsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(AllowlistsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var activeAllowlistName: String?
    @State private var showIPsCheckerSheet = false
    
    @Binding var selectedAllowlist: String?
    
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(String(localized: "IP addresses checker"), systemImage: "questionmark") {
                        showIPsCheckerSheet = true
                    }
                } label: {
                    Label("Options", systemImage: "ellipsis")
                }
            }
        }
        .onChange(of: selectedAllowlist, initial: true) { oldValue, newValue in
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
        .sheet(isPresented: $showIPsCheckerSheet) {
            AllowlistsIPsCheckerView {
                showIPsCheckerSheet = false
            }
            .environment(AllowlistsIPsCheckerViewModel())
            .interactiveDismissDisabled()
        }
        .task {
            await viewModel.fetchData()
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
                List(data.data, id: \.name, selection: $selectedAllowlist) { allowlist in
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
