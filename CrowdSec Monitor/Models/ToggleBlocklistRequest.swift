struct ToggleBlocklistRequestParams: Codable {
    let blocklistId: String
}

struct ToggleBlocklistRequestBody: Codable {
    let enabled: Bool
}
