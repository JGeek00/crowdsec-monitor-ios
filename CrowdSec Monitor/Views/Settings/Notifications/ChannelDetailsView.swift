import SwiftUI

/// Read-only summary of a channel. Secrets (passwords, tokens) are never shown.
struct ChannelDetailsView: View {
    let channel: UserNotificationChannel

    init(_ channel: UserNotificationChannel) {
        self.channel = channel
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
        List {
            Section("Channel") {
                LabeledContent("Provider") {
                    Text(verbatim: typeLabel)
                }
            }
            Section("Configuration") {
                switch channel.type {
                case .ntfy:
                    ntfyRows
                case .email:
                    emailRows
                }
            }
        }
        .navigationTitle(channel.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var ntfyRows: some View {
        let config = channel.config
        if let topic = config.topic {
            LabeledContent("Topic") {
                Text(verbatim: topic)
            }
        }
        LabeledContent("Server") {
            Text(verbatim: config.server ?? String(localized: "Default"))
        }
        if let username = config.username, !username.isEmpty {
            LabeledContent("Username") {
                Text(verbatim: username)
            }
        }
        if let priority = config.priority {
            LabeledContent("Priority") {
                Text(verbatim: priority)
            }
        }
        if let tags = config.tags, !tags.isEmpty {
            LabeledContent("Tags (comma separated)") {
                Text(verbatim: tags)
            }
        }
    }

    @ViewBuilder
    private var emailRows: some View {
        let config = channel.config
        if let host = config.host {
            LabeledContent("Host") {
                Text(verbatim: host)
            }
        }
        LabeledContent("Port") {
            Text(verbatim: config.port.map(String.init) ?? "587")
        }
        LabeledContent("Use implicit TLS (port 465)") {
            if config.secure == true {
                Text("Yes")
            } else {
                Text("No")
            }
        }
        if let username = config.username, !username.isEmpty {
            LabeledContent("Username") {
                Text(verbatim: username)
            }
        }
        if let from = config.from {
            LabeledContent("From") {
                Text(verbatim: from)
            }
        }
        if let to = config.to {
            LabeledContent("To") {
                Text(verbatim: to)
            }
        }
    }
}
