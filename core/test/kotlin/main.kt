fun main() {
    print("Testing... ")

    val tests = arrayOf(
        ::t01_ExampleContext_field,
        ::t02_ExampleContext_field_optional,
        ::t03_ExampleContext_setField,
        ::t04_ExampleContext_setField_optional,
        ::t05_DialectController_executeFunctions_set,
        ::t06_DialectController_processQueue,
        ::t07_DialectController_registerFieldCallback_match,
        ::t08_DialectController_registerFieldCallback_mismatch,
        ::t09_ExampleContext_registerOneliners,
        ::t10_ExampleContext_selfCopy,
    )

    var okCount = 0
    for (test in tests) {
        val result = test()
        if (result) {
            okCount += 1
        }
    }
    val totalCount = tests.size
    println("Done. OK/total: $okCount/$totalCount")
}