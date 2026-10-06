package org.opengamestudio

object RootComponent {
    val ctrl = DialectController(RootContext())

    init {
        rootRegisterEffects(ctrl)
        rootRegisterShoulds(ctrl)
    }

    fun setup() {
        rootSet(F.didSetup, true)
    }
}
