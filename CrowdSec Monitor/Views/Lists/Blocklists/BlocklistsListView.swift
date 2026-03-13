import SwiftUI
import CustomAlert
import SystemNotification

struct BlocklistsListView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(BlocklistsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var selectedBlocklist: Int?
    
    @State private var activeBlocklistId: Int?
    @State private var addBlocklistFormOpen = false
    @State private var blocklistAddedNotification = false
    
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
                Button("Add blocklist", systemImage: "plus") {
                    addBlocklistFormOpen = true
                }
            }
        }
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
        .sheet(isPresented: $addBlocklistFormOpen) {
            AddBlocklistFormView { blocklistAdded in
                addBlocklistFormOpen = false
                if blocklistAdded {
                    blocklistAddedNotification = true
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .systemNotification(isActive: $blocklistAddedNotification) {
            SystemNotification(icon: "checkmark", title: "Blocklist added", subtitle: "The blocklist was successfully added")
        }
        .systemNotification(isActive: $viewModel.errorEnableBlocklist) {
            SystemNotification(icon: "exclamationmark.circle", title: "Error", subtitle: "The blocklist could not be enabled", color: Color.red)
        }
        .systemNotification(isActive: $viewModel.errorDisableBlocklist) {
            SystemNotification(icon: "exclamationmark.circle", title: "Error", subtitle: "The blocklist could not be disabled", color: Color.red)
        }
        .customAlert(isPresented: $viewModel.processingModal) {
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
    func content(_ data: BlocklistsListResponse) -> some View {
        @Bindable var viewModel = viewModel
        Group {
            if data.items.isEmpty {
                ContentUnavailableView("No blocklists to display", systemImage: "list.bullet", description: Text("There are no blocklists on CrowdSec"))
            }
            else {
                List(data.items, id: \.id, selection: $selectedBlocklist) { blocklist in
                    BlocklistListItem(blocklist)
                        .tag(blocklist.id)
                        .onAppear {
                            if blocklist == data.items.last {
                                Task {
                                    await viewModel.fetchMore()
                                }
                            }
                        }
                }
                .animation(.default, value: data.items)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

fileprivate struct BlocklistListItem: View {
    let blocklist: BlocklistsListResponse_Item
    
    init(_ blocklist: BlocklistsListResponse_Item) {
        self.blocklist = blocklist
    }
    
    @Environment(BlocklistsListViewModel.self) private var viewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: blocklist.name)
                Text("\(blocklist.countIPS) blocked IP addresses")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Group {
                    switch blocklist.type {
                    case .api:
                        Text("Managed by Monitor API")
                            .foregroundStyle(Color.blue)
                    case .crowdsec:
                        Text("Managed by CrowdSec")
                            .foregroundStyle(Color.orange)
                    }
                }
                .font(.system(size: 14))
                if let lastRefreshAttempt = blocklist.lastRefreshAttempt?.toDateFromISO8601(), let lastSuccessfulRefresh = blocklist.lastSuccessfulRefresh?.toDateFromISO8601() {
                    let diff = abs(lastRefreshAttempt.timeIntervalSince(lastSuccessfulRefresh))
                    let isBigDifference = diff >= 60 * 60   // 1 hour
                    if isBigDifference == true {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Blocklist refresh failed")
                        }
                        .foregroundStyle(Color.red)
                        .font(.system(size: 14))
                    }
                }
            }
            if let value = blocklist.enabled {
                Spacer()
                Group {
                    if value == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.green)
                    }
                    else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.red)
                    }
                }
                .fontWeight(.semibold)
                .font(.system(size: 20))
            }
        }
        .contextMenu {
            if blocklist.type == .api {
                if let enabled = blocklist.enabled {
                    Section {
                        Button(
                            blocklist.enabled == true ? "Disable blocklist" : "Enable blocklist",
                            systemImage: blocklist.enabled == true ? "xmark" : "checkmark"
                        ) {
                            Task {
                                await viewModel.enableDisableBlocklist(blocklistId: blocklist.id, newStatus: !enabled)
                            }
                        }
                    }
                }
                Section {
                    Button("Delete blocklist", systemImage: "trash", role: .destructive) {
                        
                    }
                }
            }
        }
    }
}
