let agent = AgentComponent()
let cli = CLIComponent()
let llm = LLMComponent()

//otherSetupConsoleLogging(agent.ctrl, "Agent")
//otherSetupConsoleLogging(cli.ctrl, "CLI")
//otherSetupConsoleLogging(llm.ctrl, "LLM")

cli.setup()
llm.setup()

agentLaunch()
