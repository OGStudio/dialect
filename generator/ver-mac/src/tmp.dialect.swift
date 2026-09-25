// Temporarily manually written
// Will be generated someday

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

// SWIFT related functions

func swiftRegisterShoulds(_ ctrl: DialectController) {
    [
        swiftShouldResetDidLaunch,
        swiftShouldResetOut,
        swiftShouldResetOutContexts,
        swiftShouldResetOutFields,
        swiftShouldResetOutShoulds,
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

// YML related functions

func ymlRegisterShoulds(_ ctrl: DialectController) {
    [
        ymlShouldResetChunks,
        ymlShouldResetDidLaunch,
        ymlShouldResetEntities,
        ymlShouldResetEntityFields,
        ymlShouldResetEntityFieldTypes,
        ymlShouldResetEntityShouldBranches,
        ymlShouldResetEntityShoulds,
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
        F.entityShouldBranches, { (c: YMLContext) in swiftSet(F.entityShouldBranches, c.entityShouldBranches) },
        F.entityShoulds, { (c: YMLContext) in swiftSet(F.entityShoulds, c.entityShoulds) },
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