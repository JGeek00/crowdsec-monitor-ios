struct ToggleBlocklistRequestParams: Codable {
    let blocklistId: Int
}

struct ToggleBlocklistRequestBody: Codable {
    let enabled: Bool
}
