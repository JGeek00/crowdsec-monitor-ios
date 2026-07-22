struct DecisionsRequest: Sendable {
    var filters: DecisionsRequestFilters
    var pagination: DecisionsRequestPagination
}

struct DecisionsRequestFilters: Sendable {
    var onlyActive: Bool?
    var groupByIP: Bool?
}

struct DecisionsRequestPagination: Sendable {
    var offset: Int
    var limit: Int
}
