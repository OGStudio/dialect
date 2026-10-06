class AgentComponent {
    let ctrl = DialectController(AgentContext())
    static private(set) weak var singleton: AgentComponent?

    init() {
        Self.singleton = self
        agentRegisterEffects(ctrl)
        agentRegisterShoulds(ctrl)
    }
}
