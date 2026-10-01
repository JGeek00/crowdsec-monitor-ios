import SwiftUI
import SystemNotification

/// Channel summary with an in-place edit mode, mirroring
/// NotificationDetailsView. Secrets are never shown in read-only mode.
struct ChannelDetailsView: View {
    @State private var currentChannel: UserNotificationChannel
    @State private var viewModel: ChannelFormViewModel
    @State private var isEditing = false
    @State private var showResultToast = false
    @State private var saveSucceeded = false
    var onSaved: ((UserNotificationChannel) -> Void)?

    private let providers: [NotificationProvider]

    init(
        _ channel: UserNotificationChannel,
        providers: [NotificationProvider] = [],
        onSaved: ((UserNotificationChannel) -> Void)? = nil
    ) {
        _currentChannel = State(initialValue: channel)
        let vm = ChannelFormViewModel(editing: channel)
        vm.providers = providers
        _viewModel = State(initialValue: vm)
        self.providers = providers
        self.onSaved = onSaved
    }

    private var definition: NotificationProvider? {
        providers.first { $0.type == currentChannel.type.rawValue }
    }

    private var secretKeys: Set<String> {
        if let definition {
            return Set(definition.fields.filter { $0.secret == true }.map { $0.key })
        }
        return ["password", "accessToken"]
    }

    private var rows: [(label: String, value: String)] {
        if let definition {
            return definition.fields.compactMap { field in
                guard !(field.secret == true) else { return nil }
                guard let text = displayText(for: field) else { return nil }
                return (field.labelKey, text)
            }
        }
        return currentChannel.config.keys.sorted().compactMap { key in
            guard !secretKeys.contains(key), let value = currentChannel.config[key] else { return nil }
            return (key, plainText(value))
        }
    }

    private var canSave: Bool {
        viewModel.nameValid() && viewModel.providerValid()
    }

    private func displayText(for field: ProviderField) -> String? {
        if let value = currentChannel.config[field.key] {
            return plainText(value)
        }
        if let def = field.defaultValue {
            return plainText(def)
        }
        return nil
    }

    private func plainText(_ value: JSONValue) -> String {
        switch value {
        case .string(let text):
            return text
        case .int(let number):
            return String(number)
        case .double(let number):
            return String(number)
        case .bool(let flag):
            return flag ? String(localized: "Yes") : String(localized: "No")
        }
    }

    var body: some View {
        @Bindable var vm = viewModel
        Form {
            if isEditing {
                editSections
            } else {
                summarySections
            }
        }
        .disabled(vm.isSaving)
        .navigationTitle(Text(verbatim: currentChannel.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cancelEditing()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .accessibilityLabel(Text("Cancel"))
                    .disabled(vm.isSaving)
                }
                if #available(iOS 26, *) {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await save()
                        }
                    } label: {
                        if vm.isSaving {
                            ProgressView()
                        } else {
                            Label("Save", systemImage: "checkmark")
                        }
                    }
                    .accessibilityLabel(Text("Save"))
                    .disabled(!canSave || vm.isSaving)
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "pencil") {
                        isEditing = true
                    }
                }
            }
        }
        .systemNotification(isActive: $showResultToast) {
            if saveSucceeded {
                SystemNotification(icon: "checkmark", title: String(localized: "Channel saved"), subtitle: nil)
            } else {
                SystemNotification(
                    icon: "exclamationmark.circle",
                    title: String(localized: "Error"),
                    subtitle: String(localized: "The channel could not be saved. Try again later."),
                    color: Color.red
                )
            }
        }
        .alert("Error", isPresented: $vm.saveError) {
            Button("OK", role: .cancel) {
                vm.saveError = false
            }
        } message: {
            Text("The channel could not be saved. Try again later.")
        }
        .task {
            if viewModel.providers.isEmpty {
                await viewModel.loadProviders()
            }
        }
    }

    // MARK: - Read-only summary

    @ViewBuilder
    private var summarySections: some View {
        Section("Channel") {
            LabeledContent {
                HStack {
                    ChannelIcon(definition?.icon ?? currentChannel.type.rawValue)
                        .frame(width: 20, height: 20)
                    Text(verbatim: currentChannel.type.rawValue)
                }
            } label: {
                Text("Provider")
            }
        }
        Section("Configuration") {
            if rows.isEmpty {
                Text("No configuration values")
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(rows, id: \.label) { row in
                    LabeledContent {
                        Text(verbatim: row.value)
                    } label: {
                        Text(LocalizedStringKey(row.label))
                    }
                }
            }
        }
    }

    // MARK: - Edit mode

    @ViewBuilder
    private var editSections: some View {
        @Bindable var vm = viewModel
        Section("Name") {
            TextField("Name (required)", text: $vm.name)
        }
        if viewModel.definition == nil {
            Section {
                ContentUnavailableView("Provider configuration could not be loaded.", systemImage: "xmark.circle")
            }
        } else {
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

    private func fieldHeader(_ field: ProviderField) -> String {
        String(localized: String.LocalizationValue(field.labelKey))
    }

    // MARK: - Actions

    private func cancelEditing() {
        viewModel.load(channel: currentChannel)
        isEditing = false
    }

    private func save() async {
        let saved = await viewModel.save()
        saveSucceeded = saved != nil
        if let saved {
            currentChannel = saved
            viewModel.load(channel: saved)
            isEditing = false
            onSaved?(saved)
        }
        showResultToast = true
    }
}
