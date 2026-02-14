import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Remove server", role: .destructive) {
                        authViewModel.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
