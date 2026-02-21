import SwiftUI

struct CreateDecisionFormView: View {
    let onClose: () -> Void
    
    @State private var viewModel: CreateDecisionFormViewModel
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = State(wrappedValue: CreateDecisionFormViewModel())
    }
    
    @State private var confirmationDialogCloseForm = false
    
    func handleSave() {
        Task {
            let result = await viewModel.save()
            if result == true {
                onClose()
            }
        }
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section {
                    TextField("IP address", text: $viewModel.ipAddress)
                }
                
                Section {
                    Picker("Decision type", selection: $viewModel.type) {
                        ForEach(Enums.DecisionType.allCases, id: \.self) { decisionType in
                            Text(decisionType.rawValue.capitalized)
                                .tag(decisionType)
                        }
                    }
                }
                
                Section("Duration") {
                    DurationPickerView(
                        days: $viewModel.durationDays,
                        hours: $viewModel.durationHours,
                        minutes: $viewModel.durationMinutes
                    )
                }
                
                Section("Reason") {
                    TextEditor(text: $viewModel.reason)
                }
            }
            .navigationTitle("Create a decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        confirmationDialogCloseForm = true
                    }
                    .confirmationDialog("Discard changes", isPresented: $confirmationDialogCloseForm) {
                        Button("Discard changes", role: .destructive) {
                            onClose()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            handleSave()
                        } label: {
                            if viewModel.creatingDecision == true {
                                ProgressView()
                            }
                            else {
                                Label("Save", systemImage: "checkmark")
                            }
                        }
                    }
                    else {
                        Button {
                            handleSave()
                        } label: {
                            if viewModel.creatingDecision == true {
                                ProgressView()
                            }
                            else {
                                Label("Save", systemImage: "checkmark")
                            }
                        }
                    }
                }
            }
            .disabled(viewModel.creatingDecision)
        }
        .alert("Invalid values", isPresented: $viewModel.invalidFieldsAlert) {
            Button("OK") {
                viewModel.invalidFieldsAlert = false
            }
        } message: {
            Text(viewModel.invalidFieldsAlertMessage)
        }
        .alert("Error", isPresented: $viewModel.errorCreatingDecisionAlert) {
            Button("OK") {
                viewModel.errorCreatingDecisionAlert = false
            }
        } message: {
            Text("An error occurred while creating the decision. Please try again.")
        }
    }
}
