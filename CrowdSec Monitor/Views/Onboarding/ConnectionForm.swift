import SwiftUI

struct ConnectionForm: View {
    @Environment(OnboardingViewModel.self) private var viewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        @Bindable var onboardingViewModel = viewModel
        
        Form {
            Section(header: VStack(alignment: .leading) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 60))
                Spacer()
                    .frame(height: 24)
                Text("Setup the server connection")
                    .fontWeight(.semibold)
                    .font(.system(size: 30))
            }
            .padding(.vertical, 24)) {
                EmptyView()
            }
            .foregroundStyle(Color.foreground)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            Section("Server route") {
                Picker("Connection method", selection: $onboardingViewModel.connectionMethod) {
                    Text("HTTP")
                        .tag(Enums.ConnectionMethod.http)
                    Text("HTTPS")
                        .tag(Enums.ConnectionMethod.https)
                }
                TextField("IP address or domain", text: $onboardingViewModel.ipDomain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                TextField("Port", text: $onboardingViewModel.port)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("Path", text: $onboardingViewModel.path)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Section {
                Picker("Method", selection: $onboardingViewModel.authMethod) {
                    Text("None")
                        .tag(Enums.AuthMethod.none)
                    Text("Username and password")
                        .tag(Enums.AuthMethod.basic)
                    Text("Access token")
                        .tag(Enums.AuthMethod.bearer)
                }
                switch onboardingViewModel.authMethod {
                case .none:
                    Group {}
                case .basic:
                    TextField("Username", text: $onboardingViewModel.basicUser)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $onboardingViewModel.basicPassword)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                case .bearer:
                    HStack {
                        SecureField("Token", text: $onboardingViewModel.bearerToken)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Button {
                            if let clipboardText = UIPasteboard.general.string {
                                onboardingViewModel.bearerToken = clipboardText
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } header: {
                Text("Authentication")
            } footer: {
                Spacer()
                    .frame(height: 84)  // Same height as buttons overlay
            }
        }
        .overlay(alignment: .bottom, content: {
            HStack(alignment: .center) {
                Button {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
                    }
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.left")
                        Text("Back")
                        Spacer()
                    }
                    .fontWeight(.semibold)
                }
                .normalButton()
                Spacer()
                    .frame(width: 16)
                Button {
                    onboardingViewModel.connect()
                } label: {
                    Group {
                        Spacer()
                        if onboardingViewModel.connecting == true {
                            ProgressView()
                        }
                        else {
                            Text("Connect")
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                        }
                        Spacer()
                    }
                }
                .prominentButton()
            }
            .padding(.horizontal, 24)
            .frame(height: 84, alignment: .center)
            .disabled(onboardingViewModel.connecting)
            .background(Color.listBackground)
        })
        .disabled(onboardingViewModel.connecting)
        .alert("Invalid values", isPresented: $onboardingViewModel.invalidValuesAlert, actions: {
            Button {
                onboardingViewModel.invalidValuesAlert.toggle()
            } label: {
                Text("Close")
            }
        }, message: {
            Text(viewModel.invalidValuesMessage)
        })
        .alert("Connection error", isPresented: $onboardingViewModel.connectionErrorAlert, actions: {
            Button {
                onboardingViewModel.connectionErrorAlert.toggle()
            } label: {
                Text("Close")
            }
        }, message: {
            Text(viewModel.connectionErrorMessage)
        })
    }
}

#Preview {
    ConnectionForm()
        .environment(OnboardingViewModel(showOnboarding: true, selectedTab: 2))
}
