import SwiftUI

struct ConditionEditorView: View {
    @Bindable var viewModel: NotificationFormViewModel

    @State private var draft = EditableLeaf.empty
    @State private var editingIndex: Int?
    @State private var showRuleSheet = false
    @State private var sheetToken = UUID()

    static func fieldLabel(_ field: ConditionField) -> String {
        switch field {
        case .scenario:
            return String(localized: "Scenario")
        case .country:
            return String(localized: "Country")
        case .target:
            return String(localized: "Target")
        case .ipOwner:
            return String(localized: "IP owner")
        }
    }

    static func operatorPhrase(_ op: ConditionOperator) -> String {
        switch op {
        case .equals:
            return String(localized: "is")
        case .notEquals:
            return String(localized: "is not")
        case .in:
            return String(localized: "is any of")
        case .notIn:
            return String(localized: "is none of")
        case .contains:
            return String(localized: "contains")
        }
    }

    static func valuesSummary(_ values: [String]) -> String {
        if values.count <= 2 {
            return values.joined(separator: ", ")
        }
        let head = values.prefix(2).joined(separator: ", ")
        let more = String(format: String(localized: "(+%d more)"), values.count - 2)
        return head + " " + more
    }

    @ViewBuilder
    private func validationHint(_ issue: RulesValidationIssue) -> some View {
        switch issue {
        case .empty:
            Text("Add at least one rule.")
        case .incomplete:
            Text("Complete all rules.")
        case .advanced:
            Text("This notification uses an advanced condition. Replace it to edit with simple rules.")
        case .invalidWindow:
            Text("Window must be between 10 and 86400 seconds.")
        }
    }

    static func windowLabel(_ seconds: Int) -> String {
        switch seconds {
        case 60:
            return String(localized: "1 minute")
        case 300:
            return String(localized: "5 minutes")
        case 900:
            return String(localized: "15 minutes")
        case 3600:
            return String(localized: "1 hour")
        case 21600:
            return String(localized: "6 hours")
        case 86400:
            return String(localized: "24 hours")
        default:
            return String(format: String(localized: "%d seconds"), seconds)
        }
    }

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Notifications are sent by the backend when new alerts match the condition you build in the next steps. Give it a name so you can recognize it later."))
            }
            Section("Condition") {
                Toggle("Any alert", isOn: $viewModel.noCondition)
                if viewModel.noCondition {
                    Text("Triggers on any alert, without filters. Combine it with the frequency below.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }
            if viewModel.advancedCondition != nil && !viewModel.noCondition {
                Section {
                    Label(
                        "This notification uses an advanced condition that cannot be shown as simple rules.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(Color.orange)
                    .font(.subheadline)
                    Button("Replace with simple rules", role: .destructive) {
                        viewModel.replaceWithSimpleRules()
                    }
                }
            }
            if !viewModel.noCondition && viewModel.advancedCondition == nil {
                Section("Rules") {
                    if viewModel.rules.isEmpty {
                        Text("No rules yet. Add your first rule below.")
                            .foregroundStyle(Color.secondary)
                    }
                    ForEach(Array(viewModel.rules.enumerated()), id: \.offset) { index, rule in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(Self.fieldLabel(rule.field)) · \(Self.operatorPhrase(rule.op))")
                                    .font(.headline)
                                Text(verbatim: Self.valuesSummary(rule.values))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button("Edit") {
                                draft = rule
                                editingIndex = index
                                sheetToken = UUID()
                                showRuleSheet = true
                            }
                            .buttonStyle(.bordered)
                            Button(role: .destructive) {
                                viewModel.rules.remove(at: index)
                            } label: {
                                Label("Delete rule", systemImage: "trash")
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Button("Add rule", systemImage: "plus") {
                        draft = viewModel.newDraft()
                        editingIndex = nil
                        sheetToken = UUID()
                        showRuleSheet = true
                    }
                }
                if let issue = viewModel.validationIssue(step: 1) {
                    Section {
                        validationHint(issue)
                            .font(.subheadline)
                            .foregroundStyle(Color.red)
                    }
                }
            }
            Section {
                Stepper(
                    String(format: String(localized: "Count: %d"), viewModel.count),
                    value: $viewModel.count,
                    in: 1...1000
                )
                HStack {
                    Text("Time window (seconds)")
                    TextField("10", text: $viewModel.windowSecondsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("Frequency")
            } footer: {
                if viewModel.windowValid {
                    Text(
                        verbatim: String(
                            format: String(localized: "Notify when %d matching alerts arrive within %@."),
                            viewModel.count,
                            Self.windowLabel(viewModel.parsedWindowSeconds)
                        )
                    )
                } else {
                    Text("Window must be between 10 and 86400 seconds.")
                        .foregroundStyle(Color.red)
                }
            }
        }
        .sheet(isPresented: $showRuleSheet) {
            RuleEditSheet(
                draft: $draft,
                options: viewModel.filterOptions,
                onSave: {
                    if let index = editingIndex, viewModel.rules.indices.contains(index) {
                        viewModel.rules[index] = draft
                    } else {
                        viewModel.rules.append(draft)
                    }
                    showRuleSheet = false
                },
                onCancel: {
                    showRuleSheet = false
                }
            )
            .id(sheetToken)
            .interactiveDismissDisabled()
        }
    }
}
