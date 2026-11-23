/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import java.io.IOException
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

/**
 * Sleep holds: generations decide who may complete or release a hold, only
 * manual holds of normal tabs reach disk (D11), and the record is read back on
 * the next start.
 */
class TabLifecycleRegistryTest {
    private class MemoryStorage(var record: AtomicJsonFile.Read? = AtomicJsonFile.Read.Absent) :
        JsonStore {
        val writes = mutableListOf<JSONObject>()
        var failWrites = false
        var damagedCopies = 0

        override fun read(): AtomicJsonFile.Read? = record

        override fun write(json: JSONObject) {
            if (failWrites) throw IOException("disk full")
            writes += json
            record = AtomicJsonFile.Read.Present(JSONObject(json.toString()))
        }

        override fun keepDamagedCopy() {
            damagedCopies++
        }

        fun persistedTabs(): Set<String> =
            (record as? AtomicJsonFile.Read.Present)?.json?.optJSONObject("tabs")?.keys()
                ?.asSequence()?.toSet().orEmpty()
    }

    private val registry = TabLifecycleRegistry
    private lateinit var storage: MemoryStorage

    @BeforeTest
    fun setUp() {
        storage = MemoryStorage()
        registry.setStorageForTest(storage)
    }

    @AfterTest
    fun tearDown() = registry.resetForTest()

    @Test
    fun `a hold is in force from the start of a sleep, and written only when it completes`() {
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)

        assertTrue(registry.isHeld("a"))
        assertTrue(storage.writes.isEmpty())

        assertTrue(registry.completeSleep("a", gen))
        assertEquals(setOf("a"), storage.persistedTabs())
    }

    @Test
    fun `an automatic sleep never takes the place of a hold, settled or being placed`() {
        registry.completeSleep("a", registry.beginSleep("a", SleepHoldKind.MANUAL, private = false))
        val running = registry.beginSleep("b", SleepHoldKind.MANUAL, private = false)
        val generations = registry.generation("a") to registry.generation("b")

        assertNull(registry.beginAutomaticSleep("a", private = false))
        assertNull(registry.beginAutomaticSleep("b", private = false))

        assertEquals(generations, registry.generation("a") to registry.generation("b"))
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("a"))
        // The running manual sleep still owns its tab.
        assertTrue(registry.completeSleep("b", running))
        assertEquals(setOf("a", "b"), storage.persistedTabs())

        val automatic = registry.beginAutomaticSleep("c", private = false)
        assertEquals(SleepHoldKind.AUTOMATIC, registry.holdOf("c"))
        assertTrue(registry.completeSleep("c", automatic!!))
    }

    @Test
    fun `automatic and private holds are never written`() {
        val automatic = registry.beginSleep("a", SleepHoldKind.AUTOMATIC, private = false)
        val private = registry.beginSleep("p", SleepHoldKind.MANUAL, private = true)

        assertTrue(registry.completeSleep("a", automatic))
        assertTrue(registry.completeSleep("p", private))

        assertTrue(storage.writes.isEmpty())
        assertTrue(registry.isHeld("a"))
        assertTrue(registry.isHeld("p"))
    }

    @Test
    fun `a wake makes the running sleep stale, so it neither completes nor releases`() {
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)
        registry.wake("a")
        val newer = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)

        assertFalse(registry.completeSleep("a", gen))
        assertFalse(registry.releaseSleep("a", gen))
        assertTrue(registry.isHeld("a"))
        assertTrue(registry.completeSleep("a", newer))
    }

    @Test
    fun `a refused sleep releases its own hold`() {
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)

        assertTrue(registry.releaseSleep("a", gen))
        assertFalse(registry.isHeld("a"))
        assertTrue(storage.writes.isEmpty())
    }

    @Test
    fun `a sleep still running is not written with another that completes, and its refusal leaves nothing on disk`() {
        val a = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)
        val b = registry.beginSleep("b", SleepHoldKind.MANUAL, private = false)

        assertTrue(registry.completeSleep("a", a))
        assertEquals(setOf("a"), storage.persistedTabs())

        assertTrue(registry.releaseSleep("b", b))
        registry.setStorageForTest(MemoryStorage(storage.record))
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("a"))
        assertFalse(registry.isHeld("b"))
    }

    @Test
    fun `a sleep refused over a written hold removes it from disk`() {
        registry.completeSleep("a", registry.beginSleep("a", SleepHoldKind.MANUAL, private = false))
        val again = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)
        assertEquals(setOf("a"), storage.persistedTabs())

        assertTrue(registry.releaseSleep("a", again))

        assertTrue(storage.persistedTabs().isEmpty())
    }

    @Test
    fun `waking a written hold removes it from disk`() {
        registry.completeSleep("a", registry.beginSleep("a", SleepHoldKind.MANUAL, private = false))
        registry.completeSleep("b", registry.beginSleep("b", SleepHoldKind.MANUAL, private = false))

        assertTrue(registry.wake("a"))

        assertEquals(setOf("b"), storage.persistedTabs())
        assertFalse(registry.wake("a"))
    }

    @Test
    fun `the next start reads the written holds back`() {
        registry.completeSleep("a", registry.beginSleep("a", SleepHoldKind.MANUAL, private = false))
        val record = storage.record

        registry.setStorageForTest(MemoryStorage(record))

        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("a"))
        assertEquals(mapOf("a" to HeldTab(SleepHoldKind.MANUAL)), registry.heldTabs.value)
    }

    @Test
    fun `an unreadable record starts without holds, keeps a copy of the damage and enters recovery`() {
        val damaged = MemoryStorage(AtomicJsonFile.Read.Corrupt("malformed json"))
        registry.setStorageForTest(damaged)

        assertFalse(registry.isHeld("a"))
        assertEquals(1, damaged.damagedCopies)
        // D23: written over the damage before anything else proceeds.
        assertTrue(registry.inRecovery())
        assertEquals("recovery", damaged.writes.single().getString("mode"))
    }

    @Test
    fun `holds placed before the profile is readable are kept when it is`() {
        val late = MemoryStorage(record = null)
        registry.setStorageForTest(late)
        registry.beginSleep("early", SleepHoldKind.MANUAL, private = false)

        late.record = AtomicJsonFile.Read.Present(
            JSONObject().put("version", 1).put("tabs", JSONObject().put("stored", JSONObject().put("hold", "manual"))),
        )

        assertTrue(registry.isHeld("early"))
        assertTrue(registry.isHeld("stored"))
    }

    @Test
    fun `a failed write keeps the hold in force for this process`() {
        storage.failWrites = true
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)

        assertTrue(registry.completeSleep("a", gen))
        assertTrue(registry.isHeld("a"))
    }

    @Test
    fun `closed and unrestored tabs are forgotten`() {
        registry.completeSleep("a", registry.beginSleep("a", SleepHoldKind.MANUAL, private = false))
        registry.completeSleep("b", registry.beginSleep("b", SleepHoldKind.MANUAL, private = false))
        registry.completeSleep("c", registry.beginSleep("c", SleepHoldKind.MANUAL, private = false))

        registry.forget(listOf("a"))
        registry.retainOnly(setOf("c"))

        assertNull(registry.holdOf("a"))
        assertNull(registry.holdOf("b"))
        assertEquals(0L, registry.generation("a"))
        // Not written on the main thread at the close: with the next write.
        assertEquals(setOf("a", "b", "c"), storage.persistedTabs())
        registry.completeSleep("d", registry.beginSleep("d", SleepHoldKind.MANUAL, private = false))
        assertEquals(setOf("c", "d"), storage.persistedTabs())
    }

    @Test
    fun `a completed sleep is no longer tearing down`() {
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)
        registry.markTearingDown("a", gen)

        registry.completeSleep("a", gen)

        assertEquals(HeldTab(SleepHoldKind.MANUAL, tearingDown = false), registry.heldTabs.value["a"])
    }

    @Test
    fun `tearing down is marked only by the operation that owns the hold`() {
        val gen = registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)

        assertFalse(registry.markTearingDown("a", gen + 1))
        assertTrue(registry.markTearingDown("a", gen))
        assertEquals(HeldTab(SleepHoldKind.MANUAL, tearingDown = true), registry.heldTabs.value["a"])
    }
}
