// Temporarily manually written
// Will be generated someday

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
    static let parseInput = "parseInput"
    static let path = "path"
    static let readFile = "readFile"
    static let version = "version"
}

// CLIContext

struct CLIContext: DialectContext {
    var arguments = [String]()
    var consoleOutput = ""
    var didLaunch = false
    var didSetup = false
    var inputAbsoluteDir = ""
    var inputContents = ""
    var inputError = ""
    var inputFileName = ""
    var readFile = false

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "arguments") {
            return arguments as! T
        } else if (name == "consoleOutput") {
            return consoleOutput as! T
        } else if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "didSetup") {
            return didSetup as! T
        } else if (name == "inputAbsoluteDir") {
            return inputAbsoluteDir as! T
        } else if (name == "inputContents") {
            return inputContents as! T
        } else if (name == "inputError") {
            return inputError as! T
        } else if (name == "inputFileName") {
            return inputFileName as! T
        } else if (name == "readFile") {
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
        } else if (name == "consoleOutput") {
            consoleOutput = value as! String
        } else if (name == "didLaunch") {
            didLaunch = value as! Bool
        } else if (name == "didSetup") {
            didSetup = value as! Bool
        } else if (name == "inputAbsoluteDir") {
            inputAbsoluteDir = value as! String
        } else if (name == "inputContents") {
            inputContents = value as! String
        } else if (name == "inputError") {
            inputError = value as! String
        } else if (name == "inputFileName") {
            inputFileName = value as! String
        } else if (name == "readFile") {
            readFile = value as! Bool
        }
    }
}

// OutputPath

struct OutputPath {
    var path = ""
    var type = ""
}

// SwiftContext

struct SwiftContext: DialectContext {
    var didLaunch = false
    var didSetup = false
    var entities = [String]()
    var entityFields = [Int: [String]]()
    var inputAbsoluteDir = ""
    var out = ""
    var outFields = ""
    var outputPaths = [OutputPath]()
    var path = ""

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "didSetup") {
            return didSetup as! T
        } else if (name == "entities") {
            return entities as! T
        } else if (name == "entityFields") {
            return entityFields as! T
        } else if (name == "inputAbsoluteDir") {
            return inputAbsoluteDir as! T
        } else if (name == "out") {
            return out as! T
        } else if (name == "outFields") {
            return outFields as! T
        } else if (name == "outputPaths") {
            return outputPaths as! T
        } else if (name == "path") {
            return path as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "didLaunch") {
            didLaunch = value as! Bool
        } else if (name == "didSetup") {
            didSetup = value as! Bool
        } else if (name == "entities") {
            entities = value as! [String]
        } else if (name == "entityFields") {
            entityFields = value as! [Int: [String]]
        } else if (name == "inputAbsoluteDir") {
            inputAbsoluteDir = value as! String
        } else if (name == "out") {
            out = value as! String
        } else if (name == "outFields") {
            outFields = value as! String
        } else if (name == "outputPaths") {
            outputPaths = value as! [OutputPath]
        } else if (name == "path") {
            path = value as! String
        }
    }
}

// YMLContext

struct YMLContext: DialectContext {
    var chunks = [String: [String]]()
    var didLaunch = false
    var didSetup = false
    var entities = [String]()
    var entityFieldTypes = [Int: [Int: String]]()
    var entityFields = [Int: [String]]()
    var entityTypes = [Int: String]()
    var inputContents = ""
    var inputLines = [String]()
    var outputPaths = [OutputPath]()
    var parseInput = false
    var version = 0

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "chunks") {
            return chunks as! T
        } else if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "didSetup") {
            return didSetup as! T
        } else if (name == "entities") {
            return entities as! T
        } else if (name == "entityFieldTypes") {
            return entityFieldTypes as! T
        } else if (name == "entityFields") {
            return entityFields as! T
        } else if (name == "entityTypes") {
            return entityTypes as! T
        } else if (name == "inputContents") {
            return inputContents as! T
        } else if (name == "inputLines") {
            return inputLines as! T
        } else if (name == "outputPaths") {
            return outputPaths as! T
        } else if (name == "parseInput") {
            return parseInput as! T
        } else if (name == "version") {
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
        } else if (name == "didLaunch") {
            didLaunch = value as! Bool
        } else if (name == "didSetup") {
            didSetup = value as! Bool
        } else if (name == "entities") {
            entities = value as! [String]
        } else if (name == "entityFieldTypes") {
            entityFieldTypes = value as! [Int: [Int: String]]
        } else if (name == "entityFields") {
            entityFields = value as! [Int: [String]]
        } else if (name == "entityTypes") {
            entityTypes = value as! [Int: String]
        } else if (name == "inputContents") {
            inputContents = value as! String
        } else if (name == "inputLines") {
            inputLines = value as! [String]
        } else if (name == "outputPaths") {
            outputPaths = value as! [OutputPath]
        } else if (name == "parseInput") {
            parseInput = value as! Bool
        } else if (name == "version") {
            version = value as! Int
        }
    }
}

// CLI shoulds

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

    /* 1. Get file name by parsing arguments */
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

// CLI related functions

func cliRegisterShoulds(_ ctrl: DialectController) {
    [
        cliShouldResetConsoleOutput,
        cliShouldResetDidLaunch,
        cliShouldResetInputFileName,
        cliShouldResetReadFile,
    ].forEach { f in
        ctrl.registerFunction { c in f(c as! CLIContext) }
    }
}

func cliSet(
    _ key: String,
    _ value: Any
) {
    CLIComponent.singleton!.ctrl.set(key, value)
}

// SWIFT shoulds

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

    /* 1. At first just provide ctrl/ctx/reg */
    if
        c.recentField == F.didLaunch
    {
        c.out = otherBase64ToString(SWIFT_EMB64_CORE)
        c.recentField = F.out
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

// SWIFT related functions

func swiftRegisterShoulds(_ ctrl: DialectController) {
    [
        swiftShouldResetDidLaunch,
        swiftShouldResetOut,
        swiftShouldResetOutFields,
        swiftShouldResetPath,
    ].forEach { f in
        ctrl.registerFunction { c in f(c as! SwiftContext) }
    }
}

func swiftSet(
    _ key: String,
    _ value: Any
) {
    SwiftComponent.singleton!.ctrl.set(key, value)
}

// SWIFT oneliners

func swiftRegisterEffects(_ ctrl: DialectController) {
    let _: SwiftContext? = registerOneliners(ctrl, [
        F.out, { (c: SwiftContext) in otherWriteFile(c.path, c.out) },
    ])
}

// YML shoulds

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

// YML related functions

func ymlRegisterShoulds(_ ctrl: DialectController) {
    [
        ymlShouldResetChunks,
        ymlShouldResetDidLaunch,
        ymlShouldResetEntities,
        ymlShouldResetEntityFields,
        ymlShouldResetEntityTypes,
        ymlShouldResetOutputPaths,
        ymlShouldResetParseInput,
        ymlShouldResetVersion,
    ].forEach { f in
        ctrl.registerFunction { c in f(c as! YMLContext) }
    }
}

func ymlSet(
    _ key: String,
    _ value: Any
) {
    YMLComponent.singleton!.ctrl.set(key, value)
}

// YML oneliners

func ymlRegisterEffects(_ ctrl: DialectController) {
    let _: YMLContext? = registerOneliners(ctrl, [
        F.entities, { (c: YMLContext) in swiftSet(F.entities, c.entities) },
        F.entityFields, { (c: YMLContext) in swiftSet(F.entityFields, c.entityFields) },
        F.outputPaths, { (c: YMLContext) in swiftSet(F.outputPaths, c.outputPaths) },
        F.parseInput, { (c: YMLContext) in ymlReadLines(c.inputContents) },
    ])
}

// Oneliners

func cliRegisterEffects(_ ctrl: DialectController) {
    let _: CLIContext? = registerOneliners(ctrl, [
        F.consoleOutput, { (c: CLIContext) in print(c.consoleOutput) },
        F.inputAbsoluteDir, { (c: CLIContext) in swiftSet(F.inputAbsoluteDir, c.inputAbsoluteDir) },
        F.inputContents, { (c: CLIContext) in ymlSet(F.inputContents, c.inputContents) },
        F.inputFileName, { (c: CLIContext) in cliResolveAbsoluteDir(c.inputFileName) },
        F.readFile, { (c: CLIContext) in cliReadInputFile(c.inputFileName) },
    ])
}
