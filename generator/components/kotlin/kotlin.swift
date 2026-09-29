class KotlinComponent {
    let ctrl = DialectController(KotlinContext())
    static private(set) weak var singleton: KotlinComponent?

    init() {
        Self.singleton = self
        //kotlinRegisterEffects(ctrl)
        kotlinRegisterShoulds(ctrl)
    }

    func setup() {
        kotlinSet(F.didSetup, true)
    }
}
