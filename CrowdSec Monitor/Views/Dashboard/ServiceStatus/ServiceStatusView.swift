import SwiftUI

struct ServiceStatusView: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(ServiceStatusViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading...")
                    
                case .success(let data):
                    Content(status: data)
                    
                case .failure:
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.circle",
                        description: Text("An error occured when fetching the service status")
                    )
                }
            }
            .navigationTitle("Service status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
            }
        }
    }
}

fileprivate struct Content: View {
    let status: APIStatusResponse
    
    init(status: APIStatusResponse) {
        self.status = status
    }
    
    var body: some View {
        let filteredFailed = status.processes.filter({ $0.successful == false })
        let filteredRunning = status.processes.filter({ $0.successful == nil })
        let filteredSuccessful = status.processes.filter({ $0.successful == true })

        List {
            Section {
                HStack {
                    Text("LAPI available")
                    Spacer()
                    if status.csLapi.lapiConnected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    else {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                HStack {
                    Text("Bouncer available")
                    Spacer()
                    if status.csBouncer.available {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    else {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            if !filteredFailed.isEmpty {
                Section("Failed tasks") {
                    Content(filteredFailed)
                }
            }
            if !filteredRunning.isEmpty {
                Section("Running tasks") {
                    Content(filteredRunning)
                }
            }
            if !filteredSuccessful.isEmpty {
                Section("Successful tasks") {
                    Content(filteredSuccessful)
                }
            }
        }
    }
    
    @ViewBuilder
    func Content(_ items: [APIStatusResponse_Process]) -> some View {
        ForEach(items, id: \.self) { item in
            if item.blocklistImport != nil || item.blocklistEnable != nil {
                ProcessBlocklistImportEnableStatus(process: item)
            }
            if item.blocklistDelete != nil || item.blocklistDisable != nil {
                ProcessBlocklistDeleteDisableStatus(process: item)
            }
            if item.blocklistRefresh != nil {
                ProcessBlocklistRefreshStatus(process: item)
            }
        }
    }
}
