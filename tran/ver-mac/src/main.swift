let tran = TranComponent()
let cli = CLIComponent()
let llm = LLMComponent()

//otherSetupConsoleLogging(tran.ctrl, "Tran")
//otherSetupConsoleLogging(cli.ctrl, "CLI")
//otherSetupConsoleLogging(llm.ctrl, "LLM")

cli.setup()
llm.setup()

tranLaunch()