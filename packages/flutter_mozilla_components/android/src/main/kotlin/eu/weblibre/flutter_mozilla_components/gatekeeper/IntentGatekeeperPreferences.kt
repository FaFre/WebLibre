/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.flutter_mozilla_components.gatekeeper

import android.content.Context
import android.content.SharedPreferences
import java.util.UUID

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
    const val KEY_PENDING_ALWAYS_ALLOW = "pending_always_allow"
    private const val KEY_NOTIFICATION_APPROVAL_TOKENS = "notification_approval_tokens"
    private const val KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX = "notification_approval_package_"

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

    /**
     * Records that the user tapped "Always allow" for [packageName] via a
     * notification action. Also removes [packageName] from the blocked set so
     * future native intents pass through immediately, without waiting for
     * Flutter to start and consume the pending decision.
     */
    fun addPendingAlwaysAllow(context: Context, packageName: String) {
        val prefs = get(context)
        val pending = prefs.getStringSet(KEY_PENDING_ALWAYS_ALLOW, emptySet())?.toMutableSet() ?: mutableSetOf()
        val blocked = prefs.getStringSet(KEY_BLOCKED_PACKAGES, emptySet())?.toMutableSet() ?: mutableSetOf()
        pending.add(packageName)
        blocked.remove(packageName)
        prefs.edit()
            .putStringSet(KEY_PENDING_ALWAYS_ALLOW, pending)
            .putStringSet(KEY_BLOCKED_PACKAGES, blocked)
            .apply()
    }

    fun createNotificationApproval(
        context: Context,
        alwaysAllowPackage: String? = null,
    ): String {
        val prefs = get(context)
        val tokens =
            prefs.getStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, emptySet())
                ?.toMutableSet()
                ?: mutableSetOf()
        val token = UUID.randomUUID().toString()
        tokens.add(token)

        prefs.edit()
            .putStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, tokens)
            .apply {
                if (alwaysAllowPackage != null) {
                    putString(
                        "$KEY_NOTIFICATION_APPROVAL_PACKAGE_PREFIX$token",
                        alwaysAllowPackage,
                    )
                }
            }
            .apply()

        return token
    }

    fun hasNotificationApproval(context: Context, token: String): Boolean {
        val prefs = get(context)
        val tokens = prefs.getStringSet(KEY_NOTIFICATION_APPROVAL_TOKENS, emptySet()) ?: return false
        return token in tokens
    }

}
