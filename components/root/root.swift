class RootComponent {
    let ctrl = DialectController(RootContext())
    static private(set) weak var singleton: RootComponent?

    init() {
        Self.singleton = self
        rootRegisterEffects(ctrl)
        rootRegisterShoulds(ctrl)
        otherSetupConsoleLogging(ctrl, "Root")
    }

    func setup() {
        rootSet(F.didSetup, true)
    }
}
