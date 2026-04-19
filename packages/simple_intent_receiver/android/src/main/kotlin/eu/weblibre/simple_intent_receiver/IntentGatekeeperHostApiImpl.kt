/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.simple_intent_receiver

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import eu.weblibre.simple_intent_receiver.pigeons.IntentGatekeeperHostApi

/**
 * Persists the Flutter-side gatekeeper policy to a shared-prefs file that
 * [eu.weblibre.flutter_mozilla_components.activities.IntentReceiverActivity]
 * reads on each incoming intent.
 *
 * The prefs file name MUST match
 * [eu.weblibre.flutter_mozilla_components.gatekeeper.IntentGatekeeperPreferences.PREFS_NAME].
 */
class IntentGatekeeperHostApiImpl(private val context: Context) : IntentGatekeeperHostApi {
    companion object {
        private const val PREFS_NAME = "weblibre_intent_gatekeeper"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_BLOCKED_PACKAGES = "blocked_packages"
    }

    override fun setConfig(enabled: Boolean, blockedPackages: List<String>) {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY_ENABLED, enabled)
            .putStringSet(KEY_BLOCKED_PACKAGES, blockedPackages.toSet())
            .apply()
    }

    override fun resolvePackageLabel(packageName: String): String? {
        return try {
            val pm = context.applicationContext.packageManager
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(packageName, 0)
            }
            pm.getApplicationLabel(info).toString()
        } catch (_: PackageManager.NameNotFoundException) {
            null
        } catch (_: Exception) {
            null
        }
    }
}
