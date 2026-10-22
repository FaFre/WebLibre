package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.FlutterError
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile

/**
 * A failed start as Dart gets it: [FlutterError.code] is [CODE], the message
 * is sing-box's reason, and the details name the profile it failed on, when
 * sing-box says.
 *
 * Only the Go error's text crosses gomobile, and sing-box builds it as one
 * chain of causes joined by ": " (`E.Cause`), outermost first. The one stable
 * part is how every component manager (inbound, outbound, endpoint, service,
 * dns, resolver) names the component that failed —
 * `post-start endpoint/wireguard[out-singbox_<id>]: resolve endpoint domain …`.
 * That half is sing-box's bookkeeping with a tag the user has never seen, so
 * the tag is turned back into the profile it was built for and only the
 * reason after it is kept.
 */
internal object SingboxStartFailure {
    const val CODE = "start_failed"
    const val STOP_CODE = "stop_failed"

    /** `<kind>/<type>[<tag>]: `, as every sing-box component manager writes it. */
    private val componentPrefix = Regex("""\b[a-z]+/[\w-]+\[([^\]]+)\]:\s*""")

    /**
     * A line of WireGuard's IPC configuration. sing-box puts the whole of it
     * into the error when the device setup fails (`"setup wireguard: \n" +
     * ipcConf`) — the private key included.
     */
    private val ipcLine = Regex("""^[a-z_]+=.*$""")

    fun from(error: Throwable, profiles: List<SingboxProxyProfile>): FlutterError {
        if (error is FlutterError) return error

        val text = redact(error.message.orEmpty())
            .ifBlank { error.javaClass.simpleName }
        val match = componentPrefix.find(text)
            ?: return FlutterError(CODE, text, null)

        val tag = match.groupValues[1]
        val profile = profiles.firstOrNull { profile -> ownsTag(profile, tag) }

        return FlutterError(
            CODE,
            reasonAfter(text, match),
            profile?.let { mapOf("profileId" to it.id, "profileName" to it.name) },
        )
    }

    /**
     * A failed full stop as Dart gets it: not a start failure, but its reason
     * goes through the same redaction, since it is still sing-box's text.
     */
    fun stopFailure(error: Throwable): FlutterError {
        if (error is FlutterError) return error

        return FlutterError(
            STOP_CODE,
            redact(error.message.orEmpty()).ifBlank { error.javaClass.simpleName },
            null,
        )
    }

    /**
     * sing-box's verdict on a single profile, as [from] would put it: without
     * the component it names (the profile is known) and without secrets.
     */
    fun describe(text: String): String {
        val redacted = redact(text)
        val match = componentPrefix.find(redacted) ?: return redacted
        return reasonAfter(redacted, match)
    }

    private fun reasonAfter(text: String, match: MatchResult): String =
        text.substring(match.range.last + 1).ifBlank { text }

    /**
     * Whether sing-box's [tag] is one built for [profile]: its inbound and
     * outbound (`SingboxTagFormat`), or one of the DNS servers the app scopes
     * to it (`browser-doh-<id>`, `override-<id>`, which carry the id without
     * its connection prefix).
     */
    private fun ownsTag(profile: SingboxProxyProfile, tag: String): Boolean {
        if (tag == SingboxTagFormat.outboundTag(profile.id) ||
            tag == SingboxTagFormat.inboundTag(profile.id)
        ) {
            return true
        }
        val rawId = SingboxTagFormat.sanitizeTag(profile.id.substringAfter(':'))
        return tag == "browser-doh-$rawId" || tag == "override-$rawId"
    }

    /** [text] without the lines of a WireGuard IPC dump, on one line. */
    private fun redact(text: String): String = text.lines()
        .filterNot { line -> ipcLine.matches(line.trim()) }
        .joinToString(" ")
        // Where the dump was cut out of "setup wireguard: \n<dump>: <cause>".
        // The join leaves whitespace between the two colons; an IPv6 address's
        // "::" has none, and must survive.
        .replace(Regex("""\s*:\s+:\s*"""), ": ")
        .replace(Regex("""\s+"""), " ")
        .trim()
        // libbox's own wrapper around every start; it says nothing.
        .removePrefix("start or reload service: ")
}
