import SwiftUI

/// Alert-info options shared by the wizard message step and the details edit
/// form: opt-in toggle with explanatory footer, plus a collapsed-by-default
/// accordion listing the configured channels by alert-info support.
struct NotificationAlertInfoSections: View {
    @Bindable var viewModel: NotificationFormViewModel
    @State private var showSupportingChannels = false

    private var channelsBySupport: [UserNotificationChannel] {
        viewModel.channels.sorted { lhs, rhs in
            if lhs.supportsAlertInfo != rhs.supportsAlertInfo {
                return lhs.supportsAlertInfo
            }
            return lhs.id < rhs.id
        }
    }

    var body: some View {
        Section {
            Toggle(isOn: $viewModel.includeAlertInfo) {
                Text("Include alert information")
            }
        } footer: {
            Text(
                "Even when enabled, alert information is only sent through channels that support it."
            )
        }
        if !viewModel.channels.isEmpty {
            Section {
                DisclosureGroup(isExpanded: $showSupportingChannels) {
                    ForEach(channelsBySupport) { channel in
                        HStack {
                            Image(systemName: channel.supportsAlertInfo ? "checkmark" : "xmark")
                                .foregroundStyle(channel.supportsAlertInfo ? Color.green : Color.red)
                            Text(verbatim: channel.name)
                        }
                    }
                } label: {
                    Text("Which channels support it?")
                }
            }
        }
    }
}
