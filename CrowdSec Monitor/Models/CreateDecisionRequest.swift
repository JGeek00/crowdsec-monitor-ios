struct CreateDecisionRequest: Codable {
    let ip: String
    let duration: String
    let type: Enums.DecisionReason
    let reason: String
}
