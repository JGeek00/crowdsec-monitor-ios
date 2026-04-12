import SwiftUI

struct AddBlocklistFormView: View {
    var onClose: (_ blocklistAdded: Bool) -> Void
    
    init(onClose: @escaping (_ blocklistAdded: Bool) -> Void) {
        self.onClose = onClose
    }
    
    @Environment(ActiveServerViewModel.self) private var activeServerViewModel
    
    @State private var name: String = ""
    @State private var url: String = ""
    
    @State private var isSaving: Bool = false
    @State private var requiredFieldsError: Bool = false
    @State private var invalidUrlError: Bool = false
    @State private var error: Bool = false
    
    func createBlocklist() {
        if url.isEmpty || name.isEmpty {
            requiredFieldsError = true
            return
        }
        
        if NSPredicate(format: "SELF MATCHES %@", RegExps.url).evaluate(with: url) == false {
            invalidUrlError = true
            return
        }
        
        guard let apiClient = activeServerViewModel.apiClient else { return }
        
        isSaving = true
        
        Task {
            do {
                let body = AddBlocklistRequestBody(name: name, url: url)
                _ = try await apiClient.blocklists.addBlocklist(body: body)
                self.isSaving = false
                onClose(true)
            } catch {
                self.error = true
                self.isSaving = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Name", text: $name)
                TextField("URL", text: $url)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
            }
            .disabled(isSaving)
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
                        createBlocklist()
                    } label: {
                        if isSaving {
                            ProgressView()
                        }
                        else {
                            Label("Save", systemImage: "checkmark")
                        }
                    }
                    .disabled(isSaving)
                    .condition { view in
                        if #available(iOS 26.0, *) {
                            view.buttonStyle(.glassProminent)
                        }
                        else { view }
                    }
                }
            }
            .alert("Fill all required fields", isPresented: $requiredFieldsError) {
                Button("OK", role: .cancel) {
                    requiredFieldsError = false
                }
            } message: {
                Text("You must fill all the required fields to add the blocklist")
            }
            .alert("URL value not valid", isPresented: $invalidUrlError) {
                Button("OK", role: .cancel) {
                    invalidUrlError = false
                }
            } message: {
                Text("The value inputted on the URL field is not valid, please input a valid URL")
            }
            .alert("Error", isPresented: $error) {
                Button("OK", role: .cancel) {
                    invalidUrlError = false
                }
            } message: {
                Text("An error occured when adding the blocklist, please try again")
            }
        }
    }
}
