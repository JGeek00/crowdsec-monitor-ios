import SwiftUI

struct BlocklistListItem: View {
    let blocklist: BlocklistsListResponse_Item
    
    init(_ blocklist: BlocklistsListResponse_Item) {
        self.blocklist = blocklist
    }
    
    @Environment(BlocklistsListViewModel.self) private var viewModel
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        let blocklistProcess = getBlocklistActiveProcess(data: serverStatusViewModel.state.data, blocklistId: blocklist.id)
        
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
                if let lastRefreshAttempt = blocklist.lastRefreshAttempt?.toDateFromISO8601(), let lastSuccessfulRefresh = blocklist.lastSuccessfulRefresh?.toDateFromISO8601(), blocklistProcess != nil {
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
                if let enabled = blocklist.enabled {
                    Section {
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
                }
                Section {
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
    }
}
