import SwiftUI

struct ChannelListItem: View {
    let channel: UserNotificationChannel

    @Environment(NotificationChannelsListViewModel.self) private var viewModel
    @Binding var editingChannel: UserNotificationChannel?
    @Binding var showWizard: Bool

    init(
        _ channel: UserNotificationChannel,
        editingChannel: Binding<UserNotificationChannel?>,
        showWizard: Binding<Bool>
    ) {
        self.channel = channel
        _editingChannel = editingChannel
        _showWizard = showWizard
    }

    @State private var showDeleteConfirmation = false

    private var channelIcon: some View {
        ChannelIcon(channel.type.rawValue)
            .font(.title3)
            .foregroundStyle(channel.type == .email ? Color.accentColor : Color.primary)
    }

    private var typeLabel: String {
        switch channel.type {
        case .email:
            return "Email"
        case .ntfy:
            return "ntfy"
        }
    }

    var body: some View {
        HStack {
            channelIcon
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: channel.name)
                Text(verbatim: typeLabel)
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
            }
        }
        .contextMenu {
            Section {
                Button(String(localized: "Edit channel"), systemImage: "pencil") {
                    editingChannel = channel
                    showWizard = true
                }
                Button(String(localized: "Delete channel"), systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .alert("Delete channel", isPresented: $showDeleteConfirmation) {
            Button(String(localized: "Cancel"), role: .cancel) {
                showDeleteConfirmation = false
            }
            Button(String(localized: "Delete"), role: .destructive) {
                Task {
                    await viewModel.delete(channelId: channel.id)
                    await viewModel.refresh()
                }
            }
        } message: {
            Text("Are you sure you want to delete this channel? This action cannot be undone.")
        }
    }
}
