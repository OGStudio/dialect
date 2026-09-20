
// Reusable "none" constant
public let DIALECT_CONTEXT_RECENT_FIELD_NONE = "none"

// Base protocol for each component's state
public protocol DialectContext {
    var recentField: String { get set }

    func field<T>(_ name: String) -> T
    func fieldAny(_ name: String) -> Any
    mutating func setField(_ name: String, _ value: Any)
}

// Default implementation of `fieldAny` method for the protocol
public extension DialectContext {
    /// Default implementation of `fieldAny()`
    func fieldAny(_ name: String) -> Any {
        return field(name)
    }
}
