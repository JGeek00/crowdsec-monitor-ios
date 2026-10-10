import Foundation

// MARK: - Provider definition (served by the backend, drives generic forms)

struct ProviderFieldCondition: Codable, Hashable, Sendable {
    let field: String
    let equals: JSONValue?
    let present: Bool?
}

struct ProviderFieldOption: Codable, Hashable, Sendable {
    let value: String
    let labelKey: String
}

struct ProviderSection: Codable, Hashable, Sendable, Identifiable {
    let key: String
    let labelKey: String

    var id: String { key }
}

struct ProviderField: Codable, Hashable, Sendable, Identifiable {
    let key: String
    let section: String?
    let labelKey: String
    let placeholderKey: String?
    let type: String
    let list: Bool?
    let required: Bool?
    let secret: Bool?
    let defaultValue: JSONValue?
    let regex: String?
    let minLength: Int?
    let maxLength: Int?
    let min: Double?
    let max: Double?
    let integer: Bool?
    let options: [ProviderFieldOption]?
    let requiredIf: ProviderFieldCondition?
    let exclusiveWith: [String]?
    let visibleIf: ProviderFieldCondition?

    var id: String { key }

    enum CodingKeys: String, CodingKey {
        case key, section, labelKey, placeholderKey, type, list, required, secret, regex
        case minLength, maxLength, min, max, integer, options, requiredIf, exclusiveWith, visibleIf
        case defaultValue = "default"
    }
}

struct NotificationProvider: Codable, Hashable, Sendable, Identifiable {
    let type: String
    let descriptionKey: String?
    let icon: String
    let labelKey: String
    let supportsTest: Bool
    let supportsAlertInfo: Bool
    let sections: [ProviderSection]?
    let fields: [ProviderField]

    var id: String { type }
}

struct ProvidersListResponse: Codable, Hashable, Sendable {
    let version: Int
    let providers: [NotificationProvider]
}
