import SwiftUI

struct ServiceStatusView: View {
    
    @Environment(ServerStatusViewModel.self) private var viewModel

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
                    ForEach(filteredFailed, id: \.self) { item in
                        let index = status.processes.firstIndex(of: item)!
                        if item.blocklistImport != nil || item.blocklistEnable != nil {
                            ProcessBlocklistStatus(process: status.processes[index])
                        }
                    }
                }
            }
            if !filteredRunning.isEmpty {
                Section("Running tasks") {
                    ForEach(filteredRunning, id: \.self) { item in
                        let index = status.processes.firstIndex(of: item)!
                        if item.blocklistImport != nil || item.blocklistEnable != nil {
                            ProcessBlocklistStatus(process: status.processes[index])
                        }
                    }
                }
            }
            if !filteredSuccessful.isEmpty {
                Section("Successful tasks") {
                    ForEach(filteredSuccessful, id: \.self) { item in
                        let index = status.processes.firstIndex(of: item)!
                        if item.blocklistImport != nil || item.blocklistEnable != nil {
                            ProcessBlocklistStatus(process: status.processes[index])
                        }
                    }
                }
            }
        }
    }
}
