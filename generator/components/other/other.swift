import Foundation

/// Decode a base64 string back into a regular string
func otherBase64ToString(_ encoded: String) -> String {
    guard
        let data = Data(base64Encoded: encoded),
        let str = String(data: data, encoding: .utf8)
    else {
        return ""
    }
    return str
}

/// Print to stderr
func otherPrintStderr(_ txt: String) {
    if let dat = txt.data(using: .utf8) {
        FileHandle.standardError.write(dat)
    }
}

/// Print each key/value processed by a controller into stderr
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

/// Write output text to a file
func otherWriteFile(
    _ path: String,
    _ content: String
) {
    try! content.write(toFile: path, atomically: true, encoding: .utf8)
}
