package eu.weblibre.flutter_singbox_proxy

/**
 * Tells from sing-box's log whether each WireGuard tunnel's peer answers.
 *
 * "Running" only ever meant that the runtime started. A WireGuard tunnel
 * handshakes lazily, on its first packet, and one whose peer never answers
 * starts exactly as successfully as one that works — so a proxy read as up
 * while every load through it failed (issue #693). The log is where the
 * handshake shows: wireguard-go reports every initiation that goes unanswered
 * for five seconds and every response that arrives.
 *
 * sing-box hands every line to the platform whatever `log.level` says, so this
 * sees them at the default level too. Lines are matched on wireguard-go's own
 * wording, which sing-box lowercases and prefixes with the endpoint's tag:
 *
 * ```
 * endpoint/wireguard[out-…]: peer(7ept…vJwE) - handshake did not complete after 5 seconds, retrying (try 2)
 * endpoint/wireguard[out-…]: peer(7ept…vJwE) - received handshake response
 * endpoint/wireguard[out-…]: peer(7ept…vJwE) - received handshake initiation
 * ```
 *
 * Either side may start a handshake, so a peer answers in two ways: with a
 * response to ours, or with an initiation of its own, which we answer. Both
 * are logged only once wireguard-go has authenticated the message — a forged
 * or garbled one reads "received invalid … message" and has no `peer(…)` — so
 * both prove the peer is there. A tunnel that recovered through the peer's
 * handshake would otherwise read as not answering until we started one
 * ourselves, up to two minutes later, and nothing else could take that back.
 *
 * The verdict is per endpoint tag and changes on evidence only, and only a
 * change is reported. A tunnel is "not answering" after [UNANSWERED_RETRIES]
 * retries in a row without a response — fifteen seconds of silence — or when
 * wireguard-go gives up; it answers with the next response or initiation from
 * the peer, the first of a run included. Nothing is said before the first handshake, so a tunnel nobody has
 * used yet stays as it was. [reset] forgets everything: a new runtime instance
 * handshakes from scratch.
 *
 * Not thread-safe; [SingboxRuntimeManager] calls it from the log thread under
 * its own lock.
 */
internal class WireGuardHandshakeWatch(
    private val onChange: (endpointTag: String, answering: Boolean) -> Unit,
) {
    private class Tunnel {
        var unansweredRetries = 0
        var answering: Boolean? = null
    }

    private val tunnels = mutableMapOf<String, Tunnel>()

    /** Reads one log [line]; anything that is not a handshake event is ignored. */
    fun onLogLine(line: String) {
        // Cheap test first: this sees every line the runtime logs.
        if (!line.contains(ENDPOINT_MARKER)) return
        val match = PEER_EVENT.find(line) ?: return
        val tag = match.groupValues[1]
        val event = match.groupValues[2]

        when {
            event.startsWith(RESPONSE_RECEIVED) || event.startsWith(INITIATION_RECEIVED) ->
                answered(tag)
            // "… after 20 attempts, giving up" and "… after 5 seconds,
            // retrying (try 2)" share their start.
            event.startsWith(NOT_COMPLETED) && event.contains(GIVING_UP) ->
                unanswered(tag, gaveUp = true)
            event.startsWith(NOT_COMPLETED) && event.contains(RETRYING) ->
                unanswered(tag, gaveUp = false)
        }
    }

    /** Forgets every tunnel, without telling anyone: they all start over. */
    fun reset() {
        tunnels.clear()
    }

    private fun answered(tag: String) {
        val tunnel = tunnels.getOrPut(tag, ::Tunnel)
        tunnel.unansweredRetries = 0
        update(tag, tunnel, answering = true)
    }

    private fun unanswered(tag: String, gaveUp: Boolean) {
        val tunnel = tunnels.getOrPut(tag, ::Tunnel)
        tunnel.unansweredRetries++
        if (gaveUp || tunnel.unansweredRetries >= UNANSWERED_RETRIES) {
            update(tag, tunnel, answering = false)
        }
    }

    private fun update(tag: String, tunnel: Tunnel, answering: Boolean) {
        if (tunnel.answering == answering) return
        tunnel.answering = answering
        onChange(tag, answering)
    }

    internal companion object {
        /**
         * Retries in a row before a tunnel counts as not answering. Each one
         * follows five seconds without a response, and a single lost packet
         * on a mobile network is no reason to call a peer gone.
         */
        const val UNANSWERED_RETRIES = 3

        private const val ENDPOINT_MARKER = "endpoint/wireguard["
        private val PEER_EVENT = Regex("""endpoint/wireguard\[([^\]]+)\]: peer\([^)]*\) - (.+)$""")
        private const val RESPONSE_RECEIVED = "received handshake response"
        private const val INITIATION_RECEIVED = "received handshake initiation"
        private const val NOT_COMPLETED = "handshake did not complete after"
        private const val RETRYING = "retrying"
        private const val GIVING_UP = "giving up"
    }
}
