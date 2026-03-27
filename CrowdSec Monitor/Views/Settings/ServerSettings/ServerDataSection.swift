import SwiftUI

struct ServerDataSection: View {
    
    init() {}
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        Section {
            if let currentServer = authViewModel.currentServer {
                let serverValues = buildUrl(server: currentServer)
                HStack {
                    Text(verbatim: serverValues)
                    Spacer()
                    Image(systemName: "server.rack")
                }
                .foregroundStyle(Color.gray)
                .fontWeight(.medium)
            }
            Button("Remove server connection", role: .destructive) {
                showDeleteAlert = true
            }
        }
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
}
