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

        guard finished.wait(timeout: .now() + 60) == .success else {
            process.terminate()
            print("Generator timed out")
            return false
        }
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            print("Generator failed with status \(process.terminationStatus)")
            return false
        }

        let swift = try String(
            contentsOf: directory.appendingPathComponent("generated.swift"), encoding: .utf8
        )
        let kotlin = try String(
            contentsOf: directory.appendingPathComponent("generated.kt"), encoding: .utf8
        )
        return swift.contains("struct CounterContext") &&
            swift.contains("func counterShouldResetCount") &&
            kotlin.contains("data class CounterContext") &&
            kotlin.contains("fun counterShouldResetCount")
    } catch {
        print(error)
        return false
    }
}
