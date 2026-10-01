import SwiftUI

struct ChannelWizardView: View {
    let onClose: (_ saved: Bool) -> Void

    @State private var viewModel: ChannelFormViewModel
    @State private var showCancelConfirmation = false

    private let totalSteps = 4

    init(editing channel: UserNotificationChannel? = nil, onClose: @escaping (_ saved: Bool) -> Void) {
        self.onClose = onClose
        _viewModel = State(wrappedValue: ChannelFormViewModel(editing: channel))
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $vm.selectedStep) {
                    ChannelWizardIntroStep()
                        .tag(0)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    ChannelWizardProviderStep(viewModel: vm)
                        .tag(1)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    ChannelWizardFormStep(viewModel: vm)
                        .tag(2)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                    ChannelWizardFinalStep(viewModel: vm)
                        .tag(3)
                        .contentShape(Rectangle()).simultaneousGesture(DragGesture())
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .contentShape(Rectangle()).simultaneousGesture(DragGesture())
            }
            .navigationTitle(viewModel.isEditing ? "Edit channel" : "New channel")
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
                        .disabled(!canProceed() || vm.isSaving)
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
                        .disabled(!vm.nameValid() || !vm.providerValid() || vm.isSaving)
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
                Text("The channel could not be saved. Try again later.")
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func canProceed() -> Bool {
        switch viewModel.selectedStep {
        case 1:
            return viewModel.providerType != nil
        case 2:
            return viewModel.providerValid()
        default:
            return true
        }
    }
}
