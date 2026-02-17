struct DecisionsRequest {
    var filters: DecisionsRequestFilters
    var pagination: DecisionsRequestPagination
}

struct DecisionsRequestFilters {
    var onlyActive: Bool?
}

struct DecisionsRequestPagination {
    var offset: Int
    var limit: Int
}
