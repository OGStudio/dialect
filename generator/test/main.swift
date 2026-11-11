import Foundation

print("Testing... ")

let generator = URL(fileURLWithPath: CommandLine.arguments[1])
let ymlFile = URL(fileURLWithPath: CommandLine.arguments[2])
let ok = t01_generateWithoutOneliners(generator, ymlFile)

print("Done. OK/total: \(ok ? 1 : 0)/1")
exit(ok ? 0 : 1)
