// Temporarily manually written
// Will be generated someday

func cliSet(
    _ key: String,
    _ value: Any
) {
    CLIComponent.singleton!.ctrl.set(key, value)
}

struct CLIContext: DialectContext {
    var arguments = [String]()
    var didLaunch = false
    var didSetup = false
    var input = ""
    var inputFileName = ""
    var inputFileNameContents = ""
    var readFile = false
    var stdin = ""

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "arguments") {
            return arguments as! T
        } else if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "didSetup") {
            return didSetup as! T
        } else if (name == "input") {
            return input as! T
        } else if (name == "inputFileName") {
            return inputFileName as! T
        } else if (name == "inputFileNameContents") {
            return inputFileNameContents as! T
        } else if (name == "readFile") {
            return readFile as! T
        } else if (name == "stdin") {
            return stdin as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "arguments") {
            arguments = value as! [String]
        } else if (name == "didLaunch") {
            didLaunch = value as! Bool
        } else if (name == "didSetup") {
            didSetup = value as! Bool
        } else if (name == "input") {
            input = value as! String
        } else if (name == "inputFileName") {
            inputFileName = value as! String
        } else if (name == "inputFileNameContents") {
            inputFileNameContents = value as! String
        } else if (name == "readFile") {
            readFile = value as! Bool
        } else if (name == "stdin") {
            stdin = value as! String
        }
    }
}

struct F {
    static let arguments = "arguments"
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
    static let input = "input"
    static let inputFileName = "inputFileName"
    static let inputFileNameContents = "inputFileNameContents"
    static let readFile = "readFile"
    static let stdin = "stdin"
}
