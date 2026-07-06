import SwiftUI

struct AddBlocklistFormView: View {
    let onClose: (_ blocklistAdded: Bool) -> Void
    
    @State private var viewModel: AddBlocklistFormViewModel
    
    init(onClose: @escaping (_ blocklistAdded: Bool) -> Void) {
        self.onClose = onClose
        _viewModel = State(wrappedValue: AddBlocklistFormViewModel())
    }
    
    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            List {
                TextField("Name", text: $vm.name)
                TextField("URL", text: $vm.url)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
            }
            .disabled(vm.isSaving)
            .navigationTitle("Add blocklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onClose(false)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await vm.createBlocklist(name: vm.name, url: vm.url)
                            if !vm.isSaving && !vm.error {
                                onClose(true)
                            }
                        }
                    } label: {
                        if vm.isSaving {
                            ProgressView()
                        }
                        else {
                            Label("Save", systemImage: "checkmark")
                        }
                    }
                    .disabled(vm.isSaving)
                    .condition { view in
                        if #available(iOS 26.0, *) {
                            view.buttonStyle(.glassProminent)
                        }
                        else { view }
                    }
                }
            }
            .alert("Fill all required fields", isPresented: $vm.requiredFieldsError) {
                Button("OK", role: .cancel) {
                    vm.requiredFieldsError = false
                }
            } message: {
                Text("You must fill all the required fields to add the blocklist")
            }
            .alert("URL value not valid", isPresented: $vm.invalidUrlError) {
                Button("OK", role: .cancel) {
                    vm.invalidUrlError = false
                }
            } message: {
                Text("The value inputted on the URL field is not valid, please input a valid URL")
            }
            .alert("Error", isPresented: $vm.error) {
                Button("OK", role: .cancel) {
                    vm.error = false
                }
            } message: {
                Text("An error occured when adding the blocklist, please try again")
            }
        }
    }
}
