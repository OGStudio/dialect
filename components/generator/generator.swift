class GeneratorComponent {
    let ctrl = DialectController(GeneratorContext())
    static private(set) weak var singleton: GeneratorComponent?

    init() {
        Self.singleton = self
        generatorRegisterEffects(ctrl)
        generatorRegisterShoulds(ctrl)
    }
}
