import SwiftUI

struct CreateServerSheet: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @State private var discardChangesAlert = false
    @State private var connectionFormViewModel = ConnectionFormViewModel()
    
    func handleConnect() {
        Task {
            let result = await connectionFormViewModel.connect()
            if result == true {
                onClose()
            }
        }
    }
    
    var body: some View {
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
                                onClose()
                            }
                        }
                        .disabled(connectionFormViewModel.connecting)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if #available(iOS 26.0, *) {
                            Button(role: .confirm) {
                                handleConnect()
                            } label: {
                                saveButton()
                            }
                            .disabled(connectionFormViewModel.connecting)
                        }
                        else {
                            Button {
                                handleConnect()
                            } label: {
                                saveButton()
                            }
                            .disabled(connectionFormViewModel.connecting)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    func saveButton() -> some View {
        if connectionFormViewModel.connecting {
            ProgressView()
        }
        else {
            Text("Connect")
        }
    }
}

#Preview {
    CreateServerSheet {
        
    }
}
