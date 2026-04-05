import SwiftUI

struct CheckDomainReachableView: View {
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    @Environment(CheckDomainReachableViewModel.self) private var viewModel
    
    @State private var showConfirmationDialog = false
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            List {
                Section {
                    TextField("Domain", text: $viewModel.domain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                } footer: {
                    Text("The backend will try to resolve the domain against a DNS server. If the domain is resolved correctly, the backend will check if the resolved IP addresses are listed in any blocklist. The result will show the resolved IP addresses and the blocklists they are listed in, if any.")
                }
                
                Section {
                    Button {
                        viewModel.checkDomain()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Check domain")
                                .multilineTextAlignment(.center)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(viewModel.domain.isEmpty)
                }
                
                if let data = viewModel.data {
                    QueryResult(data: data)
                        .transition(.opacity)
                }
                if viewModel.error == true {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.circle", description: Text("An error occurred while checking the domain. Please try again."))
                        .transition(.opacity)
                }
                if viewModel.domainNotResolvable == true {
                    ContentUnavailableView("Domain does not exist", systemImage: "exclamationmark.circle", description: Text("The domain you entered could not be resolved. Please check the domain and try again."))
                        .transition(.opacity)
                }
            }
            .disabled(viewModel.loading == true)
            .navigationTitle("Domain reachable checker")
            .navigationBarTitleDisplayMode(.inline)
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
            .alert("Invalid domain", isPresented: $viewModel.invalidDomainAlert) {
                Button("OK", role: .cancel) {
                    viewModel.invalidDomainAlert = false
                }
            } message: {
                Text("The domain you entered is not valid. Please check the format and try again.")
            }
            .overlay {
                if viewModel.loading == true {
                    ZStack {
                        Spacer()
                            .background(Color.white.opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        VStack(alignment: .center, spacing: 24) {
                            ProgressView()
                                .controlSize(.extraLarge)
                            Text("Checking domain...\nThis may take up to one minute.")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.opacity)
                }
            }
        }
    }
}

fileprivate struct QueryResult: View {
    let data: BlocklistsCheckDomainResponse
    
    init(data: BlocklistsCheckDomainResponse) {
        self.data = data
    }
    
    var body: some View {
        Section("IP addresses") {
            ForEach(data.ips, id: \.self) { entry in
                let blocklists = entry.blocklists.joined(separator: ", ")
                VStack(alignment: .leading, spacing: 6) {
                    Text(verbatim: entry.ip)
                        .fontWeight(.medium)
                    Group {
                        if blocklists.isEmpty {
                            Text("Not blocked")
                                .foregroundStyle(Color.gray)
                        }
                        else {
                            Text("Blocklists: \(blocklists)")
                                .foregroundStyle(Color.red)
                        }
                    }
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                }
            }
        }
    }
}
