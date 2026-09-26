// Temporarily manually written
// Will be generated someday

// Root related functions

func rootRegisterShoulds(_ ctrl: DialectController) {
    [
        rootShouldResetCount,
        rootShouldResetCountText,
        rootShouldResetDidLaunch,
    ].forEach { f in
        ctrl.registerFunction { c in f(c as! RootContext) }
    }
}

func rootSet(
    _ key: String,
    _ value: Any
) {
    RootComponent.singleton!.ctrl.set(key, value)
}

// Root oneliners

func rootRegisterEffects(_ ctrl: DialectController) {
    RootVM.shared?.countText = "todo"
    let _: RootContext? = registerOneliners(ctrl, [
        F.countText, { (c: RootContext) in print(c.countText) },
        F.countText, { (c: RootContext) in RootVM.shared!.countText = c.countText },
    ])
}