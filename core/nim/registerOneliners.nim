# Nim port of core/swift/registerOneliners.swift

import dialectController

type
  DialectOneliner*[T] = object
    field*: string
    cb*: proc(c: T)

# Register several oneliner callbacks (items = [field, cb, ...])
proc dialectRegisterOneliners*[T](
  ctrl: DialectController[T],
  items: openArray[DialectOneliner[T]],
) =
  for item in items:
    registerFieldCallback(ctrl, item.field, item.cb)