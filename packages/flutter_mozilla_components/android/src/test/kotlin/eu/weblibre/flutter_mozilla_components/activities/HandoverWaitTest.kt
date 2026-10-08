/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.activities

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** A window waiting for its session to move to new components. */
class HandoverWaitTest {
    /** The scheduled timeouts, run by hand; a cancelled one is dropped. */
    private val timeouts = mutableListOf<() -> Unit>()

    /** Whether the window may commit a fragment transaction. */
    private var mayAct = true

    private val wait = HandoverWait(
        timeoutMs = 50_000L,
        schedule = { _, block ->
            timeouts += block
            ({ timeouts.remove(block) })
        },
        mayAct = { mayAct },
    )

    private val events = mutableListOf<String>()

    /** Runs the due timeouts; like a finished job, a fired one is gone. */
    private fun fireTimeouts() {
        val due = timeouts.toList()
        timeouts.clear()
        due.forEach { it() }
    }

    @Test
    fun theHandoverEndsTheWait() {
        wait.await { events += "gave up" }

        wait.arrived { endedWait -> events += "arrived, ended wait: $endedWait" }

        assertEquals(listOf("arrived, ended wait: true"), events)
        assertTrue(timeouts.isEmpty())
        assertFalse(wait.isWaiting)
    }

    @Test
    fun givingUpIsFinalAndDoesNotWaitAgain() {
        // `onGaveUp` re-enters the window's show path, which must not wait
        // again; the wait itself is over either way.
        wait.await { events += "gave up" }

        fireTimeouts()

        assertEquals(listOf("gave up"), events)
        assertFalse(wait.isWaiting)
        assertTrue(timeouts.isEmpty())
    }

    @Test
    fun aHandoverWhileTheWindowIsAwayCancelsTheTimeoutAndWaitsForResume() {
        wait.await { events += "gave up" }

        // Stopped: a commit now would throw.
        mayAct = false
        wait.arrived { endedWait -> events += "arrived, ended wait: $endedWait" }

        assertTrue(timeouts.isEmpty(), "the timeout must not fire later and commit while stopped")
        assertTrue(events.isEmpty())

        mayAct = true
        assertTrue(wait.runDeferred())
        assertEquals(listOf("arrived, ended wait: true"), events)
        assertFalse(wait.runDeferred())
    }

    @Test
    fun aTimeoutWhileTheWindowIsAwayWaitsForResume() {
        wait.await { events += "gave up" }

        mayAct = false
        fireTimeouts()
        assertTrue(events.isEmpty())

        mayAct = true
        wait.runDeferred()
        assertEquals(listOf("gave up"), events)
    }

    @Test
    fun aHandoverAfterADeferredTimeoutWins() {
        wait.await { events += "gave up" }
        mayAct = false
        fireTimeouts()

        // It arrived after all, before the window came back.
        wait.arrived { endedWait -> events += "arrived, ended wait: $endedWait" }

        mayAct = true
        wait.runDeferred()
        assertEquals(listOf("arrived, ended wait: true"), events)
    }

    @Test
    fun aHandoverWithoutAWaitSaysSo() {
        // The window already shows a fragment, maybe on the outgoing set.
        wait.arrived { endedWait -> events += "arrived, ended wait: $endedWait" }

        assertEquals(listOf("arrived, ended wait: false"), events)
    }

    @Test
    fun waitingTwiceSchedulesOneTimeout() {
        wait.await { events += "gave up" }
        wait.await { events += "gave up" }

        assertEquals(1, timeouts.size)
    }

    @Test
    fun cancellingDropsEverything() {
        wait.await { events += "gave up" }
        mayAct = false
        wait.arrived { events += "arrived" }

        wait.cancel()

        mayAct = true
        assertFalse(wait.runDeferred())
        assertTrue(timeouts.isEmpty())
        assertTrue(events.isEmpty())
    }
}
