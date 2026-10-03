class LLMComponent {
    let ctrl = DialectController(LLMContext())
    static private(set) weak var singleton: LLMComponent?

    init() {
        Self.singleton = self
        llmRegisterEffects(ctrl)
        llmRegisterShoulds(ctrl)
    }

    func setup() {
        llmSet(F.didSetup, true)
    }
}
