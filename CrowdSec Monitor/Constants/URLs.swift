class URLs {
    static let crowdsecMonitorApiRepo = "https://github.com/JGeek00/crowdsec-monitor-api"
    static func crowdsecHubScenario(scenario: String) -> String {
        let scenarioSplit = scenario.split(separator: "/")
        return "https://app.crowdsec.net/hub/author/\(scenarioSplit[0])/scenarios/\(scenarioSplit[1])"
    }
    static let crowdsecWeb = "https://crowdsec.net"
    static let appDetailsPage = ""
    static let myOtherApps = "https://apps.jgeek00.com"
}
