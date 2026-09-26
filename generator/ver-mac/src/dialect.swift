
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
    static let about = "about"
    static let arguments = "arguments"
    static let chunks = "chunks"
    static let condition = "condition"
    static let consoleOutput = "consoleOutput"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let entities = "entities"
    static let entityFieldTypes = "entityFieldTypes"
    static let entityFields = "entityFields"
    static let entityShouldBranches = "entityShouldBranches"
    static let entityShoulds = "entityShoulds"
    static let entityTypes = "entityTypes"
    static let inputAbsoluteDir = "inputAbsoluteDir"
    static let inputContents = "inputContents"
    static let inputError = "inputError"
    static let inputFileName = "inputFileName"
    static let inputLines = "inputLines"
    static let out = "out"
    static let outContexts = "outContexts"
    static let outFields = "outFields"
    static let outSets = "outSets"
    static let outShoulds = "outShoulds"
    static let outStructs = "outStructs"
    static let outputPaths = "outputPaths"
    static let parseInput = "parseInput"
    static let path = "path"
    static let reaction = "reaction"
    static let readFile = "readFile"
    static let type = "type"
    static let version = "version"

}
struct OutputPath {
    var path = String()
    var type = String()

}

struct ShouldBranch {
    var about = String()
    var condition = [String]()
    var reaction = [String]()

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
    var outSets = String()
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
        else if (name == "outSets") {
            return outSets as! T
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
        else if (name == "outSets") {
            outSets = value as! String
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

func cliSet(
    _ key: String,
    _ value: Any
) {
    CLIComponent.singleton!.ctrl.set(key, value)
}

func swiftSet(
    _ key: String,
    _ value: Any
) {
    SwiftComponent.singleton!.ctrl.set(key, value)
}

func ymlSet(
    _ key: String,
    _ value: Any
) {
    YMLComponent.singleton!.ctrl.set(key, value)
}

func cliShouldResetConsoleOutput(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. File argument was not found */
    if
        c.recentField == F.didLaunch &&
        cliArgumentValue(c.arguments, CLI_ARG_FILE).isEmpty
    {
        c.consoleOutput = CLI_CONSOLE_USAGE
        c.recentField = F.consoleOutput
        return c
    }

    /* 2. Could not open input file */
    if
        c.recentField == F.inputError
    {
        c.consoleOutput = CLI_CONSOLE_INPUT_FILE_ERROR
        c.recentField = F.consoleOutput
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetDidLaunch(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. Only once during the first setup */
    if
        c.recentField == F.didSetup &&
        c.didLaunch == false
    {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetInputFileName(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. Get file name by parsing aguments */
    if
        c.recentField == F.arguments &&
        cliArgumentValue(c.arguments, CLI_ARG_FILE) != ""
    {
        c.inputFileName = cliArgumentValue(c.arguments, CLI_ARG_FILE)
        c.recentField = F.inputFileName
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func cliShouldResetReadFile(_ c: CLIContext) -> CLIContext {
    var c = c

    /* 1. File name has been specified */
    if
        c.recentField == F.didLaunch &&
        !c.inputFileName.isEmpty
    {
        c.readFile = true
        c.recentField = F.readFile
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetDidLaunch(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. Only once during the first setup */
    if
        c.recentField == F.didSetup &&
        c.didLaunch == false
    {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOut(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. Upon launch */
    if
        c.recentField == F.didLaunch
    {
        c.out =
            otherBase64ToString(SWIFT_EMB64_CORE) +
            c.outFields +
            c.outStructs +
            c.outContexts +
            c.outSets +
            c.outShoulds
        c.recentField = F.out
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOutContexts(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. When entity field types are available */
    if
        c.recentField == F.entityFieldTypes
    {
        c.outContexts = swiftContexts(c.entities, c.entityTypes, c.entityFields, c.entityFieldTypes)
        c.recentField = F.outContexts
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOutFields(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. When entity fields are available */
    if
        c.recentField == F.entityFields
    {
        c.outFields = swiftFields(c.entityFields)
        c.recentField = F.outFields
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOutSets(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. When entities are ready */
    if
        c.recentField == F.entities
    {
        c.outSets = swiftSets(c.entities)
        c.recentField = F.outSets
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOutShoulds(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. When entity should branches are available */
    if
        c.recentField == F.entityShouldBranches
    {
        c.outShoulds = swiftShoulds(c.entities, c.entityShoulds, c.entityShouldBranches)
        c.recentField = F.outShoulds
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetOutStructs(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. When entity field types are available */
    if
        c.recentField == F.entityFieldTypes
    {
        c.outStructs = swiftStructs(c.entities, c.entityTypes, c.entityFields, c.entityFieldTypes)
        c.recentField = F.outStructs
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func swiftShouldResetPath(_ c: SwiftContext) -> SwiftContext {
    var c = c

    /* 1. Extract Swift path if present */
    if
        c.recentField == F.outputPaths &&
        c.outputPaths.contains(where: { $0.type == SWIFT_TYPE })
    {
        let last = c.outputPaths.first { $0.type == SWIFT_TYPE }?.path ?? "N/A"
        c.path = c.inputAbsoluteDir + "/" + last
        c.recentField = F.path
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetChunks(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Split input lines into chunks */
    if
        c.recentField == F.inputLines
    {
        c.chunks = ymlParseChunks(c.inputLines)
        c.recentField = F.chunks
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetDidLaunch(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Only once during the first setup */
    if
        c.recentField == F.didSetup &&
        c.didLaunch == false
    {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntities(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. When chunks are ready */
    if
        c.recentField == F.chunks
    {
        c.entities = ymlParseEntities(c.chunks)
        c.recentField = F.entities
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntityFields(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon entities */
    if
        c.recentField == F.entities
    {
        c.entityFields = ymlParseEntityFields(c.chunks, c.entities)
        c.recentField = F.entityFields
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntityFieldTypes(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon entity fields */
    if
        c.recentField == F.entityFields
    {
        c.entityFieldTypes = ymlParseEntityFieldTypes(c.chunks, c.entities, c.entityFields)
        c.recentField = F.entityFieldTypes
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntityShouldBranches(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon entity shoulds */
    if
        c.recentField == F.entityShoulds
    {
        c.entityShouldBranches = ymlParseEntityShouldBranches(c.chunks, c.entities, c.entityShoulds)
        c.recentField = F.entityShouldBranches
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntityShoulds(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon entities */
    if
        c.recentField == F.entities
    {
        c.entityShoulds = ymlParseEntityShoulds(c.chunks, c.entities)
        c.recentField = F.entityShoulds
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetEntityTypes(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon entities */
    if
        c.recentField == F.entities
    {
        c.entityTypes = ymlParseEntityTypes(c.chunks, c.entities)
        c.recentField = F.entityTypes
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetOutputPaths(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. When chunks are ready */
    if
        c.recentField == F.chunks
    {
        c.outputPaths = ymlParseOutputPaths(c.chunks)
        c.recentField = F.outputPaths
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetParseInput(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. Upon launching */
    if
        c.recentField == F.didLaunch &&
        !c.inputContents.isEmpty
    {
        c.parseInput = true
        c.recentField = F.parseInput
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func ymlShouldResetVersion(_ c: YMLContext) -> YMLContext {
    var c = c

    /* 1. When chunks are ready */
    if
        c.recentField == F.chunks
    {
        c.version = ymlParseVersion(c.chunks)
        c.recentField = F.version
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}
