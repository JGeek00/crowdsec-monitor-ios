import SwiftUI

struct ChannelWizardFormStep: View {
    @Bindable var viewModel: ChannelFormViewModel

    var body: some View {
        Form {
            switch viewModel.provider {
            case .ntfy:
                ntfyForm
            case .email:
                emailForm
            case nil:
                Text("Go back and choose a provider first.")
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private var ntfyForm: some View {
        Group {
            Section {
                FormInfoBox(label: String(localized: "Messages are published to https://ntfy.sh/<topic> or your own server. The topic works as a password on public servers: use a hard to guess value with letters, numbers, - and _ (max 64)."))
            }
            Section("Topic") {
                TextField("Topic (required)", text: $viewModel.ntfyTopic)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("Server (optional, default ntfy.sh)", text: $viewModel.ntfyServer)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            Section("Authentication (optional)") {
                TextField("Username", text: $viewModel.ntfyUsername)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.ntfyPassword)
                SecureField("Access token (instead of username/password)", text: $viewModel.ntfyAccessToken)
            }
            Section("Appearance (optional)") {
                Picker("Priority", selection: $viewModel.ntfyPriority) {
                    ForEach(ChannelFormViewModel.ntfyPriorities, id: \.self) { priority in
                        Text(verbatim: priority).tag(priority)
                    }
                }
                TextField("Tags (comma separated)", text: $viewModel.ntfyTags)
            }
        }
    }

    private var emailForm: some View {
        Group {
            Section {
                FormInfoBox(label: String(localized: "Messages are sent through your SMTP server."))
            }
            Section("Server") {
                TextField("Host (required)", text: $viewModel.emailHost)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("Port (default 587)", text: $viewModel.emailPort)
                    .keyboardType(.numberPad)
                Toggle("Use implicit TLS (port 465)", isOn: $viewModel.emailSecure)
            }
            Section("Authentication (optional)") {
                TextField("Username", text: $viewModel.emailUsername)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.emailPassword)
            }
            Section("Addresses") {
                TextField("From (required)", text: $viewModel.emailFrom)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                TextField("To, comma separated (required)", text: $viewModel.emailTo)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
        }
    }
}

struct ChannelWizardFinalStep: View {
    @Bindable var viewModel: ChannelFormViewModel

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Give the channel a name, optionally send a test notification, then finish to save it."))
            }
            Section("Name") {
                TextField("Name (required)", text: $viewModel.name)
            }
            Section("Test") {
                Button {
                    Task {
                        await viewModel.test()
                    }
                } label: {
                    HStack {
                        Text("Send test notification")
                        Spacer()
                        if viewModel.testState == .testing {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.testState == .testing || !viewModel.providerValid())
                switch viewModel.testState {
                case .idle, .testing:
                    EmptyView()
                case .success:
                    Label("Test notification sent", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                case .failure(let detail):
                    Label(
                        String(format: String(localized: "Test failed: %@"), detail),
                        systemImage: "xmark.circle.fill"
                    )
                    .foregroundStyle(Color.red)
                }
            }
        }
    }
}
