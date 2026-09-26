# Nim port of core/test/swift/main.swift
import tests

echo "Testing... "

let testProcs = [
  t01_ExampleContext_field,
  t02_ExampleContext_field_optional,
  t03_ExampleContext_setField,
  t04_ExampleContext_setField_optional,
  t05_DialectController_executeFunctions_set,
  t06_DialectController_processQueue,
  t07_DialectController_registerFieldCallback_match,
  t08_DialectController_registerFieldCallback_mismatch,
]

var okCount = 0
for test in testProcs:
  if test():
    inc okCount

let totalCount = testProcs.len
echo "Done. OK/total: ", okCount, "/", totalCount