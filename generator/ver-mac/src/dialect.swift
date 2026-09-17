
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

// The engine of the dialect components
public class DialectController {
    var callbacks = [(DialectContext) -> Void]()
    var context: DialectContext
    var functions = [(DialectContext) -> DialectContext]()
    var isProcessingQueue = false
    var queue = [DialectContext]()

    public init(_ context: DialectContext) {
        self.context = context
    }

    func executeFunctions() {
        let c = queue.removeFirst()
        // Keep SSOT: Only allow single field change per should-function
        context.recentField = c.recentField
        context.setField(c.recentField, c.fieldAny(c.recentField))
      
        for f in functions {
            let ctx = f(context)
            if ctx.recentField != DIALECT_CONTEXT_RECENT_FIELD_NONE {
                queue.append(ctx)
            }
        }
      
        reportContext()
    }

    func processQueue() {
        // Prevent recursion.
        if isProcessingQueue {
            return
        }
      
        isProcessingQueue = true
      
        while (queue.count > 0) {
            executeFunctions()
        }
      
        isProcessingQueue = false
    }

    public func registerCallback(_ cb: @escaping (DialectContext) -> Void) {
        callbacks.append(cb)
    }

    public func registerFieldCallback(
        _ fieldName: String,
        _ cb: @escaping (DialectContext) -> Void
    ) {
        callbacks.append({ c in
            if c.recentField == fieldName {
                cb(c)
            }
        })
    }

    public func registerFunction(_ f: @escaping (DialectContext) -> DialectContext) {
        functions.append(f)
    }

    func reportContext() {
        for cb in callbacks {
            cb(context)
        }
    }

    public func set(
        _ fieldName: String,
        _ value: Any
    ) {
        var c = context
        c.setField(fieldName, value)
        c.recentField = fieldName
        queue.append(c)
        processQueue()
    }
}

// Register several oneliner callbacks to a controller
func registerOneliners<T>(
    _ ctrl: DialectController,
    _ items: [Any]
) -> T? {
    let halfCount = items.count / 2
    for i in 0..<halfCount {
        let field = items[i * 2] as! String
        let callback = items[i * 2 + 1] as! (T) -> Void
        ctrl.registerFieldCallback(field) { cc in
            let c = cc as! T
            callback(c)
        }
    }

    // A hack for generics to operate
    return nil
}

// Context field names for static type check
struct F {
    static let arguments = "arguments"
    static let chunks = "chunks"
    static let consoleOutput = "consoleOutput"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let entities = "entities"
    static let entityFieldTypes = "entityFieldTypes"
    static let entityFields = "entityFields"
    static let entityTypes = "entityTypes"
    static let inputAbsoluteDir = "inputAbsoluteDir"
    static let inputContents = "inputContents"
    static let inputError = "inputError"
    static let inputFileName = "inputFileName"
    static let inputLines = "inputLines"
    static let out = "out"
    static let outFields = "outFields"
    static let outputPaths = "outputPaths"
    static let outStructs = "outStructs"
    static let parseInput = "parseInput"
    static let path = "path"
    static let readFile = "readFile"
    static let type = "type"
    static let version = "version"

}
