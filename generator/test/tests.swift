import Foundation

func t01_generateWithoutOneliners(_ generator: URL, _ fixture: URL) -> Bool {
    let files = FileManager.default
    let directory = files.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    do {
        try files.createDirectory(at: directory, withIntermediateDirectories: false)
        defer { try? files.removeItem(at: directory) }

        let input = directory.appendingPathComponent("dialect.yml")
        try files.copyItem(at: fixture, to: input)

        let process = Process()
        process.executableURL = generator
        process.arguments = ["--file=\(input.path)"]
        let finished = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in finished.signal() }
        try process.run()

        guard finished.wait(timeout: .now() + 10) == .success else {
            process.terminate()
            print("Generator timed out")
            return false
        }
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            print("Generator failed with status \(process.terminationStatus)")
            return false
        }

        let output = directory.appendingPathComponent("generated.swift")
        let source = try String(contentsOf: output, encoding: .utf8)
        return source.contains("struct CounterContext") &&
            source.contains("func counterShouldResetCount")
    } catch {
        print(error)
        return false
    }
}
