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
package eu.weblibre.flutter_mozilla_components.push

import eu.weblibre.flutter_mozilla_components.push.PushMessageWorker.Companion.deliverSurvivingRebuild
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlinx.coroutines.runBlocking

/**
 * The delivery a UI start interrupts by rebuilding the components a headless
 * start made (device test D2): it goes to the replacement once, at once.
 */
class PushMessageWorkerTest {
    private val delivered = mutableListOf<String>()
    private val lookedUp = mutableListOf<String>()

    private fun deliverTo(closed: Set<String>): suspend (String) -> Unit = { push ->
        if (push in closed) throw Push.ClosedException()
        delivered += push
    }

    @Test
    fun `an open push delivers without a replacement`() = runBlocking {
        deliverSurvivingRebuild(
            push = "external",
            replacementOf = { lookedUp += it; "full" },
            deliver = deliverTo(closed = emptySet()),
        )

        assertEquals(listOf("external"), delivered)
        assertEquals(emptyList(), lookedUp)
    }

    @Test
    fun `a push closed by a rebuild hands the message to its replacement`() = runBlocking {
        deliverSurvivingRebuild(
            push = "external",
            replacementOf = { lookedUp += it; "full" },
            deliver = deliverTo(closed = setOf("external")),
        )

        assertEquals(listOf("full"), delivered)
        assertEquals(listOf("external"), lookedUp)
    }

    @Test
    fun `without a replacement the closed failure stands so the work is retried`() {
        assertFailsWith<Push.ClosedException> {
            runBlocking {
                deliverSurvivingRebuild(
                    push = "external",
                    replacementOf = { null },
                    deliver = deliverTo(closed = setOf("external")),
                )
            }
        }
        assertEquals(emptyList(), delivered)
    }

    @Test
    fun `a replacement that closed too is not chased further`() {
        assertFailsWith<Push.ClosedException> {
            runBlocking {
                deliverSurvivingRebuild(
                    push = "external",
                    replacementOf = { lookedUp += it; "full" },
                    deliver = deliverTo(closed = setOf("external", "full")),
                )
            }
        }
        assertEquals(listOf("external"), lookedUp)
    }

    @Test
    fun `other failures do not look for a replacement`() {
        assertFailsWith<IllegalStateException> {
            runBlocking {
                deliverSurvivingRebuild(
                    push = "external",
                    replacementOf = { lookedUp += it; "full" },
                    deliver = { error("Gecko is not running") },
                )
            }
        }
        assertEquals(emptyList(), lookedUp)
    }
}
