package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito.mock

internal class LibboxRuntimeTest {
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
