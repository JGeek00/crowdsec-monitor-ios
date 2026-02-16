import SwiftUI

/// Custom property wrapper that uses UserDefaults.shared by default
///
/// This eliminates the need to specify `store: UserDefaults.shared` every time you use `@AppStorage`.
///
/// Usage:
/// ```swift
/// // Before:
/// @AppStorage("theme", store: UserDefaults.shared) var theme: Theme = .system
///
/// // After:
/// @SharedAppStorage("theme") var theme: Theme = .system
/// ```
///
/// Supported types:
/// - String, Int, Double, Bool, URL, Data
/// - RawRepresentable types (Enums with String or Int raw values)
/// - Optional versions of all types above
///
/// Examples:
/// ```swift
/// @SharedAppStorage("username") var username: String = ""
/// @SharedAppStorage("count") var count: Int = 0
/// @SharedAppStorage("theme") var theme: Theme = .light // where Theme: String-based enum
/// @SharedAppStorage("optionalValue") var value: String?
/// ```
@propertyWrapper
struct SharedAppStorage<Value>: DynamicProperty {
    @AppStorage private var value: Value
    
    var wrappedValue: Value {
        get { value }
        nonmutating set { value = newValue }
    }
    
    var projectedValue: Binding<Value> {
        $value
    }
    
    // MARK: - Non-optional types with default values
    
    init(wrappedValue: Value, _ key: String) where Value == String {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value == Int {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value == Double {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value == Bool {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value == URL {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value == Data {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    // MARK: - RawRepresentable types (Enums) with default values
    
    init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == String {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    init(wrappedValue: Value, _ key: String) where Value: RawRepresentable, Value.RawValue == Int {
        self._value = AppStorage(wrappedValue: wrappedValue, key, store: UserDefaults.shared)
    }
    
    // MARK: - Optional types without default values
    
    init(_ key: String) where Value == String? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
    
    init(_ key: String) where Value == Int? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
    
    init(_ key: String) where Value == Double? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
    
    init(_ key: String) where Value == Bool? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
    
    init(_ key: String) where Value == URL? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
    
    init(_ key: String) where Value == Data? {
        self._value = AppStorage(key, store: UserDefaults.shared)
    }
}
