class ConvComponent {
    let ctrl = DialectController(ConvContext())
    static private(set) weak var singleton: ConvComponent?

    init() {
        Self.singleton = self
        convRegisterShoulds(ctrl)
    }

    func setup() {
        convSet(F.didSetup, true)
    }
}
