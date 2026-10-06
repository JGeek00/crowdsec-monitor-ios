import SwiftUI

struct NotificationWizardView: View {
    let onClose: (_ saved: Bool) -> Void

    @State private var viewModel: NotificationFormViewModel
    @State private var showCancelConfirmation = false

    private let totalSteps = 5

    init(editing notification: UserNotification? = nil, onClose: @escaping (_ saved: Bool) -> Void) {
        self.onClose = onClose
        _viewModel = State(wrappedValue: NotificationFormViewModel(editing: notification))
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $vm.selectedStep) {
                    NotificationWizardInfoStep(viewModel: vm)
                        .tag(0)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    ConditionEditorView(viewModel: vm)
                        .tag(1)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    NotificationWizardMessageStep(viewModel: vm)
                        .tag(2)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    NotificationWizardChannelsStep(viewModel: vm)
                        .tag(3)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    NotificationWizardReviewStep(viewModel: vm)
                        .tag(4)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            }
            .navigationTitle(viewModel.isEditing ? "Edit notification" : "New notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        showCancelConfirmation = true
                    }
                    .disabled(vm.isSaving)
                }
            }
            .alert("Discard changes?", isPresented: $showCancelConfirmation) {
                Button(String(localized: "Keep editing"), role: .cancel) {
                    showCancelConfirmation = false
                }
                Button(String(localized: "Discard"), role: .destructive) {
                    onClose(false)
                }
            } message: {
                Text("Unsaved changes will be lost.")
            }
            HStack(spacing: 0) {
                HStack {
                    if vm.selectedStep > 0 {
                        Button {
                            dismissKeyboard()
                            withAnimation(.default) {
                                vm.selectedStep -= 1
                            }
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .glassButtonIfAvailable()
                        .disabled(vm.isSaving)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                WizardStepIndicator(totalSteps: totalSteps, currentStep: vm.selectedStep)
                    .frame(maxWidth: .infinity)
                HStack {
                    if vm.selectedStep < totalSteps - 1 {
                        Button {
                            dismissKeyboard()
                            withAnimation(.default) {
                                vm.selectedStep += 1
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                        }
                        .glassButtonIfAvailable()
                        .disabled(!vm.canProceed(step: vm.selectedStep) || vm.isSaving)
                    } else {
                        Button {
                            Task {
                                let saved = await vm.save()
                                if saved != nil {
                                    onClose(true)
                                }
                            }
                        } label: {
                            if vm.isSaving {
                                ProgressView()
                            } else {
                                Label("Finish", systemImage: "checkmark")
                            }
                        }
                        .prominentButton()
                        .disabled(!vm.canProceed(step: 3) || vm.isSaving)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .onChange(of: vm.selectedStep) { _, _ in
                dismissKeyboard()
            }
            .alert("Error", isPresented: $vm.saveError) {
                Button("OK", role: .cancel) {
                    vm.saveError = false
                }
            } message: {
                Text("The notification could not be saved. Try again later.")
            }
            .alert("Error", isPresented: $vm.loadError) {
                Button("OK", role: .cancel) {
                    vm.loadError = false
                }
            } message: {
                Text("Filter options could not be loaded. You can still type custom values.")
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
        .background(Color(.systemGroupedBackground))
    }
}
