/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.ContainerSiteAssignment
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.org.json.tryGetString
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONArray
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

object ContainerProxyFeature {
    private val logger = Logger("container_proxy")

    private const val CONTAINER_PROXY_REPORTER_EXTENSION_ID = "container-proxy@weblibre.eu"
    private const val CONTAINER_PROXY_REPORTER_EXTENSION_URL =
        "resource://android/assets/extensions/container_proxy/"
    private const val CONTAINER_PROXY_REPORTER_MESSAGING_ID = "containerProxy"

    /**
     * How long a request may wait for a reply before it is failed and dropped.
     *
     * Every registered handler is answered by the extension or removed by a port
     * disconnect — except one whose reply is silently lost, which would sit in
     * [requestHandlers] for the life of the process. Comfortably above the app's
     * own timeouts, so this only ever fires as a backstop.
     */
    @VisibleForTesting
    internal var requestTimeoutMs = 60_000L

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, PendingRequest>()
    private val mutex = Mutex()

    private val replayScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    /**
     * Id of the extension's current native port connection.
     *
     * Bumped on every connect and disconnect, from the callbacks themselves —
     * which Gecko delivers in order — so it, and not the order in which their
     * coroutines happen to run, decides what is current. Without it a disconnect
     * that lands after the following connect wipes the state that connect just
     * established, and routing reports itself unready for the rest of the
     * session while the extension is in fact configured.
     */
    private val connectionEpoch = AtomicLong(0)

    /**
     * Completes once the extension has confirmed applying *a* routing snapshot.
     *
     * Not the same question as [acknowledgedSnapshotGeneration], which asks whether
     * the *current* routing is installed. This asks only whether the extension has
     * stopped blocking: until its store holds a snapshot it answers every request
     * with the emergency break, and a seeded or superseded snapshot ends that just
     * as well as the current one.
     *
     * Process-global and never reset, because the thing it guards against is a
     * cold-start window, and the extension re-seeds itself on reconnect.
     */
    private val routingInstalled = CompletableDeferred<Unit>()

    /**
     * Waits for the extension to hold routing, returning false if it never does.
     *
     * For callers whose request cannot simply fail and be retried — the FxA state
     * machine disconnects the account outright when its startup call fails, so
     * letting it run into the emergency break costs the user their sign-in.
     */
    suspend fun awaitRoutingInstalled(timeoutMillis: Long): Boolean =
        withTimeoutOrNull(timeoutMillis) { routingInstalled.await() } != null

    /** A request waiting for a reply, tagged with the connection that carries it. */
    private class PendingRequest(
        val epoch: Long,
        val consumer: ResultConsumer<JSONObject>,
    )

    /** A snapshot the extension confirmed, and the connection it confirmed it on. */
    private class Acknowledgement(val generation: Long, val epoch: Long)

    /**
     * Last routing snapshot pushed from the app, kept so it can be replayed
     * when the extension's background script restarts.
     *
     * Without this, a restarted background script comes up with an empty store
     * while the app still believes its routing is installed — and an empty
     * store is what makes every request go direct.
     */
    @Volatile
    private var lastSnapshot: JSONObject? = null

    /**
     * Generation of [lastSnapshot]. Read and written only under [mutex], so a
     * replay can never observe a snapshot and a generation from different
     * pushes.
     */
    @Volatile
    private var lastSnapshotGeneration: Long? = null

    /**
     * What the extension has confirmed applying, or null when nothing is
     * confirmed. Reset on every port connect, because a reconnect means a fresh
     * background script that has lost whatever it was told before.
     */
    @Volatile
    private var acknowledged: Acknowledgement? = null

    /**
     * The routing this profile had last time it ran, restored by [loadPersisted].
     *
     * Only ever used before [lastSnapshot] exists, i.e. before anything in this
     * process has pushed. It is what keeps the headless paths usable: a Custom
     * Tab or PWA cold start never attaches a Flutter engine, so without it the
     * extension would hold no snapshot for the whole life of the process and
     * block every request in it.
     */
    @Volatile
    @VisibleForTesting
    internal var seedSnapshot: JSONObject? = null

    /**
     * The profile [lastSnapshot] was pushed for, as [RoutingSnapshotStore]
     * identifies profiles.
     *
     * Everything else here is process-global while a profile is not: components
     * are rebuilt for the incoming profile in the same process, and an
     * acknowledgement for the outgoing profile's snapshot can still be in flight
     * when they are. Persisting that would file profile A's routing as profile
     * B's, and B would come up on it on its next headless start.
     *
     * Stamped at the push rather than carried in it, which is only sound
     * because a push cannot straddle a rebind: [applySnapshot] and
     * [RoutingSnapshotStore.bind] both run on the platform thread — the first
     * from its Pigeon handler, the second under `GlobalComponents.setUp`, which
     * has one of its own — and [applySnapshot] blocks that thread until it has
     * stamped. Were a push ever stamped from another thread it could be one
     * Dart computed for the outgoing profile, and nothing here could tell:
     * saying whose routing a snapshot *is* would take a profile tag in the push
     * itself.
     */
    @Volatile
    private var lastSnapshotProfileKey: String? = null

    /**
     * Where an acknowledged snapshot is filed for the next process. Replaceable
     * so tests can observe it without a [Context].
     */
    @VisibleForTesting
    internal var persistSeed: (JSONObject, String) -> Unit = { snapshot, profileKey ->
        RoutingSnapshotStore.write(snapshot, profileKey)
    }

    /**
     * Which profile is current, i.e. the one a snapshot acknowledged now would
     * be filed under. Replaceable for the same reason as [persistSeed].
     */
    @VisibleForTesting
    internal var currentProfileKey: () -> String? = { RoutingSnapshotStore.currentKey() }

    fun acknowledgedSnapshotGeneration(): Long? = acknowledged?.generation

    /**
     * Restores this profile's last routing, so the extension can be seeded
     * before — or without — anything pushing to it.
     *
     * Called while components are created, which is early enough: the extension
     * is installed with the engine, and nothing it filters exists before that.
     *
     * [canReopenAssignedSites] says whether this process has the Dart half of
     * container site assignments — see [installPersistedRouting].
     */
    fun loadPersisted(context: Context, canReopenAssignedSites: Boolean) {
        val profileChanged = RoutingSnapshotStore.bind(context)
        installPersistedRouting(
            RoutingSnapshotStore.read(),
            profileChanged,
            canReopenAssignedSites,
        )
    }

    /**
     * Takes [seed] as the routing to fall back on, dropping what the outgoing
     * profile left behind when [profileChanged].
     *
     * The drop is what stops a port reconnect from replaying profile A's
     * routing — endpoints and all — into profile B. It deliberately does not
     * take [mutex]: this runs on the main thread while components are built, and
     * blocking it on a lock other threads hold while posting to the extension is
     * how a startup deadlocks. Unlocked is sound here because every interleaving
     * a concurrent replay can see is answered:
     *
     *  - generation cleared first, so an acknowledgement for the outgoing
     *    profile no longer matches and is ignored — including for persistence;
     *  - a replay that samples a half-cleared pair finds no generation and sends
     *    the seed, which is the incoming profile's own routing;
     *  - a replay that samples both before the drop replays what the extension
     *    already holds, which is where the switch found it.
     *
     * Site assignments are kept out of the seed unless
     * [canReopenAssignedSites]. They are the one part of a snapshot the
     * extension enforces by *cancelling* a navigation, and it does so without
     * consulting `store.isReady()` — so a seed carrying them blocks loads from
     * the first request. Cancelling is only half of that feature; the other
     * half is Dart reopening the URL in the container it belongs to, off
     * `onContainerSiteAssignment`. Where that half is missing — the headless
     * paths, which run `ensureExternalComponents` with a `NoopBinaryMessenger`
     * — the cancel is a navigation with nothing left to carry it anywhere, i.e.
     * a blank page the user cannot get past on a profile that has assignments
     * but no proxies at all. A process that does have Dart keeps enforcing
     * them, so the assignment still holds through the window before the first
     * push.
     */
    @VisibleForTesting
    internal fun installPersistedRouting(
        seed: JSONObject?,
        profileChanged: Boolean,
        canReopenAssignedSites: Boolean = true,
    ) {
        if (profileChanged) {
            lastSnapshotGeneration = null
            lastSnapshot = null
            lastSnapshotProfileKey = null
            acknowledged = null
        }

        seedSnapshot = seed?.let {
            if (canReopenAssignedSites) it else withoutSiteAssignments(it)
        }
    }

    /**
     * [snapshot] with everything the extension answers by cancelling a
     * navigation taken out, leaving only what it answers by choosing a proxy or
     * blocking a connection.
     */
    private fun withoutSiteAssignments(snapshot: JSONObject): JSONObject {
        return JSONObject(snapshot.toString()).apply {
            put("siteAssignments", JSONObject())
            put("strictContexts", JSONObject())
        }
    }

    /**
     * The form of [snapshot] that is safe to restore in a later process.
     *
     * Endpoints are dropped rather than persisted. A proxy's address is only
     * valid while its backend is running — sing-box binds a random port per run
     * — so a remembered endpoint would either be dead or, worse, be whatever
     * else has since taken that loopback port. Without endpoints the relations
     * still say which contexts must not connect directly, and the extension
     * blocks those (a relation whose proxies do not resolve is a block, not a
     * fallback), while contexts that route directly work from the first request.
     * That is the whole point: fail closed exactly where the profile asked for a
     * proxy, and nowhere else.
     *
     * Site assignments are kept: a process that can act on them enforces them
     * from its first request, and one that cannot drops them when it installs
     * the seed rather than when it files it (see [installPersistedRouting]).
     *
     * The generation is zeroed because it means nothing across processes — Dart
     * starts counting from zero again — and a seed is never acknowledged as an
     * installed generation anyway.
     */
    private fun toSeed(snapshot: JSONObject): JSONObject {
        return JSONObject(snapshot.toString()).apply {
            put("proxies", JSONArray())
            put("generation", 0)
        }
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        CONTAINER_PROXY_REPORTER_EXTENSION_ID,
        CONTAINER_PROXY_REPORTER_EXTENSION_URL,
        CONTAINER_PROXY_REPORTER_MESSAGING_ID,
    )

    /**
     * How a message reaches the extension. Replaceable so tests can observe what
     * is sent without mocking Mozilla's (final) controller class.
     */
    @VisibleForTesting
    internal var sendToExtension: (JSONObject) -> Unit = { message ->
        extensionController.sendBackgroundMessage(message)
    }

    fun scheduleRequest(command: String, args: Any) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                sendToExtension(message)
            }
        }
    }

    fun scheduleRequestWithResponse(
        command: String,
        args: Any,
        callback: ResultConsumer<JSONObject>
    ) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                mutex.withLock {
                    sendRequestWithResponseLocked(message, callback)
                }
            }
        }
    }

    /**
     * Registers [callback] and posts [message], assuming [mutex] is already
     * held.
     *
     * Split out so a caller can decide *what* to send and send it without
     * releasing the lock in between. Deliberately does not wait for the reply:
     * replies arrive through [onExtensionReply], which takes the same
     * (non-reentrant) mutex, so awaiting here would deadlock.
     */
    private fun sendRequestWithResponseLocked(
        message: JSONObject,
        callback: ResultConsumer<JSONObject>,
    ) {
        val requestId = nextRequestId
        message.put("id", requestId)

        requestHandlers[requestId] = PendingRequest(connectionEpoch.get(), callback)

        nextRequestId += 1

        expireRequest(requestId)

        sendToExtension(message)
    }

    /**
     * Fails and drops [requestId] if no reply has arrived by
     * [requestTimeoutMs].
     *
     * Removal is what matters: the reply path and this one both take the handler
     * out under [mutex], so exactly one of them ever answers the caller.
     */
    private fun expireRequest(requestId: Int) {
        val timeout = requestTimeoutMs
        replayScope.launch {
            delay(timeout)

            val expired = mutex.withLock { requestHandlers.remove(requestId) }
                ?: return@launch

            logger.warn("Container proxy request $requestId timed out")
            expired.consumer.error("Container Proxy", "Request timed out", null)
        }
    }

    private fun snapshotMessage(snapshot: JSONObject): JSONObject {
        return JSONObject().apply {
            put("action", "applySnapshot")
            put("args", snapshot)
        }
    }

    /**
     * Records [generation] as installed, but only if it is still the snapshot
     * we most recently sent.
     *
     * Called from the message handler, which already holds [mutex] — so this
     * must not take it again.
     */
    private fun onSnapshotAcknowledgedLocked(generation: Long, epoch: Long) {
        if (epoch == connectionEpoch.get()) {
            // Deliberately before the checks below. They decide whether this is the
            // routing we asked for; this only records that the extension now holds
            // routing at all, which a superseded or seeded snapshot establishes just
            // as well — and which is all [awaitRoutingInstalled] promises.
            routingInstalled.complete(Unit)
        }

        if (generation != lastSnapshotGeneration) {
            // A reply for a snapshot that has since been superseded. Treating it
            // as current would report routing as installed that is not.
            logger.debug(
                "Ignoring acknowledgement for superseded snapshot $generation"
            )
            return
        }

        if (epoch != connectionEpoch.get()) {
            // The connection that confirmed this is gone, and with it the
            // background script that was holding the snapshot.
            logger.debug(
                "Ignoring acknowledgement from stale connection $epoch"
            )
            return
        }

        val profileKey = lastSnapshotProfileKey
        if (currentProfileKey() != profileKey) {
            // The profile was switched while this was in flight. Recording it
            // would report the incoming profile's routing as installed when what
            // the extension holds is the outgoing profile's, and filing it would
            // write that routing under the incoming profile's key — which is
            // what it would then come up on.
            logger.debug(
                "Ignoring acknowledgement for a snapshot pushed under another profile"
            )
            return
        }

        acknowledged = Acknowledgement(generation, epoch)

        // No profile is bound yet, so there is nowhere this could be filed that
        // some profile would not later restore as its own.
        if (profileKey == null) return

        // Filed only once the extension confirms it, so what a later process
        // restores is routing that was actually in force and not one that failed
        // to install. Filed under the key this snapshot was pushed for, not the
        // one bound now — a switch can land between the check above and the
        // write, and [RoutingSnapshotStore.write] cannot re-derive it.
        lastSnapshot?.let { snapshot ->
            try {
                persistSeed(toSeed(snapshot), profileKey)
            } catch (e: Exception) {
                // Losing the seed costs the next headless start its routing; it
                // must not cost this one its acknowledgement.
                logger.error("Failed to persist routing snapshot", e)
            }
        }
    }

    /**
     * Pushes the authoritative routing state to the extension and reports the
     * generation it acknowledges.
     *
     * The snapshot is remembered so [replaySnapshot] can reinstall it after a
     * background-script restart.
     */
    fun applySnapshot(
        snapshot: JSONObject,
        generation: Long,
        callback: ResultConsumer<JSONObject>,
    ) {
        val message = snapshotMessage(snapshot)

        runBlocking {
            withContext(Dispatchers.Default) {
                // Caching and sending happen under one acquisition. Splitting
                // them would let a replay read the cache between the two and
                // send a snapshot that is already superseded.
                mutex.withLock {
                    lastSnapshot = snapshot
                    lastSnapshotGeneration = generation
                    // Stamped with the push, so an acknowledgement that arrives
                    // after a profile switch can tell whose routing it confirms.
                    lastSnapshotProfileKey = currentProfileKey()
                    // The extension drops its store when it restarts, so nothing
                    // is acknowledged again until it answers this push.
                    acknowledged = null

                    val epoch = connectionEpoch.get()

                    sendRequestWithResponseLocked(message, object :
                        ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch)
                            callback.success(result)
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            callback.error(errorCode, errorMessage, errorDetails)
                        }
                    })
                }
            }
        }
    }

    /**
     * Puts routing back on the extension after its port (re)connects: the
     * snapshot this process pushed if there is one, the persisted seed if there
     * is not.
     *
     * Reads the cache under the same lock that installs it, so what it sends is
     * by construction the newest snapshot — a replay racing an app-driven push
     * cannot resend an older one, and cannot leave the extension holding routing
     * the app believes it has replaced.
     *
     * Runs off the caller's thread, because [onPortConnected] is invoked on the
     * Gecko thread and this path blocks on a lock.
     *
     * [epoch] is the connection this replay was scheduled for; a replay whose
     * connection is already gone by the time it runs sends nothing.
     */
    @VisibleForTesting
    internal fun replaySnapshot(epoch: Long = connectionEpoch.get()) {
        replayScope.launch {
            mutex.withLock {
                if (epoch != connectionEpoch.get()) {
                    logger.debug("Skipping replay for stale connection $epoch")
                    return@withLock
                }

                val snapshot = lastSnapshot
                val generation = lastSnapshotGeneration
                if (snapshot == null || generation == null) {
                    // Nothing pushed in this process yet. On the headless paths
                    // nothing ever will be, so this is the only routing the
                    // extension is going to get.
                    sendSeedLocked()
                    return@withLock
                }

                logger.debug("Replaying routing snapshot generation $generation")
                acknowledged = null

                sendRequestWithResponseLocked(
                    snapshotMessage(snapshot),
                    object : ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch)
                            logger.debug("Extension reapplied routing snapshot $generation")
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            logger.error(
                                "Failed to replay routing snapshot: $errorCode $errorMessage"
                            )
                        }
                    },
                )
            }
        }
    }

    /**
     * Installs the persisted routing, assuming [mutex] is already held.
     *
     * Deliberately does not touch [lastSnapshot], [lastSnapshotGeneration] or
     * [acknowledged]: a seed is last-known routing, not routing this process
     * asked for. Leaving it out of that bookkeeping is what keeps
     * `routingStatus()` answering "not installed" until Dart really has pushed —
     * so the gates that wait for routing before opening a proxied tab still wait
     * — and what lets the first real push replace it unconditionally.
     */
    private fun sendSeedLocked() {
        val seed = seedSnapshot ?: return

        logger.debug("Seeding routing from the persisted snapshot")

        sendRequestWithResponseLocked(
            snapshotMessage(seed),
            object : ResultConsumer<JSONObject> {
                override fun success(result: JSONObject) {
                    logger.debug("Extension applied the persisted routing seed")
                }

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?
                ) {
                    logger.error(
                        "Failed to seed routing snapshot: $errorCode $errorMessage"
                    )
                }
            },
        )
    }

    /**
     * Fails every request still waiting for a reply.
     *
     * The extension answers over the port; once that is gone, no reply is ever
     * coming. Without this the app's snapshot push would await a future that
     * never completes, and — because the push is serialised — every later push
     * would queue behind it forever.
     *
     * Only what belongs to a connection older than [epoch] is dropped. A
     * reconnect that races this — the common case, since a background script
     * restart is a disconnect immediately followed by a connect — has already
     * registered its replay under a newer epoch, and clearing that would leave
     * the extension configured but permanently reported as unready.
     */
    @VisibleForTesting
    internal fun failPendingRequests(
        reason: String,
        epoch: Long = connectionEpoch.incrementAndGet(),
    ) {
        replayScope.launch {
            val pending = mutex.withLock {
                val dead = requestHandlers.filterValues { it.epoch < epoch }
                dead.keys.forEach(requestHandlers::remove)

                if ((acknowledged?.epoch ?: Long.MIN_VALUE) < epoch) {
                    acknowledged = null
                }

                dead.values.toList()
            }

            pending.forEach { handler ->
                handler.consumer.error("Container Proxy", reason, null)
            }
        }
    }

    /**
     * Takes the port connection this connect belongs to and reinstalls routing
     * on it.
     */
    @VisibleForTesting
    internal fun onPortConnected() {
        // Bumped here, on the ordered callback thread, so everything the
        // previous connection left behind is stale by construction.
        val epoch = connectionEpoch.incrementAndGet()

        // A connect means a background script that starts with an empty store —
        // it fails closed until it is told the routing again.
        acknowledged = null
        replaySnapshot(epoch)
    }

    /** Drains whatever the connection that just died was still carrying. */
    @VisibleForTesting
    internal fun onPortDisconnected() {
        failPendingRequests(
            "Container proxy port disconnected",
            connectionEpoch.incrementAndGet(),
        )
    }

    /**
     * Answers the request [message] replies to, if it is still waiting for one.
     *
     * Runs the consumer under [mutex]: a snapshot acknowledgement decides what
     * routing the app reports as installed, so it has to be recorded against a
     * cache no push can be halfway through replacing.
     */
    @VisibleForTesting
    internal fun onExtensionReply(message: JSONObject) {
        runBlocking {
            withContext(Dispatchers.Default) {
                mutex.withLock {
                    val requestId = message.getInt("id")
                    val status = message.getString("status")
                    val handler = requestHandlers.remove(requestId)?.consumer

                    if (status == "success") {
                        handler?.success(message)
                    } else {
                        handler?.error(
                            "Container Proxy",
                            "Failed to perform operation",
                            message.getString("error")
                        )
                    }
                }
            }
        }
    }

    /** Clears the singleton's state between unit tests. */
    @VisibleForTesting
    internal fun resetForTesting() {
        runBlocking {
            mutex.withLock {
                requestHandlers.clear()
                nextRequestId = 0
                lastSnapshot = null
                lastSnapshotGeneration = null
                lastSnapshotProfileKey = null
                acknowledged = null
                seedSnapshot = null
                connectionEpoch.set(0)
                requestTimeoutMs = 60_000L
            }
        }
    }

    private class ContainerProxyBackgroundMessageHandler(
        private var events: GeckoStateEvents
    ) : MessageHandler {
        override fun onPortConnected(port: Port) {
            ContainerProxyFeature.onPortConnected()
        }

        override fun onPortDisconnected(port: Port) {
            ContainerProxyFeature.onPortDisconnected()
        }

        override fun onPortMessage(message: Any, port: Port) {
            val messageJSON = message as JSONObject;
            val type = messageJSON.getString("type")

            if (type == "healthcheck" || type == "snapshotApplied") {
                onExtensionReply(messageJSON)
            } else if (type == "assignedSiteRequested") {
                val requestId = messageJSON.getString("id")
                val status = messageJSON.getString("status")
                val details = messageJSON.getJSONObject("result")

                if (status == "success") {
                    runOnUiThread {
                        events.onContainerSiteAssignment(
                            EventSequence.next(),
                            ContainerSiteAssignment(
                                requestId = requestId,
                                tabId = components.core.store.state.selectedTabId,
                                originUrl = details.tryGetString("originUrl"),
                                url = details.getString("url"),
                                blocked = details.getBoolean("blocked"),
                                strict = details.optBoolean("strict", false)
                            )
                        ) { _ -> }
                    }
                }
            }
        }
    }

    /**
     * Installs the web extension in the runtime through the WebExtensionRuntime install method
     *
     * @param runtime a WebExtensionRuntime.
     * @param productName a custom product name used to automatically label reports. Defaults to
     * "android-components".
     */
    fun install(runtime: WebExtensionRuntime, events: GeckoStateEvents) {
        extensionController.registerBackgroundMessageHandler(
            ContainerProxyBackgroundMessageHandler(events)
        )
        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed ContainerProxy webextension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install ContainerProxy webextension: ", throwable)
            },
        )
    }
}
