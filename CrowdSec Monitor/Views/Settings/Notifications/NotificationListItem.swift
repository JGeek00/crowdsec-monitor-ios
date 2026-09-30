import SwiftUI

struct NotificationListItem: View {
    let notification: UserNotification

    init(_ notification: UserNotification, editingNotification: Binding<UserNotification?>, showWizard: Binding<Bool>) {
        self.notification = notification
        _editingNotification = editingNotification
        _showWizard = showWizard
    }

    @Environment(NotificationsListViewModel.self) private var viewModel
    @Binding var editingNotification: UserNotification?
    @Binding var showWizard: Bool

    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: notification.name)
                if let description = notification.description, !description.isEmpty {
                    Text(verbatim: description)
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
                Group {
                    if notification.enabled {
                        Text("Enabled")
                            .foregroundStyle(Color.green)
                    } else {
                        Text("Disabled")
                            .foregroundStyle(Color.red)
                    }
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            }
            Spacer()
            Group {
                if notification.enabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.red)
                }
            }
            .fontWeight(.semibold)
            .font(.title3)
        }
        .contextMenu {
            Section {
                Button(
                    notification.enabled ? String(localized: "Disable notification") : String(localized: "Enable notification"),
                    systemImage: notification.enabled ? "xmark" : "checkmark"
                ) {
                    Task {
                        await viewModel.toggle(notification: notification)
                    }
                }
                Button(String(localized: "Edit notification"), systemImage: "pencil") {
                    editingNotification = notification
                    showWizard = true
                }
                Button(String(localized: "Delete notification"), systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .alert("Delete notification", isPresented: $showDeleteConfirmation) {
            Button(String(localized: "Cancel"), role: .cancel) {
                showDeleteConfirmation = false
            }
            Button(String(localized: "Delete"), role: .destructive) {
                Task {
                    await viewModel.delete(notificationId: notification.id)
                    await viewModel.refresh()
                }
            }
        } message: {
            Text("Are you sure you want to delete this notification? This action cannot be undone.")
        }
    }
}
