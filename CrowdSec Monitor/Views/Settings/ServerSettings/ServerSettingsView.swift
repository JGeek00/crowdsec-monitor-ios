import SwiftUI

struct ServerSettingsView: View {
    
    init() {}
    
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ServerStatusViewModel.self) private var serverStatusViewModel
    
    @State private var showCreateServerSheet = false
    @State private var discardChangesAlert = false
    @State private var connectionFormViewModel = ConnectionFormViewModel()
    
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
            
            ServerDataSection()
        }
        .navigationTitle("Server settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreateServerSheet) {
            NavigationStack {
                ConnectionForm(showHeader: false, viewModel: connectionFormViewModel)
                    .interactiveDismissDisabled()
                    .navigationTitle("Create server")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButton {
                                discardChangesAlert = true
                            }
                            .confirmationDialog("Discard changes", isPresented: $discardChangesAlert) {
                                Button("Discard changes", role: .destructive) {
                                    showCreateServerSheet = false
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Save") {
                                connectionFormViewModel.connect()
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ServerSettingsView()
}
