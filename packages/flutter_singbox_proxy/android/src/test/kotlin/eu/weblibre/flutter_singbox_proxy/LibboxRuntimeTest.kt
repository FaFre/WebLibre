package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlin.test.assertNull
import org.mockito.Mockito.mock

internal class LibboxRuntimeTest {
    /**
     * libbox 1.14 copies the config — WireGuard private keys, SOCKS
     * credentials — into every report it writes: crash reports, the OOM
     * recorder's draft and reports, the power report draft. Each copy goes;
     * the reports themselves stay.
     */
    @Test
    fun deleteConfigSnapshotCopies_removesEveryCopyAndNothingElse() {
        val working = kotlin.io.path.createTempDirectory("libbox-working").toFile()
        try {
            val copies = listOf(
                "crash_reports/2026-11-01T05-00-00/configuration.json",
                "oom_draft/configuration.json",
                "oom_reports/2026-11-01T05-00-00/configuration.json",
                "power_draft/configuration.json",
                "power_reports/2026-11-01T05-00-00/configuration.json",
            ).map { path -> working.resolve(path) }
            val kept = listOf(
                "crash_reports/2026-11-01T05-00-00/go.log",
                "oom_draft/metadata.json",
                "cache.db",
            ).map { path -> working.resolve(path) }
            (copies + kept).forEach { file ->
                file.parentFile.mkdirs()
                file.writeText("{}")
            }

            deleteConfigSnapshotCopies(working)

            assertEquals(emptyList(), copies.filter { file -> file.exists() })
            assertTrue(kept.all { file -> file.exists() })
        } finally {
            working.deleteRecursively()
        }
    }

    /**
     * sing-box hands the platform writer every line whatever `log.level` says
     * (`log/observable.go` only takes its early return when there is no
     * platform writer), so this side does the filtering — but it must not do it
     * *here*. SingboxRuntimeManager reads the text of lines it will not
     * forward, to recognise the oversized-packet error behind "connects but
     * nothing loads". Dropping at this level would hide that error from it.
     */
    @Test
    fun forwardLogIterator_offersEveryEntryRegardlessOfLevel() {
        val runtime = LibboxRuntime(
            mock(Context::class.java),
            mock(PlatformDohResolver::class.java),
        )
        val received = mutableListOf<Pair<Int, String>>()
        runtime.setLogSink { level, message -> received += level to message }
        runtime.setMaxLogLevel(3)

        runtime.forwardLogIterator(
            FakeLogIterator(
                listOf(
                    FakeLogEntry(5, "peer - failed to send data packets: sendmsg: message too long"),
                    FakeLogEntry(4, "inbound connection to example.test"),
                    FakeLogEntry(2, "an error"),
                ),
            ),
        )

        assertEquals(
            listOf(
                5 to "peer - failed to send data packets: sendmsg: message too long",
                4 to "inbound connection to example.test",
                2 to "an error",
            ),
            received,
        )
    }

    @Test
    fun version_isNullWithoutLibbox() {
        val runtime = LibboxRuntime(
            mock(Context::class.java),
            mock(PlatformDohResolver::class.java),
        )

        assertNull(runtime.version())
    }

    @Test
    fun stampedVersion_keepsAStampedVersion() {
        assertEquals("1.14.4", stampedVersion("1.14.4"))
        assertEquals("1.14.4", stampedVersion(" 1.14.4\n"))
    }

    @Test
    fun stampedVersion_dropsAnUnstampedBuild() {
        assertNull(stampedVersion("unknown"))
        assertNull(stampedVersion(""))
        assertNull(stampedVersion(null))
    }
}

private class FakeLogEntry(private val level: Int, private val message: String) {
    fun getLevel(): Int = level

    fun getMessage(): String = message
}

private class FakeLogIterator(entries: List<FakeLogEntry>) {
    private val entries = entries.iterator()

    fun hasNext(): Boolean = entries.hasNext()

    fun next(): Any = entries.next()
}
