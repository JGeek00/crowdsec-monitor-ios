import Foundation

nonisolated struct ScenarioParts: Sendable {
    let namespace: String
    let name: String
}

/// Safely splits a scenario string like "author/scenario-name" into namespace and name.
/// If the string contains no "/", the entire string is used as the namespace and the name is empty.
func parseScenario(_ scenario: String) -> ScenarioParts {
    let split = scenario.split(separator: "/")
    if split.count >= 2 {
        return ScenarioParts(namespace: String(split[0]), name: String(split[1]))
    } else {
        return ScenarioParts(namespace: scenario, name: "")
    }
}
