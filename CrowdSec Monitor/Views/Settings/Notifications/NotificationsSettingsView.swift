import SwiftUI

enum NotificationsSettingsTab: Hashable {
    case notifications
    case channels
}

struct NotificationsSettingsView: View {
    @State private var notificationsViewModel = NotificationsListViewModel()
    @State private var channelsViewModel = NotificationChannelsListViewModel()

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var selectedTab: NotificationsSettingsTab = .notifications
    @State private var editingNotification: UserNotification?
    @State private var showNotificationWizard = false
    @State private var editingChannel: UserNotificationChannel?
    @State private var showChannelWizard = false

    var body: some View {
        Group {
            switch selectedTab {
            case .notifications:
                NotificationsListView(
                    editingNotification: $editingNotification,
                    showWizard: $showNotificationWizard
                )
                .transition(.opacity)
            case .channels:
                ChannelsListView(
                    editingChannel: $editingChannel,
                    showWizard: $showChannelWizard
                )
                .transition(.opacity)
            }
        }
        .navigationTitle("Notifications")
        .condition { view in
            if #available(iOS 26.0, *) {
                view.navigationBarTitleDisplayMode(.inline)
            } else {
                view
            }
        }
        .toolbar {
            if #unavailable(iOS 26.0) {
                ToolbarItem(placement: .bottomBar) {
                    picker()
                        .padding(.bottom, 8)
                }
            }
        }
        .condition { view in
            if #available(iOS 26.0, *) {
                view.safeAreaBar(edge: .top) {
                    picker()
                }
            } else {
                view
            }
        }
        .sheet(isPresented: $showNotificationWizard) {
            NotificationWizardView(editing: editingNotification) { saved in
                showNotificationWizard = false
                editingNotification = nil
                if saved {
                    Task {
                        await notificationsViewModel.refresh()
                    }
                }
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showChannelWizard) {
            ChannelWizardView(editing: editingChannel) { saved in
                showChannelWizard = false
                editingChannel = nil
                if saved {
                    Task {
                        await channelsViewModel.refresh()
                    }
                }
            }
            .interactiveDismissDisabled()
        }
        .environment(notificationsViewModel)
        .environment(channelsViewModel)
    }

    @ViewBuilder
    func picker() -> some View {
        Picker(
            "Selected section",
            selection: Binding(
                get: { selectedTab },
                set: { newValue in
                    withAnimation {
                        selectedTab = newValue
                    }
                }
            )
        ) {
            Text("Notifications").tag(NotificationsSettingsTab.notifications)
            Text("Channels").tag(NotificationsSettingsTab.channels)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .condition { view in
            if horizontalSizeClass == .regular {
                view.padding(.bottom, 12)
            } else {
                view
            }
        }
    }
}
