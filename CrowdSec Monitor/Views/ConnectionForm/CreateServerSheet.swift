import SwiftUI

struct CreateServerSheet: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @State private var discardChangesAlert = false
    @State private var connectionFormViewModel = ConnectionFormViewModel()
    
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
                        Button {
                            Task {
                                let result = await connectionFormViewModel.connect()
                                if result == true {
                                    onClose()
                                }
                            }
                        } label: {
                            if connectionFormViewModel.connecting {
                                ProgressView()
                            }
                            else {
                                Text("Connect")
                            }
                        }
                        .disabled(connectionFormViewModel.connecting)
                    }
                }
        }
    }
}

#Preview {
    CreateServerSheet {
        
    }
}
