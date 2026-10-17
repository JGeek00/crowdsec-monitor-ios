import Foundation

// MARK: - Editor vocabulary (subset of the API DSL)

enum ConditionField: String, CaseIterable, Sendable {
    case scenario
    case country
    case target
    case ipOwner
}

enum ConditionOperator: String, CaseIterable, Sendable {
    case equals
    case notEquals = "not_equals"
    case `in`
    case notIn = "not_in"
    case contains

    var needsMultipleValues: Bool {
        self == .in || self == .notIn
    }
}

// MARK: - Editable tree

struct EditableLeaf: Equatable, Sendable {
    var field: ConditionField
    var op: ConditionOperator
    var values: [String]

    static var empty: EditableLeaf {
        EditableLeaf(field: .scenario, op: .equals, values: [])
    }

    var isValid: Bool {
        !values.isEmpty && values.allSatisfy { !$0.isEmpty }
    }
}

indirect enum EditableCondition: Equatable, Sendable {
    case leaf(EditableLeaf)
    case and([EditableCondition])
    case or([EditableCondition])
    case not(EditableCondition)

    var leafCount: Int {
        switch self {
        case .leaf:
            return 1
        case .and(let children), .or(let children):
            return children.reduce(0) { $0 + $1.leafCount }
        case .not(let child):
            return child.leafCount
        }
    }

    var isValid: Bool {
        switch self {
        case .leaf(let leaf):
            return leaf.isValid
        case .and(let children), .or(let children):
            return !children.isEmpty && children.allSatisfy { $0.isValid }
        case .not(let child):
            return child.isValid
        }
    }
}

// MARK: - API conversion

extension EditableCondition {
    init(api node: NotificationConditionNode) {
        switch node {
        case .leaf(let field, let op, let value):
            self = .leaf(EditableLeaf(
                field: ConditionField(rawValue: field) ?? .scenario,
                op: ConditionOperator(rawValue: op) ?? .equals,
                values: value.asArray
            ))
        case .and(let children):
            self = .and(children.map(EditableCondition.init(api:)))
        case .or(let children):
            self = .or(children.map(EditableCondition.init(api:)))
        case .not(let child):
            self = .not(EditableCondition(api: child))
        }
    }

    func toAPI() -> NotificationConditionNode {
        switch self {
        case .leaf(let leaf):
            let value: NotificationConditionValue = leaf.values.count == 1
                ? .single(leaf.values[0])
                : .multiple(leaf.values)
            return .leaf(field: leaf.field.rawValue, op: leaf.op.rawValue, value: value)
        case .and(let children):
            return .and(children.map { $0.toAPI() })
        case .or(let children):
            return .or(children.map { $0.toAPI() })
        case .not(let child):
            return .not(child.toAPI())
        }
    }
}
