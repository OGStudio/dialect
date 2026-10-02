// Swift mirror
func otherPrintStderr(_ txt: String) {
    if let dat = "\(txt)\n".data(using: .utf8) {
        FileHandle.standardError.write(dat)
    }
}

// Swift mirror
func otherSetupConsoleLogging(
    _ ctrl: DialectController,
    _ prefix: String
) {
    ctrl.registerCallback { c -> Void in
        let value = c.fieldAny(c.recentField)
        let line = "ИГР \(prefix) k/v: '\(c.recentField)'/'\(value)'"
        otherPrintStderr(line)
    }
}
