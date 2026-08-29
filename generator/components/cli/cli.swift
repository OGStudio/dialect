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
        cliSet(F.arguments, CommandLine.arguments)

        cliSet(F.didSetup, true)
    }
}
