import SwiftUI
import SystemNotification

/// Read-only summary of a notification with an in-place edit mode.
/// The toolbar switches from a pencil to Cancel/Save while editing, saving
/// blocks every field behind a progress alert and ends with a toast result.
struct NotificationDetailsView: View {
    @State private var currentNotification: UserNotification
    @State private var viewModel: NotificationFormViewModel
    @State private var isEditing = false
    @State private var showResultToast = false
    @State private var saveSucceeded = false
    var onSaved: ((UserNotification) -> Void)?

    init(_ notification: UserNotification, onSaved: ((UserNotification) -> Void)? = nil) {
        _currentNotification = State(initialValue: notification)
        _viewModel = State(initialValue: NotificationFormViewModel(editing: notification))
        self.onSaved = onSaved
    }

    private var canSave: Bool {
        [0, 1, 2, 3].allSatisfy { viewModel.canProceed(step: $0) }
    }

    private var frequencySummary: String? {
        guard let threshold = currentNotification.threshold else { return nil }
        return String(
            format: String(localized: "%d times in %d seconds"),
            threshold.count,
            threshold.windowSeconds
        )
    }

    private struct RuleSummary {
        let label: String
        let values: String
    }

    private var ruleSummaries: [RuleSummary] {
        viewModel.rules.map { rule in
            RuleSummary(
                label: "\(ConditionEditorSections.fieldLabel(rule.field)) · \(ConditionEditorSections.operatorPhrase(rule.op))",
                values: ConditionEditorSections.valuesSummary(rule.values)
            )
        }
    }

    private var channelsSummary: String {
        let names = viewModel.channels
            .filter { viewModel.selectedChannelIds.contains($0.id) }
            .map { $0.name }
        return names.isEmpty ? String(localized: "None") : names.joined(separator: ", ")
    }

    var body: some View {
        @Bindable var vm = viewModel
        Form {
            Section("Details") {
                TextField("Name", text: $vm.name)
                TextField("Description (optional)", text: $vm.notificationDescription, axis: .vertical)
            }
            .disabled(!isEditing || vm.isSaving)

            if isEditing {
                ConditionEditorSections(viewModel: vm)
                Section("Content") {
                    TextField("Message", text: $vm.message, axis: .vertical)
                        .lineLimit(4...8)
                }
                channelsSection
            } else {
                summarySections
            }
        }
        .disabled(vm.isSaving)
        .navigationTitle(isEditing ? "Edit notification" : "Notification")
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
                SystemNotification(icon: "checkmark", title: String(localized: "Notification saved"), subtitle: nil)
            } else {
                SystemNotification(
                    icon: "exclamationmark.circle",
                    title: String(localized: "Error"),
                    subtitle: String(localized: "The notification could not be saved. Try again later."),
                    color: Color.red
                )
            }
        }
        .task {
            await vm.loadOptions()
        }
        .sheet(item: $vm.ruleSheet) { sheet in
            RuleEditSheet(
                draft: Binding(
                    get: { vm.ruleSheet?.draft ?? sheet.draft },
                    set: { vm.ruleSheet?.draft = $0 }
                ),
                options: vm.filterOptions,
                onSave: { vm.commitRuleSheet() },
                onCancel: { vm.dismissRuleSheet() }
            )
            .interactiveDismissDisabled()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            vm.keyboardWillShow()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            vm.keyboardDidHide()
        }
    }

    private var channelsSection: some View {
        Section("Channels") {
            if viewModel.channels.isEmpty {
                Text("No channels configured yet")
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(viewModel.channels) { channel in
                    Button {
                        if viewModel.selectedChannelIds.contains(channel.id) {
                            viewModel.selectedChannelIds.remove(channel.id)
                        } else {
                            viewModel.selectedChannelIds.insert(channel.id)
                        }
                    } label: {
                        channelRow(channel)
                    }
                }
            }
        }
    }

    private func channelRow(_ channel: UserNotificationChannel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: channel.name)
                    .foregroundStyle(Color.primary)
                Text(channel.type == .email ? String(localized: "Email") : String(localized: "ntfy"))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            if viewModel.selectedChannelIds.contains(channel.id) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    @ViewBuilder
    private var summarySections: some View {
        Section("Condition") {
            if viewModel.noCondition {
                Text("Any alert")
            } else if viewModel.advancedCondition != nil {
                Text("Advanced condition")
            } else {
                ForEach(ruleSummaries.indices, id: \.self) { index in
                    let summary = ruleSummaries[index]
                    VStack(alignment: .leading, spacing: 4) {
                        Text(summary.label)
                        Text(verbatim: summary.values)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        Section {
            LabeledContent("Frequency", value: frequencySummary ?? String(localized: "Not configured"))
        }
        Section {
            LabeledContent(
                "Cooldown time",
                value: ConditionEditorSections.cooldownLabel(viewModel.cooldownSeconds)
            )
        }
        Section("Content") {
            Text(verbatim: viewModel.message)
        }
        Section {
            LabeledContent("Channels", value: channelsSummary)
        }
    }

    private func cancelEditing() {
        viewModel.load(notification: currentNotification)
        isEditing = false
    }

    private func save() async {
        let saved = await viewModel.save()
        saveSucceeded = saved != nil
        if let saved {
            currentNotification = saved
            viewModel.load(notification: saved)
            isEditing = false
            onSaved?(saved)
        }
        showResultToast = true
    }
}
