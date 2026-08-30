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
