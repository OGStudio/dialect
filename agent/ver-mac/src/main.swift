let cli = CLIComponent()
let llm = LLMComponent()

otherSetupConsoleLogging(cli.ctrl, "CLI")
otherSetupConsoleLogging(llm.ctrl, "LLM")

cli.setup()
llm.setup()
