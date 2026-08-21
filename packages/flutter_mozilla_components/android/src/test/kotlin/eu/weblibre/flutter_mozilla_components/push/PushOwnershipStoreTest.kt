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

import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class PushOwnershipStoreTest {
    private lateinit var root: File
    private lateinit var paths: StartupPaths
    private lateinit var store: PushOwnershipStore

    private val profileA = "0199a0b1-1111-7111-8111-111111111111"
    private val profileB = "0199a0b1-2222-7222-8222-222222222222"

    @BeforeTest
    fun setUp() {
        root = File.createTempFile("weblibre_push", "").apply {
            delete()
            mkdirs()
        }
        paths = StartupPaths(root)
        store = PushOwnershipStore(paths)
    }

    @AfterTest
    fun tearDown() {
        root.deleteRecursively()
    }

    @Test
    fun `an unknown token has no owner`() {
        // The whole point of the cache: absence must mean "do not know", never
        // "belongs to nobody", or the receiver would decline messages it should
        // handle.
        assertNull(store.ownerOf("token-1"))
    }

    @Test
    fun `a recorded token resolves to its profile`() {
        store.record("token-1", profileA, "https://example.org")

        assertEquals(profileA, store.ownerOf("token-1")?.profileId)
        assertEquals("https://example.org", store.ownerOf("token-1")?.instance)
    }

    @Test
    fun `profiles are compared case-insensitively`() {
        store.record("token-1", profileA.uppercase(), null)

        assertEquals(profileA, store.ownerOf("token-1")?.profileId)
        assertEquals(1, store.entriesForProfile(profileA.uppercase()).size)
    }

    @Test
    fun `a token belongs to one profile at a time`() {
        store.record("token-1", profileA, null)
        store.record("token-1", profileB, null)

        assertEquals(profileB, store.ownerOf("token-1")?.profileId)
        assertTrue(store.entriesForProfile(profileA).isEmpty())
    }

    @Test
    fun `forgetting one token leaves the others`() {
        store.record("token-1", profileA, null)
        store.record("token-2", profileA, null)

        store.forget("token-1")

        assertNull(store.ownerOf("token-1"))
        assertEquals(profileA, store.ownerOf("token-2")?.profileId)
    }

    @Test
    fun `purging a profile leaves other profiles untouched`() {
        // What restore and delete rely on. Taking a neighbour's entries with it
        // would make their next push arrive as an unknown token.
        store.record("token-1", profileA, null)
        store.record("token-2", profileB, null)

        store.forgetProfile(profileA)

        assertTrue(store.entriesForProfile(profileA).isEmpty())
        assertEquals(profileB, store.ownerOf("token-2")?.profileId)
    }

    @Test
    fun `a non-canonical profile is never recorded`() {
        // A bad id here would be worse than no id: the receiver would compare a
        // real committed profile against garbage and decline every message.
        store.record("token-1", "not-a-uuid", null)

        assertNull(store.ownerOf("token-1"))
    }

    @Test
    fun `a corrupt map reads as empty rather than throwing`() {
        paths.pushOwnershipFile.parentFile?.mkdirs()
        paths.pushOwnershipFile.writeText("{ not json")

        assertNull(store.ownerOf("token-1"))
        assertTrue(store.entries().isEmpty())
    }

    @Test
    fun `the map is capped and keeps the newest entries`() {
        // A distributor that churns tokens must not grow a file the receiver has to
        // parse on every broadcast.
        for (index in 0..PushOwnershipStore.MAX_ENTRIES) {
            store.record("token-$index", profileA, null, nowMillis = index.toLong())
        }

        val entries = store.entries()
        assertEquals(PushOwnershipStore.MAX_ENTRIES, entries.size)
        assertNull(store.ownerOf("token-0"))
        assertEquals(
            profileA,
            store.ownerOf("token-${PushOwnershipStore.MAX_ENTRIES}")?.profileId,
        )
    }

    @Test
    fun `the map lives outside every profile`() {
        // An uncommitted process is exactly the one that has to read it, and it
        // cannot open anything inside a profile directory.
        store.record("token-1", profileA, null)

        assertTrue(paths.pushOwnershipFile.exists())
        assertTrue(
            !paths.pushOwnershipFile.path.contains("profile-"),
            "ownership map was written inside a profile: ${paths.pushOwnershipFile.path}",
        )
    }
}
