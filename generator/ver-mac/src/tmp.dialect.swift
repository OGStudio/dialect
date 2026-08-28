// Temporarily manually written
// Will be generated someday

func cliSet(
    _ key: String,
    _ value: Any
) {
    CLIComponent.singleton!.ctrl.set(key, value)
}

struct CLIContext: DialectContext {
    var didLaunch = false
    var didSetup = false

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "didSetup") {
            return didSetup as! T
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
        }
    }
}

struct F {
    static let didLaunch = "didLaunch"
    static let didSetup = "didSetup"
}
