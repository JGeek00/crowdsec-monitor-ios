class URLs {
    static let crowdsecMonitorApiRepo = "https://github.com/JGeek00/crowdsec-monitor-api"
    static func crowdsecHubScenario(scenario: String) -> String {
        let parts = parseScenario(scenario)
        return "https://app.crowdsec.net/hub/author/\(parts.namespace)/scenarios/\(parts.name)"
    }
    static let crowdsecWeb = "https://crowdsec.net"
    static let appDetailsPage = "https://apps.jgeek00.com/2f1zi66jongz9ix"
    static let myOtherApps = "https://apps.jgeek00.com"
    static let apiPackageUrl = "https://github.com/JGeek00/crowdsec-monitor-api/pkgs/container/crowdsec-monitor-api"
}
