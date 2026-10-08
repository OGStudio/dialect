let cli = CLIComponent()
let conv = ConvComponent()
let kotlin = KotlinComponent()
let llm = LLMComponent()
let swift = SwiftComponent()
let yml = YMLComponent()

otherSetupConsoleLogging(cli.ctrl, "CLI")
otherSetupConsoleLogging(conv.ctrl, "Conv")
otherSetupConsoleLogging(llm.ctrl, "LLM")

conv.setup()
cli.setup()
yml.setup()
llm.setup()
kotlin.setup()
swift.setup()

