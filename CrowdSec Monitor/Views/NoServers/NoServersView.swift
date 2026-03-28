import SwiftUI

struct NoServersView: View {
    
    @State private var showCreateServerSheet = false
    
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Text("No servers added")
            } description: {
                Text("To start monitoring your CrowdSec instance, add a server.")
            } actions: {
                Button("Create server", systemImage: "plus") {
                    showCreateServerSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
            .sheet(isPresented: $showCreateServerSheet) {
                CreateServerSheet {
                    showCreateServerSheet = false
                }
            }
        }
    }
}
