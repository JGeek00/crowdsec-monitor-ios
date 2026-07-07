nonisolated struct ToggleBlocklistRequestParams: Codable {
    let blocklistId: String
}

nonisolated struct ToggleBlocklistRequestBody: Codable {
    let enabled: Bool
}
