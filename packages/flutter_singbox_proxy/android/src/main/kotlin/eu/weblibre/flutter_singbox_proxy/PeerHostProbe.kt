package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import java.io.ByteArrayOutputStream
import java.security.SecureRandom
import org.json.JSONObject

/**
 * The hostnames a profile's start has to resolve before it can come up.
 *
 * Only WireGuard has any: sing-box resolves a peer's address exactly once,
 * while the instance starts, and a peer that does not resolve fails the whole
 * start. Every other outbound resolves its server when it dials.
 */
internal object PeerHostProbe {
    private val ipv4Literal = Regex("""^\d{1,3}(\.\d{1,3}){3}$""")

    fun hostsOf(profile: SingboxProxyProfile): List<String> {
        if (profile.type != SingboxProxyProfileType.WIREGUARD) return emptyList()
        val config = runCatching { JSONObject(profile.configJson) }.getOrNull()
            ?: return emptyList()

        val hosts = mutableListOf<String>()
        config.optString("server").takeIf { it.isNotBlank() }?.let(hosts::add)
        config.optJSONArray("peers")?.let { peers ->
            for (index in 0 until peers.length()) {
                peers.optJSONObject(index)?.optString("address")
                    ?.takeIf { it.isNotBlank() }
                    ?.let(hosts::add)
            }
        }
        // A name outside ASCII would need IDNA first; it is left unprobed
        // rather than asked about in a form that cannot resolve.
        return hosts.map(String::trim)
            .filterNot(::isIpLiteral)
            .filter { host -> host.all { char -> char.code < 128 } }
            .distinct()
    }

    /**
     * Whether [host] is an address rather than a name. Told apart by its
     * shape: `InetAddress.getByName` would resolve a name through the system
     * resolver, which is the lookup the bootstrap exists to keep away from.
     */
    private fun isIpLiteral(host: String): Boolean =
        ':' in host || ipv4Literal.matches(host)
}

/** Just enough of the DNS wire format to ask whether a name has an address. */
internal object DnsWire {
    const val TYPE_A = 1
    const val TYPE_AAAA = 28
    private const val CLASS_IN = 1
    private const val FLAG_RECURSION_DESIRED = 0x0100
    private const val HEADER_SIZE = 12
    private val random = SecureRandom()

    fun query(host: String, type: Int): ByteArray {
        val out = ByteArrayOutputStream()
        fun short(value: Int) {
            out.write((value shr 8) and 0xFF)
            out.write(value and 0xFF)
        }

        short(random.nextInt(0x10000))
        short(FLAG_RECURSION_DESIRED)
        short(1) // QDCOUNT
        short(0) // ANCOUNT
        short(0) // NSCOUNT
        short(0) // ARCOUNT
        for (label in host.trimEnd('.').split('.')) {
            val bytes = label.toByteArray(Charsets.US_ASCII)
            require(bytes.size in 1..63) { "Invalid DNS label in $host" }
            out.write(bytes.size)
            out.write(bytes)
        }
        out.write(0)
        short(type)
        short(CLASS_IN)
        return out.toByteArray()
    }

    /** Whether [response] answers without error and with at least one record. */
    fun hasAnswer(response: ByteArray): Boolean {
        if (response.size < HEADER_SIZE) return false
        val rcode = response[3].toInt() and 0x0F
        val answers = ((response[6].toInt() and 0xFF) shl 8) or (response[7].toInt() and 0xFF)
        return rcode == 0 && answers > 0
    }
}
