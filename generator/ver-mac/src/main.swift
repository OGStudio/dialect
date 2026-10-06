let cli = CLIComponent()
let kotlin = KotlinComponent()
let llm = LLMComponent()
let swift = SwiftComponent()
let yml = YMLComponent()

otherSetupConsoleLogging(cli.ctrl, "CLI")
otherSetupConsoleLogging(llm.ctrl, "LLM")

cli.setup()
yml.setup()
llm.setup()
kotlin.setup()
swift.setup()
