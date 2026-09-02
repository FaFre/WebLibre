/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.runBlocking

/**
 * What these pin down is the handover: a launch records what it needs, the app
 * half reads it exactly once, and the launch's wait can tell "the app half has
 * not answered yet" from "it answered and the route really is blocked".
 */
class RoutingDemandsTest {
    private var now = 0L

    @BeforeTest
    fun setUp() {
        RoutingDemands.clear()
        RoutingDemands.clock = { now }
    }

    @AfterTest
    fun tearDown() {
        RoutingDemands.clear()
        RoutingDemands.clock = { 0L }
    }

    @Test
    fun aDemandIsHandedOverOnce() {
        RoutingDemands.record("general", listOf("singbox:wg"))

        assertEquals(listOf("singbox:wg"), RoutingDemands.take()?.proxyIds)
        assertNull(RoutingDemands.take())
    }

    /** Nothing to start is not a demand — there is no answer to hand over. */
    @Test
    fun anEmptyDemandIsNotRecorded() {
        RoutingDemands.record("general", emptyList())

        assertNull(RoutingDemands.take())
        assertFalse(RoutingDemands.isOutstanding("general"))
    }

    /**
     * Two launches into two containers are two needs. A slot would let the
     * second erase the first before anything read it, leaving that launch
     * waiting for a start nobody was ever asked for.
     */
    @Test
    fun demandsForDifferentContextsAreBothKept() {
        RoutingDemands.record("general", listOf("singbox:wg"))
        RoutingDemands.record("container-1", listOf("tor"))

        assertEquals("general", RoutingDemands.take()?.contextId)
        assertEquals("container-1", RoutingDemands.take()?.contextId)
    }

    @Test
    fun aDemandIsOutstandingUntilItIsRead() {
        RoutingDemands.record("general", listOf("singbox:wg"))
        assertTrue(RoutingDemands.isOutstanding("general"))

        RoutingDemands.take()

        // Still outstanding: the app half has it but cannot yet have acted on
        // it, and a blocked verdict in this window predates the request.
        assertTrue(RoutingDemands.isOutstanding("general"))

        now += 3_000
        assertFalse(RoutingDemands.isOutstanding("general"))
    }

    @Test
    fun anUnrelatedContextIsNeverOutstanding() {
        RoutingDemands.record("general", listOf("singbox:wg"))

        assertFalse(RoutingDemands.isOutstanding("container-1"))
    }

    /**
     * A launch that has long since given up must not make the next start
     * happen — or hold the next launch's wait open on its behalf.
     */
    @Test
    fun anExpiredDemandIsNeitherHandedOverNorOutstanding() {
        RoutingDemands.record("general", listOf("singbox:wg"))
        now += 2 * 60 * 1000

        assertFalse(RoutingDemands.isOutstanding("general"))
        assertNull(RoutingDemands.take())
    }

    @Test
    fun waitingResumesOnTheNextDemand() = runBlocking {
        RoutingDemands.record("general", listOf("singbox:wg"))

        assertEquals("general", RoutingDemands.next().contextId)
    }
}
