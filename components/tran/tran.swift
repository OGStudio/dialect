class TranComponent {
    let ctrl = DialectController(TranContext())
    static private(set) weak var singleton: TranComponent?

    init() {
        Self.singleton = self
        tranRegisterEffects(ctrl)
        tranRegisterShoulds(ctrl)
    }
}
