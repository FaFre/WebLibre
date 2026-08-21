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
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
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

        // Asked before anything is settled. WorkManager jobs outlive the profile
        // they were queued for — a switch, a restore, simply a long-dormant job —
        // and committing in order to discover the job is for someone else means a
        // push at three in the morning silently answers the profile question the
        // user was going to be asked at breakfast. The peek rules the work out
        // without deciding anything.
        //
        // Null is "not knowable yet", not "no": maintenance, a selection in
        // flight and a restart all withhold an answer, and none of them is a
        // reason to drop a queued message.
        val candidate = StartupArbiter.peekProfileFolder() ?: return Result.retry()
        // Keep the durable record for recovery when this profile becomes active again.
        if (candidate != queuedProfile) return Result.success()

        // Only now, having established the work belongs here. Resolved *before*
        // the delivery lock: Kotlin's Mutex is not reentrant, and commitment
        // reaches code that may take the profile lock itself; doing this inside
        // `withProfileLock` is how the nested-acquire deadlock gets in.
        val activeProfile =
            runCatching { ActiveProfile.resolveOrCommitContext(applicationContext) }.getOrNull()
                ?: return Result.retry()

        // The candidate was a prediction. A picker or a trusted launch can have
        // answered differently in between, and the commitment is what is binding.
        if (activeProfile.relativePath != queuedProfile) return Result.success()

        return ActiveProfile.withProfileLock profile@{

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
