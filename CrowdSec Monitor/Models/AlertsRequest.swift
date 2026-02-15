struct AlertsRequest {
    var filters: AlertsRequestFilters
    var pagination: AlertsRequestPagination
}

struct AlertsRequestFilters {
    var countries: [String]?
    var scenarios: [String]?
    var ipOwners: [String]?
    var targets: [String]?
}

struct AlertsRequestPagination {
    var offset: Int
    var limit: Int
}
