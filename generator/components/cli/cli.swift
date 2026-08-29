class CLIComponent {
    let ctrl = DialectController(CLIContext())
    static private(set) weak var singleton: CLIComponent?

    init() {
        Self.singleton = self
        cliRegisterShoulds(ctrl)
        otherSetupConsoleLogging(ctrl, "CLI")
        // TODO oneliners
    }

    func setup() {
        print("before didSetup")
        cliSet(F.didSetup, true)
    }
}
