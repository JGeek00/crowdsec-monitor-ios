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
                    ConditionEditorView(viewModel: vm)
                        .tag(1)
                    NotificationWizardMessageStep(viewModel: vm)
                        .tag(2)
                    NotificationWizardChannelsStep(viewModel: vm)
                        .tag(3)
                    NotificationWizardReviewStep(viewModel: vm)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
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
            .onAppear {
                UIScrollView.appearance().isScrollEnabled = false
            }
            .onDisappear {
                UIScrollView.appearance().isScrollEnabled = true
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
