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
package eu.weblibre.flutter_mozilla_components.startup

import java.io.File
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull

class PendingLaunchStoreTest {
    private lateinit var root: File
    private lateinit var paths: StartupPaths
    private lateinit var store: PendingLaunchStore

    private val now = 1_700_000_000_000L

    @BeforeTest
    fun setUp() {
        root = File.createTempFile("weblibre_pending", "").apply {
            delete()
            mkdirs()
        }
        paths = StartupPaths(root)
        paths.restartDir.mkdirs()
        store = PendingLaunchStore(paths)
    }

    @AfterTest
    fun tearDown() {
        root.deleteRecursively()
    }

    private fun launch(
        createdAt: Long = now,
        ttl: Long = PENDING_LAUNCH_TTL_MS,
    ) = PendingLaunch(
        requestId = "mismatch-$createdAt",
        intentUri = "intent://example.org#Intent;scheme=https;end",
        targetProfileId = "0199a0b1-1111-7111-8111-111111111111",
        createdAtMillis = createdAt,
        expiresAtMillis = createdAt + ttl,
    )

    @Test
    fun `a written launch survives being read back`() {
        store.write(launch())

        val read = store.consume(now + 1_000)

        assertEquals(launch().intentUri, read?.intentUri)
        assertEquals(launch().targetProfileId, read?.targetProfileId)
    }

    @Test
    fun `consuming removes the record`() {
        // A launch that survived delivery would re-open the shortcut on every
        // subsequent start of the app.
        store.write(launch())

        assertEquals(1, listOfNotNull(store.consume(now)).size)
        assertNull(store.peek())
        assertNull(store.consume(now))
    }

    @Test
    fun `an expired launch is dropped rather than replayed`() {
        store.write(launch())

        assertNull(store.consume(now + PENDING_LAUNCH_TTL_MS))
    }

    @Test
    fun `an expired launch is still removed from disk`() {
        // Leaving it behind means every later restart inherits a launch nobody
        // asked for.
        store.write(launch())

        store.consume(now + PENDING_LAUNCH_TTL_MS)

        assertFalse(paths.pendingLaunchFile().exists())
    }

    @Test
    fun `an unreadable record yields nothing`() {
        paths.pendingLaunchFile().writeText("{ not json")

        assertNull(store.consume(now))
    }

    @Test
    fun `a record with no intent is not a launch`() {
        paths.pendingLaunchFile().writeText("""{"requestId":"x","createdAt":"2026-08-19T00:00:00.000Z"}""")

        assertNull(store.consume(now))
    }
}
