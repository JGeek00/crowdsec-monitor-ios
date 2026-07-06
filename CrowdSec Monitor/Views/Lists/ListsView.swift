import SwiftUI

struct SelectedList: Hashable, Identifiable {
    let type: Enums.ListType
    let id: String
}

struct ListsView: View {
    @State private var allowlistsListViewModel = AllowlistsListViewModel()
    @State private var blocklistsListViewModel = BlocklistsListViewModel()
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedListType: Enums.ListType = .blocklist
    @State private var selectedList: SelectedList? = nil
    @State private var showIPsCheckerSheet = false
    @State private var showCheckDomainReachableSheet = false
    @State private var showRefreshBlocklistConfirmation = false
    
    var body: some View {
        NavigationSplitView {
            Group {
                switch selectedListType {
                case .allowlist:
                    AllowlistsListView(selectedList: $selectedList)
                        .transition(.opacity)
                case .blocklist:
                    BlocklistsListView(selectedList: $selectedList)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Lists")
            .condition { view in
                if #available(iOS 26.0, *) {
                    view.navigationBarTitleDisplayMode(.inline)
                }
                else {
                    view
                }
            }
            .toolbar {
                if #unavailable(iOS 26.0) {
                    ToolbarItem(placement: .bottomBar) {
                        picker()
                            .padding(.bottom, 8)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section {
                            Button(String(localized: "IP addresses checker")) {
                                showIPsCheckerSheet = true
                            }
                            Button(String(localized: "Domain reachable checker")) {
                                showCheckDomainReachableSheet = true
                            }
                        }
                        Section {
                            Button("Refresh lists") {
                                showRefreshBlocklistConfirmation = true
                            }
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
            .condition { view in
                if #available(iOS 26.0, *) {
                    view
                        .safeAreaBar(edge: .top) {
                            picker()
                        }
                }
                else { view }
            }
        } detail: {
            if let item = selectedList {
                switch item.type {
                case .allowlist:
                    AllowlistDetailsView(allowlistName: item.id)
                        .id(item.id)
                case .blocklist:
                    BlocklistDetailsView(blocklistId: item.id) {
                        selectedList = nil
                    }
                    .id(item.id)
                }
            }
            else {
                if horizontalSizeClass == .regular {
                    ContentUnavailableView(
                        "Select a list",
                        systemImage: "list.bullet",
                        description: Text("Choose a list to see the list of IPs")
                    )
                }
            }
        }
        .sheet(isPresented: $showIPsCheckerSheet) {
            IPsCheckerView {
                showIPsCheckerSheet = false
            }
            .environment(IPsCheckerViewModel())
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showCheckDomainReachableSheet) {
            CheckDomainReachableView {
                showCheckDomainReachableSheet = false
            }
            .environment(CheckDomainReachableViewModel())
            .interactiveDismissDisabled()
        }
        .alert("Refresh blocklists", isPresented: $showRefreshBlocklistConfirmation) {
            Button(role: .cancel) {
                showRefreshBlocklistConfirmation = false
            } label: {
                Text("Cancel")
            }
            if #available(iOS 26.0, *) {
                Button(role: .confirm) {
                    blocklistsListViewModel.refreshBlocklists()
                } label: {
                    Text("Refresh lists")
                }
            } else {
                Button {
                    blocklistsListViewModel.refreshBlocklists()
                } label: {
                    Text("Refresh lists")
                }
            }
        } message: {
            Text("Refreshing a blocklist is a computing expensive task that can take up to a few minutes. Don't refresh too often. Do you want to continue?")
        }
        .environment(allowlistsListViewModel)
        .environment(blocklistsListViewModel)
    }
    
    @ViewBuilder
    func picker() -> some View {
        Picker(
            "Selected list type",
            selection: Binding(
                get: { selectedListType },
                set: { newValue in
                    withAnimation {
                        selectedListType = newValue
                    }
                }
            )
        ) {
            Text("Blocklists").tag(Enums.ListType.blocklist)
            Text("Allowlists").tag(Enums.ListType.allowlist)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .condition { view in
            if horizontalSizeClass == .regular {
                view.padding(.bottom, 12)
            } else { view }
        }
    }
}
