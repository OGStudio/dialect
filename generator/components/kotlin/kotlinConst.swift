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
let KOTLIN_SET_SUFFIX = "Set"
let KOTLIN_SET_T = """

fun %FUNC%(
    key: String,
    value: Any
) {
    //%COMPONENT%.singleton!!.ctrl.set(key, value)
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
