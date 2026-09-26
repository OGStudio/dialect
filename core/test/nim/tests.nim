# Nim port of core/test/swift/tests.swift
import std/options

import dialectContext
import dialectController

# Sample Context used for testing
type
  ExampleContext* = object
    didLaunch*: bool
    host*: string
    sometimes*: Option[string]
    recentField*: string

proc field*(c: ExampleContext, name: string): DialectValue =
  if name == "didLaunch":
    return dialectValueBool(c.didLaunch)
  elif name == "host":
    return dialectValueString(c.host)
  elif name == "sometimes":
    if c.sometimes.isSome:
      return dialectValueString(c.sometimes.get)
    return dialectValueNone()

  return dialectValueString("unknown-field-name")

proc setField*(c: var ExampleContext, name: string, value: DialectValue) =
  if name == "didLaunch":
    if value.kind == dValueBool:
      c.didLaunch = value.boolean
  elif name == "host":
    if value.kind == dValueString:
      c.host = value.str
  elif name == "sometimes":
    if value.kind == dValueString:
      c.sometimes = some(value.str)
    else:
      c.sometimes = none(string)

# Sample function for processing context change
proc hostToDidLaunch*(c: ExampleContext): ExampleContext =
  result = c

  if result.recentField == "host":
    result.didLaunch = true
    result.recentField = "didLaunch"
  else:
    result.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE

# Validate field access by name
proc t01_ExampleContext_field*(): bool =
  var c = ExampleContext()
  c.host = "abc"
  let v = c.field("host")
  return v.kind == dValueString and c.host == v.str

# Validate field access by name for optional value
proc t02_ExampleContext_field_optional*(): bool =
  var c = ExampleContext()
  let ok1 = c.field("sometimes").kind == dValueNone

  c.sometimes = some("def")
  let v = c.field("sometimes")
  let ok2 = v.kind == dValueString and c.sometimes.isSome and c.sometimes.get == v.str

  return ok1 and ok2

# Validate changing field value by name
proc t03_ExampleContext_setField*(): bool =
  var c = ExampleContext()
  c.didLaunch = true
  c.setField("didLaunch", dialectValueBool(false))
  return c.didLaunch == false

# Validate changing field optional value by name
proc t04_ExampleContext_setField_optional*(): bool =
  var c = ExampleContext()
  c.sometimes = some("anything")
  c.setField("sometimes", dialectValueNone())
  let ok1 = c.field("sometimes").kind == dValueNone

  c.setField("sometimes", dialectValueString("make it quick"))
  let v = c.field("sometimes")
  let ok2 = v.kind == dValueString and c.sometimes.isSome and c.sometimes.get == v.str

  return ok1 and ok2

# Validate executeFunctions() and set()
proc t05_DialectController_executeFunctions_set*(): bool =
  var ctrl = dialectControllerCreate(ExampleContext())

  # Disable the execution of executeFunctions() for testing purpose
  ctrl.isProcessingQueue = true

  ctrl.dialectControllerSet("host", dialectValueString("123"))

  ctrl.registerFunction(hostToDidLaunch)

  # Apply `host` value
  ctrl.executeFunctions()
  # Apply `didLaunch` value
  ctrl.executeFunctions()

  return ctrl.context.host == "123" and ctrl.context.didLaunch == true

# Validate processQueue()
proc t06_DialectController_processQueue*(): bool =
  var ctrl = dialectControllerCreate(ExampleContext())

  ctrl.registerFunction(hostToDidLaunch)
  ctrl.dialectControllerSet("host", dialectValueString("123"))

  return ctrl.context.didLaunch == true

# Validate registerFieldCallback() if an expected field was changed
proc t07_DialectController_registerFieldCallback_match*(): bool =
  var ec = ExampleContext()
  ec.host = "123"
  ec.recentField = "host"
  var callbackHost = ""

  var ctrl = dialectControllerCreate(ec)
  ctrl.registerFieldCallback("host") do (c: ExampleContext):
    callbackHost = c.host
  ctrl.reportContext()

  return ctrl.context.host == callbackHost

# Validate registerFieldCallback() if an unexpected field was changed, i.e.,
# callback should not be called
proc t08_DialectController_registerFieldCallback_mismatch*(): bool =
  var ec = ExampleContext()
  ec.host = "123"
  ec.recentField = "host"
  var callbackHost = ""

  var ctrl = dialectControllerCreate(ec)
  ctrl.registerFieldCallback("didLaunch") do (c: ExampleContext):
    callbackHost = c.host
  ctrl.reportContext()

  return callbackHost == ""
static:
  doAssert ExampleContext is DialectContext
