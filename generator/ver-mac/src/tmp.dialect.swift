// Temporarily manually written
// Will be generated someday

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
        c.out =
            otherBase64ToString(SWIFT_EMB64_CORE) +
            c.outFields +
            c.outStructs +
            c.outContexts +
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


// SWIFT related functions

func swiftRegisterShoulds(_ ctrl: DialectController) {
    [
        swiftShouldResetDidLaunch,
        swiftShouldResetOut,
        swiftShouldResetOutContexts,
        swiftShouldResetOutFields,
        swiftShouldResetOutStructs,
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
        ymlShouldResetEntityFieldTypes,
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
        F.entityFieldTypes, { (c: YMLContext) in swiftSet(F.entityFieldTypes, c.entityFieldTypes) },
        F.entityTypes, { (c: YMLContext) in swiftSet(F.entityTypes, c.entityTypes) },
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
