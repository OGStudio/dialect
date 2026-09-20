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
let SWIFT_STRUCT_FIELD_T = "    var %NAME% = %DEFAULT%\n"
let SWIFT_STRUCT_T = """

struct %NAME% {
%FIELDS%
}

"""
let SWIFT_TYPE = "swift"
let SWIFT_TYPE_CONTEXT = "context"
let SWIFT_TYPE_STRUCT = "struct"
