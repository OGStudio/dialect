let transpiler = TranspilerComponent()
let cli = CLIComponent()
let llm = LLMComponent()

otherSetupConsoleLogging(transpiler.ctrl, "Transpiler")
otherSetupConsoleLogging(cli.ctrl, "CLI")
//otherSetupConsoleLogging(llm.ctrl, "LLM")

cli.setup()
llm.setup()

transpilerLaunch()
