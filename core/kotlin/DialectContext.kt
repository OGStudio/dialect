/**
 * This file is a part of Kotlin dialect:
 *     https://github.com/OGStudio/kotlin-dialect
 * License: CC0
 * Version: 3.2.0
 */

package org.opengamestudio

import kotlin.js.JsExport

@JsExport
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
