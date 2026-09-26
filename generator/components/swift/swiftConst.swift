let SWIFT_CONTEXT_FIELD_T = "    var %NAME% = %DEFAULT%\n"
let SWIFT_CONTEXT_GETTER_T = """
        %ELSE%if (name == \"%NAME%\") {
            return %NAME% as! T
        }

"""
let SWIFT_CONTEXT_SETTER_T = """
        %ELSE%if (name == \"%NAME%\") {
            %NAME% = value as! %TYPE%
        }

"""
let SWIFT_CONTEXT_T = """

struct %NAME%: DialectContext {
%FIELDS%
    var recentField = ""

    func field<T>(_ name: String) -> T {
%GETTERS%
        return "unknown-field-name" as! T
    }

    mutating func setField(
        _ name: String,
        _ value: Any
    ) {
%SETTERS%
    }
}

"""
let SWIFT_FIELD_T = "    static let %NAME% = \"%NAME%\"\n"
let SWIFT_FIELDS_T = """

// Context field names for static type check
struct F {
%ITEMS%
}
"""
let SWIFT_REGISTER_EFFECTS_SUFFIX = "RegisterEffects"
let SWIFT_REGISTER_EFFECTS_T = """

func %FUNC%(_ ctrl: DialectController) {
    let _: %CONTEXT%? = registerOneliners(ctrl, [
%ITEMS%
    ])
}

"""
let SWIFT_REGISTER_EFFECT_ITEM_T = "        F.%FIELD%, { (c: %CONTEXT%) in %REACTION% },\n"
let SWIFT_REGISTER_SHOULDS_SUFFIX = "RegisterShoulds"
let SWIFT_REGISTER_SHOULDS_T = """

func %FUNC%(_ ctrl: DialectController) {
    [
%ITEMS%
    ].forEach { f in
        ctrl.registerFunction { c in f(c as! %CONTEXT%) }
    }
}

"""
let SWIFT_SET_SUFFIX = "Set"
let SWIFT_SET_T = """

func %FUNC%(
    _ key: String,
    _ value: Any
) {
    %COMPONENT%.singleton!.ctrl.set(key, value)
}

"""
let SWIFT_STRUCT_FIELD_T = "    var %NAME% = %DEFAULT%\n"
let SWIFT_STRUCT_T = """

struct %NAME% {
%FIELDS%
}


"""
let SWIFT_SHOULD_BRANCH_T = """
    /* %ABOUT% */
    if
%CONDITION%
    {
%REACTION%
        c.recentField = F.%FIELD%
        return c
    }


"""
let SWIFT_SHOULD_INDENTATION = "        "
let SWIFT_SHOULD_RESET = "ShouldReset"
let SWIFT_SHOULD_T = """

func %FUNC%(_ c: %CONTEXT%) -> %CONTEXT% {
    var c = c

%BRANCHES%
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

"""
let SWIFT_SUFFIX_COMPONENT = "Component"
let SWIFT_SUFFIX_CONTEXT = "Context"
let SWIFT_TYPE = "swift"
let SWIFT_TYPE_COMPONENT = "component"
let SWIFT_TYPE_CONTEXT = "context"
let SWIFT_TYPE_STRUCT = "struct"
