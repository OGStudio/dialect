# Nim port of core/swift/DialectContext.swift

# Reusable "none" constant
const DIALECT_CONTEXT_RECENT_FIELD_NONE* = "none"

# A value of a context field (mirrors Swift `Any`)
type
  # OutputPath: path: String, type: String
  OutputPath* = object
    path*: string
    `type`*: string

  # ShouldBranch: desc: String, if: [String], then: [String]
  ShouldBranch* = object
    desc*: string
    `if`*: seq[string]
    then*: seq[string]

  DialectValueKind* = enum
    dValueNone, dValueBool, dValueString, dValueOutputPath, dValueShouldBranch

  DialectValue* = object
    kind*: DialectValueKind
    boolean*: bool
    str*: string
    outputPath*: OutputPath
    shouldBranch*: ShouldBranch

proc dialectValueNone*(): DialectValue =
  DialectValue(kind: dValueNone)

proc dialectValueBool*(b: bool): DialectValue =
  DialectValue(kind: dValueBool, boolean: b)

proc dialectValueString*(s: string): DialectValue =
  DialectValue(kind: dValueString, str: s)

# Base "protocol" for each component's state (mirrors Swift's DialectContext):
#   recentField: string
#   field(name): DialectValue
#   fieldAny(name): DialectValue   <- default implementation below
#   setField(name, value)
type
  DialectContext* = concept c
    c.recentField is string
    field(c, "x") is DialectValue
    fieldAny(c, "x") is DialectValue
    setField(c, "x", dialectValueNone())

# Default implementation of `fieldAny`, mirroring the Swift DialectContext extension
proc fieldAny*[T](c: T, name: string): DialectValue =
  mixin field
  field(c, name)