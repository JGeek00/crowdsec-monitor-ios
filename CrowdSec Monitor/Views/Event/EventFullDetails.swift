import SwiftUI

struct EventFullDetails: View {
    let data: [EventItemDataElement]
    let onClose: () -> Void
    
    init(data: [EventItemDataElement], onClose: @escaping () -> Void) {
        self.data = data
        self.onClose = onClose
    }
    
    var body: some View {
        NavigationStack {
            List(data, id: \.self) { element in
                HStack {
                    Text(element.key)
                        .font(.headline)
                    Spacer()
                    Text(element.value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .navigationTitle("Event details")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
            }
        }
    }
}

#Preview {
    EventFullDetails(data: [
        EventItemDataElement(key: "ASNNumber", value: "16509"),
        EventItemDataElement(key: "ASNOrg", value: "AMAZON-02"),
        EventItemDataElement(key: "IsInEU", value: "false"),
        EventItemDataElement(key: "IsoCode", value: "US"),
        EventItemDataElement(key: "SourceRange", value: "52.41.0.0/16"),
        EventItemDataElement(key: "datasource_path", value: "/var/log/nginx/access.log"),
        EventItemDataElement(key: "datasource_type", value: "file"),
        EventItemDataElement(key: "http_args_len", value: "23"),
        EventItemDataElement(key: "http_path", value: "/wp-login.php"),
        EventItemDataElement(key: "http_status", value: "401"),
        EventItemDataElement(key: "http_user_agent", value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"),
        EventItemDataElement(key: "http_verb", value: "POST"),
        EventItemDataElement(key: "log_type", value: "http_access-log"),
        EventItemDataElement(key: "service", value: "http"),
        EventItemDataElement(key: "source_ip", value: "52.41.128.45"),
        EventItemDataElement(key: "target_fqdn", value: "example.com"),
        EventItemDataElement(key: "timestamp", value: "2026-02-15T14:23:15+01:00"),
    ], onClose: {})
}
