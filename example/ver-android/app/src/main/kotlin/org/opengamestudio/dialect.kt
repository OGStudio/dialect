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

// Context field names for static type check
object F {
    const val count = "count"
    const val countText = "countText"
    const val didClickIncrement = "didClickIncrement"
    const val didLaunch = "didLaunch"
    const val didSetup = "didSetup"

}

@Suppress("UNCHECKED_CAST")
data class RootContext(
    var count: Int = 0,
    var countText: String = "",
    var didClickIncrement: Boolean = false,
    var didLaunch: Boolean = false,
    var didSetup: Boolean = false,

    override var recentField: String = ""
) : DialectContext {
    override fun <T> field(name: String): T {
        if (name == "count") {
            return count as T
        }
        else if (name == "countText") {
            return countText as T
        }
        else if (name == "didClickIncrement") {
            return didClickIncrement as T
        }
        else if (name == "didLaunch") {
            return didLaunch as T
        }
        else if (name == "didSetup") {
            return didSetup as T
        }

        return "" as T
    }

    override fun selfCopy(): DialectContext {
        return this.copy()
    }

    override fun setField(
        name: String,
        value: Any?
    ) {
        if (name == "count") {
            count = value as Int
        }
        else if (name == "countText") {
            countText = value as String
        }
        else if (name == "didClickIncrement") {
            didClickIncrement = value as Boolean
        }
        else if (name == "didLaunch") {
            didLaunch = value as Boolean
        }
        else if (name == "didSetup") {
            didSetup = value as Boolean
        }

    }
}

fun rootSet(
    key: String,
    value: Any
) {
    RootComponent.ctrl.set(key, value)
}

fun rootShouldResetCount(c: RootContext): RootContext {
    val c = c

    // 1. Upon hitting 10 the first time
    if (
        c.recentField == F.didClickIncrement && c.count == 9
    ) {
        c.count += 10
        c.recentField = F.count
        return c
    }

    // 2. Upon each button click
    if (
        c.recentField == F.didClickIncrement
    ) {
        c.count += 1
        c.recentField = F.count
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

fun rootShouldResetCountText(c: RootContext): RootContext {
    val c = c

    // 1. Upon each count chang
    if (
        c.recentField == F.count
    ) {
        c.countText = "Count: '${c.count}'"
        c.recentField = F.countText
        return c
    }

    // 2. Upon launc
    if (
        c.recentField == F.didLaunch
    ) {
        c.countText = "Press the button to count"
        c.recentField = F.countText
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

fun rootShouldResetDidLaunch(c: RootContext): RootContext {
    val c = c

    // 1. Only once during the first setup
    if (
        !c.recentField == F.didSetup &&
        c.didLaunch == false
    ) {
        c.didLaunch = true
        c.recentField = F.didLaunch
        return c
    }


    c.recentField = DIALECT_CONTEXT_RECENT_FIELD_NONE
    return c
}

fun rootRegisterShoulds(ctrl: DialectController) {
    listOf(
        ::rootShouldResetCount,
        ::rootShouldResetCountText,
        ::rootShouldResetDidLaunch,

    ).forEach { f ->
        ctrl.registerFunction { c -> f(c as RootContext) }
    }
}

fun rootRegisterEffects(ctrl: DialectController) {
    registerOneliners(ctrl, arrayOf(
        F.countText, { c: DialectContext ->
            if (false) {
                /**
print(c.countText)
                */
            }
        },
        F.countText, { c: DialectContext ->
            if (false) {
                /**
RootVM.shared!.countText = c.countText
                */
            }
        },

    ))
}
