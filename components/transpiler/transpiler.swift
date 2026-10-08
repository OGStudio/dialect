class TranspilerComponent {
    let ctrl = DialectController(TranspilerContext())
    static private(set) weak var singleton: TranspilerComponent?

    init() {
        Self.singleton = self
        transpilerRegisterEffects(ctrl)
        transpilerRegisterShoulds(ctrl)
    }
}
