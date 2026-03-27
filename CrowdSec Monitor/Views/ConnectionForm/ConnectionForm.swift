import SwiftUI

struct ConnectionForm: View {
    let showHeader: Bool
    @Binding var viewModel: ConnectionFormViewModel
    
    init(showHeader: Bool = true, viewModel: ConnectionFormViewModel) {
        self.showHeader = showHeader
        self._viewModel = Binding.constant(viewModel)
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Form {
            if showHeader {
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
            }
            Section("Server route") {
                TextField("Name", text: $viewModel.name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                Picker("Connection method", selection: $viewModel.connectionMethod) {
                    Text("HTTP")
                        .tag(Enums.ConnectionMethod.http)
                    Text("HTTPS")
                        .tag(Enums.ConnectionMethod.https)
                }
                TextField("IP address or domain", text: $viewModel.ipDomain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                TextField("Port", text: $viewModel.port)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("Path", text: $viewModel.path)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Section {
                Picker("Method", selection: $viewModel.authMethod) {
                    Text("None")
                        .tag(Enums.AuthMethod.none)
                    Text("Username and password")
                        .tag(Enums.AuthMethod.basic)
                    Text("Access token")
                        .tag(Enums.AuthMethod.bearer)
                }
                switch viewModel.authMethod {
                case .none:
                    Group {}
                case .basic:
                    TextField("Username", text: $viewModel.basicUser)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $viewModel.basicPassword)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                case .bearer:
                    HStack {
                        SecureField("Token", text: $viewModel.bearerToken)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Button {
                            if let clipboardText = UIPasteboard.general.string {
                                viewModel.bearerToken = clipboardText
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } header: {
                Text("Authentication")
            }
        }
        .disabled(viewModel.connecting)
        .alert("Invalid values", isPresented: $viewModel.invalidValuesAlert, actions: {
            Button {
                viewModel.invalidValuesAlert.toggle()
            } label: {
                Text("Close")
            }
        }, message: {
            Text(viewModel.invalidValuesMessage)
        })
        .alert("Connection error", isPresented: $viewModel.connectionErrorAlert, actions: {
            Button {
                viewModel.connectionErrorAlert.toggle()
            } label: {
                Text("Close")
            }
        }, message: {
            Text(viewModel.connectionErrorMessage)
        })
    }
}
