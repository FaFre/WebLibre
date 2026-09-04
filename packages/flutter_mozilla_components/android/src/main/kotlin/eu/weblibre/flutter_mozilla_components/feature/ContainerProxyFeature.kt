/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import androidx.annotation.MainThread
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.ContainerSiteAssignment
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
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
     * Which app half a push belongs to.
     *
     * Bumped whenever the routing this process pushed stops describing anything
     * — the Flutter engine going away, a profile change — so a reply that was
     * still in flight then cannot be read as an answer about what came after.
     * Generations alone cannot tell them apart: a new isolate starts counting
     * from zero again, so the dead half's generation 0 and the new half's are
     * the same number, and matching them would mark routing installed that the
     * extension has not confirmed — and file it as this profile's seed.
     */
    private val appHalfEpoch = AtomicLong(0)

    /**
     * Whether the extension has confirmed applying *a* routing snapshot that
     * the app half now running pushed.
     *
     * Not the same question as [acknowledgedSnapshotGeneration], which asks whether
     * the *current* routing is installed. This asks only whether the extension has
     * stopped blocking: until its store holds a snapshot it answers every request
     * with the emergency break, and a superseded snapshot ends that just as well
     * as the current one.
     *
     * Cleared wherever the routing behind it stops describing anything — the app
     * half going away, a profile change — because the callers waiting on it are
     * waiting to put traffic on the network, and a process outlives its app half.
     * Left latched it would answer for the previous half's routing: a second
     * [awaitRoutingInstalled] would return at once and start FxA over endpoints
     * whose backends died with the isolate that opened them, which is exactly
     * the failure the wait exists to prevent.
     *
     * A flag rather than a `CompletableDeferred` so it can be cleared at all.
     */
    private val routingInstalled = MutableStateFlow(false)

    /**
     * Whether a background script of the proxy extension has connected its
     * native port at any point in this process.
     *
     * This is not about routing. It is the cheapest proof available that Gecko
     * ran the delayed startup it gates on a chrome window existing: a
     * background script cannot run before `extensions-late-startup` fires, and
     * that notification releases *every* extension's background at once. The
     * engine warm-up session watches it to know its job is done.
     *
     * Latched, unlike everything else here: it answers "did that ever happen",
     * not "is a port up now", so a background restart must not clear it.
     */
    private val extensionBackgroundStartedState = MutableStateFlow(false)

    /** See [extensionBackgroundStartedState]. */
    internal val extensionBackgroundStarted: StateFlow<Boolean> =
        extensionBackgroundStartedState.asStateFlow()

    /**
     * Waits for the extension to hold routing, returning false if it never does.
     *
     * For callers whose request cannot simply fail and be retried — the FxA state
     * machine disconnects the account outright when its startup call fails, so
     * letting it run into the emergency break costs the user their sign-in.
     */
    suspend fun awaitRoutingInstalled(timeoutMillis: Long): Boolean =
        withTimeoutOrNull(timeoutMillis) { routingInstalled.first { it } } != null

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
     * The last snapshot this process pushed *and* had confirmed, or null while
     * it has had none confirmed.
     *
     * Held apart from [acknowledged] for two reasons, both about
     * [installedRoutingVerdict] having to answer a launch decision:
     *
     *  - one field, so a reader gets a snapshot and its confirmation together.
     *    Reading `acknowledged` and `lastSnapshot` separately can pair the
     *    snapshot a push has just installed with the acknowledgement of the one
     *    it replaced, and report a confident verdict for routing the extension
     *    has not answered for yet.
     *  - it survives a port disconnect, which [acknowledged] deliberately does
     *    not. A background-script restart clears what the *extension* holds, and
     *    [replaySnapshot] immediately puts this very snapshot back — so to a
     *    caller asking "did the app half come up, and what did it install?" the
     *    gap is noise. A poll that happened to sample inside one would otherwise
     *    read UNKNOWN and send a perfectly serviceable launch to the browser.
     *
     * Cleared only on a profile change, where the routing itself stops being
     * this process's answer.
     *
     * A flow rather than a field so [awaitInstalledRoutingVerdict] can be told
     * when it changes instead of sampling it.
     */
    private val installedRouting = MutableStateFlow<JSONObject?>(null)

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
     * Whether the seed announces itself as provisional, i.e. whether this
     * process has an app half that is going to push the live routing over it.
     *
     * The seed carries relations but no endpoints — an address is only valid
     * while its backend runs — so every context it routes through a proxy
     * resolves to "blocked" until that push lands. Told this, the extension
     * holds those requests for the push instead of answering them with an error
     * page; told the opposite, it blocks them straight away, because in a
     * process with no app half (a Custom Tab or PWA cold start) the seed is all
     * the routing there is ever going to be and waiting could only delay the
     * same answer.
     */
    @Volatile
    @VisibleForTesting
    internal var seedAwaitsPush: Boolean = false

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
     * Whether the app half has pushed a routing snapshot in this process,
     * confirmed or not.
     *
     * A progress signal, not an answer about routing — nothing may act on this,
     * and [installedRoutingVerdict] remains the only reading of what is in
     * force. It exists so a launch waiting for the app half can tell "Dart has
     * got as far as pushing, and the extension has yet to answer" from "Dart is
     * not there at all", and be patient with the first while giving up on the
     * second.
     */
    internal fun hasPushedSnapshot(): Boolean = lastSnapshotGeneration != null

    /**
     * Drops everything this process pushed, because the half that made it true
     * has gone away.
     *
     * Destroying the Flutter engine detaches the proxy plugins and stops
     * sing-box and Tor with them, so every endpoint in the installed snapshot
     * now names a loopback port nothing is listening on. Left in place, that
     * snapshot reads as LIVE and waves the next Custom Tab or PWA launch
     * through headlessly — into exactly the dead window the bootstrap exists to
     * prevent. Cleared, the launch reads UNKNOWN, falls back to the persisted
     * answer, and either connects directly or starts the app half again.
     *
     * The same fields a profile change drops, and for the same reason: what was
     * installed no longer describes anything. Dropping the generation with them
     * also puts a port reconnect back on the seed, which carries no endpoints,
     * rather than replaying ports that have since died.
     *
     * Does not take [mutex], on the same grounds as [installPersistedRouting]:
     * this runs on the main thread while an activity is being torn down, and
     * the interleavings a concurrent replay can see are the ones described
     * there — the generation goes first, so an acknowledgement for the dropped
     * snapshot no longer matches and is ignored.
     */
    @MainThread
    fun onAppHalfStopped() = dropInstalledRouting(awaitSeed = false)

    /**
     * [onAppHalfStopped] for a half that is being replaced on the spot — a hot
     * restart, where the next isolate arrives in this same engine.
     *
     * The same drop, except the seed is on the extension before this returns.
     * Deferring the send is safe for a teardown with nothing behind it: anything
     * that pushes afterwards is by construction the dying isolate's last word,
     * which names the same dead ports and is discarded on purpose. A restart
     * breaks that reasoning — the next push on this channel is the
     * *replacement's* — and a deferred send that reached the lock after it would
     * wipe routing the new half had already installed, leaving every proxied
     * context blocked until something pushed again. Nothing marks that push as
     * belonging to a newer half, so ordering is what has to settle it, and
     * blocking here settles it: the replacement does not exist yet.
     */
    @MainThread
    fun onAppHalfReplaced() = dropInstalledRouting(awaitSeed = true)

    private fun dropInstalledRouting(awaitSeed: Boolean) {
        val stale = lastSnapshot
        if (lastSnapshotGeneration == null && installedRouting.value == null) return

        logger.debug("App half stopped; dropping the routing it installed")

        // First, so a reply the dying isolate's push is still waiting for can no
        // longer be mistaken for an answer about whatever comes next.
        val epoch = appHalfEpoch.incrementAndGet()

        lastSnapshotGeneration = null
        lastSnapshot = null
        lastSnapshotProfileKey = null
        acknowledged = null
        installedRouting.value = null
        // The half whose routing this stood for is gone; the next one has to
        // install its own before anything may wait on this again.
        routingInstalled.value = false

        // What this process pushed, minus the endpoints that died with it. Site
        // assignments go too: enforcing one means cancelling a navigation, and
        // the Dart half that reopens it in the right container is exactly what
        // has just stopped (see [installPersistedRouting]).
        stale?.let { seedSnapshot = withoutSiteAssignments(toSeed(it)) }
        // Nothing is going to push over it — the half that would have is gone —
        // so a request the seed blocks is answered rather than held.
        seedAwaitsPush = false

        blockDeadEndpoints(epoch, awaitSeed)
    }

    /**
     * Puts the endpoint-less seed on the extension, because the endpoints it is
     * still holding are dead.
     *
     * Dropping our own bookkeeping is only half of a teardown: the Gecko runtime
     * and the extension outlive the Flutter engine, so its store keeps naming
     * loopback ports whose backends stopped with the isolate. Those connections
     * do not merely fail — a freed loopback port can be taken by anything else on
     * the device, which is the same reason endpoints are never persisted (see
     * [toSeed]). The seed blocks exactly the contexts that asked for a proxy and
     * leaves the direct ones direct.
     *
     * Off the caller's thread because [onAppHalfStopped] runs on the main thread
     * during teardown and this takes [mutex] — unless a replacement half is
     * already on its way, which is the one case that cannot tolerate this
     * landing late. See [onAppHalfReplaced].
     */
    private fun blockDeadEndpoints(epoch: Long, awaitSeed: Boolean) {
        if (awaitSeed) {
            // Holding the platform thread on this lock is what an app-driven
            // push does already, and for the same span: everything under it
            // queues a message rather than waiting for one.
            runBlocking {
                withContext(Dispatchers.Default) {
                    mutex.withLock { blockDeadEndpointsLocked(epoch) }
                }
            }
            return
        }

        replayScope.launch {
            mutex.withLock { blockDeadEndpointsLocked(epoch) }
        }
    }

    private fun blockDeadEndpointsLocked(epoch: Long) {
        // A new app half has pushed since; its routing is live and this
        // teardown is history.
        if (epoch != appHalfEpoch.get()) return

        // A last push from the dying isolate can have landed between the
        // clear above and this lock. It names the same dead ports.
        lastSnapshot = null
        lastSnapshotGeneration = null
        lastSnapshotProfileKey = null
        acknowledged = null

        sendSeedLocked()
    }

    /**
     * What the routing this process installed means for traffic in [contextId],
     * or [RoutingVerdict.UNKNOWN] when this process has installed none.
     *
     * Deliberately answers UNKNOWN while only a seed is in force: a seed carries
     * no endpoints, so every proxied context in it reads as blocked, and a
     * launch decision made on that would send a perfectly serviceable proxied
     * PWA to the ordinary browser. "Installed" here means the app pushed it and
     * the extension confirmed it.
     *
     * One read of one field, deliberately — see [installedRouting].
     */
    fun installedRoutingVerdict(contextId: String): RoutingVerdict =
        RoutingResolution.verdict(installedRouting.value, contextId)

    /**
     * The proxy ids this process's installed routing sends [contextId] through
     * and has no endpoint for — what a launch there would need started.
     *
     * Empty while nothing is installed: the seed's blocks are not this
     * process's answer, on the same grounds as [installedRoutingVerdict].
     */
    fun installedBlockedProxyIds(contextId: String): List<String> =
        RoutingResolution.blockedProxyIds(installedRouting.value, contextId)

    /**
     * Completes as soon as routing this process installed covers [contextId].
     *
     * The launch paths wait on this rather than polling [installedRoutingVerdict]:
     * what they are waiting for is a Dart isolate reaching a particular point in
     * its startup, and this resumes them in the same turn the acknowledgement
     * lands instead of up to a poll interval later.
     *
     * [acceptBlocked] decides whether a blocked verdict is an answer. It is not
     * one while the app half has been asked to start the proxy carrying this
     * context and has not had the chance to — the routing being read then
     * predates the request rather than replying to it. Re-evaluated on every
     * emission, and on every re-entry from the poll loop, so a request that is
     * never picked up stops holding the wait.
     */
    suspend fun awaitInstalledRoutingVerdict(
        contextId: String,
        acceptBlocked: () -> Boolean = { true },
    ): RoutingVerdict =
        installedRouting
            .map { RoutingResolution.verdict(it, contextId) }
            .first {
                when (it) {
                    RoutingVerdict.UNKNOWN -> false
                    RoutingVerdict.BLOCKED -> acceptBlocked()
                    else -> true
                }
            }

    /**
     * Restores this profile's last routing, so the extension can be seeded
     * before — or without — anything pushing to it.
     *
     * Called while components are created, which is early enough: the extension
     * is installed with the engine, and nothing it filters exists before that.
     *
     * [canReopenAssignedSites] says whether this process has the Dart half of
     * container site assignments — see [installPersistedRouting].
     * [expectsAppPush] says whether it has the Dart half that pushes live
     * routing — see [seedAwaitsPush].
     */
    fun loadPersisted(
        context: Context,
        canReopenAssignedSites: Boolean,
        expectsAppPush: Boolean,
    ) {
        val profileChanged = RoutingSnapshotStore.bind(context)
        installPersistedRouting(
            RoutingSnapshotStore.read(),
            profileChanged,
            canReopenAssignedSites,
            expectsAppPush,
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
        expectsAppPush: Boolean = true,
    ) {
        if (profileChanged) {
            // Same reason as in [onAppHalfStopped]: an acknowledgement for the
            // outgoing profile's push must not answer for the incoming one's.
            appHalfEpoch.incrementAndGet()

            lastSnapshotGeneration = null
            lastSnapshot = null
            lastSnapshotProfileKey = null
            acknowledged = null
            // The one place this is dropped: routing installed for the outgoing
            // profile says nothing about the incoming one, and unlike a port
            // disconnect nothing is going to replay it.
            installedRouting.value = null
            // And nothing may wait on the outgoing profile's routing to decide
            // that the incoming one's network is safe to touch.
            routingInstalled.value = false
            // A demand names the outgoing profile's proxies, which the app half
            // coming up cannot start and should not be asked to.
            RoutingDemands.clear()
        }

        seedAwaitsPush = expectsAppPush
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
     * [snapshot] tagged with whether a live push is expected to replace it.
     *
     * Only the copy that goes to the extension carries the tag: it says
     * something about *this process*, not about the routing, and the seed
     * itself outlives the process that installed it.
     */
    private fun asProvisional(snapshot: JSONObject, provisional: Boolean): JSONObject {
        return JSONObject(snapshot.toString()).apply {
            put("provisional", provisional)
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
            // Both say something about the process that pushed it, not about
            // the routing: whether a *restored* seed expects a successor is
            // decided by the process restoring it (in [asProvisional]), and the
            // starts that were in flight last time ended with that process.
            remove("provisional")
            remove("awaitingProxies")
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
    private fun onSnapshotAcknowledgedLocked(
        generation: Long,
        epoch: Long,
        appHalf: Long,
    ) {
        if (appHalf != appHalfEpoch.get()) {
            // The half that pushed this is gone. Its generations mean nothing
            // here — the isolate that replaced it counts from zero as well — so
            // this reply cannot say anything about what is installed now, and
            // must not report that the extension is holding it either.
            logger.debug(
                "Ignoring acknowledgement from a stopped app half $appHalf"
            )
            return
        }

        if (epoch == connectionEpoch.get()) {
            // Deliberately before the checks below. They decide whether this is the
            // routing we asked for; this only records that the extension now holds
            // routing at all, which a superseded snapshot establishes just as well
            // — and which is all [awaitRoutingInstalled] promises.
            routingInstalled.value = true
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
        // Published together with the acknowledgement it belongs to, under the
        // same lock, so [installedRoutingVerdict] can never pair one push's
        // snapshot with another's confirmation.
        installedRouting.value = lastSnapshot

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
                    val appHalf = appHalfEpoch.get()

                    sendRequestWithResponseLocked(message, object :
                        ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch, appHalf)
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

                val appHalf = appHalfEpoch.get()

                sendRequestWithResponseLocked(
                    snapshotMessage(snapshot),
                    object : ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch, appHalf)
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
            snapshotMessage(asProvisional(seed, seedAwaitsPush)),
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

        // Latched, never cleared: see [extensionBackgroundStartedState].
        extensionBackgroundStartedState.value = true

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
                installedRouting.value = null
                routingInstalled.value = false
                seedSnapshot = null
                seedAwaitsPush = false
                connectionEpoch.set(0)
                appHalfEpoch.set(0)
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
