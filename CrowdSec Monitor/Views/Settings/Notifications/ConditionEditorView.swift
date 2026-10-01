import SwiftUI

struct ConditionEditorView: View {
    @Bindable var viewModel: NotificationFormViewModel

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Notifications are sent by the backend when new alerts match the condition you build in the next steps. Give it a name so you can recognize it later."))
            }
            ConditionEditorSections(viewModel: viewModel)
        }
    }
}
