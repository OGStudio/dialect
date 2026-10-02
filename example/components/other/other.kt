package org.opengamestudio

fun otherPrintStderr(txt: String) {
    System.err.println(txt)
}

fun otherSetupConsoleLogging(
    ctrl: DialectController,
    prefix: String
) {
    ctrl.registerCallback { c ->
        val value = c.fieldAny(c.recentField)
        val line = "ИГР $prefix k/v: '${c.recentField}'/'$value'"
        otherPrintStderr(line)
    }
}
