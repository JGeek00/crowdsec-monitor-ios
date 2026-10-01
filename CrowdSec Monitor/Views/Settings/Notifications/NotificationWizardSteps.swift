import SwiftUI

struct NotificationWizardInfoStep: View {
    @Bindable var viewModel: NotificationFormViewModel

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Notifications are sent by the backend when new alerts match the condition you build in the next steps. Give it a name so you can recognize it later."))
            }
            Section("Details") {
                TextField("Name", text: $viewModel.name)
                TextField("Description (optional)", text: $viewModel.notificationDescription, axis: .vertical)
            }
        }
    }
}

struct NotificationWizardMessageStep: View {
    @Bindable var viewModel: NotificationFormViewModel

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "This is the text sent through the selected channels every time the condition triggers."))
            }
            Section("Content") {
                TextField("Message", text: $viewModel.message, axis: .vertical)
                    .lineLimit(4...8)
            }
        }
    }
}

struct NotificationWizardChannelsStep: View {
    @Bindable var viewModel: NotificationFormViewModel

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Choose one or more channels used to deliver this notification. Channels are configured in the Channels tab."))
            }
            Section("Channels") {
                if viewModel.channels.isEmpty {
                    Text("No channels configured yet")
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(viewModel.channels) { channel in
                        Button {
                            if viewModel.selectedChannelIds.contains(channel.id) {
                                viewModel.selectedChannelIds.remove(channel.id)
                            } else {
                                viewModel.selectedChannelIds.insert(channel.id)
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(verbatim: channel.name)
                                        .foregroundStyle(Color.primary)
                                    Text(channel.type == .email ? String(localized: "Email") : String(localized: "ntfy"))
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                                if viewModel.selectedChannelIds.contains(channel.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct NotificationWizardReviewStep: View {
    @Bindable var viewModel: NotificationFormViewModel

    private var channelNames: String {
        let names = viewModel.channels
            .filter { viewModel.selectedChannelIds.contains($0.id) }
            .map { $0.name }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }

    var body: some View {
        Form {
            Section {
                FormInfoBox(label: String(localized: "Review the notification before finishing. Use Back to change anything."))
            }
            Section("Summary") {
                LabeledContent("Name", value: viewModel.name)
                if !viewModel.notificationDescription.isEmpty {
                    LabeledContent("Description", value: viewModel.notificationDescription)
                }
                if viewModel.noCondition {
                    LabeledContent("Condition", value: "Any alert")
                } else {
                    LabeledContent("Condition blocks", value: "\(viewModel.rules.count)")
                }
                LabeledContent(
                    "Frequency",
                    value: String(
                        format: String(localized: "%d times in %d seconds"),
                        viewModel.count,
                        viewModel.parsedWindowSeconds
                    )
                )
                LabeledContent("Message", value: viewModel.message)
                LabeledContent("Channels", value: channelNames)
            }
        }
    }
}
