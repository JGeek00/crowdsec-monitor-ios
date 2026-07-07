nonisolated struct DecisionsRequest: Sendable {
    var filters: DecisionsRequestFilters
    var pagination: DecisionsRequestPagination
}

nonisolated struct DecisionsRequestFilters: Sendable {
    var onlyActive: Bool?
}

nonisolated struct DecisionsRequestPagination: Sendable {
    var offset: Int
    var limit: Int
}
