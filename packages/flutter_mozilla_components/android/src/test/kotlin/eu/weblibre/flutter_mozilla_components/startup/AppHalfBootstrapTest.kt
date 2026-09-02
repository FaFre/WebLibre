/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.startup

import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.feature.RoutingDemand
import eu.weblibre.flutter_mozilla_components.feature.RoutingDemands
import eu.weblibre.flutter_mozilla_components.feature.RoutingVerdict
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withTimeoutOrNull
import org.json.JSONArray
import org.json.JSONObject

/**
 * What these pin down is the wait a launch does after the app half is up: a
 * blocked verdict is the first thing that names the proxy to start, so it is a
 * reason to ask for one and wait again rather than to end the launch — but only
 * for a proxy nobody has been asked for yet.
 */
class AppHalfBootstrapTest {
    private val sentMessages = mutableListOf<JSONObject>()
    private val persisted = mutableListOf<Pair<JSONObject, String>>()
    private lateinit var originalSend: (JSONObject) -> Unit
    private lateinit var originalPersist: (JSONObject, String) -> Unit
    private lateinit var originalProfileKey: () -> String?
    private lateinit var originalBootstrapClock: () -> Long
    private lateinit var originalStageProbe: () -> BootstrapStage
    private var originalPollIntervalMs = 0L

    /** Read from the waiting coroutine on [Dispatchers.Default], written here. */
    @Volatile
    private var now = 0L

    @BeforeTest
    fun setUp() {
        originalSend = ContainerProxyFeature.sendToExtension
        originalPersist = ContainerProxyFeature.persistSeed
        originalProfileKey = ContainerProxyFeature.currentProfileKey
        originalBootstrapClock = AppHalfBootstrap.clock
        originalStageProbe = AppHalfBootstrap.stageProbe
        originalPollIntervalMs = AppHalfBootstrap.pollIntervalMs

        sentMessages.clear()
        persisted.clear()
        now = 0L

        ContainerProxyFeature.sendToExtension = { message ->
            synchronized(sentMessages) { sentMessages.add(message) }
        }
        ContainerProxyFeature.persistSeed = { snapshot, key ->
            synchronized(persisted) { persisted.add(snapshot to key) }
        }
        ContainerProxyFeature.currentProfileKey = { "profile-a" }

        RoutingDemands.clear()
        RoutingDemands.clock = { now }

        AppHalfBootstrap.clock = { now }
        AppHalfBootstrap.pollIntervalMs = 10L
        AppHalfBootstrap.stageProbe = { BootstrapStage.SNAPSHOT_PUSHED }
    }

    @AfterTest
    fun tearDown() {
        ContainerProxyFeature.resetForTesting()
        ContainerProxyFeature.sendToExtension = originalSend
        ContainerProxyFeature.persistSeed = originalPersist
        ContainerProxyFeature.currentProfileKey = originalProfileKey

        RoutingDemands.clear()
        RoutingDemands.clock = { 0L }

        AppHalfBootstrap.clock = originalBootstrapClock
        AppHalfBootstrap.pollIntervalMs = originalPollIntervalMs
        AppHalfBootstrap.stageProbe = originalStageProbe
    }

    /**
     * The cold-start case the re-wait exists for: nothing was persisted, so the
     * launch had nothing to demand before the app half came up, and the block it
     * publishes is the first thing that names the proxy carrying this context.
     */
    @Test
    fun aBlockedVerdictAfterBootstrapRecordsTheNowKnownDemand() = runBlocking {
        val waiting = awaitOutcome(demanded = emptyList())

        installBlockedRouting(generation = 1)

        assertNull(
            withTimeoutOrNull(250) { waiting.await() },
            "a newly discovered blocked proxy must be handed to the app half before failing",
        )

        val demand = awaitDemand()
        assertEquals("work", demand.contextId)
        assertEquals(listOf("container"), demand.proxyIds)

        // Past the handover grace, with nothing having started: the block is now
        // an answer to the demand rather than a description of what preceded it.
        now += 3_000

        val outcome = withTimeout(5_000) { waiting.await() }
        assertEquals(LaunchRoutingPlan.OPEN_IN_BROWSER, outcome.plan)
        assertEquals(BootstrapFailure.ROUTE_BLOCKED, outcome.failure)
    }

    /**
     * The point of handing the demand over. Dart reads it, starts the backend,
     * and pushes routing with an endpoint; the launch that would have been sent
     * to the browser proceeds instead.
     */
    @Test
    fun theLaunchProceedsWhenTheDemandBringsTheProxyUp() = runBlocking {
        val waiting = awaitOutcome(demanded = emptyList())

        installBlockedRouting(generation = 1)
        awaitDemand()

        // What the app half pushes once the backend it was asked for is running.
        installRouting(routedSnapshot(generation = 2), index = 1)

        val outcome = withTimeout(5_000) { waiting.await() }
        assertEquals(LaunchRoutingPlan.PROCEED, outcome.plan)
        assertNull(outcome.failure)
    }

    /**
     * A demand already in flight for this proxy is not recorded twice: the block
     * being read is the state that demand was recorded *about*. Waiting again on
     * it would spend the launch's patience on an answer already given.
     */
    @Test
    fun aProxyAlreadyDemandedIsNotHandedOverAgain() = runBlocking {
        // As `ensure` leaves it when the persisted seed named the same proxy.
        RoutingDemands.record("work", listOf("container"))
        val handedOver = awaitDemand()
        assertEquals(listOf("container"), handedOver.proxyIds)

        val waiting = awaitOutcome(demanded = listOf("container"))
        installBlockedRouting(generation = 1)
        now += 3_000

        val outcome = withTimeout(5_000) { waiting.await() }
        assertEquals(LaunchRoutingPlan.OPEN_IN_BROWSER, outcome.plan)
        assertEquals(BootstrapFailure.ROUTE_BLOCKED, outcome.failure)
        assertNull(RoutingDemands.take(), "the same proxy must not be demanded twice")
    }

    /**
     * The seed is what this profile routed through last time, so the proxy it
     * names can be one the container no longer uses. The block the app half
     * publishes names the current one, and that is a need nobody has been asked
     * to meet.
     */
    @Test
    fun aDifferentProxyThanTheOneDemandedIsStillHandedOver() = runBlocking {
        val waiting = awaitOutcome(demanded = listOf("stale-proxy"))

        installBlockedRouting(generation = 1)

        val demand = awaitDemand()
        assertEquals(listOf("container"), demand.proxyIds)

        now += 3_000
        assertEquals(BootstrapFailure.ROUTE_BLOCKED, withTimeout(5_000) { waiting.await() }.failure)
    }

    /**
     * The wait, running off the test thread so the test can drive the routing
     * and the clock it is waiting on.
     */
    private fun CoroutineScope.awaitOutcome(demanded: List<String>): Deferred<BootstrapOutcome> =
        async(Dispatchers.Default) {
            AppHalfBootstrap.awaitOutcomeAfterStart(
                contextId = "work",
                persisted = RoutingVerdict.UNKNOWN,
                demanded = demanded,
            )
        }

    /** Pushes [snapshot] and acknowledges it as the extension would. */
    private fun installRouting(snapshot: JSONObject, index: Int) {
        ContainerProxyFeature.applySnapshot(snapshot, snapshot.getLong("generation"), noopConsumer())
        awaitMessages(index + 1)
        ContainerProxyFeature.onExtensionReply(reply(messageAt(index).getInt("id")))
    }

    private fun installBlockedRouting(generation: Long) =
        installRouting(blockedSnapshot(generation), index = 0)

    /** Routes `work` through a proxy with no endpoint and nothing starting it. */
    private fun blockedSnapshot(generation: Long): JSONObject =
        routedSnapshot(generation).apply { put("proxies", JSONArray()) }

    /** The same routing, once the proxy the demand asked for is running. */
    private fun routedSnapshot(generation: Long): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put(
                "proxies",
                JSONArray().put(
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
                JSONObject().put("work", JSONArray().put("container")),
            )
            put("provisional", true)
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

    private fun awaitDemand(): RoutingDemand {
        val deadline = System.currentTimeMillis() + 5_000
        while (System.currentTimeMillis() < deadline) {
            RoutingDemands.take()?.let { return it }
            Thread.sleep(10)
        }
        throw AssertionError("expected a routing demand")
    }
}
