/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.flutter_mozilla_components.gatekeeper

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import eu.weblibre.flutter_mozilla_components.R

/**
 * Posts an actionable heads-up notification when an intent is blocked by the
 * native gatekeeper. The notification shows "Allow once" and "Always allow"
 * action buttons, and auto-dismisses after [TIMEOUT_MS] milliseconds.
 */
object IntentBlockNotifier {
    private const val CHANNEL_ID = "intent_gatekeeper_channel_v2"
    private const val CHANNEL_NAME = "Blocked app launches"
    private const val CHANNEL_DESC = "Shown when another app is prevented from opening WebLibre, with options to allow."

    private const val TIMEOUT_MS = 8_000L

    fun notifyBlocked(context: Context, packageName: String, blockedIntent: Intent) {
        val appCtx = context.applicationContext
        ensureChannel(appCtx)

        val label = resolveAppLabel(appCtx, packageName) ?: packageName
        val notificationId = (System.currentTimeMillis() and 0x7FFFFFFF).toInt()

        val builder = NotificationCompat.Builder(appCtx, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("Blocked app launch")
            .setContentText("Prevented $label from opening WebLibre.")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("Prevented $label from opening WebLibre.")
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setSilent(true)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setTimeoutAfter(TIMEOUT_MS)

        builder.addAction(
            0,
            "Always allow",
            buildActionIntent(
                context = appCtx,
                action = GatekeeperNotificationActionReceiver.ACTION_ALWAYS_ALLOW,
                packageName = packageName,
                blockedIntent = blockedIntent,
                notificationId = notificationId,
                requestCode = notificationId + 2,
            ),
        )

        builder.addAction(
            0,
            "Allow once",
            buildActionIntent(
                context = appCtx,
                action = GatekeeperNotificationActionReceiver.ACTION_ALLOW_ONCE,
                packageName = packageName,
                blockedIntent = blockedIntent,
                notificationId = notificationId,
                requestCode = notificationId + 1,
            ),
        )

        val manager = ContextCompat.getSystemService(appCtx, NotificationManager::class.java)
            ?: return
        manager.notify(notificationId, builder.build())
    }

    private fun buildActionIntent(
        context: Context,
        action: String,
        packageName: String,
        blockedIntent: Intent,
        notificationId: Int,
        requestCode: Int,
    ): PendingIntent {
        val intent = Intent(action).apply {
            setClass(context, GatekeeperNotificationActionReceiver::class.java)
            putExtra(GatekeeperNotificationActionReceiver.EXTRA_PACKAGE_NAME, packageName)
            putExtra(GatekeeperNotificationActionReceiver.EXTRA_NOTIFICATION_ID, notificationId)
            putExtra(
                GatekeeperNotificationActionReceiver.EXTRA_BLOCKED_INTENT,
                Intent(blockedIntent),
            )
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(context, requestCode, intent, flags)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = ContextCompat.getSystemService(context, NotificationManager::class.java)
            ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = CHANNEL_DESC
            setShowBadge(false)
            enableLights(false)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun resolveAppLabel(context: Context, packageName: String): String? {
        return try {
            val pm = context.packageManager
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(
                    packageName,
                    PackageManager.ApplicationInfoFlags.of(0),
                )
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
