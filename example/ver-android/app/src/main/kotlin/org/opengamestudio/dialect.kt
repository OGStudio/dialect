package org.opengamestudio

val DIALECT_CONTEXT_RECENT_FIELD_NONE = "none"

interface DialectContext {
    /**
     * Name of the field that has just been changed
     *
     * Allows should-functions (reducers) to react only to
     * relevant changes and ignore other changes of DialectContext
     */
    var recentField: String

    /**
     * Get field's value by its name
     */
    fun <T> field(name: String): T
    /**
     * Erase type
     *
     * Used by DialectController to assign recent field's value
     */
    fun fieldAny(name: String): Any {
        return field(name)
    }
    /**
     * Create a copy of the DialectContext derivative
     *
     * Used by DialectController to treat all derived contexts as DialectContext
     */
    fun selfCopy(): DialectContext
    /**
     * Set field's value by its name
     */
    fun setField(name: String, value: Any?)
}
package org.opengamestudio

class DialectController(
    var context: DialectContext
) {
    internal var callbacks = mutableListOf<(c: DialectContext) -> Unit>()
    internal var functions = mutableListOf<(c: DialectContext) -> DialectContext>()
    var isProcessingQueue = false
    internal var queue = mutableListOf<DialectContext>()
 
    fun executeFunctions() {
        val c = queue.removeAt(0)
        // Keep SSOT: Only allow single field change per should-function
        context.recentField = c.recentField
        context.setField(c.recentField, c.fieldAny(c.recentField))
       
        for (f in functions) {
            val ctx = f(context.selfCopy())
            if (ctx.recentField != DIALECT_CONTEXT_RECENT_FIELD_NONE) {
                queue.add(ctx)
            }
        }
       
        reportContext()
    }
 
    fun processQueue() {
        // Prevent recursion.
        if (isProcessingQueue) {
            return
        }
       
        isProcessingQueue = true
       
        while (queue.size > 0) {
            executeFunctions()
        }
       
        isProcessingQueue = false
    }
 
    fun registerCallback(cb: (c: DialectContext) -> Unit) {
        callbacks.add(cb)
    }
 
    fun registerFieldCallback(
        fieldName: String,
        cb: (DialectContext) -> Unit
    ) {
        callbacks.add({ c ->
            if (c.recentField == fieldName) {
                cb(c)
            }
        })
    }
 
    fun registerFunction(f: (DialectContext) -> DialectContext) {
        functions.add(f)
    }
 
    fun reportContext() {
        for (cb in callbacks) {
            cb(context)
        }
    }
 
    fun set(fieldName: String, value: Any) {
        var c = context.selfCopy()
        c.setField(fieldName, value)
        c.recentField = fieldName
        queue.add(c)
        processQueue()
    }
}
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
        ctrl.registerFieldCallback(field, callback)
    }
}
