let cli = CLIComponent()
let kotlin = KotlinComponent()
let swift = SwiftComponent()
let yml = YMLComponent()

otherSetupConsoleLogging(cli.ctrl, "CLI")
otherSetupConsoleLogging(kotlin.ctrl, "Kotlin")
otherSetupConsoleLogging(swift.ctrl, "Swift")
otherSetupConsoleLogging(yml.ctrl, "YML")

cli.setup()
yml.setup()
//kotlin.setup()
swift.setup()
