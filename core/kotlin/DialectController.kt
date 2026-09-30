/**
 * This file is a part of Kotlin dialect:
 *     https://github.com/OGStudio/kotlin-dialect
 * License: CC0
 * Version: 3.2.0
 */

package org.opengamestudio

import kotlin.js.JsExport

val DIALECT_CONTEXT_RECENT_FIELD_NONE = "none"

@JsExport
class DialectController(
    var context: DialectContext
) {
    internal var callbacks = mutableListOf<(c: DialectContext) -> Unit>()
    internal var functions = mutableListOf<(c: DialectContext) -> DialectContext>()
    var isProcessingQueue = false
    internal var queue = mutableListOf<DialectContext>()
 
    fun executeFunctions() {
        val c = queue.removeAt(0)
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
