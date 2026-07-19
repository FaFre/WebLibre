/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.content.Intent
import android.util.Log
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileContext
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.Executors
import kotlinx.coroutines.Job
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import org.ironfoxoss.unifiedpush.PushError
import org.unifiedpush.android.connector.FailedReason
import org.unifiedpush.android.connector.MessagingReceiver
import org.unifiedpush.android.connector.data.PushEndpoint
import org.unifiedpush.android.connector.data.PushMessage

class UnifiedPushReceiver : MessagingReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val token = runCatching { intent.getStringExtra(EXTRA_TOKEN) }.getOrNull()
        if (action !in SUPPORTED_ACTIONS || token.isNullOrBlank()) {
            Log.w(TAG, "Ignoring invalid UnifiedPush broadcast")
            return
        }

        val pendingResult = goAsync()
        synchronized(submissionLock) {
            executor.execute {
                try {
                    val profileContext = ActiveProfile.resolveContext(context.applicationContext)
                    if (profileContext == null) {
                        Log.e(TAG, "UnifiedPush broadcast has no active profile")
                        return@execute
                    }
                    currentToken.set(token)
                    currentMessageId.set(runCatching { intent.getStringExtra(EXTRA_MESSAGE_ID) }.getOrNull())
                    super.onReceive(profileContext, intent)
                } catch (error: Throwable) {
                    // An exception from onMessage deliberately prevents the connector from ACKing.
                    Log.e(TAG, "UnifiedPush broadcast processing failed", error)
                } finally {
                    currentToken.remove()
                    currentMessageId.remove()
                    pendingResult.finish()
                }
            }
        }
    }

    override fun onMessage(context: Context, message: PushMessage, instance: String) {
        check(message.decrypted) { "Refusing to ACK an undecrypted push message" }
        val profileContext = context as? ProfileContext
            ?: error("UnifiedPush message did not use a profile context")
        val id = durableMessageId(instance, checkNotNull(currentToken.get()), currentMessageId.get())
        val stored = PushMessageStore(profileContext).persist(instance, message.content, id)
        // MessagingReceiver sends its connector ACK only after this callback returns.
        try {
            PushMessageScheduler.enqueue(profileContext, stored.id)
        } catch (error: Throwable) {
            PushMessageScheduler.recoverLater(profileContext)
            throw error
        }
    }

    override fun onNewEndpoint(context: Context, endpoint: PushEndpoint, instance: String) {
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.onNewEndpoint(instance, endpoint) }
            push.emitStatusChanged()
            return
        }
        if (PushProfileState.updateEndpoint(context, instance, endpoint)) {
            Log.i(TAG, "Persisted endpoint for cold profile callback")
        }
    }

    override fun onRegistrationFailed(context: Context, reason: FailedReason, instance: String) {
        val error = reason.toPushError()
        Log.w(TAG, "Push registration failed: ${error.message}")
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.recordRegistrationError(instance, error) }
            push.emitStatusChanged()
        } else {
            PushProfileState.recordError(
                context,
                instance,
                PushProfileState.errorType(error),
                error.message,
            )
        }
    }

    override fun onTempUnavailable(context: Context, instance: String) {
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.recordTemporaryUnavailable(instance) }
            push.emitStatusChanged()
        } else {
            PushProfileState.recordTemporaryUnavailable(context, instance)
        }
    }

    override fun onUnregistered(context: Context, instance: String) {
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.onUnregistered(instance) }
            push.emitStatusChanged()
        } else {
            PushProfileState.removeEndpoint(context, instance)
        }
    }

    private fun FailedReason.toPushError(): PushError = when (this) {
        FailedReason.NETWORK -> PushError.Network("Push service needs network to register")
        FailedReason.INTERNAL_ERROR -> PushError.ServiceUnavailable("Unknown error")
        FailedReason.ACTION_REQUIRED ->
            PushError.ServiceUnavailable("Push service waits for a user action")
        FailedReason.VAPID_REQUIRED -> PushError.Registration("Push service requires VAPID")
    }

    companion object {
        private const val TAG = "UnifiedPushReceiver"
        private const val EXTRA_TOKEN = "token"
        private const val EXTRA_MESSAGE_ID = "id"
        private val SUPPORTED_ACTIONS = setOf(
            "org.unifiedpush.android.connector.MESSAGE",
            "org.unifiedpush.android.connector.UNREGISTERED",
            "org.unifiedpush.android.connector.NEW_ENDPOINT",
            "org.unifiedpush.android.connector.REGISTRATION_FAILED",
            "org.unifiedpush.android.connector.TEMP_UNAVAILABLE",
        )
        private val executor = Executors.newSingleThreadExecutor()
        private val submissionLock = Any()
        private val currentToken = ThreadLocal<String?>()
        private val currentMessageId = ThreadLocal<String?>()

        internal fun durableMessageId(
            scope: String,
            connectorToken: String,
            connectorId: String?,
        ): String {
            if (connectorId == null) return UUID.randomUUID().toString()
            return MessageDigest.getInstance("SHA-256")
                .digest("$scope\u0000$connectorToken\u0000$connectorId".toByteArray())
                .joinToString("") { "%02x".format(it) }
        }

        internal suspend fun <T> runExclusive(block: suspend () -> T): T =
            suspendCancellableCoroutine { continuation ->
                synchronized(submissionLock) {
                    val operationJob = Job(continuation.context[Job])
                    val future = executor.submit {
                        val result = runCatching { runBlocking(operationJob) { block() } }
                        operationJob.complete()
                        if (continuation.isActive) continuation.resumeWith(result)
                    }
                    continuation.invokeOnCancellation {
                        operationJob.cancel()
                        future.cancel(true)
                    }
                }
            }
    }
}
