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
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicInteger
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

/** Profile-scoped UnifiedPush state and Gecko web-push integration. */
class Push(
    private val components: Components,
) : AutoCloseable {
    private val initialized = AtomicBoolean(false)
    private val closed = AtomicBoolean(false)
    internal val isClosed: Boolean
        get() = closed.get()
    private val dispatcher: ExecutorCoroutineDispatcher =
        Executors.newSingleThreadExecutor { runnable ->
            Thread(runnable, "WebLibrePush-${components.profileApplicationContext.relativePath.hashCode()}")
        }.asCoroutineDispatcher()
    private val eventScope = CoroutineScope(dispatcher + SupervisorJob())

    private val context: Context
        get() = components.profileApplicationContext

    private val prefs = PushProfileState.prefs(context)
    private val subscriptionsDb = SubscriptionsDB(context)

    val feature = UnifiedPushFeature(
        context = context,
        coroutineContext = dispatcher,
        db = subscriptionsDb,
    )

    private val webPushEngineIntegration =
        WebPushEngineIntegration(components.core.engine, feature)

    fun initialize() {
        check(!closed.get()) { "Push is closed" }
        if (!initialized.compareAndSet(false, true)) return

        restoreRememberedDistributor()
        components.core.store
        webPushEngineIntegration.start()
        feature.initialize()
        eventScope.launch {
            while (!PushMessageScheduler.recover(components.profileApplicationContext)) {
                delay(RECOVERY_RETRY_DELAY_MS)
            }
            notifyIfDistributorMissing()
        }
    }

    fun status(): PushStatusSnapshot {
        val available = UnifiedPush.getDistributors(context).map { it.toDistributorInfo() }
        val acknowledged = UnifiedPush.getAckDistributor(context)
        val saved = UnifiedPush.getSavedDistributor(context)
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
            lastError = PushProfileState.lastError(context),
        )
    }

    suspend fun setDistributor(packageName: String) = UnifiedPushReceiver.runExclusive {
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
            feature.renewRegistration()
        }
    }

    suspend fun removeDistributor() = UnifiedPushReceiver.runExclusive {
        withContext(dispatcher) {
            check(!closed.get()) { "Push is closed" }
            removeTransportRegistrationsAndEndpoints()
            prefs.edit().remove(PushProfileState.KEY_SELECTED_DISTRIBUTOR).commit()
            PushProfileState.clearError(context)
            cancelMissingDistributorNotification()
        }
    }

    suspend fun renewRegistration() = UnifiedPushReceiver.runExclusive {
        withContext(dispatcher) {
            check(!closed.get()) { "Push is closed" }
            restoreRememberedDistributor()
            feature.renewRegistration()
        }
    }

    suspend fun subscriptions(): List<PushSubscriptionInfo> = withContext(dispatcher) {
        subscriptionsDb.listSubscriptions().map {
            PushSubscriptionInfo(scope = it.scope, hasEndpoint = it.endpoint != null)
        }
    }

    suspend fun onNewEndpoint(scope: String, endpoint: PushEndpoint) = withContext(dispatcher) {
        feature.onNewEndpoint(scope, endpoint)
        if (endpoint.pubKeySet != null) PushProfileState.clearError(context, scope)
    }

    suspend fun invalidateEndpoint(scope: String) = withContext(dispatcher) {
        subscriptionsDb.removeEndpoint(scope)
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

    suspend fun deliverMessage(scope: String, payload: ByteArray) {
        val external = GlobalComponents.isExternalMode
        val deliver: suspend () -> Unit = {
            withContext(Dispatchers.Main.immediate) {
                check(!closed.get()) { "Push is closed" }
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

    /**
     * Persist the profile switch while holding the profile lock, so an in-flight
     * delivery worker (which holds the same lock for the duration of a delivery)
     * cannot straddle the switch and deliver this profile's message after disk
     * state has moved on. Throws on failure so the caller can abort rather than
     * proceed with an inconsistent on-disk profile.
     */
    suspend fun persistProfileSwitch(targetProfileId: String) {
        check(!closed.get()) { "Push is closed" }
        persistProfileSwitch(targetProfileId) { true }
    }

    /**
     * Persist the switch if profile and receiver exclusivity can be obtained
     * within [startTimeoutMillis]. The timeout stops applying once the atomic
     * file write starts.
     */
    suspend fun persistProfileSwitch(
        targetProfileId: String,
        startTimeoutMillis: Long,
    ): Boolean {
        check(!closed.get()) { "Push is closed" }
        return runWithStartTimeout(startTimeoutMillis) { tryStart ->
            persistProfileSwitch(targetProfileId, tryStart)
        }
    }

    private suspend fun persistProfileSwitch(
        targetProfileId: String,
        tryStart: () -> Boolean,
    ) {
        ActiveProfile.withProfileLock {
            UnifiedPushReceiver.runExclusive {
                if (tryStart()) {
                    ActiveProfile.switchTo(
                        components.profileApplicationContext.rootApplicationContext,
                        targetProfileId,
                    )
                }
            }
        }
    }

    /**
     * Detach the now-inactive profile's push transport. Best-effort: a stale
     * registration is harmless and is cleaned up when that profile next becomes
     * active. Subscriptions and the remembered distributor are preserved.
     */
    suspend fun detachTransportForSwitch() {
        ActiveProfile.withProfileLock {
            UnifiedPushReceiver.runExclusive {
                withContext(dispatcher) {
                    if (!closed.get()) {
                        removeTransportRegistrationsAndEndpoints(notifyGecko = false)
                    }
                }
            }
        }
    }

    /** Persist the switch (mandatory), then best-effort detach the old transport. */
    suspend fun suspendForProfileSwitch(targetProfileId: String) {
        persistProfileSwitch(targetProfileId)
        runCatching { detachTransportForSwitch() }
            .onFailure { error ->
                Log.w(TAG, "Failed to detach push transport during profile switch", error)
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

    private fun restoreRememberedDistributor() {
        if (UnifiedPush.getSavedDistributor(context) != null) return
        val remembered = rememberedDistributor() ?: return
        if (UnifiedPush.getDistributors(context).contains(remembered)) {
            UnifiedPush.saveDistributor(context, remembered)
        }
    }

    private suspend fun removeTransportRegistrationsAndEndpoints(notifyGecko: Boolean = true) {
        UnifiedPush.removeDistributor(context)
        subscriptionsDb.listSubscriptions().forEach {
            subscriptionsDb.removeEndpoint(it.scope)
            if (notifyGecko) webPushEngineIntegration.invalidateEndpoint(it.scope)
        }
    }

    private fun rememberedDistributor(): String? =
        prefs.getString(PushProfileState.KEY_SELECTED_DISTRIBUTOR, null)

    private fun rememberDistributor(packageName: String) {
        prefs.edit().putString(PushProfileState.KEY_SELECTED_DISTRIBUTOR, packageName).commit()
    }

    private fun notifyIfDistributorMissing() {
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
    }
}
