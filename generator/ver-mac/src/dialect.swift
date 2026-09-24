
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
    static let desc = "desc"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let entities = "entities"
    static let entityFieldTypes = "entityFieldTypes"
    static let entityFields = "entityFields"
    static let entityShouldBranches = "entityShouldBranches"
    static let entityShoulds = "entityShoulds"
    static let entityTypes = "entityTypes"
    static let `if` = "if"
    static let inputAbsoluteDir = "inputAbsoluteDir"
    static let inputContents = "inputContents"
    static let inputError = "inputError"
    static let inputFileName = "inputFileName"
    static let inputLines = "inputLines"
    static let out = "out"
    static let outContexts = "outContexts"
    static let outFields = "outFields"
    static let outShoulds = "outShoulds"
    static let outStructs = "outStructs"
    static let outputPaths = "outputPaths"
    static let parseInput = "parseInput"
    static let path = "path"
    static let readFile = "readFile"
    static let then = "then"
    static let type = "type"
    static let version = "version"

}
struct OutputPath {
    var path = String()
    var type = String()

}

struct ShouldBranch {
    var desc = String()
    var `if` = String()
    var then = String()

}

struct CLIContext: DialectContext {
    var arguments = [String]()
    var consoleOutput = String()
    var didLaunch = Bool()
    var didSetup = Bool()
    var inputAbsoluteDir = String()
    var inputContents = String()
    var inputError = String()
    var inputFileName = String()
    var readFile = Bool()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "arguments") {
            return arguments as! T
        }
        else if (name == "consoleOutput") {
            return consoleOutput as! T
        }
        else if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }
        else if (name == "inputAbsoluteDir") {
            return inputAbsoluteDir as! T
        }
        else if (name == "inputContents") {
            return inputContents as! T
        }
        else if (name == "inputError") {
            return inputError as! T
        }
        else if (name == "inputFileName") {
            return inputFileName as! T
        }
        else if (name == "readFile") {
            return readFile as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "arguments") {
            arguments = value as! [String]
        }
        else if (name == "consoleOutput") {
            consoleOutput = value as! String
        }
        else if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }
        else if (name == "inputAbsoluteDir") {
            inputAbsoluteDir = value as! String
        }
        else if (name == "inputContents") {
            inputContents = value as! String
        }
        else if (name == "inputError") {
            inputError = value as! String
        }
        else if (name == "inputFileName") {
            inputFileName = value as! String
        }
        else if (name == "readFile") {
            readFile = value as! Bool
        }

    }
}

struct RootContext: DialectContext {
    var didLaunch = Bool()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "didLaunch") {
            didLaunch = value as! Bool
        }

    }
}

struct SwiftContext: DialectContext {
    var didLaunch = Bool()
    var didSetup = Bool()
    var entities = [String]()
    var entityFields = [Int: [String]]()
    var entityFieldTypes = [Int: [Int: String]]()
    var entityShouldBranches = [Int: [Int: [ShouldBranch]]]()
    var entityShoulds = [Int: [String]]()
    var entityTypes = [Int: String]()
    var inputAbsoluteDir = String()
    var path = String()
    var out = String()
    var outContexts = String()
    var outFields = String()
    var outputPaths = [OutputPath]()
    var outShoulds = String()
    var outStructs = String()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }
        else if (name == "entities") {
            return entities as! T
        }
        else if (name == "entityFields") {
            return entityFields as! T
        }
        else if (name == "entityFieldTypes") {
            return entityFieldTypes as! T
        }
        else if (name == "entityShouldBranches") {
            return entityShouldBranches as! T
        }
        else if (name == "entityShoulds") {
            return entityShoulds as! T
        }
        else if (name == "entityTypes") {
            return entityTypes as! T
        }
        else if (name == "inputAbsoluteDir") {
            return inputAbsoluteDir as! T
        }
        else if (name == "path") {
            return path as! T
        }
        else if (name == "out") {
            return out as! T
        }
        else if (name == "outContexts") {
            return outContexts as! T
        }
        else if (name == "outFields") {
            return outFields as! T
        }
        else if (name == "outputPaths") {
            return outputPaths as! T
        }
        else if (name == "outShoulds") {
            return outShoulds as! T
        }
        else if (name == "outStructs") {
            return outStructs as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }
        else if (name == "entities") {
            entities = value as! [String]
        }
        else if (name == "entityFields") {
            entityFields = value as! [Int: [String]]
        }
        else if (name == "entityFieldTypes") {
            entityFieldTypes = value as! [Int: [Int: String]]
        }
        else if (name == "entityShouldBranches") {
            entityShouldBranches = value as! [Int: [Int: [ShouldBranch]]]
        }
        else if (name == "entityShoulds") {
            entityShoulds = value as! [Int: [String]]
        }
        else if (name == "entityTypes") {
            entityTypes = value as! [Int: String]
        }
        else if (name == "inputAbsoluteDir") {
            inputAbsoluteDir = value as! String
        }
        else if (name == "path") {
            path = value as! String
        }
        else if (name == "out") {
            out = value as! String
        }
        else if (name == "outContexts") {
            outContexts = value as! String
        }
        else if (name == "outFields") {
            outFields = value as! String
        }
        else if (name == "outputPaths") {
            outputPaths = value as! [OutputPath]
        }
        else if (name == "outShoulds") {
            outShoulds = value as! String
        }
        else if (name == "outStructs") {
            outStructs = value as! String
        }

    }
}

struct YMLContext: DialectContext {
    var chunks = [String: [String]]()
    var didLaunch = Bool()
    var didSetup = Bool()
    var entities = [String]()
    var entityFields = [Int: [String]]()
    var entityFieldTypes = [Int: [Int: String]]()
    var entityShouldBranches = [Int: [Int: [ShouldBranch]]]()
    var entityShoulds = [Int: [String]]()
    var entityTypes = [Int: String]()
    var inputContents = String()
    var inputLines = [String]()
    var outputPaths = [OutputPath]()
    var parseInput = Bool()
    var version = Int()

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "chunks") {
            return chunks as! T
        }
        else if (name == "didLaunch") {
            return didLaunch as! T
        }
        else if (name == "didSetup") {
            return didSetup as! T
        }
        else if (name == "entities") {
            return entities as! T
        }
        else if (name == "entityFields") {
            return entityFields as! T
        }
        else if (name == "entityFieldTypes") {
            return entityFieldTypes as! T
        }
        else if (name == "entityShouldBranches") {
            return entityShouldBranches as! T
        }
        else if (name == "entityShoulds") {
            return entityShoulds as! T
        }
        else if (name == "entityTypes") {
            return entityTypes as! T
        }
        else if (name == "inputContents") {
            return inputContents as! T
        }
        else if (name == "inputLines") {
            return inputLines as! T
        }
        else if (name == "outputPaths") {
            return outputPaths as! T
        }
        else if (name == "parseInput") {
            return parseInput as! T
        }
        else if (name == "version") {
            return version as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "chunks") {
            chunks = value as! [String: [String]]
        }
        else if (name == "didLaunch") {
            didLaunch = value as! Bool
        }
        else if (name == "didSetup") {
            didSetup = value as! Bool
        }
        else if (name == "entities") {
            entities = value as! [String]
        }
        else if (name == "entityFields") {
            entityFields = value as! [Int: [String]]
        }
        else if (name == "entityFieldTypes") {
            entityFieldTypes = value as! [Int: [Int: String]]
        }
        else if (name == "entityShouldBranches") {
            entityShouldBranches = value as! [Int: [Int: [ShouldBranch]]]
        }
        else if (name == "entityShoulds") {
            entityShoulds = value as! [Int: [String]]
        }
        else if (name == "entityTypes") {
            entityTypes = value as! [Int: String]
        }
        else if (name == "inputContents") {
            inputContents = value as! String
        }
        else if (name == "inputLines") {
            inputLines = value as! [String]
        }
        else if (name == "outputPaths") {
            outputPaths = value as! [OutputPath]
        }
        else if (name == "parseInput") {
            parseInput = value as! Bool
        }
        else if (name == "version") {
            version = value as! Int
        }

    }
}
