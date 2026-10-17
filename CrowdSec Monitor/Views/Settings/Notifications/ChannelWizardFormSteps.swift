import SwiftUI

struct ChannelWizardFormStep: View {
    @Bindable var viewModel: ChannelFormViewModel

    var body: some View {
        Form {
            if viewModel.definition == nil {
                Section {
                    FormInfoBox(label: String(localized: "Go back and choose a provider first."))
                }
            } else {
                if let descriptionKey = viewModel.definition?.descriptionKey {
                    Section {
                        FormInfoBox(label: String(localized: String.LocalizationValue(descriptionKey)))
                    }
                }
                ForEach(viewModel.groupedFields(), id: \.section?.key) { group in
                    if let section = group.section {
                        Section(LocalizedStringKey(section.labelKey)) {
                            ForEach(group.fields) { field in
                                fieldEditor(field)
                            }
                        }
                    } else {
                        ForEach(group.fields) { field in
                            fieldEditor(field)
                        }
                    }
                }
            }
        }
        .task {
            if viewModel.providers.isEmpty {
                await viewModel.loadProviders()
            }
        }
    }

    private func fieldHeader(_ field: ProviderField) -> String {
        String(localized: String.LocalizationValue(field.labelKey))
    }

    @ViewBuilder
    private func fieldEditor(_ field: ProviderField) -> some View {
        switch field.type {
        case "password":
            SecureField(fieldHeader(field), text: viewModel.stringBinding(for: field.key))
        case "number":
            TextField(fieldHeader(field), text: viewModel.stringBinding(for: field.key))
                .keyboardType(.decimalPad)
        case "boolean":
            Toggle(fieldHeader(field), isOn: viewModel.boolBinding(for: field.key))
        case "select":
            Picker(fieldHeader(field), selection: viewModel.stringBinding(for: field.key)) {
                let current = viewModel.stringBinding(for: field.key).wrappedValue
                let opts = field.options ?? []
                if !current.isEmpty && !opts.contains(where: { $0.value == current }) {
                    Text(verbatim: current).tag(current)
                }
                ForEach(opts, id: \.value) { option in
                    Text(LocalizedStringKey(option.labelKey)).tag(option.value)
                }
            }
        case "email":
            TextField(fieldHeader(field), text: viewModel.stringBinding(for: field.key))
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        case "url":
            TextField(fieldHeader(field), text: viewModel.stringBinding(for: field.key))
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        default:
            TextField(fieldHeader(field), text: viewModel.stringBinding(for: field.key))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
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
