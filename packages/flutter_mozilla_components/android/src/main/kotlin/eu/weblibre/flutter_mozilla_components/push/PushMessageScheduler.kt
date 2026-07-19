/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.util.Log
import androidx.work.BackoffPolicy
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import eu.weblibre.flutter_mozilla_components.ProfileContext
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import mozilla.components.support.ktx.android.content.runOnlyInMainProcess

object PushMessageScheduler {
    fun enqueue(context: ProfileContext, messageId: String) {
        val request = OneTimeWorkRequestBuilder<PushMessageWorker>()
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                MIN_BACKOFF_SECONDS,
                TimeUnit.SECONDS,
            )
            .setInputData(
                Data.Builder()
                    .putString(PushMessageWorker.KEY_PROFILE_PATH, context.relativePath)
                    .putString(PushMessageWorker.KEY_MESSAGE_ID, messageId)
                    .build(),
            )
            .build()
        val operation = WorkManager.getInstance(context)
            .enqueueUniqueWork(workName(context.relativePath, messageId), ExistingWorkPolicy.KEEP, request)
        operation.result.addListener(
            {
                runCatching { operation.result.get() }.onFailure { error ->
                    Log.e(TAG, "Unable to enqueue push message $messageId", error)
                    recoverLater(context)
                }
            },
            recoveryExecutor,
        )
    }

    fun recover(context: ProfileContext): Boolean {
        val store = PushMessageStore(context)
        return store.ids().map { messageId ->
            runCatching { enqueue(context, messageId) }
                .onFailure { error ->
                    Log.e(TAG, "Unable to recover queued push message $messageId", error)
                }
                .isSuccess
        }.all { it }
    }

    fun recoverLater(context: ProfileContext) {
        context.runOnlyInMainProcess {
            if (!recoveringProfiles.add(context.relativePath)) return@runOnlyInMainProcess
            scheduleRecovery(context, 0)
        }
    }

    private fun scheduleRecovery(context: ProfileContext, delaySeconds: Long) {
        recoveryExecutor.schedule(
            {
                val recovered = runCatching { recover(context) }
                    .onFailure { error ->
                        Log.e(TAG, "Queued push recovery failed for ${context.relativePath}", error)
                    }
                    .getOrDefault(false)
                if (recovered) {
                    recoveringProfiles.remove(context.relativePath)
                } else {
                    scheduleRecovery(context, RECOVERY_RETRY_SECONDS)
                }
            },
            delaySeconds,
            TimeUnit.SECONDS,
        )
    }

    private fun workName(profilePath: String, messageId: String): String =
        "push-message-$profilePath-$messageId"

    private const val MIN_BACKOFF_SECONDS = 10L
    private const val RECOVERY_RETRY_SECONDS = 30L
    private const val TAG = "PushMessageScheduler"
    private val recoveringProfiles = ConcurrentHashMap.newKeySet<String>()
    private val recoveryExecutor = Executors.newSingleThreadScheduledExecutor { runnable ->
        Thread(runnable, "PushMessageRecovery").apply { isDaemon = true }
    }
}
