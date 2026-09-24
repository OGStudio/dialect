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
let SWIFT_FIELD_T = "    static let %DECL% = \"%NAME%\"\n"
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
let SWIFT_SHOULD_BRANCH_T = """
    /* %DESC% */
    if
%IF%
    {
%THEN%
        c.recentField = F.%FIELD%
        return c
    }


"""
let SWIFT_SHOULD_T = """

func %FUNC%(_ c: %CONTEXT%) -> %CONTEXT% {
    var c = c

%BOTH%
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
let swiftKeywords = Set<String>([
    "Any",
    "as",
    "associatedtype",
    "break",
    "case",
    "catch",
    "class",
    "continue",
    "default",
    "defer",
    "deinit",
    "do",
    "else",
    "enum",
    "extension",
    "fallthrough",
    "false",
    "fileprivate",
    "for",
    "func",
    "guard",
    "if",
    "import",
    "in",
    "init",
    "inout",
    "internal",
    "is",
    "let",
    "nil",
    "open",
    "operator",
    "private",
    "protocol",
    "public",
    "repeat",
    "rethrows",
    "return",
    "self",
    "Self",
    "static",
    "struct",
    "subscript",
    "super",
    "switch",
    "throw",
    "throws",
    "true",
    "try",
    "typealias",
    "var",
    "where",
    "while",
])
