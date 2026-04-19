/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.flutter_mozilla_components.gatekeeper

import android.content.Context
import android.content.SharedPreferences

/**
 * Cross-package shared-prefs file used to replicate the Flutter-side intent
 * gatekeeper policy to the native side so [IntentReceiverActivity] can block
 * intents without launching Flutter.
 *
 * The file name is a stable constant: other packages (e.g. simple_intent_receiver)
 * write to the same file using [Context.getSharedPreferences] with this name.
 */
object IntentGatekeeperPreferences {
    const val PREFS_NAME = "weblibre_intent_gatekeeper"
    const val KEY_ENABLED = "enabled"
    const val KEY_BLOCKED_PACKAGES = "blocked_packages"

    fun get(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun isEnabled(context: Context): Boolean =
        get(context).getBoolean(KEY_ENABLED, false)

    fun isBlocked(context: Context, packageName: String): Boolean {
        val prefs = get(context)
        if (!prefs.getBoolean(KEY_ENABLED, false)) return false
        val blocked = prefs.getStringSet(KEY_BLOCKED_PACKAGES, emptySet()) ?: return false
        return packageName in blocked
    }
}
