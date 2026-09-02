/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.feature

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONObject

class ContainerProxyFeatureTest {
    private val sentMessages = mutableListOf<JSONObject>()
    private val persisted = mutableListOf<Pair<JSONObject, String>>()
    private lateinit var originalSend: (JSONObject) -> Unit
    private lateinit var originalPersist: (JSONObject, String) -> Unit
    private lateinit var originalProfileKey: () -> String?

    /** Stands in for the profile the snapshot store is bound to. */
    @Volatile
    private var profileKey: String? = "profile-a"

    @BeforeTest
    fun setUp() {
        originalSend = ContainerProxyFeature.sendToExtension
        originalPersist = ContainerProxyFeature.persistSeed
        originalProfileKey = ContainerProxyFeature.currentProfileKey
        sentMessages.clear()
        persisted.clear()
        profileKey = "profile-a"

        ContainerProxyFeature.sendToExtension = { message ->
            synchronized(sentMessages) { sentMessages.add(message) }
        }
        ContainerProxyFeature.persistSeed = { snapshot, key ->
            synchronized(persisted) { persisted.add(snapshot to key) }
        }
        ContainerProxyFeature.currentProfileKey = { profileKey }
    }

    @AfterTest
    fun tearDown() {
        ContainerProxyFeature.resetForTesting()
        ContainerProxyFeature.sendToExtension = originalSend
        ContainerProxyFeature.persistSeed = originalPersist
        ContainerProxyFeature.currentProfileKey = originalProfileKey
    }

    /**
     * The race this guards: a port reconnect fires while a newer snapshot is
     * being pushed. If the replay reads the cache outside the lock that installs
     * it, it can resend the older snapshot afterwards — leaving the extension
     * routing by superseded rules while the app believes the newer ones are live.
     */
    @Test
    fun replaySendsTheNewestSnapshotNotTheOneCachedEarlier() {
        ContainerProxyFeature.applySnapshot(snapshot(1), 1L, noopConsumer())
        ContainerProxyFeature.applySnapshot(snapshot(2), 2L, noopConsumer())

        ContainerProxyFeature.replaySnapshot()
        awaitMessages(3)

        val replayed = messageAt(2)
        assertEquals("applySnapshot", replayed.getString("action"))
        assertEquals(
            2L,
            replayed.getJSONObject("args").getLong("generation"),
            "replay must resend the newest snapshot",
        )
    }

    /** A replay must not roll the cache back to what it resent. */
    @Test
    fun replayLeavesTheNewestSnapshotCached() {
        ContainerProxyFeature.applySnapshot(snapshot(1), 1L, noopConsumer())
        ContainerProxyFeature.applySnapshot(snapshot(7), 7L, noopConsumer())

        ContainerProxyFeature.replaySnapshot()
        awaitMessages(3)

        ContainerProxyFeature.replaySnapshot()
        awaitMessages(4)

        assertEquals(
            7L,
            messageAt(3).getJSONObject("args").getLong("generation"),
            "a replay must not regress the cached snapshot",
        )
    }

    /**
     * Without this the app awaits an acknowledgement that can never arrive, and
     * because pushes are serialised every later push queues behind it forever.
     */
    @Test
    fun pendingRequestsFailWhenThePortDisconnects() {
        val failed = CountDownLatch(1)
        ContainerProxyFeature.applySnapshot(
            snapshot(1),
            1L,
            object : ResultConsumer<JSONObject> {
                override fun success(result: JSONObject) = Unit

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?
                ) {
                    failed.countDown()
                }
            },
        )
        awaitMessages(1)

        ContainerProxyFeature.failPendingRequests("port disconnected")

        assertTrue(
            failed.await(5, TimeUnit.SECONDS),
            "a pending snapshot request must fail once the port is gone",
        )
    }

    /**
     * A background-script restart is a disconnect immediately followed by a
     * connect, and the two drain off the caller's thread in whatever order they
     * get scheduled. When the disconnect's drain runs last it must not take the
     * reconnect's replay with it: the extension would be configured and routing
     * traffic while the app reported it as unready for the rest of the session,
     * refusing to open or switch into every proxied container.
     */
    @Test
    fun aDisconnectDrainThatRunsLateLeavesTheReconnectAlone() {
        ContainerProxyFeature.applySnapshot(snapshot(1), 1L, noopConsumer())
        awaitMessages(1)

        ContainerProxyFeature.onPortDisconnected()
        ContainerProxyFeature.onPortConnected()
        awaitMessages(2)

        // The disconnect's drain, arriving after the replay it must not touch.
        ContainerProxyFeature.failPendingRequests("port disconnected", epoch = 1L)
        Thread.sleep(200)

        ContainerProxyFeature.onExtensionReply(reply(messageAt(1).getInt("id")))

        assertEquals(
            1L,
            ContainerProxyFeature.acknowledgedSnapshotGeneration(),
            "the replayed snapshot must still be able to be acknowledged",
        )
    }

    /**
     * A reply that is silently dropped would otherwise leave its handler
     * registered for the life of the process.
     */
    @Test
    fun aRequestThatIsNeverAnsweredIsFailedAndDropped() {
        ContainerProxyFeature.requestTimeoutMs = 50L

        val failed = CountDownLatch(1)
        ContainerProxyFeature.scheduleRequestWithResponse(
            "healthcheck",
            JSONObject(),
            object : ResultConsumer<JSONObject> {
                override fun success(result: JSONObject) = Unit

                override fun error(
                    errorCode: String,
                    errorMessage: String?,
                    errorDetails: Any?
                ) {
                    failed.countDown()
                }
            },
        )

        assertTrue(
            failed.await(5, TimeUnit.SECONDS),
            "a request with no reply must be failed rather than kept forever",
        )

        // Answering it afterwards must find nothing, i.e. it really was dropped.
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))
    }

    /**
     * Races replays against app-driven pushes and asserts the generations
     * actually sent never go backwards.
     *
     * Pushes are issued in order because that is the app's contract — Dart
     * serialises them behind one lock — so the only thing racing here is the
     * replay, which is exactly the bug's shape.
     *
     * This is the property the lock buys: a replay reads the cache under the
     * same lock that installs it, so it can only ever send the newest snapshot.
     * A replay that samples the cache outside that lock re-sends a superseded
     * generation after a newer one has already gone out.
     */
    @Test
    fun sentGenerationsNeverGoBackwards() {
        val generationCount = 60L
        val done = CountDownLatch(1)

        val replayer = Thread {
            while (done.count > 0) {
                ContainerProxyFeature.replaySnapshot()
                Thread.sleep(1)
            }
        }
        replayer.start()

        for (generation in 1..generationCount) {
            ContainerProxyFeature.applySnapshot(
                snapshot(generation),
                generation,
                noopConsumer(),
            )
        }

        done.countDown()
        replayer.join()
        Thread.sleep(300)

        val generations = synchronized(sentMessages) {
            sentMessages.map { it.getJSONObject("args").getLong("generation") }
        }

        generations.reduce { previous, current ->
            assertTrue(
                current >= previous,
                "generation $current was sent after $previous: $generations",
            )
            current
        }
        assertEquals(generationCount, generations.last())
    }

    /**
     * The headless paths — a Custom Tab or PWA cold start — never attach a
     * Flutter engine, so nothing ever pushes. Without the seed the extension
     * holds no snapshot for the life of that process and blocks every request in
     * it, which is what made external links and PWAs unusable in #571.
     */
    @Test
    fun theSeedIsInstalledWhenNothingEverPushes() {
        ContainerProxyFeature.seedSnapshot = seed()

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)

        val sent = messageAt(0)
        assertEquals("applySnapshot", sent.getString("action"))
        assertEquals(
            "container",
            sent.getJSONObject("args").getJSONObject("relations").getJSONArray("work")
                .getString(0),
            "the persisted routing must reach the extension",
        )
    }

    /**
     * A seed carries relations but no endpoints, so every context it routes
     * through a proxy resolves to "blocked". In a process whose app half is
     * about to push the live routing that is a startup window, not a decision,
     * and the extension is told so it can hold those requests for the push
     * instead of turning the first page load into a proxy error page.
     */
    @Test
    fun aSeedInstalledWhereTheAppWillPushIsMarkedProvisional() {
        ContainerProxyFeature.installPersistedRouting(
            seed(),
            profileChanged = false,
            expectsAppPush = true,
        )

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)

        assertTrue(
            messageAt(0).getJSONObject("args").getBoolean("provisional"),
            "the extension must know a live push is following this seed",
        )
    }

    /**
     * The headless paths have no app half, so the seed is all the routing that
     * process is ever going to get. Waiting for a push that cannot come could
     * only delay the same answer.
     */
    @Test
    fun aSeedInstalledWhereNothingWillPushIsFinal() {
        ContainerProxyFeature.installPersistedRouting(
            seed(),
            profileChanged = false,
            canReopenAssignedSites = false,
            expectsAppPush = false,
        )

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)

        assertFalse(
            messageAt(0).getJSONObject("args").getBoolean("provisional"),
            "nothing follows a seed in a process with no app half",
        )
    }

    /**
     * A seed is last-known routing, not routing this process asked for. Counting
     * it as installed would let the gates that wait for routing before opening a
     * proxied tab proceed on it.
     */
    @Test
    fun anInstalledSeedIsNotReportedAsRoutingReady() {
        ContainerProxyFeature.seedSnapshot = seed()

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertNull(
            ContainerProxyFeature.acknowledgedSnapshotGeneration(),
            "a seed must not answer for a snapshot the app never pushed",
        )
    }

    /** Whatever the app pushed wins over the seed, and the seed is not resent. */
    @Test
    fun theSeedIsSkippedOnceTheAppHasPushed() {
        ContainerProxyFeature.seedSnapshot = seed()
        ContainerProxyFeature.applySnapshot(snapshot(4), 4L, noopConsumer())
        awaitMessages(1)

        ContainerProxyFeature.onPortConnected()
        awaitMessages(2)

        assertEquals(
            4L,
            messageAt(1).getJSONObject("args").getLong("generation"),
            "a connect after a push must replay the push, not the seed",
        )
    }

    /**
     * A proxy's address is only valid while its backend runs — sing-box binds a
     * random port per run — so a remembered endpoint would point at a dead port
     * or at whatever else has since taken it. Relations are kept: without a live
     * endpoint the extension blocks them, which is the right answer for a
     * process that has not started any proxy.
     */
    @Test
    fun thePersistedSnapshotKeepsRelationsButDropsEndpoints() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(9), 9L, noopConsumer())
        awaitMessages(1)

        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        val (stored, storedKey) = synchronized(persisted) { persisted.single() }
        assertEquals("profile-a", storedKey, "it belongs to the profile that pushed it")
        assertEquals(0, stored.getJSONArray("proxies").length(), "endpoints must not be persisted")
        assertEquals(
            0L,
            stored.getLong("generation"),
            "a generation means nothing across processes",
        )
        assertEquals(
            "container",
            stored.getJSONObject("relations").getJSONArray("work").getString(0),
            "the relation that decides what to block must survive",
        )
        assertFalse(
            stored.has("provisional"),
            "whether a start is still expected belongs to the process that pushed it",
        )
    }

    /**
     * A seeded site assignment cancels the navigation it does not like, and the
     * half of that feature which reopens the URL in the container it belongs to
     * lives in Dart. The headless paths have no Dart, so an assignment seeded
     * there is a navigation cancelled with nothing to carry it anywhere — a
     * blank page the user cannot get past on a profile that has assignments but
     * no proxies at all.
     */
    @Test
    fun aSeedDropsWhatCancelsNavigationsWhereNothingCanReopenThem() {
        ContainerProxyFeature.installPersistedRouting(
            routedSnapshot(4),
            profileChanged = false,
            canReopenAssignedSites = false,
        )

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)

        val seeded = messageAt(0).getJSONObject("args")
        assertEquals(
            0,
            seeded.getJSONObject("siteAssignments").length(),
            "an assignment nothing can act on must not block the load",
        )
        assertEquals(
            0,
            seeded.getJSONObject("strictContexts").length(),
            "a strict context nothing can act on must not block the load",
        )
        assertEquals(
            "container",
            seeded.getJSONObject("relations").getJSONArray("work").getString(0),
            "the relation the seed exists for must survive",
        )
    }

    /** Where Dart is there to reopen them, the assignment still holds. */
    @Test
    fun aSeedKeepsSiteAssignmentsWhereDartCanReopenThem() {
        ContainerProxyFeature.installPersistedRouting(
            routedSnapshot(4),
            profileChanged = false,
            canReopenAssignedSites = true,
        )

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)

        assertEquals(
            "work",
            messageAt(0).getJSONObject("args")
                .getJSONObject("siteAssignments")
                .getString("https://example.com"),
            "the window before the first push must still enforce assignments",
        )
    }

    /**
     * Components are rebuilt for the incoming profile in the same process, so an
     * acknowledgement for the outgoing profile's snapshot can still be in
     * flight. Filing it would write profile A's routing under profile B's key,
     * and B would come up on it on its next headless start.
     */
    @Test
    fun aSnapshotIsNotPersistedUnderTheProfileThatReplacedIt() {
        profileKey = "profile-a"
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)

        profileKey = "profile-b"
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertTrue(
            synchronized(persisted) { persisted.isEmpty() },
            "the outgoing profile's routing must not become the incoming one's",
        )
        assertNull(
            ContainerProxyFeature.acknowledgedSnapshotGeneration(),
            "routing the incoming profile never pushed must not read as installed",
        )
    }

    /**
     * The same staleness on the live side: what the extension is put back on
     * after a reconnect must be the incoming profile's routing, never the
     * outgoing profile's — endpoints and all.
     */
    @Test
    fun aProfileSwitchDropsTheOutgoingProfilesRouting() {
        profileKey = "profile-a"
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        profileKey = "profile-b"
        ContainerProxyFeature.installPersistedRouting(seed(), profileChanged = true)

        ContainerProxyFeature.onPortConnected()
        awaitMessages(2)

        assertEquals(
            0L,
            messageAt(1).getJSONObject("args").getLong("generation"),
            "a reconnect after a switch must install the seed, not the old push",
        )
        assertEquals(
            0,
            messageAt(1).getJSONObject("args").getJSONArray("proxies").length(),
            "the outgoing profile's endpoints must not be replayed",
        )
        assertNull(
            ContainerProxyFeature.acknowledgedSnapshotGeneration(),
            "the outgoing profile's acknowledgement must not answer for the new one",
        )
    }

    /**
     * The verdict a launch decision is made on must never be a snapshot the
     * extension has not confirmed.
     *
     * A push installs the new snapshot and drops the previous acknowledgement,
     * and the two used to be read from separate fields — so a reader could pair
     * the just-pushed routing with the *previous* push's confirmation and report
     * a confident verdict for routing nothing had answered for yet.
     */
    @Test
    fun anUnacknowledgedPushDoesNotInheritTheLastOnesVerdict() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertEquals(
            RoutingVerdict.LIVE,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "the confirmed snapshot answers for itself",
        )

        // A second push, deliberately left unanswered: `work` now routes
        // somewhere with no endpoint, which is a different verdict entirely.
        ContainerProxyFeature.applySnapshot(snapshot(2), 2L, noopConsumer())
        awaitMessages(2)

        assertEquals(
            RoutingVerdict.LIVE,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "an unconfirmed push must not be reported as installed routing",
        )
    }

    /**
     * A background-script restart is a disconnect immediately followed by a
     * connect, and [replaySnapshot] puts the same routing straight back. To a
     * caller asking "did the app half come up, and what did it install?" that
     * gap is noise — and a launch that happened to ask inside one used to be
     * told UNKNOWN and sent to the ordinary browser.
     */
    @Test
    fun installedRoutingSurvivesAPortDisconnect() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        ContainerProxyFeature.onPortDisconnected()

        assertEquals(
            RoutingVerdict.LIVE,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "a transient port drop is not the app half un-installing its routing",
        )
    }

    /** A profile switch is: the outgoing profile's routing is not the incoming one's. */
    @Test
    fun installedRoutingIsDroppedWhenTheProfileChanges() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        ContainerProxyFeature.installPersistedRouting(seed(), profileChanged = true)

        assertEquals(
            RoutingVerdict.UNKNOWN,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "the incoming profile has installed nothing",
        )
    }

    /**
     * The app half dying is not a transient gap: sing-box and Tor run in the
     * Flutter isolate, so every endpoint in the installed snapshot names a
     * loopback port nothing is listening on any more. Left installed, the next
     * Custom Tab or PWA launch reads it as LIVE and is served headlessly into
     * that dead window.
     */
    @Test
    fun installedRoutingIsDroppedWhenTheAppHalfStops() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        ContainerProxyFeature.onAppHalfStopped()

        assertEquals(
            RoutingVerdict.UNKNOWN,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "routing whose backends have stopped describes nothing",
        )
        assertNull(
            ContainerProxyFeature.acknowledgedSnapshotGeneration(),
            "nothing the extension confirmed to the dead isolate still holds",
        )
        assertFalse(
            ContainerProxyFeature.hasPushedSnapshot(),
            "a launch must not be patient with a push no live isolate made",
        )
    }

    /**
     * And what the extension gets on its next connect is the seed, not the ports
     * the isolate that died was listening on.
     */
    @Test
    fun aReconnectAfterTheAppHalfStopsReplaysTheSeedNotTheDeadEndpoints() {
        ContainerProxyFeature.seedSnapshot = seed()
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        ContainerProxyFeature.onAppHalfStopped()

        ContainerProxyFeature.onPortConnected()
        awaitMessages(2)

        val replayed = messageAt(1).getJSONObject("args")
        assertEquals(
            0L,
            replayed.getLong("generation"),
            "a reconnect after the backends stopped must send the seed",
        )
        assertEquals(
            0,
            replayed.getJSONArray("proxies").length(),
            "and the seed carries no endpoints",
        )
    }

    /** A seed is not routing this process asked for, so it answers for nothing. */
    @Test
    fun aSeedIsNotInstalledRouting() {
        ContainerProxyFeature.seedSnapshot = seed()

        ContainerProxyFeature.onPortConnected()
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertEquals(
            RoutingVerdict.UNKNOWN,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "a seed carries no endpoints; deciding a launch on it strands proxied PWAs",
        )
    }

    /** The wait resumes on the acknowledgement rather than a poll tick. */
    @Test
    fun theRoutingWaitResumesOnTheAcknowledgement() = runBlocking {
        val waiting = async(Dispatchers.Default) {
            ContainerProxyFeature.awaitInstalledRoutingVerdict("work")
        }

        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertEquals(RoutingVerdict.LIVE, withTimeout(5_000) { waiting.await() })
    }

    /**
     * The whole point of a demand: a launch asked for this proxy to be started,
     * and the routing published before the app half could act on that says
     * nothing about whether the request will be met. Ending the launch's wait
     * on it hands the user "this route is blocked" about a backend that is at
     * that moment being started for them.
     */
    @Test
    fun aBlockedVerdictIsNotAnAnswerWhileADemandIsOutstanding() = runBlocking {
        val acceptBlocked = java.util.concurrent.atomic.AtomicBoolean(false)
        val waiting = async(Dispatchers.Default) {
            ContainerProxyFeature.awaitInstalledRoutingVerdict("work") {
                acceptBlocked.get()
            }
        }

        ContainerProxyFeature.applySnapshot(blockedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertNull(
            withTimeoutOrNull(250) { waiting.await() },
            "a block published before the app half could start anything is not an answer",
        )

        acceptBlocked.set(true)
        // The wait re-enters on the caller's poll interval; the flow replays its
        // current value to the new collector, so no further push is needed.
        val reentered = async(Dispatchers.Default) {
            ContainerProxyFeature.awaitInstalledRoutingVerdict("work") {
                acceptBlocked.get()
            }
        }

        assertEquals(RoutingVerdict.BLOCKED, withTimeout(5_000) { reentered.await() })
        waiting.cancel()
        Unit
    }

    /** Nothing is filed until the extension confirms it holds the routing. */
    @Test
    fun anUnacknowledgedSnapshotIsNotPersisted() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)

        assertTrue(
            synchronized(persisted) { persisted.isEmpty() },
            "a snapshot that never installed must not become the next start's routing",
        )
    }

    /**
     * The extension outlives the Flutter engine, so dropping our own bookkeeping
     * is only half of a teardown: left alone its store keeps routing traffic to
     * loopback ports whose backends died with the isolate, and a freed port can
     * be taken by anything else on the device.
     */
    @Test
    fun theExtensionIsPutBackOnTheSeedWhenTheAppHalfStops() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        ContainerProxyFeature.onAppHalfStopped()
        awaitMessages(2)

        val replacement = messageAt(1).getJSONObject("args")
        assertEquals(
            0,
            replacement.getJSONArray("proxies").length(),
            "the endpoints the dead isolate opened must not still be routable",
        )
        assertFalse(
            replacement.getBoolean("provisional"),
            "nothing is going to push over this; a blocked request is answered now",
        )
        assertEquals(
            0,
            replacement.getJSONObject("siteAssignments").length(),
            "cancelling a navigation needs the Dart half that reopens it",
        )
    }

    /**
     * A reply the dying isolate's push was still waiting for must not be read as
     * an answer about the next one's. Dart counts generations from zero in every
     * isolate, so the number alone cannot tell them apart — and a mismatched
     * match would report routing installed that the extension never confirmed,
     * then file it as this profile's seed.
     */
    @Test
    fun aLateAcknowledgementFromTheStoppedAppHalfIsNotTheNewOnesAnswer() {
        ContainerProxyFeature.applySnapshot(routedSnapshot(0), 0L, noopConsumer())
        awaitMessages(1)
        val staleRequestId = messageAt(0).getInt("id")

        ContainerProxyFeature.onAppHalfStopped()

        // A new isolate, counting from zero again.
        ContainerProxyFeature.applySnapshot(routedSnapshot(0), 0L, noopConsumer())

        ContainerProxyFeature.onExtensionReply(reply(staleRequestId))

        assertEquals(
            RoutingVerdict.UNKNOWN,
            ContainerProxyFeature.installedRoutingVerdict("work"),
            "the extension has not answered the new push yet",
        )
        assertTrue(
            synchronized(persisted) { persisted.isEmpty() },
            "and nothing it never confirmed may become the next start's routing",
        )
    }

    /**
     * The FxA state machine disconnects the account outright when its startup
     * call fails, so it waits for routing before touching the network. A process
     * outlives its app half — latched, the wait would return at once for the
     * second one and start over endpoints that died with the first.
     */
    @Test
    fun theRoutingWaitStartsOverWhenTheAppHalfStops() = runBlocking {
        ContainerProxyFeature.applySnapshot(routedSnapshot(1), 1L, noopConsumer())
        awaitMessages(1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(0).getInt("id")))

        assertTrue(
            ContainerProxyFeature.awaitRoutingInstalled(5_000),
            "the extension confirmed the push",
        )

        ContainerProxyFeature.onAppHalfStopped()

        assertFalse(
            ContainerProxyFeature.awaitRoutingInstalled(100),
            "the routing that answered for is gone with the isolate that pushed it",
        )

        val waiting = async(Dispatchers.Default) {
            ContainerProxyFeature.awaitRoutingInstalled(5_000)
        }

        ContainerProxyFeature.applySnapshot(routedSnapshot(0), 0L, noopConsumer())
        awaitMessages(3)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(2).getInt("id")))

        assertTrue(
            withTimeout(5_000) { waiting.await() },
            "and it is answered again by the routing the new half installs",
        )
    }

    private fun snapshot(generation: Long): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put("proxies", org.json.JSONArray())
            put("relations", JSONObject())
        }
    }

    /**
     * A snapshot routing the `work` context through a live proxy endpoint, with
     * `example.com` assigned to it and the context marked strict.
     */
    /** Routes `work` through a proxy with no endpoint and nothing starting it. */
    private fun blockedSnapshot(generation: Long): JSONObject {
        return routedSnapshot(generation).apply {
            put("proxies", org.json.JSONArray())
        }
    }

    private fun routedSnapshot(generation: Long): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put(
                "proxies",
                org.json.JSONArray().put(
                    JSONObject().apply {
                        put("id", "container")
                        put("type", "socks")
                        put("host", "127.0.0.1")
                        put("port", 41234)
                    },
                ),
            )
            put(
                "relations",
                JSONObject().put("work", org.json.JSONArray().put("container")),
            )
            put(
                "siteAssignments",
                JSONObject().put("https://example.com", "work"),
            )
            put(
                "strictContexts",
                JSONObject().put("work", org.json.JSONArray().put("https://example.com")),
            )
            // Every app push carries this; whether a *restored* one is
            // provisional is decided by the process that restores it.
            put("provisional", true)
        }
    }

    /** What [routedSnapshot] looks like after a process restart. */
    private fun seed(): JSONObject {
        return routedSnapshot(0).apply {
            put("proxies", org.json.JSONArray())
            remove("provisional")
        }
    }

    private fun reply(requestId: Int): JSONObject {
        return JSONObject().apply {
            put("type", "snapshotApplied")
            put("id", requestId)
            put("status", "success")
        }
    }

    private fun noopConsumer() = object : ResultConsumer<JSONObject> {
        override fun success(result: JSONObject) = Unit
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) = Unit
    }

    private fun messageAt(index: Int): JSONObject =
        synchronized(sentMessages) { sentMessages[index] }

    private fun awaitMessages(count: Int) {
        val deadline = System.currentTimeMillis() + 5_000
        while (System.currentTimeMillis() < deadline) {
            if (synchronized(sentMessages) { sentMessages.size } >= count) return
            Thread.sleep(10)
        }
        val actual = synchronized(sentMessages) { sentMessages.size }
        throw AssertionError("expected $count messages, only $actual were sent")
    }
}
