// Temporarily manually written
// Will be generated someday

// Root shoulds

func rootShouldResetCount(_ c: RootContext) -> RootContext {
    var c = c

    /* 1. Upon hitting 10 the first time */
    if
        c.recentField == F.didClickIncrement &&
        c.count == 9
    {
        c.count += 10
        c.recentField = F.count
        return c
    }

    /* 2. Upon each button click */
    if
        c.recentField == F.didClickIncrement
    {
        c.count += 1
        c.recentField = F.count
        return c
    }

    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

func rootShouldResetDidLaunch(_ c: RootContext) -> RootContext {
    var c = c

    /* 1. Only once during the first setup */
    if
        c.recentField == F.didSetup &&
        c.didLaunch == false
    {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }

    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

// Root related functions

func rootRegisterShoulds(_ ctrl: DialectController) {
    [
        rootShouldResetCount,
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
    let _: RootContext? = registerOneliners(ctrl, [
        F.count, { (c: RootContext) in print(c.count) },
    ])
}
