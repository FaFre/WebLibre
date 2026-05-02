/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.flutter_mozilla_components.gatekeeper

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat

/**
 * Handles notification action buttons on blocked-intent notifications.
 *
 * "Allow once" re-fires the original blocked intent to [IntentReceiverActivity]
 * with a one-shot approval marker so the already-approved launch bypasses both
 * the native and Flutter gatekeepers.
 *
 * "Always allow" additionally writes a pending decision to
 * [IntentGatekeeperPreferences] so that Flutter can persist the policy change
 * before the next gatekeeper decision, even if the app process is already up.
 */
class GatekeeperNotificationActionReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "GatekeeperActionReceiver"

        const val ACTION_ALLOW_ONCE = "eu.weblibre.gecko.gatekeeper.ALLOW_ONCE"
        const val ACTION_ALWAYS_ALLOW = "eu.weblibre.gecko.gatekeeper.ALWAYS_ALLOW"

        const val EXTRA_PACKAGE_NAME = "gatekeeper_package"
        const val EXTRA_BLOCKED_INTENT = "gatekeeper_blocked_intent"
        const val EXTRA_NOTIFICATION_ID = "gatekeeper_notification_id"
        const val EXTRA_NOTIFICATION_APPROVAL_TOKEN = "eu.weblibre.gatekeeper.notification_approval_token"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: return
        val blockedIntent = getBlockedIntent(intent)
        cancelNotification(context, intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1))

        Log.d(TAG, "action=${intent.action} package=$packageName hasIntent=${blockedIntent != null}")

        when (intent.action) {
            ACTION_ALLOW_ONCE -> {
                blockedIntent?.let {
                    openIntent(
                        context = context,
                        blockedIntent = it,
                        approvalToken = IntentGatekeeperPreferences.createNotificationApproval(
                            context,
                        ),
                    )
                }
            }
            ACTION_ALWAYS_ALLOW -> {
                IntentGatekeeperPreferences.addPendingAlwaysAllow(context, packageName)
                blockedIntent?.let {
                    openIntent(
                        context = context,
                        blockedIntent = it,
                        approvalToken = IntentGatekeeperPreferences.createNotificationApproval(
                            context,
                            alwaysAllowPackage = packageName,
                        ),
                    )
                }
            }
        }
    }

    private fun cancelNotification(context: Context, notificationId: Int) {
        if (notificationId == -1) return

        ContextCompat.getSystemService(context, NotificationManager::class.java)
            ?.cancel(notificationId)
    }

    private fun getBlockedIntent(intent: Intent): Intent? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(EXTRA_BLOCKED_INTENT, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_BLOCKED_INTENT)
        }
    }

    private fun openIntent(
        context: Context,
        blockedIntent: Intent,
        approvalToken: String,
    ) {
        try {
            val relaunchIntent = Intent(blockedIntent).apply {
                setClassName(
                    context.packageName,
                    "eu.weblibre.flutter_mozilla_components.activities.IntentReceiverActivity",
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra(EXTRA_NOTIFICATION_APPROVAL_TOKEN, approvalToken)
            }
            context.startActivity(relaunchIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to replay blocked intent after gatekeeper action", e)
        }
    }
}
