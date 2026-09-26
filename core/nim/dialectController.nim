# Nim port of core/swift/DialectController.swift

import dialectContext

type
  DialectController*[T] = ref object
    callbacks*: seq[proc(c: T)]
    context*: T
    functions*: seq[proc(c: T): T]
    isProcessingQueue*: bool
    queue*: seq[T]

proc dialectControllerCreate*[T](context: T): DialectController[T] =
  DialectController[T](context: context)

proc executeFunctions*[T](ctrl: DialectController[T]) =
  mixin setField, fieldAny, reportContext

  let c = ctrl.queue[0]
  ctrl.queue.delete(0)
  # Keep SSOT: Only allow single field change per should-function
  ctrl.context.recentField = c.recentField
  setField(ctrl.context, c.recentField, fieldAny(c, c.recentField))

  for function in ctrl.functions:
    let ctx = function(ctrl.context)
    if ctx.recentField != DIALECT_CONTEXT_RECENT_FIELD_NONE:
      ctrl.queue.add(ctx)

  reportContext(ctrl)

proc processQueue*[T](ctrl: DialectController[T]) =
  # Prevent recursion.
  if ctrl.isProcessingQueue:
    return

  ctrl.isProcessingQueue = true

  while ctrl.queue.len > 0:
    executeFunctions(ctrl)

  ctrl.isProcessingQueue = false

proc registerCallback*[T](ctrl: DialectController[T], cb: proc(c: T)) =
  ctrl.callbacks.add(cb)

proc registerFieldCallback*[T](
  ctrl: DialectController[T],
  fieldName: string,
  cb: proc(c: T),
) =
  ctrl.callbacks.add(proc(c: T) =
    if c.recentField == fieldName:
      cb(c))

proc registerFunction*[T](ctrl: DialectController[T], f: proc(c: T): T) =
  ctrl.functions.add(f)

proc reportContext*[T](ctrl: DialectController[T]) =
  for cb in ctrl.callbacks:
    cb(ctrl.context)

proc dialectControllerSet*[T](
  ctrl: DialectController[T],
  fieldName: string,
  value: DialectValue,
) =
  mixin setField

  var c = ctrl.context
  setField(c, fieldName, value)
  c.recentField = fieldName
  ctrl.queue.add(c)
  ctrl.processQueue()