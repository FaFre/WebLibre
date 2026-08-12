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
import kotlin.test.assertTrue
import org.json.JSONObject

class ContainerProxyFeatureTest {
    private val sentMessages = mutableListOf<JSONObject>()
    private lateinit var originalSend: (JSONObject) -> Unit

    @BeforeTest
    fun setUp() {
        originalSend = ContainerProxyFeature.sendToExtension
        sentMessages.clear()

        ContainerProxyFeature.sendToExtension = { message ->
            synchronized(sentMessages) { sentMessages.add(message) }
        }
    }

    @AfterTest
    fun tearDown() {
        ContainerProxyFeature.resetForTesting()
        ContainerProxyFeature.sendToExtension = originalSend
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

    private fun snapshot(generation: Long): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put("proxies", org.json.JSONArray())
            put("relations", JSONObject())
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
