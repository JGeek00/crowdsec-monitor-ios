import SwiftUI

enum AllowlistsIPsCheckerNavigation: Hashable {
    case results
}

struct AllowlistsIPsCheckerView: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(AllowlistsIPsCheckerViewModel.self) private var viewModel
    
    @State private var showInvalidIPAlert = false
    @State private var showConfirmationDialog = false
    @State private var showResultsView = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            List {
                Section("IP addresses to validate") {
                    ForEach(viewModel.ipsToCheck.indices, id: \.self) { index in
                        HStack {
                            TextField("Input an IP address", text: $viewModel.ipsToCheck[index].value)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            if viewModel.ipsToCheck[index].invalid == true {
                                Button {
                                    showInvalidIPAlert = true
                                } label: {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundStyle(Color.red)
                                }
                            }
                        }
                        .onChange(of: viewModel.ipsToCheck[index].value) {
                            viewModel.validateIP(index)
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.removeEntry(at: indexSet)
                    }
                    Button("Add", systemImage: "plus") {
                        viewModel.addEntry()
                    }
                }
                
                Section {
                    Button {
                        viewModel.validateIps()
                        showResultsView = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Check IP addresses")
                                .multilineTextAlignment(.center)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.ipsToCheck.isEmpty)
                }
            }
            .animation(.default, value: viewModel.ipsToCheck)
            .navigationTitle("Check IP addresses")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showResultsView, destination: {
                AllowlistsIPsCheckerResultView()
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        showConfirmationDialog = true
                    }
                    .confirmationDialog("Close validator?", isPresented: $showConfirmationDialog) {
                        Button("Close", role: .destructive) {
                            onClose()
                        }
                    }
                }
            }
            .alert("Invalid IP address", isPresented: $showInvalidIPAlert) {
                Button("OK", role: .cancel) {
                    showInvalidIPAlert = false
                }
            } message: {
                Text("The value introduced doesn't correspond to a valid IPv4 or IPv6 address.")
            }
        }
    }
}
