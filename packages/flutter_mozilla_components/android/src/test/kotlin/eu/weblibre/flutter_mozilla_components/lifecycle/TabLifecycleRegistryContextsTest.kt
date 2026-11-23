/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.EngineEnforcement
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import java.io.IOException
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

/**
 * The registry's context records (5.6 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): strict writes, the one
 * restriction predicate, the recovery table after a restart, recovery mode
 * (D23), owner reconciliation and the deletion phases (D28).
 */
class TabLifecycleRegistryContextsTest {
    private class MemoryStorage(var record: AtomicJsonFile.Read? = AtomicJsonFile.Read.Absent) :
        JsonStore {
        val writes = mutableListOf<JSONObject>()
        var failWrites = false

        /** What the next writes do instead of succeeding, in order. */
        val failures = ArrayDeque<Failure>()

        override fun read(): AtomicJsonFile.Read? = record

        override fun write(json: JSONObject) {
            if (failWrites) throw IOException("disk full")
            when (failures.removeFirstOrNull()) {
                Failure.NOT_WRITTEN -> throw IOException("disk full")
                Failure.UNCONFIRMED -> {
                    store(json)
                    throw AtomicJsonFile.UnconfirmedWriteException("no directory sync", IOException("EIO"))
                }
                null -> store(json)
            }
        }

        private fun store(json: JSONObject) {
            writes += json
            record = AtomicJsonFile.Read.Present(JSONObject(json.toString()))
        }

        override fun keepDamagedCopy() = Unit

        fun contexts(): JSONObject =
            (record as AtomicJsonFile.Read.Present).json.optJSONObject("contexts") ?: JSONObject()

        fun phaseOf(contextId: String): String? = contexts().optJSONObject(contextId)?.optString("phase")
    }

    private enum class Failure { NOT_WRITTEN, UNCONFIRMED }

    private val registry = TabLifecycleRegistry
    private lateinit var storage: MemoryStorage

    @BeforeTest
    fun setUp() {
        storage = MemoryStorage()
        registry.setStorageForTest(storage)
    }

    @AfterTest
    fun tearDown() = registry.resetForTest()

    /** A new process reading what this one wrote. */
    private fun restart() {
        val record = storage.record
        storage = MemoryStorage(record)
        registry.setStorageForTest(storage)
    }

    private fun recordOnDisk(vararg contexts: Pair<String, JSONObject>, mode: String = "normal") {
        val json = JSONObject().put("version", 1).put("mode", mode).put("tabs", JSONObject())
            .put("contexts", JSONObject().apply { contexts.forEach { (id, entry) -> put(id, entry) } })
        storage = MemoryStorage(AtomicJsonFile.Read.Present(json))
        registry.setStorageForTest(storage)
    }

    private fun entry(phase: String, owner: String? = "c1", previous: String? = null) = JSONObject().apply {
        put("phase", phase)
        owner?.let { put("owner", it) }
        previous?.let { put("previous", it) }
    }

    @Test
    fun `a freeze intent is written before it counts, and restricts its contexts`() {
        assertFalse(registry.isRestricted("ctx"))

        val gen = assertNotNull(registry.beginFreeze("c1", listOf("ctx")))

        assertTrue(registry.isRestricted("ctx"))
        assertEquals("freezing", storage.phaseOf("ctx"))
        assertTrue(registry.owns(listOf("ctx"), gen))
        assertEquals(listOf("ctx"), registry.restrictedContexts())
        assertFalse(registry.isRestricted(null))
    }

    @Test
    fun `a freeze intent that cannot be written changes nothing`() {
        storage.failWrites = true

        assertNull(registry.beginFreeze("c1", listOf("ctx")))

        assertFalse(registry.isRestricted("ctx"))
        assertTrue(registry.snapshot().contexts.isEmpty())
    }

    @Test
    fun `a write that replaced the file unconfirmed is undone there too when it counts as failed`() {
        storage.failures += Failure.UNCONFIRMED

        assertNull(registry.beginFreeze("c1", listOf("ctx")))

        // Memory and file agree: a restart does not bring the freeze back.
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        restart()
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `an unconfirmed write that cannot be undone counts as written, though not as durable`() {
        storage.failures += listOf(Failure.UNCONFIRMED, Failure.NOT_WRITTEN)

        assertNotNull(registry.beginFreeze("c1", listOf("ctx")))

        assertTrue(registry.isRestricted("ctx"))
        assertEquals("freezing", storage.phaseOf("ctx"))
        assertFalse(registry.isDurablyRecorded(listOf("ctx")))

        // The next confirmed write makes it durable.
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("ctx")))
        registry.setPhase(listOf("ctx"), gen, ContextPhase.FROZEN)
        assertTrue(registry.isDurablyRecorded(listOf("ctx")))
    }

    @Test
    fun `an unconfirmed Resume write leaves the records where the file has them`() {
        recordOnDisk("ctx" to entry("frozen"))
        val gen = assertNotNull(registry.beginResume(listOf("ctx"), null))
        storage.failures += Failure.UNCONFIRMED

        assertNull(registry.removeRecords(listOf("ctx"), gen))

        assertTrue(registry.isRestricted("ctx"))
        assertEquals("resuming", storage.phaseOf("ctx"))
    }

    @Test
    fun `the restricted contexts among many are read at once`() {
        registry.beginFreeze("c1", listOf("ctx"))

        assertEquals(setOf<String?>("ctx"), registry.restrictedAmong(listOf("ctx", "other", null)))
    }

    @Test
    fun `a Resume takes the contexts over, so the freeze no longer owns them`() {
        val freeze = assertNotNull(registry.beginFreeze("c1", listOf("ctx")))
        val resume = assertNotNull(registry.beginResume(listOf("ctx"), wakeTabId = "t"))

        assertFalse(registry.owns(listOf("ctx"), freeze))
        assertTrue(registry.owns(listOf("ctx"), resume))
        // A stale completion writes nothing.
        assertFalse(registry.setPhase(listOf("ctx"), freeze, ContextPhase.FROZEN))
        assertEquals("resuming", storage.phaseOf("ctx"))
    }

    @Test
    fun `a refused freeze forgets new contexts and puts back the ones restricted before`() {
        recordOnDisk("old" to entry("failed"))
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("old", "new")))

        registry.abandonFreeze(
            listOf("old", "new"),
            gen,
            LifecycleFailure.PROTECTED_ACTIVITY,
            restore = mapOf("old" to ContextRecord("c1", ContextPhase.FAILED)),
        )

        assertFalse(registry.isRestricted("new"))
        assertTrue(registry.isRestricted("old"))
        assertEquals("failed", storage.phaseOf("old"))
        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, registry.statusOf("old")?.failure)
    }

    @Test
    fun `after a restart a freeze the process did not finish is frozen, and a Resume is not`() {
        recordOnDisk(
            "a" to entry("freezing"),
            "b" to entry("failed"),
            "c" to entry("resuming"),
            "d" to entry("frozen"),
        )

        assertEquals(listOf("a", "b", "c", "d"), registry.restrictedContexts())
        assertEquals(ContextPhase.FROZEN, registry.recordOf("a")?.phase)
        assertEquals(ContextPhase.FROZEN, registry.recordOf("b")?.phase)
        assertEquals(ContextPhase.RESUMING, registry.recordOf("c")?.phase)
        assertEquals("frozen", storage.phaseOf("a"))
        // The init-time restriction is what the engine enforces.
        assertEquals(EngineEnforcement.ENFORCED, registry.statusOf("c")?.enforcement)
    }

    @Test
    fun `a damaged record restricts every context until reconstructed`() {
        storage = MemoryStorage(AtomicJsonFile.Read.Corrupt("malformed json"))
        registry.setStorageForTest(storage)

        assertEquals(listOf(TabLifecycleRegistry.ALL_CONTEXTS), registry.restrictedContexts())
        assertTrue(registry.isRestricted("anything"))
        assertTrue(registry.anyRestricted())
        assertFalse(registry.isRestricted(null))

        // Survives a restart: still recovery.
        restart()
        assertTrue(registry.inRecovery())
        assertEquals(listOf(TabLifecycleRegistry.ALL_CONTEXTS), registry.restrictedContexts())
    }

    @Test
    fun `an entry that cannot be understood is damage, not absence`() {
        recordOnDisk("x" to JSONObject().put("phase", "sleeping"))

        assertTrue(registry.inRecovery())
        assertTrue(registry.isRestricted("other"))
    }

    /** A record as this version writes it, with [change] applied. */
    private fun damagedOnDisk(change: JSONObject.() -> Unit) {
        val json = JSONObject().put("version", 1).put("mode", "normal").put("tabs", JSONObject())
            .put("contexts", JSONObject().put("ctx", entry("frozen")))
        storage = MemoryStorage(AtomicJsonFile.Read.Present(json.apply(change)))
        registry.setStorageForTest(storage)
    }

    @Test
    fun `a field of the wrong type is damage, not absence`() {
        val damages = listOf<JSONObject.() -> Unit>(
            { put("contexts", org.json.JSONArray()) },
            { put("contexts", "ctx") },
            { remove("contexts") },
            { put("mode", 1) },
            { put("tabs", org.json.JSONArray()) },
            { put("since", "yesterday") },
            { getJSONObject("contexts").put("ctx", org.json.JSONArray()) },
            { getJSONObject("contexts").getJSONObject("ctx").put("owner", 7) },
            { getJSONObject("contexts").getJSONObject("ctx").put("wakeTab", JSONObject()) },
            { getJSONObject("contexts").getJSONObject("ctx").put("recovered", "yes") },
            { getJSONObject("contexts").getJSONObject("ctx").put("phase", 2) },
        )
        damages.forEachIndexed { index, damage ->
            damagedOnDisk(damage)

            assertTrue(registry.inRecovery(), "damage $index")
            assertTrue(registry.isRestricted("ctx"), "damage $index")
            assertTrue(registry.isRestricted("other"), "damage $index")
        }
    }

    @Test
    fun `a record of another or no format version is damage`() {
        for (version in listOf<Any?>(null, 2, "1", 1.5)) {
            damagedOnDisk { if (version == null) remove("version") else put("version", version) }

            assertTrue(registry.inRecovery(), "version $version")
        }
    }

    @Test
    fun `the hold-only record of the first sleep builds is read as it was written`() {
        storage = MemoryStorage(
            AtomicJsonFile.Read.Present(
                JSONObject().put("version", 1).put("tabs", JSONObject().put("t", JSONObject().put("hold", "manual"))),
            ),
        )
        registry.setStorageForTest(storage)

        assertFalse(registry.inRecovery())
        assertFalse(registry.isRestricted("ctx"))
        assertTrue(registry.isHeld("t"))
    }

    @Test
    fun `a recovery that could not be written still restricts everything`() {
        storage = MemoryStorage(AtomicJsonFile.Read.Corrupt("empty")).apply { failWrites = true }
        registry.setStorageForTest(storage)

        assertTrue(registry.inRecovery())
        assertEquals(listOf(TabLifecycleRegistry.ALL_CONTEXTS), registry.restrictedContexts())
    }

    @Test
    fun `the reconstruction writes normal mode first, and the engine wildcard ends separately`() {
        storage = MemoryStorage(AtomicJsonFile.Read.Corrupt("malformed json"))
        registry.setStorageForTest(storage)
        registry.inRecovery()

        assertTrue(
            registry.installReconstruction(
                mapOf(
                    "a" to ContextRecord("c1", ContextPhase.FROZEN, recovered = true),
                    "o" to ContextRecord(null, ContextPhase.ORPHANED),
                ),
            ),
        )

        // On disk a restart is safe now: explicit records, normal mode.
        assertEquals("normal", (storage.record as AtomicJsonFile.Read.Present).json.getString("mode"))
        assertEquals(listOf("a", "o"), registry.restrictedContexts())
        // In this process "*" stays until its lift is acknowledged.
        assertTrue(registry.inRecovery())
        assertTrue(registry.isRestricted("unlisted"))

        registry.endWildcard()
        assertFalse(registry.inRecovery())
        assertFalse(registry.isRestricted("unlisted"))
        assertTrue(registry.isRestricted("a"))
        assertTrue(registry.recordOf("a")!!.recovered)
    }

    @Test
    fun `the reconstruction is refused in normal mode`() {
        assertFalse(registry.installReconstruction(mapOf("a" to ContextRecord("c1", ContextPhase.FROZEN))))
        assertFalse(registry.isRestricted("a"))
    }

    @Test
    fun `owner reconciliation follows the table in 5_5`() {
        recordOnDisk(
            "pendingPresent" to entry("deletionPending", owner = "kept", previous = "frozen"),
            "pendingGone" to entry("deletionPending", owner = "gone", previous = "frozen"),
            "releasing" to entry("releasing", owner = "kept"),
            "frozenGone" to entry("frozen", owner = "gone"),
            "orphan" to entry("orphaned", owner = null),
            "frozenKept" to entry("frozen", owner = "kept"),
        )

        val due = registry.reconcileOwners(setOf("kept"))

        assertEquals(setOf("pendingGone", "releasing"), due.toSet())
        assertEquals(ContextPhase.FROZEN, registry.recordOf("pendingPresent")?.phase)
        assertEquals(ContextPhase.RELEASING, registry.recordOf("pendingGone")?.phase)
        assertEquals(ContextPhase.RELEASING, registry.recordOf("releasing")?.phase)
        assertEquals(ContextPhase.ORPHANED, registry.recordOf("frozenGone")?.phase)
        assertEquals(ContextPhase.ORPHANED, registry.recordOf("orphan")?.phase)
        assertEquals(ContextPhase.FROZEN, registry.recordOf("frozenKept")?.phase)
        assertEquals("orphaned", storage.phaseOf("frozenGone"))
    }

    @Test
    fun `a deletion is pending on disk before the row goes, and a cancel puts the phase back`() {
        recordOnDisk("ctx" to entry("frozen"))

        assertTrue(registry.beginDeletion("c1"))
        assertEquals("deletionPending", storage.phaseOf("ctx"))
        assertEquals("frozen", storage.contexts().getJSONObject("ctx").getString("previous"))
        assertTrue(registry.isRestricted("ctx"))

        assertTrue(registry.cancelDeletion("c1"))
        assertEquals("frozen", storage.phaseOf("ctx"))
    }

    @Test
    fun `a deletion that cannot be written leaves the phase as it was`() {
        recordOnDisk("ctx" to entry("frozen"))
        registry.recordOf("ctx")
        storage.failWrites = true

        assertFalse(registry.beginDeletion("c1"))
        assertEquals(ContextPhase.FROZEN, registry.recordOf("ctx")?.phase)
    }

    @Test
    fun `removing records after a lift is one write, and a failed one keeps them all`() {
        recordOnDisk("a" to entry("frozen"), "b" to entry("frozen"))
        val gen = assertNotNull(registry.beginResume(listOf("a", "b"), null))
        storage.failWrites = true

        assertNull(registry.removeRecords(listOf("a", "b"), gen))
        assertTrue(registry.isRestricted("a"))
        assertTrue(registry.isRestricted("b"))

        storage.failWrites = false
        assertEquals(listOf("a", "b"), registry.removeRecords(listOf("a", "b"), gen))
        assertFalse(registry.isRestricted("a"))
        assertEquals(0, storage.contexts().length())
    }

    @Test
    fun `every context change raises the revision`() {
        val before = registry.revision()
        registry.beginFreeze("c1", listOf("ctx"))
        val afterFreeze = registry.revision()
        registry.setEnforcement(listOf("ctx"), EngineEnforcement.ENFORCED)

        assertTrue(afterFreeze > before)
        assertTrue(registry.revision() > afterFreeze)
        assertEquals(registry.revision(), registry.snapshot().revision)
    }

    @Test
    fun `sleep holds and context records share the file without losing each other`() {
        registry.beginFreeze("c1", listOf("ctx"))
        val gen = registry.beginSleep("tab", SleepHoldKind.MANUAL, private = false)
        registry.completeSleep("tab", gen)

        val json = (storage.record as AtomicJsonFile.Read.Present).json
        assertTrue(json.getJSONObject("tabs").has("tab"))
        assertEquals("freezing", json.getJSONObject("contexts").getJSONObject("ctx").getString("phase"))
    }

    @Test
    fun `a record waiting for its data to be deleted holds no owner`() {
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("own", "group")))
        registry.setPhase(listOf("own", "group"), gen, ContextPhase.FROZEN)
        assertNotNull(registry.beginRelease(listOf("group")))

        // Frozen, with an isolation group whose release did not finish.
        assertEquals(ContextPhase.FROZEN, registry.ownerPhase("c1"))

        // Resumed: only the group is left, which does not make it frozen.
        assertNotNull(registry.removeRecords(listOf("own"), gen))
        assertNull(registry.ownerPhase("c1"))
        assertTrue(registry.isRestricted("group"))
    }

}
