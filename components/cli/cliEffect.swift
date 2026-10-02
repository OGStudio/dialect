import Foundation

/// Read an input file and push its contents into the context
func cliReadInputFile(_ fileName: String) {
    let url = URL(fileURLWithPath: fileName)
    do {
        let data = try Data(contentsOf: url)
        guard let str = String(data: data, encoding: .utf8) else {
            throw CLIError.invalidString
        }
        cliSet(F.inputContents, str)
    } catch {
        cliSet(F.inputError, "\(error)")
    }
}

/// Resolve the absolute directory of an input file and push it into the context
func cliResolveAbsoluteDir(_ fileName: String) {
    let cwd = FileManager.default.currentDirectoryPath
    let fullPath = fileName.hasPrefix("/") ? fileName : cwd + "/" + fileName
    let dir = URL(fileURLWithPath: fullPath).deletingLastPathComponent()
    cliSet(F.inputAbsoluteDir, dir.standardizedFileURL.path)
}
