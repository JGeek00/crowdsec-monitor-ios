import SwiftUI

fileprivate struct SelectedList {
    let type: Enums.ListType
    let id: String
}

struct ListsView: View {
    @Environment(AllowlistsListViewModel.self) private var allowlistsViewModel
    @Environment(BlocklistsListViewModel.self) private var blocklistsViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedListType: Enums.ListType = .blocklist
    @State private var selectedAllowlist: String? = nil
    @State private var selectedBlocklist: Int? = nil
    @State private var selectedList: SelectedList? = nil
    @State private var showIPsCheckerSheet = false
    @State private var showCheckDomainReachableSheet = false
    
    var body: some View {
        NavigationSplitView {
            Group {
                switch selectedListType {
                case .allowlist:
                    AllowlistsListView(selectedAllowlist: $selectedAllowlist)
                        .transition(.opacity)
                case .blocklist:
                    BlocklistsListView(selectedBlocklist: $selectedBlocklist)
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
                        Button(String(localized: "IP addresses checker")) {
                            showIPsCheckerSheet = true
                        }
                        Button(String(localized: "Domain reachable checker")) {
                            showCheckDomainReachableSheet = true
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis")
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
            if let selectedList = selectedList {
                switch selectedList.type {
                case .allowlist:
                    AllowlistDetailsView(allowlistName: selectedList.id)
                        .id(selectedList.id)
                case .blocklist:
                    BlocklistDetailsView(blocklistId: Int(selectedList.id)!)
                        .id(selectedList.id)
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
        .onChange(of: selectedAllowlist, initial: true) { _, value in
            if let value = value {
                selectedList = SelectedList(type: .allowlist, id: value)
                selectedBlocklist = nil
            }
        }
        .onChange(of: selectedBlocklist, initial: true) { _, value in
            if let value = value {
                selectedList = SelectedList(type: .blocklist, id: String(value))
                selectedAllowlist = nil
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
    }
}
