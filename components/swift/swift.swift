class SwiftComponent {
    let ctrl = DialectController(SwiftContext())
    static private(set) weak var singleton: SwiftComponent?

    init() {
        Self.singleton = self
        swiftRegisterEffects(ctrl)
        swiftRegisterShoulds(ctrl)
    }

    func setup() {
        swiftSet(F.didSetup, true)
    }
}
