import SwiftUI

/// Read-only summary of a channel. Secrets are never shown.
struct ChannelDetailsView: View {
    let channel: UserNotificationChannel
    var providers: [NotificationProvider] = []

    init(_ channel: UserNotificationChannel, providers: [NotificationProvider] = []) {
        self.channel = channel
        self.providers = providers
    }

    private var definition: NotificationProvider? {
        providers.first { $0.type == channel.type.rawValue }
    }

    private var secretKeys: Set<String> {
        if let definition {
            return Set(definition.fields.filter { $0.secret == true }.map { $0.key })
        }
        return ["password", "accessToken"]
    }

    private var rows: [(label: String, value: String)] {
        if let definition {
            return definition.fields.compactMap { field in
                guard !(field.secret == true) else { return nil }
                guard let text = displayText(for: field) else { return nil }
                return (field.labelKey, text)
            }
        }
        return channel.config.keys.sorted().compactMap { key in
            guard !secretKeys.contains(key), let value = channel.config[key] else { return nil }
            return (key, plainText(value))
        }
    }

    private func displayText(for field: ProviderField) -> String? {
        if let value = channel.config[field.key] {
            return plainText(value)
        }
        if let def = field.defaultValue {
            return plainText(def)
        }
        return nil
    }

    private func plainText(_ value: JSONValue) -> String {
        switch value {
        case .string(let text):
            return text
        case .int(let number):
            return String(number)
        case .double(let number):
            return String(number)
        case .bool(let flag):
            return flag ? String(localized: "Yes") : String(localized: "No")
        }
    }

    var body: some View {
        List {
            Section("Channel") {
                LabeledContent("Provider") {
                    HStack {
                        ChannelIcon(definition?.icon ?? channel.type.rawValue)
                            .frame(width: 20, height: 20)
                        Text(verbatim: channel.type.rawValue)
                    }
                }
            }
            Section("Configuration") {
                if rows.isEmpty {
                    Text("No configuration values")
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(rows, id: \.label) { row in
                        LabeledContent {
                            Text(verbatim: row.value)
                        } label: {
                            Text(LocalizedStringKey(row.label))
                        }
                    }
                }
            }
        }
        .navigationTitle(channel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
