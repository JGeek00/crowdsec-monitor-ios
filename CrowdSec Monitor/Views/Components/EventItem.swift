import SwiftUI

struct EventItemDataElement: Hashable {
    let key: String
    let value: [String]
}

struct EventItem: View {
    let data: [EventItemDataElement]
    
    init(data: [EventItemDataElement]) {
        self.data = data
    }
    
    @State private var showFullDetailsSheet = false
    
    func isValidUserAgent(_ value: String) -> String {
        if value != "-" {
            return value
        }
        else {
            return String(localized: "User agent not available")
        }
    }
    
    var body: some View {
        // General fields
        let targetFqdn = data.first(where: { $0.key == "target_fqdn" })
        let logType = data.first(where: { $0.key == "log_type" })
        let service = data.first(where: { $0.key == "service" })
        
        // HTTP specific fields
        let httpVerb = data.first(where: { $0.key == "http_verb" })
        let httpPath = data.first(where: { $0.key == "http_path" })
        let httpStatus = data.first(where: { $0.key == "http_status" })
        let httpUserAgent = data.first(where: { $0.key == "http_user_agent" })
        
        // SSH and Network specific fields
        let datasourcePath = data.first(where: { $0.key == "datasource_path" })
        let asnOrg = data.first(where: { $0.key == "ASNOrg" })
        
        Button {
            showFullDetailsSheet = true
        } label: {
            VStack(alignment: .leading) {
                // Target FQDN (if available)
                if let targetFqdn = targetFqdn, let value = targetFqdn.value.first {
                    HStack {
                        Spacer()
                        Text(value)
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                    }
                    Spacer()
                        .frame(height: 24)
                }
                
                // HTTP Events
                if let httpVerb = httpVerb, let httpPath = httpPath, let httpStatus = httpStatus, let httpUserAgent = httpUserAgent, let httpVerbValue = httpVerb.value.first, let httpPathValue = httpPath.value.first, let httpStatusValue = httpStatus.value.first {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(httpVerbValue)
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.white)
                                .background(Color.blue)
                                .clipShape(Capsule())
                            Text(httpPathValue)
                                .fontWeight(.medium)
                                .font(.system(size: 16))
                            Spacer()
                            Text(httpStatusValue)
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.white)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                            Text(verbatim: isValidUserAgent(httpUserAgent.value[0]))
                        }
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.gray)
                            .fontDesign(.monospaced)
                        if let datasourcePath = datasourcePath, let value = datasourcePath.value.first {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 12))
                                Text(verbatim: value)
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.gray)
                                    .fontDesign(.monospaced)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
                // SSH Events
                else if let logType = logType, logType.value.contains("ssh"), let service = service, let serviceValue = service.value.first, let logTypeValue = logType.value.first {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(serviceValue.uppercased())
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.white)
                                .background(Color.orange)
                                .clipShape(Capsule())
                            Text(logTypeValue)
                                .fontWeight(.medium)
                                .font(.system(size: 16))
                            Spacer()
                        }
                        if let datasourcePath = datasourcePath, let value = datasourcePath.value.first {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 12))
                                Text(verbatim: value)
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.gray)
                                    .fontDesign(.monospaced)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
                // Port Scan / Network Events
                else if let logType = logType, let service = service, let serviceValue = service.value.first, let logTypeValue = logType.value.first {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(serviceValue.uppercased())
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundStyle(Color.white)
                                .background(Color.purple)
                                .clipShape(Capsule())
                            Text(logTypeValue)
                                .fontWeight(.medium)
                                .font(.system(size: 16))
                            Spacer()
                        }
                        if let datasourcePath = datasourcePath, let value = datasourcePath.value.first {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 12))
                                Text(verbatim: value)
                                    .font(.system(size: 11))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.gray)
                                    .fontDesign(.monospaced)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    }
                }
                // Generic fallback for any other event type
                else if let logType = logType, let logTypeValue = logType.value.first {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            if let service = service, let serviceValue = service.value.first {
                                Text(serviceValue.uppercased())
                                    .fontWeight(.semibold)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .foregroundStyle(Color.white)
                                    .background(Color.gray)
                                    .clipShape(Capsule())
                            }
                            Text(logTypeValue)
                                .fontWeight(.medium)
                                .font(.system(size: 16))
                            Spacer()
                        }
                        if let asnOrg = asnOrg, let value = asnOrg.value.first {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 12))
                                Text(verbatim: value)
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
            }
        }
        .foregroundStyle(Color.foreground)
        .sheet(isPresented: $showFullDetailsSheet) {
            EventFullDetails(data: data) {
                showFullDetailsSheet = false
            }
        }
    }
}

#Preview("HTTP Path Traversal Attack") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["14061"]),
            EventItemDataElement(key: "ASNOrg", value: ["DIGITALOCEAN-ASN"]),
            EventItemDataElement(key: "IsInEU", value: ["true"]),
            EventItemDataElement(key: "IsoCode", value: ["DE"]),
            EventItemDataElement(key: "SourceRange", value: ["159.65.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/nginx-proxy-manager/default-host_access.log"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "http_args_len", value: ["0"]),
            EventItemDataElement(key: "http_path", value: ["/cgi-bin/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/.%2e/bin/sh"]),
            EventItemDataElement(key: "http_status", value: ["400"]),
            EventItemDataElement(key: "http_user_agent", value: ["-"]),
            EventItemDataElement(key: "http_verb", value: ["POST"]),
            EventItemDataElement(key: "log_type", value: ["http_access-log"]),
            EventItemDataElement(key: "service", value: ["http"]),
            EventItemDataElement(key: "source_ip", value: ["159.65.119.52"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T13:58:28+01:00"]),
        ])
    }
}

#Preview("HTTP Brute Force Login") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["16509"]),
            EventItemDataElement(key: "ASNOrg", value: ["AMAZON-02"]),
            EventItemDataElement(key: "IsInEU", value: ["false"]),
            EventItemDataElement(key: "IsoCode", value: ["US"]),
            EventItemDataElement(key: "SourceRange", value: ["52.41.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/nginx/access.log"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "http_args_len", value: ["23"]),
            EventItemDataElement(key: "http_path", value: ["/wp-login.php"]),
            EventItemDataElement(key: "http_status", value: ["401"]),
            EventItemDataElement(key: "http_user_agent", value: ["Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"]),
            EventItemDataElement(key: "http_verb", value: ["POST"]),
            EventItemDataElement(key: "log_type", value: ["http_access-log"]),
            EventItemDataElement(key: "service", value: ["http"]),
            EventItemDataElement(key: "source_ip", value: ["52.41.128.45"]),
            EventItemDataElement(key: "target_fqdn", value: ["example.com"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T14:23:15+01:00"]),
        ])
    }
}

#Preview("SSH Brute Force") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["4837"]),
            EventItemDataElement(key: "ASNOrg", value: ["CHINA169-BACKBONE"]),
            EventItemDataElement(key: "IsInEU", value: ["false"]),
            EventItemDataElement(key: "IsoCode", value: ["CN"]),
            EventItemDataElement(key: "SourceRange", value: ["218.92.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/auth.log"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "log_type", value: ["ssh_failed-auth"]),
            EventItemDataElement(key: "service", value: ["ssh"]),
            EventItemDataElement(key: "source_ip", value: ["218.92.0.167"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T15:12:03+01:00"]),
        ])
    }
}

#Preview("SQL Injection Attempt") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["20473"]),
            EventItemDataElement(key: "ASNOrg", value: ["AS-CHOOPA"]),
            EventItemDataElement(key: "IsInEU", value: ["false"]),
            EventItemDataElement(key: "IsoCode", value: ["SG"]),
            EventItemDataElement(key: "SourceRange", value: ["45.32.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/apache2/access.log"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "http_args_len", value: ["67"]),
            EventItemDataElement(key: "http_path", value: ["/index.php"]),
            EventItemDataElement(key: "http_status", value: ["403"]),
            EventItemDataElement(key: "http_user_agent", value: ["sqlmap/1.5.2#stable"]),
            EventItemDataElement(key: "http_verb", value: ["GET"]),
            EventItemDataElement(key: "log_type", value: ["http_access-log"]),
            EventItemDataElement(key: "service", value: ["http"]),
            EventItemDataElement(key: "source_ip", value: ["45.32.156.23"]),
            EventItemDataElement(key: "target_fqdn", value: ["api.example.com"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T16:45:32+01:00"]),
        ])
    }
}

#Preview("Port Scan Detection") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["8075"]),
            EventItemDataElement(key: "ASNOrg", value: ["MICROSOFT-CORP-MSN-AS-BLOCK"]),
            EventItemDataElement(key: "IsInEU", value: ["true"]),
            EventItemDataElement(key: "IsoCode", value: ["NL"]),
            EventItemDataElement(key: "SourceRange", value: ["13.69.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/syslog"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "log_type", value: ["iptables_drop"]),
            EventItemDataElement(key: "service", value: ["tcp"]),
            EventItemDataElement(key: "source_ip", value: ["13.69.234.12"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T17:03:45+01:00"]),
        ])
    }
}

#Preview("Directory Enumeration") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: ["16276"]),
            EventItemDataElement(key: "ASNOrg", value: ["OVH"]),
            EventItemDataElement(key: "IsInEU", value: ["true"]),
            EventItemDataElement(key: "IsoCode", value: ["FR"]),
            EventItemDataElement(key: "SourceRange", value: ["51.178.0.0/16"]),
            EventItemDataElement(key: "datasource_path", value: ["/var/log/nginx/access.log"]),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "http_args_len", value: ["0"]),
            EventItemDataElement(key: "http_path", value: ["/.env"]),
            EventItemDataElement(key: "http_status", value: ["404"]),
            EventItemDataElement(key: "http_user_agent", value: ["Mozilla/5.0 (compatible; Nuclei)"]),
            EventItemDataElement(key: "http_verb", value: ["GET"]),
            EventItemDataElement(key: "log_type", value: ["http_access-log"]),
            EventItemDataElement(key: "service", value: ["http"]),
            EventItemDataElement(key: "source_ip", value: ["51.178.62.95"]),
            EventItemDataElement(key: "target_fqdn", value: ["app.example.com"]),
            EventItemDataElement(key: "timestamp", value: ["2026-02-15T18:20:11+01:00"]),
        ])
    }
}

#Preview("Empty Values Test") {
    List {
        EventItem(data: [
            EventItemDataElement(key: "ASNNumber", value: []),
            EventItemDataElement(key: "ASNOrg", value: ["Unknown"]),
            EventItemDataElement(key: "IsInEU", value: []),
            EventItemDataElement(key: "IsoCode", value: []),
            EventItemDataElement(key: "SourceRange", value: []),
            EventItemDataElement(key: "datasource_path", value: []),
            EventItemDataElement(key: "datasource_type", value: ["file"]),
            EventItemDataElement(key: "http_args_len", value: []),
            EventItemDataElement(key: "http_path", value: ["/api/test"]),
            EventItemDataElement(key: "http_status", value: ["500"]),
            EventItemDataElement(key: "http_user_agent", value: []),
            EventItemDataElement(key: "http_verb", value: ["GET"]),
            EventItemDataElement(key: "log_type", value: ["http_access-log"]),
            EventItemDataElement(key: "service", value: ["http"]),
            EventItemDataElement(key: "source_ip", value: ["192.168.1.100"]),
            EventItemDataElement(key: "target_fqdn", value: []),
            EventItemDataElement(key: "timestamp", value: ["2026-02-18T10:30:00+01:00"]),
        ])
    }
}
