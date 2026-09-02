class YMLComponent {
    let ctrl = DialectController(YMLContext())
    static private(set) weak var singleton: YMLComponent?

    init() {
        Self.singleton = self
        ymlRegisterShoulds(ctrl)
        otherSetupConsoleLogging(ctrl, "YML")
    }

    func setup() {
        ymlSet(F.didSetup, true)
    }
}
