/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PushMessageWorker(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {
    override suspend fun getForegroundInfo(): ForegroundInfo {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            applicationContext.getSystemService(NotificationManager::class.java)
                .createNotificationChannel(
                    NotificationChannel(
                        FOREGROUND_CHANNEL_ID,
                        "Web notification delivery",
                        NotificationManager.IMPORTANCE_LOW,
                    ).apply {
                        description = "Keeps web notification delivery active"
                        setShowBadge(false)
                    },
                )
        }

        val appLabel = applicationContext.applicationInfo
            .loadLabel(applicationContext.packageManager)
        val notification = NotificationCompat.Builder(applicationContext, FOREGROUND_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_sync_noanim)
            .setContentTitle(appLabel)
            .setContentText("Delivering web notification")
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setLocalOnly(true)
            .setOngoing(true)
            .setSilent(true)
            .setShowWhen(false)
            .build()
        val notificationId = (id.hashCode() and Int.MAX_VALUE).coerceAtLeast(1)
        return ForegroundInfo(notificationId, notification)
    }

    override suspend fun doWork(): Result {
        val queuedProfile = inputData.getString(KEY_PROFILE_PATH) ?: return Result.failure()
        val messageId = inputData.getString(KEY_MESSAGE_ID) ?: return Result.failure()
        return ActiveProfile.withProfileLock profile@{
            val activeProfile = runCatching { ActiveProfile.resolveContext(applicationContext) }.getOrNull()
                ?: return@profile Result.retry()
            // Keep the durable record for recovery when this profile becomes active again.
            if (activeProfile.relativePath != queuedProfile) return@profile Result.success()

            val existing = GlobalComponents.components
            if (existing != null && existing.profileApplicationContext.relativePath != queuedProfile) {
                return@profile Result.success()
            }
            val initialized = existing != null || withContext(Dispatchers.Main.immediate) {
                GlobalComponents.ensureExternalComponents(applicationContext)
            }
            if (!initialized) return@profile Result.retry()

            val push = GlobalComponents.pushForProfile(activeProfile) ?: return@profile Result.retry()
            val store = PushMessageStore(activeProfile)
            val message = try {
                store.get(messageId)
            } catch (error: CorruptPushMessageException) {
                Log.e(TAG, "Discarding corrupt queued push message $messageId", error)
                if (!store.complete(messageId)) {
                    Log.e(TAG, "Unable to mark corrupt push message $messageId as discarded")
                }
                return@profile Result.failure()
            } ?: return@profile Result.success()

            try {
                push.deliverMessage(message.scope, message.payload)
                if (!store.complete(message.id)) {
                    Log.e(TAG, "Unable to mark delivered push message ${message.id} complete")
                    return@profile Result.retry()
                }
                Result.success()
            } catch (error: CancellationException) {
                throw error
            } catch (error: Throwable) {
                Log.w(
                    TAG,
                    "Push delivery attempt ${runAttemptCount + 1} failed for $messageId",
                    error,
                )
                Result.retry()
            }
        }
    }

    companion object {
        const val KEY_PROFILE_PATH = "profilePath"
        const val KEY_MESSAGE_ID = "messageId"
        private const val FOREGROUND_CHANNEL_ID = "weblibre_push_delivery"
        private const val TAG = "PushMessageWorker"
    }
}
