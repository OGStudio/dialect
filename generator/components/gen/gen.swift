class GenComponent {
    let ctrl = DialectController(GenContext())
    static private(set) weak var singleton: GenComponent?

    init() {
        Self.singleton = self
        genRegisterEffects(ctrl)
        genRegisterShoulds(ctrl)
        otherSetupConsoleLogging(ctrl, "Gen")
    }

    func setup() {
        genSet(F.didSetup, true)
    }
}
