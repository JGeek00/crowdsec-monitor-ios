import SwiftUI

struct RuleEditSheet: View {
    @Binding var draft: EditableLeaf
    var options: NotificationFilterOptions
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var selectedOption: String
    @State private var customValue: String
    @State private var customMultiValue: String

    init(
        draft: Binding<EditableLeaf>,
        options: NotificationFilterOptions,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _draft = draft
        self.options = options
        self.onSave = onSave
        self.onCancel = onCancel
        let available = Self.availableOptions(for: draft.wrappedValue.field, in: options)
        let first = draft.wrappedValue.values.first ?? ""
        if available.contains(first) {
            _selectedOption = State(initialValue: first)
            _customValue = State(initialValue: "")
        } else {
            _selectedOption = State(initialValue: available.first ?? "")
            _customValue = State(initialValue: first)
        }
        _customMultiValue = State(initialValue: "")
    }

    private var currentOptions: [String] {
        Self.availableOptions(for: draft.field, in: options)
    }

    private static func availableOptions(for field: ConditionField, in options: NotificationFilterOptions) -> [String] {
        switch field {
        case .scenario:
            return options.scenarios
        case .country:
            return options.countries
        case .target:
            return options.targets
        case .ipOwner:
            return options.ipOwners
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("1. What to look at") {
                    Picker("Field", selection: $draft.field) {
                        Text("Scenario").tag(ConditionField.scenario)
                        Text("Country").tag(ConditionField.country)
                        Text("Target").tag(ConditionField.target)
                        Text("IP owner").tag(ConditionField.ipOwner)
                    }
                }
                Section("2. How to compare") {
                    Picker("Operator", selection: $draft.op) {
                        Text("is").tag(ConditionOperator.equals)
                        Text("is not").tag(ConditionOperator.notEquals)
                        Text("is any of").tag(ConditionOperator.in)
                        Text("is none of").tag(ConditionOperator.notIn)
                        Text("contains").tag(ConditionOperator.contains)
                    }
                }
                Section("3. Values") {
                    valueEditor
                }
            }
            .navigationTitle("Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(!draft.isValid)
                }
            }
        }
        .onChange(of: draft.field) { _, _ in
            customValue = ""
            customMultiValue = ""
            selectedOption = currentOptions.first ?? ""
            if draft.op.needsMultipleValues || draft.op == .contains {
                draft.values = []
            } else {
                syncSingleValue()
            }
        }
        .onChange(of: draft.op) { _, _ in
            if !draft.op.needsMultipleValues && draft.op != .contains {
                if selectedOption.isEmpty || !currentOptions.contains(selectedOption) {
                    selectedOption = draft.values.first(where: { currentOptions.contains($0) })
                        ?? currentOptions.first ?? ""
                }
            }
            syncSingleValue()
        }
        .onChange(of: selectedOption) { _, _ in
            syncSingleValue()
        }
        .onChange(of: customValue) { _, _ in
            syncSingleValue()
        }
    }

    @ViewBuilder
    private var valueEditor: some View {
        if draft.op.needsMultipleValues {
            if currentOptions.isEmpty {
                Text("No options available")
                    .foregroundStyle(Color.secondary)
            } else {
                ForEach(currentOptions, id: \.self) { option in
                    Button {
                        if draft.values.contains(option) {
                            draft.values.removeAll { $0 == option }
                        } else {
                            draft.values.append(option)
                        }
                    } label: {
                        HStack {
                            Text(verbatim: option)
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if draft.values.contains(option) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }
            let customValues = draft.values.filter { !currentOptions.contains($0) }
            if !customValues.isEmpty {
                ForEach(customValues, id: \.self) { value in
                    HStack {
                        Text(verbatim: value)
                            .foregroundStyle(Color.primary)
                        Spacer()
                        Button(role: .destructive) {
                            draft.values.removeAll { $0 == value }
                        } label: {
                            Label("Remove value", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
            HStack {
                TextField("Custom value", text: $customMultiValue)
                Button("Add") {
                    let trimmed = customMultiValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty && !draft.values.contains(trimmed) {
                        draft.values.append(trimmed)
                    }
                    customMultiValue = ""
                }
                .disabled(customMultiValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        } else if draft.op == .contains {
            TextField("Text", text: Binding(
                get: { draft.values.first ?? "" },
                set: { draft.values = $0.isEmpty ? [] : [$0] }
            ))
        } else {
            if !currentOptions.isEmpty {
                Picker("Value", selection: $selectedOption) {
                    ForEach(currentOptions, id: \.self) { option in
                        Text(verbatim: option).tag(option)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text("No options available, type a custom value below")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            TextField("Or type a custom value", text: $customValue)
        }
    }

    private func syncSingleValue() {
        if draft.op.needsMultipleValues || draft.op == .contains {
            return
        }
        let trimmed = customValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = trimmed.isEmpty ? selectedOption : trimmed
        let next = value.isEmpty ? [] : [value]
        if draft.values != next {
            draft.values = next
        }
    }
}
