class CLIComponent {
    let ctrl = DialectController(CLIContext())
    static private(set) weak var singleton: CLIComponent?

    init() {
        Self.singleton = self
        cliRegisterEffects(ctrl);
        cliRegisterShoulds(ctrl)
    }

    func setup() {
        cliSet(F.arguments, CommandLine.arguments)

        cliSet(F.didSetup, true)
    }
}
