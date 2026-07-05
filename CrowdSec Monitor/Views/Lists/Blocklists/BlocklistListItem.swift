import SwiftUI

struct BlocklistListItem: View {
    let blocklist: BlocklistsListResponse_Item
    
    init(_ blocklist: BlocklistsListResponse_Item) {
        self.blocklist = blocklist
    }
    
    @Environment(BlocklistsListViewModel.self) private var viewModel
    @Environment(ServiceStatusViewModel.self) private var serviceStatusViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var showRefreshBlocklistConfirmation = false
    
    var body: some View {
        let blocklistProcess = getBlocklistActiveProcess(data: serviceStatusViewModel.state.data, blocklistId: blocklist.id)
        
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
                if blocklist.lastRefreshFailed == true {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Blocklist refresh failed")
                    }
                    .foregroundStyle(Color.red)
                    .font(.system(size: 14))
                }
                if let blocklistProcess = blocklistProcess {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.mini)
                        Text(verbatim: getProcessType(blocklistProcess))
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
                Section {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        showRefreshBlocklistConfirmation = true
                    }
                    .disabled(blocklistProcess != nil)
                }
                Section {
                    if let enabled = blocklist.enabled {
                        Button(
                            blocklist.enabled == true ? String(localized: "Disable blocklist") : String(localized: "Enable blocklist"),
                            systemImage: blocklist.enabled == true ? "xmark" : "checkmark"
                        ) {
                            Task {
                                await viewModel.enableDisableBlocklist(blocklistId: blocklist.id, newStatus: !enabled)
                            }
                        }
                        .disabled(blocklistProcess != nil)
                    }
                    Button(String(localized: "Delete blocklist"), systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(blocklistProcess != nil)
                }
            }
        }
        .alert("Delete blocklist", isPresented: $showDeleteConfirmation) {
            Button(String(localized: "Cancel"), role: .cancel) {
                showDeleteConfirmation = false
            }
            Button(String(localized: "Delete"), role: .destructive) {
                Task {
                    await viewModel.deleteBlocklist(blocklistId: blocklist.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this blocklist? This action cannot be undone.")
        }
        .alert("Refresh blocklist", isPresented: $showRefreshBlocklistConfirmation) {
            Button(role: .cancel) {
                showRefreshBlocklistConfirmation = false
            } label: {
                Text("Cancel")
            }
            if #available(iOS 26.0, *) {
                Button(role: .confirm) {
                    viewModel.refreshBlocklists(blocklistId: blocklist.id)
                } label: {
                    Text("Refresh list")
                }
            } else {
                Button {
                    viewModel.refreshBlocklists(blocklistId: blocklist.id)
                } label: {
                    Text("Refresh list")
                }
            }
        } message: {
            Text("Refreshing a blocklist is a computing expensive task that can take up to a few minutes. Don't refresh too often. Do you want to continue?")
        }
    }
}
