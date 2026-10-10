let cli = CLIComponent()
let conv = ConvComponent()
let kotlin = KotlinComponent()
let llm = LLMComponent()
let swift = SwiftComponent()
let yml = YMLComponent()

otherSetupConsoleLogging(conv.ctrl, "Conv")
otherSetupConsoleLogging(kotlin.ctrl, "Kotlin")
otherSetupConsoleLogging(llm.ctrl, "LLM")

conv.setup()
cli.setup()
yml.setup()
llm.setup()
kotlin.setup()
swift.setup()

otherLaunch()
