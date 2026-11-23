/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.rootApplicationContext
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
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

        // Stamped before goAsync: the broadcast's deadline counts from here, so
        // time spent queued behind other work on the executor counts too.
        val receivedAt = SystemClock.elapsedRealtime()
        val pendingResult = goAsync()
        synchronized(submissionLock) {
            executor.execute {
                try {
                    val application = context.applicationContext

                    // Checked before anything commits. A broadcast for a profile
                    // this process is not going to be is not a reason to bind the
                    // process at all, and the connector would drop it anyway — its
                    // token lookup runs against one profile's database.
                    if (!mayHandle(application, token)) return@execute

                    // May be the first thing running in this process, so it is
                    // allowed to commit the *candidate* — never a profile of its
                    // own choosing. A null means the process refuses to bind right
                    // now (selecting, under maintenance, restarting): we return
                    // without calling super, so the connector never ACKs and the
                    // message stays deliverable to whoever owns it.
                    val profileContext = ActiveProfile.resolveOrCommitContext(application)
                    if (profileContext == null) {
                        Log.w(TAG, "UnifiedPush broadcast arrived with no committed profile")
                        return@execute
                    }

                    // Re-checked against what actually got committed, which is not
                    // necessarily the candidate that was compared above.
                    val owner = runCatching {
                        ownershipStore(application).ownerOf(token)
                    }.getOrNull()
                    if (owner != null && owner.profileId != profileContext.profileId) {
                        Log.i(TAG, "Leaving a push for ${owner.profileId} unacknowledged")
                        return@execute
                    }

                    // Nothing may open the connector or decrypt into the queue
                    // until the one-time transport migration is done: a tree an
                    // older build cloned may hold another profile's keys. It runs
                    // on its own thread; this waits only what is left of the
                    // broadcast's budget, and declines without an ACK after that.
                    val remaining = BROADCAST_BUDGET_MS - (SystemClock.elapsedRealtime() - receivedAt)
                    if (!PushTransportMigration.awaitOpen(StartupPaths(application), remaining)) {
                        Log.w(TAG, "Push transport not verified yet; leaving the broadcast unacknowledged")
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
                    logLatency(action, receivedAt)
                }
            }
        }
    }

    /** Receipt to `finish()`, for the device runs that check the broadcast deadline. */
    private fun logLatency(action: String?, receivedAt: Long) {
        val elapsed = SystemClock.elapsedRealtime() - receivedAt
        if (elapsed >= SLOW_BROADCAST_MS) {
            Log.w(TAG, "Broadcast ${action?.substringAfterLast('.')} finished ${elapsed} ms after receipt")
        } else {
            Log.d(TAG, "Broadcast ${action?.substringAfterLast('.')} finished ${elapsed} ms after receipt")
        }
    }

    override fun onMessage(context: Context, message: PushMessage, instance: String) {
        check(message.decrypted) { "Refusing to ACK an undecrypted push message" }
        val profileContext = context as? ProfileContext
            ?: error("UnifiedPush message did not use a profile context")
        rememberOwnership(profileContext, instance)
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
        rememberOwnership(context, instance)
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.onNewEndpoint(instance, endpoint) }
            push.emitStatusChanged()
            return
        }
        // Without Push nothing can tell Gecko, and a row written here would make
        // the next start's renewal find the same values and stay quiet: the site
        // would keep the old endpoint. So the row is left alone. The connector
        // still ACKs, and the renewal at the next start asks the distributor
        // again and passes the change on.
        if (endpoint.pubKeySet != null) PushProfileState.clearError(context, instance)
        Log.i(TAG, "Endpoint for a profile without push running; the next start renews it")
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
        // The token is dead, so the mapping is too. Keeping it would make the
        // receiver decline a *future* token that happened to reuse the string.
        currentToken.get()?.let { token ->
            runCatching { ownershipStore(context).forget(token) }
        }
        val push = GlobalComponents.pushForProfile(context)
        if (push != null) {
            runBlocking { push.onUnregistered(instance) }
            push.emitStatusChanged()
        } else {
            PushProfileState.removeEndpoint(context, instance)
        }
    }

    /**
     * Whether this process should even try to handle a broadcast for [token].
     *
     * Only ever answers "no" from positive knowledge: an unknown token falls
     * through, because the map is a cache and its absence must cost a wake-up
     * rather than a message.
     */
    private fun mayHandle(application: Context, token: String): Boolean {
        val owner = runCatching { ownershipStore(application).ownerOf(token) }.getOrNull()
            ?: return true

        // The committed profile, or the one this process *would* bind to: the
        // arbiter's in-memory candidate, which a restart target has already
        // replaced while `current_profile` still names the old process's profile.
        // Committing just to discover the message belongs elsewhere would spend
        // the process's one identity on nothing. Null is "not knowable yet"
        // (maintenance, a requested picker, a restart): the commit below decides.
        val serving = runCatching { StartupArbiter.peekProfileId() }.getOrNull() ?: return true
        if (owner.profileId == serving) return true

        Log.i(TAG, "Push for ${owner.profileId} arrived in a process for $serving; declining")
        return false
    }

    /**
     * Records the token/profile pair after the connector has proved it.
     *
     * A callback only fires when the connector found the token in the database of
     * the profile whose context it was given, so this is the one moment the
     * mapping is known rather than assumed.
     */
    private fun rememberOwnership(context: Context, instance: String) {
        val profileId = (context as? ProfileContext)?.profileId ?: return
        val token = currentToken.get() ?: return

        runCatching { ownershipStore(context).record(token, profileId, instance) }
            .onFailure { Log.w(TAG, "Could not record push ownership", it) }
    }

    /**
     * The ownership map, always rooted at the *global* files directory.
     *
     * [ProfileContext.getApplicationContext] returns the profile context itself
     * and its `filesDir` points inside the profile, so handing one to
     * [StartupPaths] would file the global map under whichever profile happened to
     * be in hand — where no uncommitted process could ever read it.
     */
    private fun ownershipStore(context: Context) = PushOwnershipStore(
        StartupPaths(context.rootApplicationContext),
    )

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
        // What is left of a goAsync() receiver's roughly 10 s after this, for the
        // transport check; the rest stays for the connector's own work.
        private const val BROADCAST_BUDGET_MS = 5000L
        private const val SLOW_BROADCAST_MS = 2000L
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
                .toHexString()
        }

        /**
         * Queues [block] on the executor and returns at once. For connector calls
         * made from a thread the executor may be waiting for, where [runExclusive]
         * would deadlock.
         */
        internal fun submitExclusive(block: () -> Unit) {
            synchronized(submissionLock) {
                executor.execute {
                    try {
                        block()
                    } catch (error: Throwable) {
                        Log.w(TAG, "A queued connector call failed", error)
                    }
                }
            }
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
