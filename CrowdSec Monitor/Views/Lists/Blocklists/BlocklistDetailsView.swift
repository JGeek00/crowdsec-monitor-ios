import SwiftUI

struct BlocklistDetailsView: View {
    let blocklistId: String
    let onDismiss: (() -> Void)?

    @State private var viewModel: BlocklistDetailsViewModel

    init(blocklistId: String, onDismiss: (() -> Void)? = nil) {
        self.blocklistId = blocklistId
        self.onDismiss = onDismiss
        _viewModel = State(wrappedValue: BlocklistDetailsViewModel(blocklistId: blocklistId))
    }

    @Environment(BlocklistsListViewModel.self) private var blocklistsViewModel
    @Environment(ServiceStatusViewModel.self) private var serviceStatusViewModel

    @State private var browserOpen = false
    @State private var showDeleteConfirmation = false
    @State private var showRefreshConfirmation = false

    private var blocklistInfo: BlocklistsListResponse_Item? {
        blocklistsViewModel.state.data?.items.first { $0.id == blocklistId }
    }

    private var activeProcess: APIStatusResponse_Process? {
        getBlocklistActiveProcess(data: serviceStatusViewModel.state.data, blocklistId: blocklistId)
    }
    
    var body: some View {
        let blocklist = blocklistsViewModel.state.data?.items.first { $0.id == blocklistId }
        Group {
            switch viewModel.status {
            case .loading:
                ProgressView("Loading...")
            case .success(let data):
                content(data.data)
            case .failure:
                ContentUnavailableView("Cannot get blocklist information", systemImage: "exclamationmark.circle", description: Text("An error occured when fetching the blocklist data"))
            }
        }
        .transition(.opacity)
        .navigationTitle(blocklist?.name ?? "Blocklist details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if blocklistInfo?.type == .api, blocklistInfo?.enabled == true {
                        Section {
                            Button("Refresh", systemImage: "arrow.clockwise") {
                                showRefreshConfirmation = true
                            }
                            .disabled(activeProcess != nil)
                        }
                    }

                    if blocklistInfo?.type == .api {
                        Section {
                            if let enabled = blocklistInfo?.enabled {
                                Button(
                                    enabled ? String(localized: "Disable blocklist") : String(localized: "Enable blocklist"),
                                    systemImage: enabled ? "xmark" : "checkmark"
                                ) {
                                    Task {
                                        await blocklistsViewModel.enableDisableBlocklist(blocklistId: blocklistId, newStatus: !enabled)
                                    }
                                }
                                .disabled(activeProcess != nil)
                            }

                            Button(String(localized: "Delete blocklist"), systemImage: "trash", role: .destructive) {
                                showDeleteConfirmation = true
                            }
                            .disabled(activeProcess != nil)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(String(localized: "Delete blocklist"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button(String(localized: "Delete"), role: .destructive) {
                Task {
                    await blocklistsViewModel.deleteBlocklist(blocklistId: blocklistId)
                    if blocklistsViewModel.blocklistDeletedSuccessfully {
                        onDismiss?()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this blocklist? This action cannot be undone.")
        }
        .alert(String(localized: "Refresh blocklist"), isPresented: $showRefreshConfirmation) {
            Button(role: .cancel) { showRefreshConfirmation = false } label: { Text("Cancel") }
            if #available(iOS 26.0, *) {
                Button(role: .confirm) { blocklistsViewModel.refreshBlocklists(blocklistId: blocklistId) } label: { Text("Refresh list") }
            } else {
                Button { blocklistsViewModel.refreshBlocklists(blocklistId: blocklistId) } label: { Text("Refresh list") }
            }
        } message: {
            Text("Refreshing a blocklist is a computing expensive task that can take up to a few minutes. Don't refresh too often. Do you want to continue?")
        }
        .onChange(of: blocklistId) { _, newValue in
            viewModel.updateBlocklistId(newValue)
        }
    }
    
    @ViewBuilder
    func content(_ data: BlocklistDataResponse_Data) -> some View {
        let blocklistProcess = getBlocklistActiveProcess(data: serviceStatusViewModel.state.data, blocklistId: blocklistId)
        
        let newMin = Config.ipsAmountBatch*viewModel.ipsRound
        let endIndex = newMin > data.blocklistIPS.count ? data.blocklistIPS.count : newMin
        let slicedIps = Array(data.blocklistIPS[0..<endIndex])
        
        List {
            Section("Information") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(verbatim: data.name)
                        .foregroundStyle(Color.gray)
                }
                if let url = data.url {
                    Button {
                        browserOpen = true
                    } label: {
                        HStack {
                            Text(verbatim: "URL")
                            Spacer()
                            Text(verbatim: url)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .foregroundStyle(Color.foreground)
                    .safariView(isPresented: $browserOpen, urlString: url)
                }
                HStack {
                    Text("Amount of blocked IPs")
                    Spacer()
                    Text(data.countIPS.formatted())
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("Managed by")
                    Spacer()
                    switch data.type {
                    case .api:
                        Text(verbatim: "Monitor API")
                            .foregroundStyle(Color.blue)
                    case .crowdsec:
                        Text(verbatim: "CrowdSec")
                            .foregroundStyle(Color.orange)
                    }
                }
                if let value = data.enabled {
                    HStack {
                        Text("Enabled")
                        Spacer()
                        Image(systemName: value ? "checkmark.circle.fill" : "x.circle.fill")
                            .foregroundStyle(value ? .green : .red)
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                    }
                }
                if let added = data.addedDate?.toDateFromISO8601() {
                    HStack {
                        Text("Added")
                        Spacer()
                        Text(added.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(Color.gray)
                    }
                }
                if let lastSuccessfulRefresh = data.lastSuccessfulRefresh?.toDateFromISO8601() {
                    HStack {
                        Text(data.lastRefreshFailed == true ? "Last successful refresh" : "Last refresh")
                        Spacer()
                        Text(lastSuccessfulRefresh.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(Color.gray)
                    }
                }
                if data.lastRefreshFailed == true, let lastRefreshAttempt = data.lastRefreshAttempt?.toDateFromISO8601() {
                    HStack {
                        Text("Last refresh attempt failed")
                        Spacer()
                        Text(lastRefreshAttempt.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(Color.red)
                    }
                }
                if let blocklistProcess = blocklistProcess {
                    HStack {
                        Text(verbatim: "\(getProcessType(blocklistProcess))...")
                        Spacer()
                        ProgressView()
                    }
                }
            }
            
            Section("Blocked IPs") {
                if data.blocklistIPS.isEmpty {
                    ContentUnavailableView("Blocklist with no IPs", systemImage: "list.bullet", description: Text("This blocklist does not contain any blocked IP address"))
                }
                else {
                    ForEach(slicedIps, id: \.self) { ip in
                        Text(verbatim: ip)
                            .onAppear {
                                if ip == slicedIps.last && endIndex < data.blocklistIPS.count {
                                    viewModel.incrementIpsRound()
                                }
                            }
                    }
                }
            }
        }
        .searchable(
            text: Binding(
                get: { viewModel.searchText },
                set: { newValue in
                    withAnimation {
                        viewModel.searchText = newValue
                    }
                }
            ),
            isPresented: Binding(
                get: { viewModel.searchPresented },
                set: { newValue in
                    withAnimation {
                        viewModel.searchPresented = newValue
                    }
                }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search IPs"
        )
        .refreshable {
            await viewModel.fetchData()
        }
        .overlay {
            if viewModel.searchPresented {
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView("Input search text", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.background)
                        .transition(.opacity)
                }
                else {
                    let filterIps = data.blocklistIPS.filter() { $0.hasPrefix(viewModel.searchText) }
                    let endIndex = newMin > filterIps.count ? filterIps.count : newMin
                    let slicedIps = Array(filterIps[0..<endIndex])
                    if slicedIps.isEmpty {
                        ContentUnavailableView("No results for '\(viewModel.searchText)'", systemImage: "magnifyingglass", description: Text("Change the inputted search term"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .background(Color.background)
                            .transition(.opacity)
                    }
                    else {
                        List(slicedIps, id: \.self) { ip in
                            Text(verbatim: ip)
                        }
                        .animation(.default, value: slicedIps)
                        .transition(.opacity)
                    }
                }
            }
        }
    }
}
