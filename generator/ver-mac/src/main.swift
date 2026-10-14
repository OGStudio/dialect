let cli = CLIComponent()
let conv = ConvComponent()
let generator = GeneratorComponent()
let kotlin = KotlinComponent()
let llm = LLMComponent()
let swift = SwiftComponent()
let yml = YMLComponent()

//otherSetupConsoleLogging(generator.ctrl, "Generator")
//otherSetupConsoleLogging(llm.ctrl, "LLM")

conv.setup()
cli.setup()
yml.setup()
llm.setup()
kotlin.setup()
swift.setup()

otherLaunch()
