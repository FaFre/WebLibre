package eu.weblibre.flutter_singbox_proxy

import kotlin.test.Test
import kotlin.test.assertEquals

internal class WireGuardHandshakeWatchTest {
    private val changes = mutableListOf<Pair<String, Boolean>>()
    private val watch = WireGuardHandshakeWatch { tag, answering -> changes += tag to answering }

    /** As sing-box hands them over: colored level, context, endpoint tag. */
    private fun line(tag: String, event: String) =
        "\u001B[37mDEBUG\u001B[0m[0005] endpoint/wireguard[$tag]: peer(7ept…vJwE) - $event"

    private fun retry(tag: String = TAG, attempt: Int = 2) =
        line(tag, "handshake did not complete after 5 seconds, retrying (try $attempt)")

    private fun response(tag: String = TAG) = line(tag, "received handshake response")

    /**
     * The log in issues #693 and #694: handshakes went unanswered for minutes
     * while the proxy read as up. New traffic restarts wireguard-go's own
     * count, so the same "try 2" repeats.
     */
    @Test
    fun reportsATunnelWhoseHandshakesGoUnanswered() {
        watch.onLogLine(line(TAG, "sending handshake initiation"))
        watch.onLogLine(retry(attempt = 2))
        watch.onLogLine(retry(attempt = 2))
        assertEquals(emptyList(), changes)

        watch.onLogLine(retry(attempt = 2))
        watch.onLogLine(retry(attempt = 3))

        assertEquals(listOf(TAG to false), changes)
    }

    @Test
    fun reportsATunnelThatAnswersAgain() {
        repeat(WireGuardHandshakeWatch.UNANSWERED_RETRIES) { watch.onLogLine(retry()) }
        watch.onLogLine(response())
        watch.onLogLine(response())

        assertEquals(listOf(TAG to false, TAG to true), changes)
    }

    /**
     * The peer may start the handshake itself. wireguard-go then logs the
     * initiation it received and the response it sent, never a "received
     * handshake response", and the tunnel works all the same.
     */
    @Test
    fun reportsATunnelThatRecoversThroughThePeersHandshake() {
        repeat(WireGuardHandshakeWatch.UNANSWERED_RETRIES) { watch.onLogLine(retry()) }
        watch.onLogLine(line(TAG, "received handshake initiation"))
        watch.onLogLine(line(TAG, "sending handshake response"))

        assertEquals(listOf(TAG to false, TAG to true), changes)
    }

    /** Ours to send, so it says nothing about whether the peer is there. */
    @Test
    fun sendingAResponseIsNoAnswer() {
        repeat(WireGuardHandshakeWatch.UNANSWERED_RETRIES) { watch.onLogLine(retry()) }
        watch.onLogLine(line(TAG, "sending handshake response"))

        assertEquals(listOf(TAG to false), changes)
    }

    @Test
    fun aSingleLostHandshakeIsNotNews() {
        watch.onLogLine(response())
        watch.onLogLine(retry())
        watch.onLogLine(retry())
        watch.onLogLine(response())

        assertEquals(listOf(TAG to true), changes)
    }

    @Test
    fun reportsATunnelWireGuardGaveUpOn() {
        watch.onLogLine(line(TAG, "handshake did not complete after 20 attempts, giving up"))

        assertEquals(listOf(TAG to false), changes)
    }

    @Test
    fun keepsTunnelsApart() {
        repeat(2) { watch.onLogLine(retry(tag = TAG)) }
        watch.onLogLine(retry(tag = OTHER_TAG))
        watch.onLogLine(retry(tag = TAG))

        assertEquals(listOf(TAG to false), changes)
    }

    @Test
    fun startsOverAfterAReset() {
        repeat(WireGuardHandshakeWatch.UNANSWERED_RETRIES) { watch.onLogLine(retry()) }
        watch.reset()
        repeat(WireGuardHandshakeWatch.UNANSWERED_RETRIES - 1) { watch.onLogLine(retry()) }
        watch.onLogLine(response())

        // The first answer after the reset is said, whatever was said before.
        assertEquals(listOf(TAG to false, TAG to true), changes)
    }

    @Test
    fun ignoresEverythingElse() {
        watch.onLogLine(line(TAG, "sending keepalive packet"))
        watch.onLogLine("endpoint/wireguard[$TAG]: udp bind has been updated")
        watch.onLogLine("inbound/socks[in-x]: inbound connection to example.test:443")
        watch.onLogLine(
            "connection: open connection to example.test:443 using " +
                "outbound/wireguard[$TAG]: lookup example.test: context deadline exceeded",
        )

        assertEquals(emptyList(), changes)
    }

    private companion object {
        const val TAG = "out-singbox_f1c6cf3a-9be2-477d-acf9-a94098312bf2"
        const val OTHER_TAG = "out-singbox_other"
    }
}
