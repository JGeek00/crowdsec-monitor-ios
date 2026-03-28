import SwiftUI

struct ServerSettingsView: View {
    
    init() {}
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @State private var showCreateServerSheet = false
    
    var body: some View {
        List {
            Section("Servers") {
                ForEach(authViewModel.servers, id: \.id) { server in
                    ServerListItem(server: server)
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
    }
}

#Preview {
    ServerSettingsView()
}
