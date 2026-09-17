let SWIFT_FIELD_T = "    static let %NAME% = \"%NAME%\"\n"
let SWIFT_FIELDS_T = """

// Context field names for static type check
struct F {
%ITEMS%
}
"""
let SWIFT_STRUCT_FIELD_T = "    var %NAME% = %DEFAULT%\n"
let SWIFT_STRUCT_T = """

struct %NAME% {
%FIELDS%
}
"""
let SWIFT_TYPE = "swift"
let SWIFT_TYPE_STRUCT = "struct"
