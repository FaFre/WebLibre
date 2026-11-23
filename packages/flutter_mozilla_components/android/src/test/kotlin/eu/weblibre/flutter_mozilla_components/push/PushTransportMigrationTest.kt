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

import eu.weblibre.flutter_mozilla_components.startup.MaintenanceScan
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import java.io.IOException
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.json.JSONObject
import org.junit.After
import org.junit.Assume.assumeTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"
private const val PROFILE_C = "0199a0b1-3333-7333-8333-333333333333"

// Robolectric for android.util.Log, which the migration logs to.
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [33])
class PushTransportMigrationTest {
    private lateinit var root: File
    private lateinit var paths: StartupPaths

    @Before
    fun setUp() {
        root = Files.createTempDirectory("weblibre_push_migration").toFile()
        paths = StartupPaths(root)
        PushTransportMigration.resetForTest()
    }

    @After
    fun tearDown() {
        PushTransportMigration.resetForTest()
        root.deleteRecursively()
    }

    private fun profile(id: String, transport: Boolean = true): File {
        val dir = paths.profileDir(id)
        File(dir, "databases").mkdirs()
        if (transport) seedTransport(dir)
        return dir
    }

    private fun seedTransport(tree: File) {
        PushTransportFiles.connectorFiles(tree).take(2).forEach {
            it.parentFile.mkdirs()
            it.writeText("tokens and keys")
        }
        File(PushTransportFiles.queuedMessagesDir(tree), "m1.push").apply {
            parentFile.mkdirs()
            writeText("decrypted payload")
        }
    }

    private fun hasTransport(id: String) = PushTransportFiles.hasConnectorDatabase(paths.profileDir(id))

    private fun hasQueue(id: String) = PushTransportFiles.queuedMessagesDir(paths.profileDir(id)).exists()

    private fun endpointsReset(id: String) = PushTransportFiles.endpointResetMarker(paths.profileDir(id)).exists()

    private fun state(): JSONObject = JSONObject(paths.pushTransportMigrationFile.readText())

    private fun open() = PushTransportMigration.awaitOpen(paths, 5_000, committed = true)

    @Test
    fun `a sole legacy transport is kept`() {
        // The accepted limitation: nothing tells an old clone whose source is
        // gone from the profile that made it, and resetting every sole
        // transport would cost every push user a pushsubscriptionchange round.
        profile(PROFILE_A)
        profile(PROFILE_B, transport = false)

        assertTrue(open())

        assertTrue(hasTransport(PROFILE_A))
        assertTrue(hasQueue(PROFILE_A))
        assertFalse(endpointsReset(PROFILE_A))
        assertEquals("done", state().getString("phase"))
    }

    @Test
    fun `two legacy transports are both reset, without sending anything`() {
        profile(PROFILE_A)
        profile(PROFILE_B)
        profile(PROFILE_C, transport = false)
        val ownership = PushOwnershipStore(paths)
        ownership.record("token-a", PROFILE_A, "scope-a")
        ownership.record("token-c", PROFILE_C, "scope-c")

        assertTrue(open())

        for (id in listOf(PROFILE_A, PROFILE_B)) {
            assertFalse(hasTransport(id), id)
            assertTrue(PushTransportFiles.connectorFiles(paths.profileDir(id)).none(File::exists), id)
            assertFalse(hasQueue(id), id)
            assertTrue(endpointsReset(id), id)
        }
        // The cache loses the reset profiles' entries; others keep theirs.
        assertEquals(null, ownership.ownerOf("token-a"))
        assertEquals(PROFILE_C, ownership.ownerOf("token-c")?.profileId)
        // A profile without a transport is not touched.
        assertFalse(endpointsReset(PROFILE_C))
    }

    @Test
    fun `nothing opens before a commit`() {
        profile(PROFILE_A)
        profile(PROFILE_B)

        assertFalse(PushTransportMigration.awaitOpen(paths, 1_000, committed = false))

        assertTrue(hasTransport(PROFILE_A))
        assertFalse(paths.pushTransportMigrationFile.exists())
    }

    @Test
    fun `a transport deleted by maintenance still counts`() {
        // A queued delete runs before anything commits. Captured first, the
        // deleted clone still makes its source reset.
        profile(PROFILE_A)
        val clone = profile(PROFILE_B)
        PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)
        clone.deleteRecursively()

        assertTrue(open())

        assertFalse(hasTransport(PROFILE_A))
        assertTrue(endpointsReset(PROFILE_A))
    }

    @Test
    fun `a transport under a restore workspace counts, and lands on its target`() {
        // A restore over B was interrupted with B's original moved aside. Only A
        // is in the profile list; recovery has not decided which tree survives.
        profile(PROFILE_A)
        seedTransport(paths.restoreOldDir("task-1"))
        paths.maintenanceJournalsDir.mkdirs()
        paths.journalFile("task-1").writeText(
            JSONObject()
                .put("taskId", "task-1")
                .put("kind", "restore")
                .put("phase", "oldMoved")
                .put("targetProfileId", PROFILE_B)
                .toString(),
        )
        PushTransportMigration.captureEvidence(paths, MaintenanceScan.scan(paths))
        assertEquals(listOf(PROFILE_A, PROFILE_B), state().getJSONArray("legacy").let { a ->
            (0 until a.length()).map(a::getString)
        })

        // Recovery rolled back: the aside tree is B again, transport and all.
        paths.journalFile("task-1").delete()
        paths.profilesDir.mkdirs()
        assertTrue(paths.restoreOldDir("task-1").renameTo(paths.profileDir(PROFILE_B)))

        assertTrue(open())

        assertFalse(hasTransport(PROFILE_A))
        assertFalse(hasTransport(PROFILE_B))
    }

    @Test
    fun `profiles that cannot be listed are no evidence of none`() {
        profile(PROFILE_A)
        paths.profilesDir.setReadable(false)
        try {
            assumeTrue("running with permission checks", paths.profilesDir.listFiles() == null)

            assertFailsWith<IOException> {
                PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)
            }
            assertFalse(paths.pushTransportMigrationFile.exists())
            assertFalse(open())
        } finally {
            paths.profilesDir.setReadable(true)
        }
    }

    @Test
    fun `an existing record is never recaptured`() {
        profile(PROFILE_A)
        PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)
        profile(PROFILE_B)

        PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)

        assertEquals(1, state().getJSONArray("legacy").length())
    }

    @Test
    fun `an ambiguous old restore resets even a sole transport`() {
        val target = profile(PROFILE_A)
        PushTransportFiles.transportUnknownMarker(target).apply {
            parentFile.mkdirs()
            writeText("{}")
        }

        assertTrue(open())

        assertFalse(hasTransport(PROFILE_A))
        assertFalse(PushTransportFiles.transportUnknownMarker(target).exists())
        assertTrue(endpointsReset(PROFILE_A))
    }

    @Test
    fun `a corrupt record is never done and resets every transport`() {
        profile(PROFILE_A)
        paths.pushTransportMigrationFile.apply {
            parentFile.mkdirs()
            writeText("{not json")
        }

        assertTrue(open())

        assertFalse(hasTransport(PROFILE_A))
        assertEquals("done", state().getString("phase"))
    }

    @Test
    fun `an unfinished reset is retried with its own set, not a fresh count`() {
        // A crash after A's reset: B alone now looks like a sole transport, but
        // the set written before any delete still names it.
        profile(PROFILE_A, transport = false)
        profile(PROFILE_B)
        paths.pushTransportMigrationFile.apply {
            parentFile.mkdirs()
            writeText(
                JSONObject()
                    .put("version", 1)
                    .put("phase", "resetting")
                    .put("reset", org.json.JSONArray(listOf(PROFILE_A, PROFILE_B)))
                    .toString(),
            )
        }

        assertTrue(open())

        assertFalse(hasTransport(PROFILE_B))
        assertTrue(endpointsReset(PROFILE_B))
    }

    @Test
    fun `a failed reset is not done, and keeps the set for the retry`() {
        profile(PROFILE_A)
        profile(PROFILE_B)
        // A directory where the connector database should be cannot be deleted
        // as a file.
        val blocker = PushTransportFiles.connectorFiles(paths.profileDir(PROFILE_B))[1]
        blocker.delete()
        File(blocker, "child").apply {
            parentFile.mkdirs()
            writeText("x")
        }

        assertFalse(open())
        assertEquals("resetting", state().getString("phase"))

        blocker.deleteRecursively()
        assertTrue(open())
        assertEquals("done", state().getString("phase"))
        assertFalse(hasTransport(PROFILE_B))
    }

    /** Runs [block] while the record's folder cannot be opened, so it cannot be synced. */
    private fun withUnsyncableRecord(block: () -> Unit) {
        val dir = paths.pushTransportMigrationFile.parentFile
        dir.setReadable(false)
        try {
            assumeTrue(
                "running with permission checks",
                runCatching { java.nio.channels.FileChannel.open(dir.toPath()).close() }.isFailure,
            )
            block()
        } finally {
            dir.setReadable(true)
        }
    }

    private fun writeState(json: JSONObject) {
        paths.pushTransportMigrationFile.apply {
            parentFile.mkdirs()
            writeText(json.toString())
        }
    }

    @Test
    fun `a visible reset set is confirmed durable before anything is deleted`() {
        // A write that renamed the set into place and then failed its directory
        // sync looks the same as a durable one. Deleting on it would let a
        // power cut take the set back after the first delete.
        profile(PROFILE_A)
        profile(PROFILE_B)
        writeState(
            JSONObject().put("version", 1).put("phase", "resetting")
                .put("reset", org.json.JSONArray(listOf(PROFILE_A, PROFILE_B))),
        )

        withUnsyncableRecord {
            assertFalse(open())
            assertTrue(hasTransport(PROFILE_A))
            assertTrue(hasTransport(PROFILE_B))
        }

        assertTrue(open())
        assertFalse(hasTransport(PROFILE_A))
        assertFalse(hasTransport(PROFILE_B))
    }

    @Test
    fun `an existing evidence record that cannot be confirmed is no evidence`() {
        profile(PROFILE_A)
        PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)

        withUnsyncableRecord {
            assertFailsWith<IOException> {
                PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)
            }
        }

        PushTransportMigration.captureEvidence(paths, MaintenanceScan.EMPTY)
    }

    @Test
    fun `a done that cannot be confirmed keeps push closed`() {
        profile(PROFILE_A)
        writeState(JSONObject().put("version", 1).put("phase", "done"))

        withUnsyncableRecord { assertFalse(open()) }

        assertTrue(open())
        assertTrue(hasTransport(PROFILE_A))
    }

    @Test
    fun `once done it stays done`() {
        profile(PROFILE_A)
        assertTrue(open())

        PushTransportMigration.resetForTest()
        profile(PROFILE_B)

        assertTrue(open())
        assertTrue(hasTransport(PROFILE_A))
        assertTrue(hasTransport(PROFILE_B))
    }

    @Test
    fun `a reset is idempotent and writes the marker before deleting`() {
        val tree = profile(PROFILE_A)

        PushTransportFiles.reset(tree)
        PushTransportFiles.reset(tree)

        assertTrue(PushTransportFiles.endpointResetMarker(tree).exists())
        assertFalse(PushTransportFiles.hasConnectorDatabase(tree))
    }
}
