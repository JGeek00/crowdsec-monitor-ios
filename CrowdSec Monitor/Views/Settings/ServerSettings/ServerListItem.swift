import SwiftUI
import SystemNotification

struct ServerListItem: View {
    let server: CSServer
    let onSetNewDefaultServer: ((String) -> Void)
    
    init(server: CSServer, onSetNewDefaultServer: @escaping ((String) -> Void)) {
        self.server = server
        self.onSetNewDefaultServer = onSetNewDefaultServer
    }
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var showErrorDeleteServerAlert = false
    @State private var showErrorSetDefaultServer = false
    
    var body: some View {
        Button {
            authViewModel.changeCurrentServer(server: server)
        } label: {
            HStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 20))
                Spacer()
                    .frame(width: 16)
                VStack(alignment: .leading, spacing: 6) {
                    Text(server.name)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(buildUrl(server: server))
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                if server == authViewModel.currentServer {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.blue)
                        .fontWeight(.medium)
                }
            }
            .foregroundStyle(Color.foreground)
        }
        .contextMenu {
            Section {
                if server.isDefaultServer == true {
                    Button("Default server", systemImage: "star.fill") {}
                        .disabled(true)
                }
                else {
                    Button("Set as default server", systemImage: "star") {
                        let changed = authViewModel.setDefaultServer(server)
                        if changed == true {
                            onSetNewDefaultServer(server.name)
                        }
                        else {
                            showErrorSetDefaultServer = true
                        }
                    }
                }
            }
            Section {
                Button("Delete server", systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .alert("Delete server", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                let deleted = authViewModel.deleteServer(server: server)
                if deleted == false {
                    showErrorDeleteServerAlert = true
                }
            }
        } message: {
            Text("Are you sure you want to delete this server? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showErrorDeleteServerAlert) {
            Button("OK", role: .cancel) {
                showErrorDeleteServerAlert = false
            }
        } message: {
            Text("An error occurred while deleting the server. This could mean that the database is corrupted. Please try deleting the server again. If the problem persists, uninstall the application and install it again.")
        }
        .alert("Error", isPresented: $showErrorSetDefaultServer) {
            Button("OK", role: .cancel) {
                showErrorSetDefaultServer = false
            }
        } message: {
            Text("An error occurred while setting the default server. Please try again. If the problem persists, uninstall the application and install it again.")
        }
    }
}
