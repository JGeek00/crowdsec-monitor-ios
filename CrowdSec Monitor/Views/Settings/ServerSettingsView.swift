import SwiftUI

struct ServerSettingsView: View {
    
    init() {}
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            Section("Information") {
                HStack {
                    Text("LAPI status")
                    Spacer()
                    Group {
                        switch serverStatusViewModel.status {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            if data.csLapi.lapiConnected == true {
                                online()
                            }
                            else {
                                offline()
                            }
                        case .failure:
                           offline()
                        }
                    }
                }
                HStack {
                    Text("API version")
                    Spacer()
                    Group {
                        switch serverStatusViewModel.status {
                        case .loading:
                            ProgressView()
                        case .success(let data):
                            Text(verbatim: data.csMonitorAPI.version)
                        case .failure:
                            Text(verbatim: "N/A")
                        }
                    }
                }
            }
            Section {
                Button("Remove server connection", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .navigationTitle("Server settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Removing server", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert = false
            }
            Button("Delete", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to remove the server connection? You will have to create the connection from scratch.")
        }
    }
    
    @ViewBuilder
    func online() -> some View {
        HStack {
            Image(systemName: "checkmark")
            Spacer()
                .frame(width: 8)
            Text("Online")
        }
        .foregroundStyle(Color.green)
    }
    
    @ViewBuilder
    func offline() -> some View {
        HStack {
            Image(systemName: "xmark")
            Spacer()
                .frame(width: 8)
            Text("Offline")
        }
        .foregroundStyle(Color.red)
    }
}

#Preview {
    ServerSettingsView()
}
