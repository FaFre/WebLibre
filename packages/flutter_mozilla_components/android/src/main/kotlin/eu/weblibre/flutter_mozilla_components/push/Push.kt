/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.lifecycle.ContextPush
import eu.weblibre.flutter_mozilla_components.lifecycle.PushOutbox
import eu.weblibre.flutter_mozilla_components.rootApplicationContext
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExecutorCoroutineDispatcher
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.asCoroutineDispatcher
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.withContext
import org.ironfoxoss.unifiedpush.DefaultDistributorManager
import org.ironfoxoss.unifiedpush.PushError
import org.ironfoxoss.unifiedpush.SubscriptionsDB
import org.ironfoxoss.unifiedpush.UnifiedPushFeature
import org.ironfoxoss.unifiedpush.UnifiedPushNotification
import org.unifiedpush.android.connector.UnifiedPush
import org.unifiedpush.android.connector.data.PushEndpoint
import org.mozilla.gecko.GeckoThread
import mozilla.components.support.ktx.kotlin.getOrigin

private const val START_WAITING = 0
private const val STARTED = 1
private const val START_TIMED_OUT = 2

/**
 * Bounds only the wait for [operation] to call its start gate. Once started,
 * the operation is allowed to finish so a completed side effect cannot be
 * reported as a timeout.
 */
internal suspend fun runWithStartTimeout(
    timeoutMillis: Long,
    operation: suspend (tryStart: () -> Boolean) -> Unit,
): Boolean = coroutineScope {
    require(timeoutMillis > 0) { "Timeout must be positive" }

    val state = AtomicInteger(START_WAITING)
    val started = CompletableDeferred<Unit>()
    val operationJob = async {
        operation {
            if (!state.compareAndSet(START_WAITING, STARTED)) {
                false
            } else {
                started.complete(Unit)
                true
            }
        }
    }

    val startedBeforeTimeout = withTimeoutOrNull(timeoutMillis) {
        started.await()
        true
    } == true

    if (!startedBeforeTimeout && state.compareAndSet(START_WAITING, START_TIMED_OUT)) {
        operationJob.cancelAndJoin()
        false
    } else {
        operationJob.await()
        true
    }
}

/** Lifecycle state of the selected UnifiedPush distributor. */
enum class DistributorStatus {
    NONE_AVAILABLE,
    NOT_SELECTED,
    PENDING,
    READY,
    UNAVAILABLE,
}

data class DistributorInfo(val packageName: String, val label: String?)

data class PushStatusSnapshot(
    val status: DistributorStatus,
    val current: DistributorInfo?,
    val available: List<DistributorInfo>,
    val lastError: String?,
)

data class PushSubscriptionInfo(val scope: String, val hasEndpoint: Boolean)

/**
 * Profile-scoped UnifiedPush state and Gecko web-push integration.
 *
 * ## Threads
 *
 * Every connector call runs on the receiver's executor, between broadcasts and
 * never beside one ([UnifiedPushReceiver.runExclusive]): the connector's status
 * getters change its state too, and a handoff or an UNREGISTERED handled in the
 * middle of a registration would leave a REGISTER for a token it removed. Each
 * call is its own task, so no broadcast waits for more than one of them. The
 * receiver's executor may wait for this instance's dispatcher (its callbacks do),
 * so nothing here ever blocks the dispatcher on the executor: it suspends.
 */
class Push(
    private val components: Components,
) : AutoCloseable, ContextPush {
    private val initialized = AtomicBoolean(false)
    private val closed = AtomicBoolean(false)
    internal val isClosed: Boolean
        get() = closed.get()

    /** [initialize] ran: the engine's web push delegate is registered. */
    internal val isInitialized: Boolean
        get() = initialized.get()

    /**
     * This instance was closed before a delivery reached Gecko. In a process
     * that keeps its profile, a component rebuild (external to full) is what
     * closes it, and the instance that replaced it serves the same profile.
     */
    class ClosedException : IllegalStateException("Push is closed")
    private val dispatcher: ExecutorCoroutineDispatcher =
        Executors.newSingleThreadExecutor { runnable ->
            Thread(runnable, "WebLibrePush-${components.profileApplicationContext.relativePath.hashCode()}")
        }.asCoroutineDispatcher()
    private val eventScope = CoroutineScope(dispatcher + SupervisorJob())

    /**
     * Completes when this instance's start has settled; [started] says how.
     *
     * Gecko's delegate, the settings calls and the status wait for it, because
     * the start may first have to wait for the transport migration and clear the
     * endpoints a restore left. The receiver's callbacks never wait: the start
     * itself waits for the receiver's executor. They cannot run early either,
     * since a tree whose transport was replaced has no token to call back for.
     */
    private val startup = CompletableDeferred<Unit>()

    @Volatile
    private var started = false

    private val context: Context
        get() = components.profileApplicationContext

    private val prefs = PushProfileState.prefs(context)
    private val subscriptionsDb = SubscriptionsDB(context)
    private val distributors = DefaultDistributorManager()
    private val renewal = RegistrationRenewal(context, subscriptionsDb, distributors)
    private val privateCleanup = PrivateSubscriptionCleanup(context, subscriptionsDb, distributors)

    private val feature = UnifiedPushFeature(
        context = context,
        coroutineContext = dispatcher,
        db = subscriptionsDb,
        up = ExclusiveDistributorManager(distributors),
    )

    private val webPushEngineIntegration = WebPushEngineIntegration(
        engine = components.core.engine,
        pushFeature = feature,
        rowVersion = { scope ->
            withContext(dispatcher) { SubscriptionVersion.of(subscriptionsDb.getSubscription(scope, null)) }
        },
        whenReady = ::whenReady,
    )

    fun initialize() {
        check(!closed.get()) { "Push is closed" }
        if (!initialized.compareAndSet(false, true)) return

        components.core.store
        // Registered at once, as before: the delegate's requests wait for the
        // start below rather than being refused while it runs.
        webPushEngineIntegration.start()
        eventScope.launch { startUp() }
    }

    /**
     * Off the main thread, in order: the transport check, the endpoint reset,
     * the remembered distributor, then the outbox and the registrations.
     */
    private suspend fun startUp() {
        val open = try {
            transportOpen() && clearReplacedEndpoints()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Push could not verify its transport", e)
            false
        }
        if (!open) {
            Log.e(TAG, "Push stays off in this process; the next start tries again")
            finishStart(false)
            return
        }

        try {
            UnifiedPushReceiver.runExclusive { restoreRememberedDistributor() }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Could not restore the remembered distributor", e)
        }
        finishStart(true)

        // Before the outbox, which would hand their changes to Gecko. The
        // renewal skips what this leaves.
        removePrivateSubscriptions()

        // Subscription changes deferred while their container was frozen, for
        // the ones resumed since (also after a death mid-Resume, D25), and
        // changes a death kept from Gecko after their row was written.
        try {
            webPushEngineIntegration.drainOutbox()
        } catch (e: CancellationException) {
            // Closed meanwhile: stop, the next start drains it.
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Could not drain the push outbox", e)
        }

        registerAll()

        while (!PushMessageScheduler.recover(components.profileApplicationContext)) {
            delay(RECOVERY_RETRY_DELAY_MS)
        }
        notifyIfDistributorMissing()
    }

    /** Waits for the one-time transport migration, which runs on its own thread. */
    private suspend fun transportOpen(): Boolean = withContext(Dispatchers.IO) {
        PushTransportMigration.awaitOpen(
            StartupPaths(context.rootApplicationContext),
            STARTUP_TRANSPORT_TIMEOUT_MS,
        )
    }

    /**
     * A clone, a restore or the transport migration left subscription rows that
     * still carry the endpoints and keys of a transport this tree no longer has.
     * They go before Gecko, the settings or a registration can read them. The
     * scopes stay: the registrations below ask for new endpoints, and Gecko learns
     * each as a subscription change.
     */
    private suspend fun clearReplacedEndpoints(): Boolean = withContext(dispatcher) {
        val marker = PushTransportFiles.endpointResetMarker(components.profileApplicationContext)
        if (!marker.exists()) return@withContext true

        subscriptionsDb.listSubscriptions().forEach { subscriptionsDb.removeEndpoint(it.scope) }
        if (!marker.delete() && marker.exists()) {
            // Left behind, it would clear the new endpoints at the next start too.
            Log.e(TAG, "Could not remove the endpoint reset marker")
            return@withContext false
        }
        Log.i(TAG, "Cleared the endpoints of a replaced push transport")
        true
    }

    private fun finishStart(open: Boolean) {
        if (open) started = true
        startup.complete(Unit)
    }

    /** Whether push may be read, once its start has settled. */
    private suspend fun awaitStart(): Boolean {
        startup.await()
        return started && !closed.get()
    }

    /** [awaitStart] for a callback: runs [block] once the start settled, or at once. */
    private fun whenReady(block: (Boolean) -> Unit) {
        startup.invokeOnCompletion {
            try {
                block(started && !closed.get())
            } catch (error: Throwable) {
                Log.w(TAG, "A web push request failed", error)
            }
        }
    }

    private suspend fun requireStarted() {
        check(awaitStart()) { "Push could not start in this process" }
    }

    /** See [PrivateSubscriptionCleanup]; what it leaves, the next start tries again. */
    private suspend fun removePrivateSubscriptions() {
        try {
            withContext(dispatcher) { privateCleanup.run(closed::get) }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Could not remove the push subscriptions of private browsing", e)
        }
    }

    /** See [RegistrationRenewal]. */
    private suspend fun registerAll() {
        try {
            renewal.run(closed::get)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Could not renew the push registrations", e)
        }
    }

    suspend fun status(): PushStatusSnapshot {
        if (!awaitStart()) {
            // Without the connector, which was never opened: what is installed,
            // what this profile chose, and why nothing more is known.
            return snapshot(
                installed = UnifiedPush.getDistributors(context),
                acknowledged = null,
                saved = null,
                lastError = START_FAILED_ERROR,
            )
        }

        // The saved and acknowledged getters drop uninstalled distributors and
        // may broadcast UNREGISTERED: they change connector state, so they take
        // the receiver's turn like every other connector call.
        val (installed, acknowledged, saved) = UnifiedPushReceiver.runExclusive {
            Triple(
                UnifiedPush.getDistributors(context),
                UnifiedPush.getAckDistributor(context),
                UnifiedPush.getSavedDistributor(context),
            )
        }
        return snapshot(installed, acknowledged, saved, PushProfileState.lastError(context))
    }

    private fun snapshot(
        installed: List<String>,
        acknowledged: String?,
        saved: String?,
        lastError: String?,
    ): PushStatusSnapshot {
        val available = installed.map { it.toDistributorInfo() }
        val remembered = rememberedDistributor()
        val status = when {
            acknowledged != null -> DistributorStatus.READY
            saved != null -> DistributorStatus.PENDING
            remembered != null && available.none { it.packageName == remembered } ->
                DistributorStatus.UNAVAILABLE
            available.isEmpty() -> DistributorStatus.NONE_AVAILABLE
            else -> DistributorStatus.NOT_SELECTED
        }

        return PushStatusSnapshot(
            status = status,
            current = (acknowledged ?: saved ?: remembered)?.toDistributorInfo(),
            available = available,
            lastError = lastError,
        )
    }

    suspend fun setDistributor(packageName: String) {
        requireStarted()
        UnifiedPushReceiver.runExclusive {
            withContext(dispatcher) {
                check(!closed.get()) { "Push is closed" }
                require(UnifiedPush.getDistributors(context).contains(packageName)) {
                    "UnifiedPush distributor is not installed: $packageName"
                }

                val current = UnifiedPush.getSavedDistributor(context) ?: rememberedDistributor()
                if (current != null && current != packageName) {
                    removeTransportRegistrationsAndEndpoints()
                }
                UnifiedPush.saveDistributor(context, packageName)
                rememberDistributor(packageName)
                PushProfileState.clearError(context)
                cancelMissingDistributorNotification()
            }
        }
        registerAll()
    }

    suspend fun removeDistributor() {
        requireStarted()
        UnifiedPushReceiver.runExclusive {
            withContext(dispatcher) {
                check(!closed.get()) { "Push is closed" }
                removeTransportRegistrationsAndEndpoints()
                prefs.edit().remove(PushProfileState.KEY_SELECTED_DISTRIBUTOR).commit()
                PushProfileState.clearError(context)
                cancelMissingDistributorNotification()
            }
        }
    }

    suspend fun renewRegistration() {
        requireStarted()
        UnifiedPushReceiver.runExclusive {
            withContext(dispatcher) {
                check(!closed.get()) { "Push is closed" }
                restoreRememberedDistributor()
            }
        }
        registerAll()
    }

    suspend fun subscriptions(): List<PushSubscriptionInfo> {
        requireStarted()
        return withContext(dispatcher) {
            subscriptionsDb.listSubscriptions().map {
                PushSubscriptionInfo(scope = it.scope, hasEndpoint = it.endpoint != null)
            }
        }
    }

    /**
     * A NEW_ENDPOINT handled while this instance exists.
     *
     * When it changes the row, the new version goes into [PushOutbox] **before**
     * the feature writes it. The feature tells Gecko only 100 ms after its write,
     * so a death in between used to leave the new endpoint stored, Gecko
     * uninformed, and the next renewal with nothing to report. The entry is
     * cleared only by a handoff of this version. An unchanged endpoint records
     * nothing, and the feature does not notify for it.
     */
    suspend fun onNewEndpoint(scope: String, endpoint: PushEndpoint) = withContext(dispatcher) {
        val keys = endpoint.pubKeySet
        if (keys != null) {
            val stored = subscriptionsDb.getSubscription(scope, null)
            val incoming = SubscriptionVersion.of(endpoint.url, keys.pubKey, keys.auth)
            if (stored != null && SubscriptionVersion.of(stored) != incoming) {
                recordChange(scope, incoming)
            }
        }
        feature.onNewEndpoint(scope, endpoint)
        if (keys != null) PushProfileState.clearError(context, scope)
    }

    suspend fun invalidateEndpoint(scope: String) = withContext(dispatcher) {
        clearEndpoint(scope)
        PushProfileState.clearError(context, scope)
        webPushEngineIntegration.invalidateEndpoint(scope)
    }

    suspend fun onUnregistered(scope: String) = invalidateEndpoint(scope)

    suspend fun recordRegistrationError(scope: String, error: PushError) = withContext(dispatcher) {
        PushProfileState.recordError(
            context,
            scope,
            PushProfileState.errorType(error),
            error.message,
        )
    }

    suspend fun recordTemporaryUnavailable(scope: String) = withContext(dispatcher) {
        PushProfileState.recordTemporaryUnavailable(context, scope)
    }

    /** Throws [ClosedException] once this instance is closed and the message has not reached Gecko. */
    suspend fun deliverMessage(scope: String, payload: ByteArray) {
        // Not a headless session on the engine of a set already replaced.
        if (closed.get()) throw ClosedException()
        // Before any headless session is created: a frozen container's message
        // is consumed (5.8). The integration checks again on delivery.
        if (PushContextGate.consumeIfRestricted(scope)) return
        val external = GlobalComponents.isExternalMode
        val deliver: suspend () -> Unit = {
            withContext(Dispatchers.Main.immediate) {
                if (closed.get()) throw ClosedException()
                check(GeckoThread.isStateAtLeast(GeckoThread.State.RUNNING)) {
                    "Gecko is not running"
                }
                webPushEngineIntegration.deliverMessage(scope, payload)
            }
        }

        if (!external) {
            deliver()
            return
        }

        // Headless: the push message is decrypted and permitted, but GeckoView
        // will not run the service worker's push handler without a live browsing
        // context — with no open session the ServiceWorkerManager never dispatches
        // the event (opening a tab is what makes it fire). Create a throwaway
        // session for the duration of delivery so Gecko has a window to run the
        // worker in, then tear it down.
        val origin = runCatching { scope.getOrigin() }.getOrNull()
        val session = withContext(Dispatchers.Main.immediate) {
            components.core.engine.createSession().also { it.loadUrl("about:blank") }
        }
        try {
            // Give the browsing context time to come up before handing off the push.
            delay(HEADLESS_SESSION_WARMUP_MS)
            // The push handoff returns no completion signal, so keep this delivery
            // alive until the service worker actually posts its notification,
            // bounded by a timeout.
            components.core.webNotificationDrainCoordinator.drainWhileDelivering(
                origin = origin,
                timeoutMillis = HEADLESS_DELIVERY_DRAIN_TIMEOUT_MS,
                graceMillis = HEADLESS_DELIVERY_POST_GRACE_MS,
                deliver = deliver,
            )
        } finally {
            withContext(Dispatchers.Main.immediate) { session.close() }
        }
    }

    override suspend fun removeSubscriptions(contextId: String): Boolean {
        check(!closed.get()) { "Push is closed" }
        if (!awaitStart()) return false
        return withContext(dispatcher) {
            subscriptionsDb.listSubscriptions()
                .filter { PushContextGate.contextOf(it.scope) == contextId }
                .forEach { subscription ->
                    val removed = CompletableDeferred<Boolean>()
                    feature.unsubscribe(
                        scope = subscription.scope,
                        onUnsubscribeError = { removed.complete(false) },
                        onUnsubscribe = { removed.complete(it) },
                    )
                    if (withTimeoutOrNull(UNSUBSCRIBE_TIMEOUT_MS) { removed.await() } == true) {
                        // Gone with its subscription: nothing left to tell Gecko.
                        PushOutbox.removed(subscription.scope)
                    }
                }
            subscriptionsDb.listSubscriptions().none { PushContextGate.contextOf(it.scope) == contextId }
        }
    }

    override suspend fun contextsWithSubscriptions(): Set<String>? {
        if (closed.get() || !awaitStart()) return null
        return withContext(dispatcher) {
            subscriptionsDb.listSubscriptions().mapNotNullTo(mutableSetOf()) { PushContextGate.contextOf(it.scope) }
        }
    }

    override suspend fun drainOutbox(contextIds: Collection<String>?) {
        if (closed.get() || !initialized.get()) return
        if (!awaitStart()) return
        webPushEngineIntegration.drainOutbox(contextIds)
    }

    /**
     * Quiesce push ahead of a restart. Best-effort by design.
     *
     * The transport stays. The profile being left keeps its registrations, so
     * its endpoints stay valid while another profile is active, and its next
     * start renews them. Only the active profile receives: a broadcast for this
     * one in another profile's process is declined, unacknowledged. Choosing or
     * removing a distributor in the settings still unregisters.
     *
     * It writes no profile state either. Under the restart protocol the target
     * lives in the durable restart request and is applied by the *next* process,
     * so this process must never leave disk saying B while it is still serving A.
     *
     * The profile lock and the receiver's exclusivity are a drain: they wait for
     * a delivery or a distributor change already running, so it cannot straddle
     * the restart boundary. They do not stop a broadcast that arrives after them,
     * which still runs before the process exits; that is safe, because a message
     * is persisted before its ACK.
     */
    suspend fun suspendForRestart() {
        runCatching {
            ActiveProfile.withProfileLock {
                UnifiedPushReceiver.runExclusive { }
            }
        }.onFailure { error ->
            Log.w(TAG, "Failed to drain push before restart", error)
        }
    }

    fun emitStatusChanged() {
        if (closed.get() || GlobalComponents.pushEvents == null) return
        eventScope.launch {
            val snapshot = runCatching { status().toPigeon() }.getOrNull() ?: return@launch
            val sequence = EventSequence.next()
            withContext(kotlinx.coroutines.Dispatchers.Main) {
                GlobalComponents.pushEvents?.onPushStatusChanged(sequence, snapshot) { }
            }
        }
    }

    override fun close() {
        if (!beginClose()) return
        try {
            runBlocking { finishClose() }
        } finally {
            dispatcher.close()
        }
    }

    /** Mark closed immediately and drain profile resources without blocking the caller. */
    internal fun closeDeferred() {
        if (!beginClose()) return
        CoroutineScope(SupervisorJob() + Dispatchers.IO).launch {
            try {
                finishClose()
            } catch (error: Throwable) {
                Log.w(TAG, "Failed to finish deferred push cleanup", error)
            } finally {
                dispatcher.close()
            }
        }
    }

    private fun beginClose(): Boolean {
        if (!closed.compareAndSet(false, true)) return false
        eventScope.cancel()
        // Releases whatever still waits for a start that will not come.
        startup.complete(Unit)
        if (initialized.get()) {
            webPushEngineIntegration.close()
        }
        return true
    }

    private suspend fun finishClose() {
        if (initialized.get()) {
            val drained = CompletableDeferred<Unit>()
            feature.withCoroutine { drained.complete(Unit) }
            withTimeoutOrNull(FEATURE_DRAIN_TIMEOUT_MS) { drained.await() }
        }
        withContext(dispatcher) {
            subscriptionsDb.close()
        }
    }

    /** Connector calls: only on the receiver's executor ([UnifiedPushReceiver.runExclusive]). */
    private fun restoreRememberedDistributor() {
        if (UnifiedPush.getSavedDistributor(context) != null) return
        val remembered = rememberedDistributor() ?: return
        if (UnifiedPush.getDistributors(context).contains(remembered)) {
            UnifiedPush.saveDistributor(context, remembered)
        }
    }

    /** Connector calls: only on the receiver's executor ([UnifiedPushReceiver.runExclusive]). */
    private suspend fun removeTransportRegistrationsAndEndpoints() {
        UnifiedPush.removeDistributor(context)
        subscriptionsDb.listSubscriptions().forEach {
            clearEndpoint(it.scope)
            webPushEngineIntegration.invalidateEndpoint(it.scope)
        }
    }

    /** Empties [scope]'s row, recording the change first as [onNewEndpoint] does. */
    private fun clearEndpoint(scope: String) {
        if (subscriptionsDb.getSubscription(scope, null)?.endpoint != null) {
            recordChange(scope, SubscriptionVersion.NONE)
        }
        subscriptionsDb.removeEndpoint(scope)
    }

    private fun recordChange(scope: String, version: String) {
        if (!PushOutbox.record(scope, version)) {
            // As for a frozen context's deferral: the change still goes to Gecko
            // in this process, and only a death before that loses it.
            Log.w(TAG, "Could not record a subscription change before writing it")
        }
    }

    private fun rememberedDistributor(): String? =
        prefs.getString(PushProfileState.KEY_SELECTED_DISTRIBUTOR, null)

    private fun rememberDistributor(packageName: String) {
        prefs.edit().putString(PushProfileState.KEY_SELECTED_DISTRIBUTOR, packageName).commit()
    }

    private suspend fun notifyIfDistributorMissing() {
        if (status().status != DistributorStatus.UNAVAILABLE) return
        val notificationManager = NotificationManagerCompat.from(context)
        if (!notificationManager.areNotificationsEnabled()) return
        try {
            notificationManager.notify(
                UnifiedPushNotification.getNotificationId(context),
                UnifiedPushNotification.createMissingServiceNotification(context),
            )
        } catch (_: SecurityException) {
            // The settings status remains available when POST_NOTIFICATIONS is denied.
        }
    }

    private fun cancelMissingDistributorNotification() {
        NotificationManagerCompat.from(context)
            .cancel(UnifiedPushNotification.getNotificationId(context))
    }

    private fun String.toDistributorInfo(): DistributorInfo =
        DistributorInfo(packageName = this, label = resolveLabel(this))

    private fun resolveLabel(packageName: String): String? = try {
        val packageManager = context.packageManager
        packageManager.getApplicationInfo(packageName, 0).loadLabel(packageManager).toString()
    } catch (_: PackageManager.NameNotFoundException) {
        null
    }

    companion object {
        private const val TAG = "Push"
        private const val FEATURE_DRAIN_TIMEOUT_MS = 5000L
        // Upper bound on how long a headless delivery keeps the worker alive
        // waiting for the service worker to post its notification.
        private const val HEADLESS_DELIVERY_DRAIN_TIMEOUT_MS = 25000L
        // Extra time after onShowNotification fires so the delegate's async
        // notify can land before the process loses foreground priority.
        private const val HEADLESS_DELIVERY_POST_GRACE_MS = 1500L
        // Time for the throwaway delivery session's browsing context to come up
        // before the push is handed off.
        private const val HEADLESS_SESSION_WARMUP_MS = 1500L
        private const val RECOVERY_RETRY_DELAY_MS = 30000L
        private const val UNSUBSCRIBE_TIMEOUT_MS = 10000L
        // The migration deletes files; it should take milliseconds. Longer
        // means storage trouble, and push then stays off in this process.
        private const val STARTUP_TRANSPORT_TIMEOUT_MS = 30000L
        private const val START_FAILED_ERROR = "Push could not start; it will try again when the app restarts"
    }
}
