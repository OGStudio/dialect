let transpiler = TranspilerComponent()
let cli = CLIComponent()
let conv = ConvComponent()
let llm = LLMComponent()

otherSetupConsoleLogging(transpiler.ctrl, "Transpiler")
otherSetupConsoleLogging(cli.ctrl, "CLI")
otherSetupConsoleLogging(conv.ctrl, "Conv")
//otherSetupConsoleLogging(llm.ctrl, "LLM")

conv.setup()
llm.setup()
cli.setup()

transpilerLaunch()
