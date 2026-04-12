import SwiftUI
import SystemNotification

struct ServerSettingsView: View {
    
    init() {}
    
    @Environment(ServersManagerViewModel.self) private var serversManagerViewModel
    @Environment(ServiceStatusViewModel.self) private var serviceStatusViewModel
    
    @State private var showCreateServerSheet = false
    @State private var newDefaultServer: String? = nil
    
    var body: some View {
        List {
            Section("Servers") {
                ForEach(serversManagerViewModel.servers, id: \.id) { server in
                    ServerListItem(server: server) { name in
                        newDefaultServer = name
                    }
                }
                Button("Create server", systemImage: "plus") {
                    showCreateServerSheet = true
                }
            }
            
            ServerInformationSection()
        }
        .navigationTitle("Server settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateServerSheet) {
            CreateServerSheet {
                showCreateServerSheet = false
            }
        }
        .systemNotification(isActive: Binding(get: { newDefaultServer != nil }, set: { _ in newDefaultServer = nil })) {
            SystemNotification(icon: "star.fill", title: String(localized: "Default server"), subtitle: String(localized: "\(String(newDefaultServer ?? "N/A")) is now the default server"))
        }
    }
}

#Preview {
    ServerSettingsView()
}
