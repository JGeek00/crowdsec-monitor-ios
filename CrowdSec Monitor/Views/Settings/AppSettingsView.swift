import SwiftUI

struct AppSettingsView: View {
    @SharedAppStorage(StorageKeys.topItemsDashboard) private var amountItemsDashboard: Int = Defaults.topItemsDashboard
    @SharedAppStorage(StorageKeys.showDefaultActiveDecisions) private var showDefaultActiveDecisions: Bool = Defaults.showDefaultActiveDecisions
    @SharedAppStorage(StorageKeys.hideDefaultDuplicatedDecisions) private var hideDefaultDuplicatedDecisions: Bool = Defaults.hideDefaultDuplicatedDecisions
    
    @Environment(AuthViewModel.self) private var authViewModel
    
    @State private var showDeleteAlert = false
        
    var body: some View {
        List {
            Section("Dashboard") {
                HStack {
                    Stepper("Amount of items to display in dashboard lists", value: $amountItemsDashboard, in: 5...10)
                    Spacer()
                        .frame(width: 24)
                    Text(verbatim: "\(amountItemsDashboard)")
                        .monospacedDigit()
                        .background(Circle().fill(Color.gray.opacity(0.2)).frame(width: 30, height: 30))
                }
            }
            
            Section("Decisions") {
                Toggle("Show by default only active decisions", isOn: $showDefaultActiveDecisions)
                Toggle("Hide by default active duplicated decisions", isOn: $hideDefaultDuplicatedDecisions)
            }
            
            Section("Server") {
                Button("Remove server connection", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .navigationTitle("Application settings")
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

#Preview {
    AppSettingsView()
}
