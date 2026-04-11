import SwiftUI
import CustomAlert
import SystemNotification

struct BlocklistsListView: View {
    @Environment(BlocklistsListViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var selectedBlocklist: String?
    
    @State private var activeBlocklistId: String?
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
        .systemNotification(isActive: $viewModel.blocklistDeletedSuccessfully) {
            SystemNotification(icon: "checkmark", title: "Blocklist deleted", subtitle: "The blocklist has been deleted")
        }
        .systemNotification(isActive: $viewModel.errorEnableBlocklist) {
            SystemNotification(icon: "exclamationmark.circle", title: "Error", subtitle: "The blocklist could not be enabled", color: Color.red)
        }
        .systemNotification(isActive: $viewModel.errorDisableBlocklist) {
            SystemNotification(icon: "exclamationmark.circle", title: "Error", subtitle: "The blocklist could not be disabled", color: Color.red)
        }
        .systemNotification(isActive: $viewModel.errorDeleteBlocklist) {
            SystemNotification(icon: "exclamationmark.circle", title: "Error", subtitle: "The blocklist could not be deleted", color: Color.red)
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
