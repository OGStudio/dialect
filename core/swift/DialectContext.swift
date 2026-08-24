public protocol DialectContext {
    var recentField: String { get set }

    func field<T>(_ name: String) -> T
    func fieldAny(_ name: String) -> Any
    mutating func setField(_ name: String, _ value: Any)
}

public extension DialectContext {
    /// Default implementation of `fieldAny()`
    func fieldAny(_ name: String) -> Any {
        return field(name)
    }
}
