/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 */
package eu.weblibre.flutter_mozilla_components.gatekeeper

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import eu.weblibre.flutter_mozilla_components.R

/**
 * Posts a purely informational notification when an intent is blocked by the
 * gatekeeper. The notification has no actions and no content intent.
 */
object IntentBlockNotifier {
    private const val CHANNEL_ID = "intent_gatekeeper_channel"
    private const val CHANNEL_NAME = "Blocked app launches"
    private const val CHANNEL_DESC = "Informs you when another app is prevented from opening WebLibre."

    fun notifyBlocked(context: Context, packageName: String) {
        val appCtx = context.applicationContext
        ensureChannel(appCtx)

        val label = resolveAppLabel(appCtx, packageName) ?: packageName
        val notificationId = (System.currentTimeMillis() and 0x7FFFFFFF).toInt()

        val notification: Notification = NotificationCompat.Builder(appCtx, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("Blocked app launch")
            .setContentText("Prevented $label from opening WebLibre.")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("Prevented $label from opening WebLibre.")
            )
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setSilent(true)
            .setAutoCancel(true)
            .setShowWhen(true)
            .build()

        val manager = ContextCompat.getSystemService(appCtx, NotificationManager::class.java)
            ?: return
        manager.notify(notificationId, notification)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = ContextCompat.getSystemService(context, NotificationManager::class.java)
            ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = CHANNEL_DESC
            setShowBadge(false)
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
