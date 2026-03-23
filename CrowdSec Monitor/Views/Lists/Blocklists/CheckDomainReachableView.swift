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
                    Text("The backend will trigger a traceroute command to the specified domain and check if any of the IP addresses are in a blocklist.")
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
                    TracerouteResult(data: data)
                        .transition(.opacity)
                }
                if viewModel.error == true {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.circle", description: Text("An error occurred while checking the domain. Please try again."))
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

fileprivate struct TracerouteResult: View {
    let data: BlocklistsCheckDomainResponse
    
    init(data: BlocklistsCheckDomainResponse) {
        self.data = data
    }
    
    var body: some View {
        Section("Traceroute result") {
            ForEach(data.hops, id: \.self) { hop in
                HStack(spacing: 12) {
                    Text(verbatim: String(hop.hop))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.gray)
                    VStack(alignment: .leading, spacing: 6) {
                        Group {
                            if let ip = hop.ip {
                                Text(verbatim: ip)
                            }
                            else {
                                Text(verbatim: "N/A")
                            }
                        }
                        .font(.system(size: 16))
                        if let blocklist = hop.blocklist {
                            Text("Blocklist: \(blocklist)")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.red)
                        }
                    }
                    if hop.timedOut == true {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark")
                            Text(verbatim: "Timed out")
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
                    }
                }
            }
        }
    }
}
