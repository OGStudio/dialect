// Temporarily manually written
// Will be generated someday

struct F {
    static let arguments = "arguments"
    static let consoleOutput = "consoleOutput"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let inputFileName = "inputFileName"
    static let inputFileNameContents = "inputFileNameContents"
    static let readFile = "readFile"
}

// CLIContext

struct CLIContext: DialectContext {
    var arguments = [String]()
    var consoleOutput = ""
    var didLaunch = false
    var didSetup = false
    var inputFileName = ""
    var inputFileNameContents = ""
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
        } else if (name == "inputFileName") {
            return inputFileName as! T
        } else if (name == "inputFileNameContents") {
            return inputFileNameContents as! T
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
        } else if (name == "inputFileName") {
            inputFileName = value as! String
        } else if (name == "inputFileNameContents") {
            inputFileNameContents = value as! String
        } else if (name == "readFile") {
            readFile = value as! Bool
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
        c.recentField == F.inputFileName
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

// Oneliners

func cliRegisterEffects(_ ctrl: DialectController) {
    let _: CLIContext? = registerOneliners(ctrl, [
        F.consoleOutput, { (c: CLIContext) in print(c.consoleOutput) },
    ])
}
