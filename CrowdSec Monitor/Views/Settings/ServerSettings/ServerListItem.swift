import SwiftUI

struct ServerListItem: View {
    let server: CSServer
    
    init(server: CSServer) {
        self.server = server
    }
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var showDeleteConfirmation = false
    @State private var showErrorDeleteServerAlert = false
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: "server.rack")
                    .font(.system(size: 20))
                Spacer()
                    .frame(width: 24)
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
                if server.id == authViewModel.currentServer?.id {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.blue)
                        .fontWeight(.medium)
                }
            }
            .foregroundStyle(Color.foreground)
        }
        .contextMenu {
            Button("Delete server", systemImage: "trash", role: .destructive) {
                showDeleteConfirmation = true
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
    }
}
