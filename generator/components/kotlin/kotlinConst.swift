let KOTLIN_FIELD_T = "    const val %NAME% = \"%NAME%\"\n"
let KOTLIN_FIELDS_T = """

// Context field names for static type check
object F {
%ITEMS%
}

"""
let KOTLIN_OGS_PKG = "package org.opengamestudio"
let KOTLIN_SET_SUFFIX = "Set"
let KOTLIN_SET_T = """

fun %FUNC%(
    key: String,
    value: Any
) {
    %COMPONENT%.singleton!!.ctrl.set(key, value)
}

"""
let KOTLIN_SUFFIX_COMPONENT = "Component"
let KOTLIN_SUFFIX_CONTEXT = "Context"
let KOTLIN_TYPE = "kotlin"
let KOTLIN_TYPE_COMPONENT = "component"
let KOTLIN_TYPE_CONTEXT = "context"
let KOTLIN_TYPE_STRUCT = "struct"
