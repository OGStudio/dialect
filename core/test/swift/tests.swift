
/// Sample Context used for testing
struct ExampleContext: DialectContext {
    var didLaunch = false
    var host = ""
    var sometimes: String?

    var recentField = ""

    func field<T>(_ name: String) -> T {
        if (name == "didLaunch") {
            return didLaunch as! T
        } else if (name == "host") {
            return host as! T
        } else if (name == "sometimes") {
            return sometimes as! T
        }

        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
        if (name == "didLaunch") {
            didLaunch = value as! Bool
        } else if (name == "host") {
            host = value as! String
        } else if (name == "sometimes") {
            sometimes = value as! Optional<String>
        }
    }
}

/// Sample function for processing context change
func hostToDidLaunch(_ c: ExampleContext) -> ExampleContext {
    var c = c

    if c.recentField == "host" {
        c.didLaunch = true
        c.recentField = "didLaunch"
        return c
    }

    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

/// Validate field access by name
func t01_ExampleContext_field() -> Bool {
    var c = ExampleContext()
    c.host = "abc"
    return c.host == c.field("host")
}

/// Validate field access by name for optional value
func t02_ExampleContext_field_optional() -> Bool {
    var c = ExampleContext()
    let ok1 = c.field("sometimes") == nil

    c.sometimes = "def"
    let ok2 = c.sometimes == c.field("sometimes") ?? "N/A"

    return ok1 && ok2
}

/// Validate changing field value by name
func t03_ExampleContext_setField() -> Bool {
    var c = ExampleContext()
    c.didLaunch = true
    c.setField("didLaunch", false)
    return c.didLaunch == false
}

/// Validate changing field optional value by name
func t04_ExampleContext_setField_optional() -> Bool {
    var c = ExampleContext()
    c.sometimes = "anything"
    c.setField("sometimes", Optional<String>.none as Any)
    let ok1 = c.field("sometimes") == nil

    c.setField("sometimes", "make it quick")
    let ok2 = c.sometimes == c.field("sometimes") ?? "N/A"

    return ok1 && ok2
}

/// Validate `executeFunctions()` and `set()`
func t05_DialectController_executeFunctions_set() -> Bool {
    let ctrl = DialectController(ExampleContext())

    // Disable the execution of `executeFunctions()` for testing purpose
    ctrl.isProcessingQueue = true

    ctrl.set("host", "123")

    ctrl.registerFunction { c in
        hostToDidLaunch(c as! ExampleContext)
    }

    // Apply `host` value
    ctrl.executeFunctions()
    // Apply `didLaunch` value
    ctrl.executeFunctions()

    let c = ctrl.context as! ExampleContext
    return c.host == "123" &&
        c.didLaunch == true
}

/// Validate `processQueue()`
func t06_DialectController_processQueue() -> Bool {
    let ctrl = DialectController(ExampleContext())

    ctrl.registerFunction { c in
        hostToDidLaunch(c as! ExampleContext)
    }
    ctrl.set("host", "123")
    let c = ctrl.context as! ExampleContext
    return c.didLaunch == true
}

/// Validate `registerFieldCallback()` if an expected field was changed
func t07_DialectController_registerFieldCallback_match() -> Bool {
    var ec = ExampleContext()
    ec.host = "123"
    ec.recentField = "host"
    var callbackHost = ""

    let ctrl = DialectController(ec)
    ctrl.registerFieldCallback("host") { c in
        callbackHost = (c as! ExampleContext).host
    }
    ctrl.reportContext()

    let c = ctrl.context as! ExampleContext
    return c.host == callbackHost
}

/// Validate `registerFieldCallback()` if an unexpected field was changed, i.e.,
/// callback should not be called
func t08_DialectController_registerFieldCallback_mismatch() -> Bool {
    var ec = ExampleContext()
    ec.host = "123"
    ec.recentField = "host"
    var callbackHost = ""

    let ctrl = DialectController(ec)
    ctrl.registerFieldCallback("didLaunch") { c in
        callbackHost = (c as! ExampleContext).host
    }
    ctrl.reportContext()

    return callbackHost == ""
}
