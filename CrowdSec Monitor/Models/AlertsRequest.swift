nonisolated struct AlertsRequest: Sendable {
    var filters: AlertsRequestFilters
    var pagination: AlertsRequestPagination
}

nonisolated struct AlertsRequestFilters: Sendable {
    var countries: [String]
    var scenarios: [String]
    var ipOwners: [String]
    var targets: [String]
}

nonisolated struct AlertsRequestPagination: Sendable {
    var offset: Int
    var limit: Int
}
