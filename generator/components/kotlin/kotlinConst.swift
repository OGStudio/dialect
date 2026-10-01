let KOTLIN_CONTEXT_FIELD_T = "    var %NAME%: %TYPE% = %DEFAULT%,\n"
let KOTLIN_CONTEXT_GETTER_T = """
        %ELSE%if (name == \"%NAME%\") {
            return %NAME% as T
        }

"""
let KOTLIN_CONTEXT_SETTER_T = """
        %ELSE%if (name == \"%NAME%\") {
            %NAME% = value as %TYPE%
        }

"""
let KOTLIN_CONTEXT_T = """

@Suppress("UNCHECKED_CAST")
data class %NAME%(
%FIELDS%
    override var recentField: String = ""
) : DialectContext {
    override fun <T> field(name: String): T {
%GETTERS%
        return \"\" as T
    }

    override fun selfCopy(): DialectContext {
        return this.copy()
    }

    override fun setField(
        name: String,
        value: Any?
    ) {
%SETTERS%
    }
}

"""
let KOTLIN_DEFAULT_BOOL = "false"
let KOTLIN_DEFAULT_INT = "0"
let KOTLIN_DEFAULT_LIST = "arrayOf()"
let KOTLIN_DEFAULT_MAP = "mapOf()"
let KOTLIN_DEFAULT_NAMED_T = "%TYPE%()"
let KOTLIN_DEFAULT_STRING = "\"\""
let KOTLIN_FIELD_T = "    const val %NAME% = \"%NAME%\"\n"
let KOTLIN_FIELDS_T = """

// Context field names for static type check
object F {
%ITEMS%
}

"""
let KOTLIN_LIST_T = "Array<%TYPE%>"
let KOTLIN_MAPPED_BOOL = "Boolean"
let KOTLIN_MAPPED_INT = "Int"
let KOTLIN_MAPPED_STRING = "String"
let KOTLIN_MAP_T = "Map<%KEY%, %VALUE%>"
let KOTLIN_OGS_PKG = "package org.opengamestudio"
let KOTLIN_REGISTER_EFFECTS_SUFFIX = "RegisterEffects"
let KOTLIN_REGISTER_EFFECTS_T = """

fun %FUNC%(ctrl: DialectController) {
    registerOneliners(ctrl, arrayOf(
%ITEMS%
    ))
}

"""
let KOTLIN_REGISTER_EFFECT_ITEM_T = """
        F.%FIELD%, { c: DialectContext ->
            if (false) {
                /**
%REACTION%
                */
            }
        },

"""
let KOTLIN_REGISTER_SHOULDS_SUFFIX = "RegisterShoulds"
let KOTLIN_REGISTER_SHOULDS_T = """

fun %FUNC%(ctrl: DialectController) {
    listOf(
%ITEMS%
    ).forEach { f ->
        ctrl.registerFunction { c -> f(c as %CONTEXT%) }
    }
}

"""
let KOTLIN_REGISTER_SHOULDS_ITEM_T = "        ::%SHOULD%,\n"
let KOTLIN_SET_SUFFIX = "Set"
let KOTLIN_SET_T = """

fun %FUNC%(
    key: String,
    value: Any
) {
    //%COMPONENT%.singleton!!.ctrl.set(key, value)
}

"""
let KOTLIN_SHOULD_BRANCH_T = """
    // %ABOUT%
    if (false) {
        /**
%CONDITION%
        */
        /**
%REACTION%
        */
        c.recentField = F.%FIELD%
        return c
    }


"""
let KOTLIN_SHOULD_INDENTATION = "        "
let KOTLIN_SHOULD_RESET = "ShouldReset"
let KOTLIN_SHOULD_T = """

// Should-functions of %CONTEXT%, transcribed from the Swift dialect
// The Swift source of every branch is preserved in block comments,
// so the blocks stay inert until they are hand-ported to Kotlin
fun %FUNC%(c: %CONTEXT%): %CONTEXT% {
    val c = c

%BRANCHES%
    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

"""
let KOTLIN_STRUCT_FIELD_T = "    var %NAME%: %TYPE% = %DEFAULT%,\n"
let KOTLIN_STRUCT_T = """

data class %NAME%(
%FIELDS%
)

"""
let KOTLIN_SUFFIX_COMPONENT = "Component"
let KOTLIN_SUFFIX_CONTEXT = "Context"
let KOTLIN_TYPE = "kotlin"
let KOTLIN_TYPE_BOOL = "Bool"
let KOTLIN_TYPE_COMPONENT = "component"
let KOTLIN_TYPE_CONTEXT = "context"
let KOTLIN_TYPE_INT = "Int"
let KOTLIN_TYPE_STRING = "String"
let KOTLIN_TYPE_STRUCT = "struct"
