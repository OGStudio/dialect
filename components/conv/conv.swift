class ConvComponent {
    let ctrl = DialectController(ConvContext())
    static private(set) weak var singleton: ConvComponent?

    init() {
        Self.singleton = self
        convRegisterEffects(ctrl)
        convRegisterShoulds(ctrl)
    }

    func setup() {
        convSet(F.didSetup, true)
    }
}
