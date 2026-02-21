struct CreateDecisionRequest: Codable {
    let ip: String
    let duration: String
    let type: Enums.DecisionType
    let reason: String
}
