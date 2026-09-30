package org.opengamestudio

// Register several oneliner callbacks to a controller
@Suppress("UNCHECKED_CAST")
fun registerOneliners(
    ctrl: DialectController,
    items: Array<Any>
) {
    val halfCount = items.size / 2
    for (i in 0..<halfCount) {
        val field = items[i * 2] as String
        val callback = items[i * 2 + 1] as (c: DialectContext) -> Unit
        ctrl.registerFieldCallback(field, callback);
    }
}
