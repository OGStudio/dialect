class CLIComponent {
    let ctrl = DialectController(CLIContext())
    static private(set) weak var singleton: CLIComponent?

    init() {
        Self.singleton = self
        cliRegisterShoulds(ctrl)
        // TODO oneliners
    }

    func setup() {
        cliSet(F.didSetup, true)
    }
}
