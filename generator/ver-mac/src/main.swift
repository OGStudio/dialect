import Foundation
import Yams

let cli = CLIComponent()

cli.setup()





guard CommandLine.arguments.count > 1 else {
    print("Usage: yamlparser <file.yaml>")
    print("       cat file.yaml | yamlparser -")
    exit(1)
}

print("ИГР args: '\(CommandLine.arguments)'")

let arg = CommandLine.arguments[1]
let input: String

if arg == "-" {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    input = String(data: data, encoding: .utf8) ?? ""
} else {
    let url = URL(fileURLWithPath: arg)
    guard let data = try? Data(contentsOf: url),
          let str = String(data: data, encoding: .utf8) else {
        print("Error: could not read '\(arg)'")
        exit(1)
    }
    input = str
}

guard let node = try? Yams.load(yaml: input) else {
    print("Error: failed to parse YAML")
    exit(1)
}

func printValue(_ value: Any, indent: Int = 0) {
    let pad = String(repeating: "  ", count: indent)

    if let dict = value as? [String: Any] {
        for (k, v) in dict {
            if v is [String: Any] || v is [Any] {
                print("\(pad)\(k):")
                printValue(v, indent: indent + 1)
            } else {
                print("\(pad)\(k): \(v)")
            }
        }
    } else if let arr = value as? [Any] {
        for item in arr {
            if let d = item as? [String: Any] {
                print("\(pad)-")
                printValue(d, indent: indent + 1)
            } else if let a = item as? [Any] {
                print("\(pad)-")
                printValue(a, indent: indent + 1)
            } else {
                print("\(pad)- \(item)")
            }
        }
    } else {
        print("\(pad)\(value)")
    }
}

print("--- Parsed YAML ---")
printValue(node)
