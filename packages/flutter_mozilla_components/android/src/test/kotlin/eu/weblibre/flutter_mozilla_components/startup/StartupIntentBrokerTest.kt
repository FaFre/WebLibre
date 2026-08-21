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
import java.nio.file.Files
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"

class StartupIntentBrokerTest {
    private lateinit var filesDir: File
    private lateinit var paths: StartupPaths
    private var now: Long = 1_000_000L

    private class RecordingWriter : CommittedProfileWriter {
        override fun persist(profileId: String) = Unit
    }

    @BeforeTest
    fun setUp() {
        filesDir = Files.createTempDirectory("weblibre_broker").toFile()
        paths = StartupPaths(filesDir)
        paths.profilesDir.mkdirs()
        paths.maintenanceJournalsDir.mkdirs()
        paths.maintenanceRestoreDir.mkdirs()
        paths.startupIntentsDir.mkdirs()
        StartupArbiter.resetForTest()
    }

    @AfterTest
    fun tearDown() {
        StartupArbiter.resetForTest()
        filesDir.deleteRecursively()
    }

    private fun writeProfile(profileId: String) {
        val dir = File(paths.profilesDir, "profile-$profileId")
        dir.mkdirs()
        File(dir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", profileId).put("name", "Profile").toString(),
        )
    }

    private fun initialize() {
        StartupArbiter.initialize(paths, RecordingWriter()) { now }
    }

    private fun descriptor(url: String) = StartupIntentDescriptor(
        action = "android.intent.action.VIEW",
        dataUri = url,
    )

    private fun enqueue(url: String) = checkNotNull(
        StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = descriptor(url),
            nowMillis = now,
        ),
    )

    // --- what gets taken ------------------------------------------------------

    @Test
    fun `an uncommitted process takes the launch`() {
        // The window this exists for: nothing on the Dart side is listening, so
        // the ordinary delivery would send the intent into a void.
        writeProfile(PROFILE_A)
        initialize()

        assertTrue(StartupIntentBroker.shouldTake())
    }

    @Test
    fun `a committed process does not take the launch`() {
        // Once committed, the app's providers exist and the live path works. Taking
        // it here would turn one delivery into two.
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.tryCommitExternal(requestedProfileId = null, trusted = false)

        assertFalse(StartupIntentBroker.shouldTake())
    }

    @Test
    fun `maintenance takes the launch too`() {
        // Nothing is committed while maintenance owns the process, and it may own
        // it for a whole restore.
        initialize()

        assertTrue(StartupIntentBroker.shouldTake())
    }

    // --- ordering and delivery -------------------------------------------------

    @Test
    fun `launches come back in the order they arrived`() {
        initialize()
        enqueue("https://first.test")
        enqueue("https://second.test")
        enqueue("https://third.test")

        val claimed = StartupIntentBroker.claim(paths, "engine-1", now)

        assertEquals(
            listOf("https://first.test", "https://second.test", "https://third.test"),
            claimed.map { it.dataUri },
        )
    }

    @Test
    fun `a claimed launch is not handed to a second engine`() {
        initialize()
        enqueue("https://a.test")

        StartupIntentBroker.claim(paths, "engine-1", now)
        val second = StartupIntentBroker.claim(paths, "engine-2", now)

        assertTrue(second.isEmpty())
    }

    @Test
    fun `the same engine may re-claim what it already holds`() {
        // A engine that asked twice — after a hot restart, say — must get its own
        // work back rather than be locked out of it.
        initialize()
        enqueue("https://a.test")

        StartupIntentBroker.claim(paths, "engine-1", now)
        val again = StartupIntentBroker.claim(paths, "engine-1", now)

        assertEquals(1, again.size)
    }

    @Test
    fun `an expired claim is taken over rather than stranded`() {
        initialize()
        enqueue("https://a.test")
        StartupIntentBroker.claim(paths, "engine-1", now)

        val later = now + STARTUP_INTENT_CLAIM_TTL_MS
        val second = StartupIntentBroker.claim(paths, "engine-2", later)

        assertEquals(1, second.size)
    }

    // --- acknowledgement -------------------------------------------------------

    @Test
    fun `an acknowledged launch is never replayed`() {
        initialize()
        val entry = enqueue("https://a.test")
        StartupIntentBroker.claim(paths, "engine-1", now)

        assertTrue(StartupIntentBroker.acknowledge(paths, entry.id, "engine-1"))
        assertTrue(StartupIntentBroker.claim(paths, "engine-1", now).isEmpty())
    }

    @Test
    fun `only the holder may acknowledge`() {
        // Otherwise one engine could retire work another is still doing, and the
        // launch would be lost with no record that it ever existed.
        initialize()
        val entry = enqueue("https://a.test")
        StartupIntentBroker.claim(paths, "engine-1", now)

        assertFalse(StartupIntentBroker.acknowledge(paths, entry.id, "engine-2"))
        assertEquals(1, StartupIntentBroker.claim(paths, "engine-1", now).size)
    }

    @Test
    fun `an unclaimed launch cannot be acknowledged`() {
        initialize()
        val entry = enqueue("https://a.test")

        assertFalse(StartupIntentBroker.acknowledge(paths, entry.id, "engine-1"))
    }

    @Test
    fun `a released launch goes to whoever asks next`() {
        initialize()
        val entry = enqueue("https://a.test")
        StartupIntentBroker.claim(paths, "engine-1", now)

        assertTrue(StartupIntentBroker.release(paths, entry.id, "engine-1"))

        assertEquals(1, StartupIntentBroker.claim(paths, "engine-2", now).size)
    }

    // --- expiry and durability -------------------------------------------------

    @Test
    fun `a stale launch is not delivered`() {
        // Opening a link the user tapped twenty minutes ago is not helpful.
        initialize()
        enqueue("https://a.test")

        val later = now + STARTUP_INTENT_TTL_MS
        assertTrue(StartupIntentBroker.claim(paths, "engine-1", later).isEmpty())
    }

    @Test
    fun `pruning clears what can no longer be delivered`() {
        initialize()
        enqueue("https://a.test")

        StartupIntentBroker.prune(paths, now + STARTUP_INTENT_TTL_MS)

        assertTrue(StartupIntentQueueStore(paths).read().entries.isEmpty())
    }

    @Test
    fun `the queue survives being written and read again`() {
        // The point of the file: a launch queued in one process is delivered by
        // the next one.
        initialize()
        enqueue("https://a.test")

        val reread = StartupIntentQueueStore(paths).read()

        assertEquals(1, reread.entries.size)
        assertEquals("https://a.test", reread.entries.single().dataUri)
    }

    @Test
    fun `sequence numbers never repeat`() {
        initialize()
        val first = enqueue("https://a.test")
        val second = enqueue("https://b.test")

        assertTrue(second.sequence > first.sequence)
    }

    // --- extras ---------------------------------------------------------------

    @Test
    fun `a launch carries its action, data and extras through the queue`() {
        // The round trip that matters: what a share or a shortcut needs has to
        // still be there after the file has been written and read again.
        initialize()

        StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.SEND",
                dataUri = "https://a.test",
                mimeType = "text/plain",
                categories = listOf("android.intent.category.BROWSABLE"),
                extras = mapOf(
                    "shortcut_container_mode" to "isolated",
                    "count" to 3,
                    "tags" to listOf("a", "b"),
                ),
            ),
            nowMillis = now,
        )

        val claimed = StartupIntentBroker.claim(paths, "engine-1", now).single()

        assertEquals("android.intent.action.SEND", claimed.action)
        assertEquals("https://a.test", claimed.dataUri)
        assertEquals("text/plain", claimed.mimeType)
        assertTrue(claimed.categories.contains("android.intent.category.BROWSABLE"))
        assertEquals("isolated", claimed.extras["shortcut_container_mode"])
        assertEquals(3, claimed.extras["count"])
        assertEquals(listOf("a", "b"), claimed.extras["tags"])
    }

    @Test
    fun `a trusted profile hint only counts for a trusted launch`() {
        // An untrusted caller naming a profile must not be able to steer the
        // process onto it.
        initialize()

        StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.VIEW",
                trustedProfileId = PROFILE_A,
                classification = LaunchClassification.UNKNOWN,
            ),
            nowMillis = now,
        )

        val claimed = StartupIntentBroker.claim(paths, "engine-1", now).single()

        assertEquals(PROFILE_A, claimed.trustedProfileId)
        assertNull(claimed.effectiveTrustedProfileId)
    }

    @Test
    fun `a trusted launch keeps its profile across the queue`() {
        // The other half of the rule above, and the one that was silently broken:
        // `MainActivity` queued every launch with the defaults, so a pinned PWA
        // that arrived while the picker or maintenance owned the process came back
        // as UNKNOWN with no profile. The queue is the only channel that can carry
        // this — Dart is forbidden from deriving trust from the raw extras the
        // entry still holds, because those are exactly what any app can forge.
        initialize()

        StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.VIEW",
                dataUri = "https://pwa.test/app",
                trustedProfileId = PROFILE_A,
                classification = LaunchClassification.TRUSTED_PWA,
            ),
            nowMillis = now,
        )

        val claimed = StartupIntentBroker.claim(paths, "engine-1", now).single()

        assertEquals(LaunchClassification.TRUSTED_PWA, claimed.classification)
        assertEquals(PROFILE_A, claimed.effectiveTrustedProfileId)
    }

    @Test
    fun `a trusted basic shortcut keeps its profile across the queue`() {
        initialize()

        StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.VIEW",
                dataUri = "https://shortcut.test",
                trustedProfileId = PROFILE_A,
                classification = LaunchClassification.TRUSTED_SHORTCUT,
            ),
            nowMillis = now,
        )

        val claimed = StartupIntentBroker.claim(paths, "engine-1", now).single()

        assertEquals(LaunchClassification.TRUSTED_SHORTCUT, claimed.classification)
        assertEquals(PROFILE_A, claimed.effectiveTrustedProfileId)
    }

    // --- shared files ----------------------------------------------------------

    @Test
    fun `a launch with no shared file needs no staging`() {
        assertFalse(StartupIntentPayloads.needsStaging(descriptor("https://a.test")))
    }

    @Test
    fun `a content uri in the data needs staging`() {
        // Its grant is scoped to the receiving activity, so it resolves to
        // nothing once the process this queue exists to survive has died.
        assertTrue(
            StartupIntentPayloads.needsStaging(
                StartupIntentDescriptor(dataUri = "content://media/external/images/1"),
            ),
        )
    }

    @Test
    fun `a shared stream needs staging`() {
        assertTrue(
            StartupIntentPayloads.needsStaging(
                StartupIntentDescriptor(
                    action = "android.intent.action.SEND",
                    extras = mapOf(
                        "android.intent.extra.STREAM" to "content://media/external/images/1",
                    ),
                ),
            ),
        )
    }

    @Test
    fun `a file uri is already durable`() {
        // Already staged, or never a grant in the first place. Copying it again
        // would double the disk cost for nothing.
        assertFalse(
            StartupIntentPayloads.needsStaging(
                StartupIntentDescriptor(dataUri = "file:///data/x/stream"),
            ),
        )
    }

    @Test
    fun `a launch whose file cannot be staged is declined, not queued`() {
        // The rule §7.1 states directly: block rather than promise a replay that
        // cannot be delivered. A queued entry pointing at a dead content URI is a
        // share of a file the user will never see.
        initialize()

        val queued = StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.SEND",
                dataUri = "content://media/external/images/1",
            ),
            nowMillis = now,
            stage = { _, _ -> null },
        )

        assertNull(queued)
        assertTrue(StartupIntentQueueStore(paths).read().entries.isEmpty())
    }

    @Test
    fun `a staged launch records where its bytes went`() {
        initialize()

        val entry = StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = StartupIntentDescriptor(
                action = "android.intent.action.SEND",
                dataUri = "content://media/external/images/1",
            ),
            nowMillis = now,
            stage = { _, descriptor ->
                descriptor.copy(dataUri = "file:///staged/data")
            },
        )

        assertEquals(entry?.id, entry?.payloadDirName)
        assertEquals("file:///staged/data", entry?.dataUri)
    }

    @Test
    fun `a launch that needed no staging records no payload directory`() {
        initialize()

        val entry = StartupIntentBroker.enqueue(
            paths = paths,
            descriptor = descriptor("https://a.test"),
            nowMillis = now,
            stage = { _, descriptor -> descriptor },
        )

        assertNull(entry?.payloadDirName)
    }

    @Test
    fun `acknowledging a staged launch removes its bytes`() {
        initialize()

        val entry = checkNotNull(
            StartupIntentBroker.enqueue(
                paths = paths,
                descriptor = StartupIntentDescriptor(
                    action = "android.intent.action.SEND",
                    dataUri = "content://media/external/images/1",
                ),
                nowMillis = now,
                stage = { entryId, descriptor ->
                    paths.startupIntentPayloadDir(entryId).mkdirs()
                    File(paths.startupIntentPayloadDir(entryId), "data").writeText("bytes")
                    descriptor.copy(dataUri = "file:///staged/data")
                },
            ),
        )
        StartupIntentBroker.claim(paths, "engine-1", now)

        StartupIntentBroker.acknowledge(paths, entry.id, "engine-1")

        assertFalse(paths.startupIntentPayloadDir(entry.id).exists())
    }

    @Test
    fun `pruning sweeps bytes no entry refers to`() {
        // A crash between staging and the queue write leaves a directory nothing
        // names. Sweeping by what survives collects those too.
        initialize()
        val orphan = paths.startupIntentPayloadDir("orphan")
        orphan.mkdirs()
        File(orphan, "data").writeText("bytes")

        StartupIntentBroker.prune(paths, now)

        assertFalse(orphan.exists())
    }

    @Test
    fun `pruning keeps the bytes of a launch still waiting`() {
        initialize()
        val entry = enqueue("https://a.test")
        val payload = paths.startupIntentPayloadDir(entry.id)
        payload.mkdirs()
        File(payload, "data").writeText("bytes")

        StartupIntentBroker.prune(paths, now)

        assertTrue(payload.exists())
    }
}
