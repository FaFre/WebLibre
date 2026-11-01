package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyConfigResult
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsServerConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogLevel
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeEndpoint
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import java.io.IOException
import java.net.InetAddress
import java.net.ServerSocket
import java.net.URI
import java.security.SecureRandom
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

private const val LOCALHOST = "127.0.0.1"
private const val BASE64_URL_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
private val IPV4_LITERAL = Regex("^\\d{1,3}(\\.\\d{1,3}){3}$")
private val IPV6_LITERAL = Regex("^[0-9A-Fa-f:.]+$")

/** An address family, as far as a tunnel can carry one. */
internal enum class IpFamily(
    /** The DNS question for the other family's addresses. */
    val otherFamilyQueryType: String,
    /** The sing-box domain strategy that asks for this family alone. */
    val onlyStrategy: String,
) {
    IPV4(otherFamilyQueryType = "AAAA", onlyStrategy = "ipv4_only"),
    IPV6(otherFamilyQueryType = "A", onlyStrategy = "ipv6_only"),
}

/** A profile whose tunnel carries one address family only. */
internal data class SingleFamilyTunnel(
    val inboundTag: String,
    val outboundTag: String,
    val family: IpFamily,
)

/**
 * Tag of the always-emitted `type: "local"` DNS server. Hooked at runtime by
 * our LocalDNSTransport bridge (PlatformDohResolver), so every hostname in
 * the config — including DoH endpoint hostnames and WireGuard peer
 * hostnames — resolves through DoH instead of `/etc/resolv.conf`.
 */
private const val DNS_BOOTSTRAP_TAG = "local"

class SingboxConfigBuilder(
    private val random: SecureRandom = SecureRandom()
) {
    fun validateProfile(profile: SingboxProxyProfile): String? {
        if (profile.id.isBlank()) return "Profile id is required."
        if (profile.name.isBlank()) return "Profile name is required."

        val outbound = try {
            buildOutbound(profile)
        } catch (error: JSONException) {
            return "Invalid outbound JSON: ${error.message}"
        } catch (error: IllegalArgumentException) {
            return error.message
        }

        val expectedType = expectedOutboundType(profile.type)
        val actualType = outbound.optString("type")
        if (expectedType != null && actualType != expectedType) {
            return "Profile type ${profile.type.name} requires sing-box outbound type '$expectedType'."
        }

        return null
    }

    fun build(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions,
        reusableEndpoints: List<SingboxProxyRuntimeEndpoint> = emptyList(),
    ): SingboxProxyConfigResult {
        profiles.forEach { profile ->
            validateProfile(profile)?.let { throw IllegalArgumentException(it) }
        }

        val inbounds = JSONArray()
        val endpointsJson = JSONArray()
        val outbounds = JSONArray()
        val rules = JSONArray()
        val endpoints = mutableListOf<SingboxProxyRuntimeEndpoint>()
        val ports = inboundPorts(profiles, options, reusableEndpoints)
        val reusableByProfile = reusableEndpoints.associateBy { it.profileId }
        val singleFamilyTunnels = mutableListOf<SingleFamilyTunnel>()

        profiles.forEachIndexed { index, profile ->
            val inboundTag = inboundTag(profile.id)
            val outboundTag = outboundTag(profile.id)
            val port = ports[index]
            // A profile that keeps its port across a reload keeps its
            // credentials too, so its endpoint comes out of the reload
            // unchanged. Every start, stop or reload rebuilds the whole
            // config; fresh credentials for profiles that merely stayed up
            // turned every one of those into an authentication failure for
            // whatever Gecko already held their old endpoint for (issue #671).
            val reused = reusableByProfile[profile.id]?.takeIf { endpoint ->
                endpoint.port == port &&
                    endpoint.username.isNotEmpty() &&
                    endpoint.password.isNotEmpty()
            }
            val username = reused?.username ?: generateToken("u")
            val password = reused?.password ?: generateToken("p")

            inbounds.put(JSONObject().apply {
                put("type", "socks")
                put("tag", inboundTag)
                put("listen", LOCALHOST)
                put("listen_port", port)
                put("users", JSONArray().put(JSONObject().apply {
                    put("username", username)
                    put("password", password)
                }))
            })

            if (profile.type == SingboxProxyProfileType.WIREGUARD) {
                val endpoint = buildWireGuardEndpoint(profile, outboundTag)
                endpointsJson.put(endpoint)
                tunnelFamily(endpoint)?.let { family ->
                    singleFamilyTunnels += SingleFamilyTunnel(inboundTag, outboundTag, family)
                }
            } else {
                outbounds.put(buildOutbound(profile).apply {
                    put("tag", outboundTag)
                })
            }

            rules.put(JSONObject().apply {
                put("inbound", JSONArray().put(inboundTag))
                put("action", "route")
                put("outbound", outboundTag)
            })

            endpoints += SingboxProxyRuntimeEndpoint(
                profileId = profile.id,
                host = LOCALHOST,
                port = port,
                username = username,
                password = password
            )
        }

        val finalOutbound = if (options.blockUnmatchedTraffic) "block" else "direct"
        outbounds.put(JSONObject().apply {
            put("type", finalOutbound)
            put("tag", finalOutbound)
        })
        // Always expose a `direct` outbound even when blockUnmatchedTraffic =
        // true so internal bootstrap/fallback paths still have a direct route.
        if (finalOutbound != "direct") {
            outbounds.put(JSONObject().apply {
                put("type", "direct")
                put("tag", "direct")
            })
        }

        val configuredDnsBlock = options.dnsConfig?.let { dns ->
            buildDnsBlock(dns, singleFamilyTunnels)
        }
        if (configuredDnsBlock != null && options.bootstrapDohUrl.isNullOrBlank()) {
            throw IllegalArgumentException(
                "bootstrapDohUrl is required when dnsConfig is provided."
            )
        }
        // A caller with a bootstrap URL but no servers still gets the platform
        // `local` transport and `default_domain_resolver` below. Without a
        // `dns` block sing-box resolves through /etc/resolv.conf, which does
        // not exist on Android — every hostname, the WireGuard peer included,
        // then fails to resolve.
        val dnsBlock = configuredDnsBlock
            ?: bootstrapOnlyDnsBlock(options.bootstrapDohUrl, singleFamilyTunnels)

        val config = JSONObject().apply {
            put("log", JSONObject().apply {
                put("level", singboxLogLevel(options.logLevel))
            })
            put("inbounds", inbounds)
            if (endpointsJson.length() > 0) {
                put("endpoints", endpointsJson)
            }
            put("outbounds", outbounds)
            put("route", JSONObject().apply {
                put("rules", rules)
                put("final", finalOutbound)
                // When DNS is configured, route everything's hostname
                // resolution through the platform LocalDNSTransport bridge so
                // WireGuard peer hostnames and any other outbound-dialer
                // hostname go through DoH, not /etc/resolv.conf.
                if (dnsBlock != null) {
                    put("default_domain_resolver", DNS_BOOTSTRAP_TAG)
                }
            })
            dnsBlock?.let { put("dns", it) }
        }

        return SingboxProxyConfigResult(
            configJson = config.toString(2),
            endpoints = endpoints
        )
    }

    /**
     * sing-box `log.level` for [level].
     *
     * `info` and above cost roughly one line per connection each from the SOCKS
     * inbound, the DNS router (on cache hits too) and the outbound, and every
     * line is forwarded to Dart over the platform channel on the main thread.
     * That is a diagnostic mode, which is why `warn` is the default and the
     * verbose levels are reachable only through a setting.
     */
    private fun singboxLogLevel(level: SingboxProxyLogLevel): String = when (level) {
        SingboxProxyLogLevel.WARN -> "warn"
        SingboxProxyLogLevel.INFO -> "info"
        SingboxProxyLogLevel.DEBUG -> "debug"
        SingboxProxyLogLevel.TRACE -> "trace"
    }

    private fun inboundPorts(
        profiles: List<SingboxProxyProfile>,
        options: SingboxProxyRuntimeOptions,
        reusableEndpoints: List<SingboxProxyRuntimeEndpoint>,
    ): List<Long> {
        options.preferredBasePort?.let { basePort ->
            return profiles.indices.map { index -> basePort + index }
        }

        val reusablePortsByProfile = reusableEndpoints.associate { endpoint ->
            endpoint.profileId to endpoint.port
        }
        val usedPorts = mutableSetOf<Int>()
        val reservedSockets = mutableListOf<ServerSocket>()

        try {
            return profiles.map { profile ->
                val reusablePort = reusablePortsByProfile[profile.id]
                    ?.toInt()
                    ?.takeIf { it in 1..65535 && usedPorts.add(it) }

                (reusablePort ?: reserveRandomLocalPort(usedPorts, reservedSockets)).toLong()
            }
        } finally {
            reservedSockets.forEach { socket -> runCatching { socket.close() } }
        }
    }

    private fun reserveRandomLocalPort(
        usedPorts: MutableSet<Int>,
        reservedSockets: MutableList<ServerSocket>,
    ): Int {
        repeat(64) {
            val socket = ServerSocket(0, 0, InetAddress.getByName(LOCALHOST))
            val port = socket.localPort
            if (usedPorts.add(port)) {
                reservedSockets += socket
                return port
            }

            socket.close()
        }

        throw IOException("Could not allocate a free local SOCKS port")
    }

    /** DNS block holding nothing but the platform bootstrap transport. */
    private fun bootstrapOnlyDnsBlock(
        bootstrapDohUrl: String?,
        singleFamilyTunnels: List<SingleFamilyTunnel>,
    ): JSONObject? {
        if (bootstrapDohUrl.isNullOrBlank()) return null

        val rulesJson = JSONArray()
        singleFamilyTunnels.forEach { tunnel -> rulesJson.put(otherFamilyRule(tunnel)) }

        return JSONObject().apply {
            put("servers", JSONArray().put(JSONObject().apply {
                put("type", "local")
                put("tag", DNS_BOOTSTRAP_TAG)
            }))
            if (rulesJson.length() > 0) {
                put("rules", rulesJson)
            }
            put("final", DNS_BOOTSTRAP_TAG)
        }
    }

    /**
     * Answers every lookup a single-family tunnel makes for the other family
     * with "no such record".
     *
     * A tunnel that only has an IPv4 address cannot reach anything over IPv6,
     * yet its lookups asked for both, waited on both, and handed sing-box IPv6
     * addresses to dial — each one failing as `missing IPv6 local address`,
     * which is what the logs in issue #694 are full of. sing-box 1.14 applies
     * `query_type` to its own lookups too (the ones an endpoint makes to reach
     * a domain), so this keeps the question from being asked at all. The
     * tunnel's own traffic decides the family, not the device's network.
     *
     * Not the rule action's `strategy`, which would say the same in fewer
     * words: 1.14 deprecated it and 1.16 removes it.
     */
    private fun otherFamilyRule(tunnel: SingleFamilyTunnel) = JSONObject().apply {
        put("inbound", JSONArray().put(tunnel.inboundTag))
        put("query_type", JSONArray().put(tunnel.family.otherFamilyQueryType))
        put("action", "predefined")
        put("rcode", "NOERROR")
    }

    private fun buildDnsBlock(
        dns: SingboxProxyDnsConfig,
        singleFamilyTunnels: List<SingleFamilyTunnel>,
    ): JSONObject? {
        if (dns.servers.isEmpty()) return null
        val familyByOutbound = singleFamilyTunnels.associate { it.outboundTag to it.family }

        val serversJson = JSONArray()
        val rulesJson = JSONArray()

        // Always emit the platform `local` server first. It is the foundation
        // every other server's `domain_resolver` (and the route's
        // default_domain_resolver) points at, and the LocalDNSTransport
        // bridge backs it with DoH at runtime.
        serversJson.put(JSONObject().apply {
            put("type", "local")
            put("tag", DNS_BOOTSTRAP_TAG)
        })

        // A DNS server's own hostname resolves through `local`, always and
        // before anything else can claim it. Without this a lookup for a DoH
        // endpoint can take the rules path and land on a DoH server — possibly
        // the one being dialled, possibly one behind a tunnel that is still
        // waiting on this very lookup.
        val bootstrapDomains = dns.servers
            .mapNotNull { server -> parseDnsAddress(server.address).server }
            .filterNot { host -> isIpLiteral(host) }
            .distinct()
        if (bootstrapDomains.isNotEmpty()) {
            rulesJson.put(JSONObject().apply {
                put("domain", JSONArray(bootstrapDomains))
                put("action", "route")
                put("server", DNS_BOOTSTRAP_TAG)
            })
        }

        // Ahead of the per-inbound routes below, which would otherwise answer
        // first and send the other family's question into the tunnel anyway.
        singleFamilyTunnels.forEach { tunnel -> rulesJson.put(otherFamilyRule(tunnel)) }

        for (server in dns.servers) {
            serversJson.put(buildDnsServer(server, server.detourTag?.let(familyByOutbound::get)))

            if (server.matchDomainSuffixes.isNotEmpty() ||
                server.matchInbounds.isNotEmpty()
            ) {
                rulesJson.put(JSONObject().apply {
                    if (server.matchDomainSuffixes.isNotEmpty()) {
                        put(
                            "domain_suffix",
                            JSONArray(server.matchDomainSuffixes)
                        )
                    }
                    if (server.matchInbounds.isNotEmpty()) {
                        put("inbound", JSONArray(server.matchInbounds))
                    }
                    put("action", "route")
                    put("server", server.tag)
                })
            }
        }

        return JSONObject().apply {
            put("servers", serversJson)
            if (rulesJson.length() > 0) {
                put("rules", rulesJson)
            }
            if (dns.domainStrategy.isNotBlank()) {
                put("strategy", dns.domainStrategy)
            }
            val finalTag = dns.finalServerTag ?: DNS_BOOTSTRAP_TAG
            put("final", finalTag)
        }
    }

    /**
     * [detourFamily] is the one family the tunnel [server] is reached through
     * can carry, if it carries only one.
     */
    private fun buildDnsServer(
        server: SingboxProxyDnsServerConfig,
        detourFamily: IpFamily?,
    ): JSONObject {
        val parsed = parseDnsAddress(server.address)
        return JSONObject().apply {
            put("type", parsed.type)
            put("tag", server.tag)
            parsed.server?.let { put("server", it) }
            parsed.serverPort?.let { put("server_port", it) }
            parsed.path?.let { put("path", it) }
            server.detourTag?.takeUnless { it == "direct" }?.let { put("detour", it) }
            // Hostname targets always bootstrap through `local`; sing-box
            // ignores `domain_resolver` for IP-literal servers, so emitting
            // it unconditionally is fine and keeps the JSON uniform.
            if (parsed.server != null && !parsed.serverIsIpLiteral) {
                if (detourFamily == null) {
                    put("domain_resolver", DNS_BOOTSTRAP_TAG)
                } else {
                    // The server's name resolves outside the tunnel, so the
                    // rule that keeps a tunnel's lookups to its own family
                    // never sees it. Unrestricted, a resolver behind an
                    // IPv4-only tunnel got its IPv6 addresses too, and its
                    // connections tried them first.
                    put("domain_resolver", JSONObject().apply {
                        put("server", DNS_BOOTSTRAP_TAG)
                        put("strategy", detourFamily.onlyStrategy)
                    })
                }
            }
        }
    }

    private fun parseDnsAddress(address: String): ParsedDnsAddress {
        val trimmed = address.trim()
        if (trimmed == "local") {
            return ParsedDnsAddress(type = "local")
        }

        val uri = if (trimmed.contains("://")) URI(trimmed) else null
        val scheme = uri?.scheme?.lowercase()
        return when (scheme) {
            null -> parseHostPort(trimmed, "udp", 53)
            "udp" -> parseUriHostPort(uri!!, "udp", 53)
            "tcp" -> parseUriHostPort(uri!!, "tcp", 53)
            "tls" -> parseUriHostPort(uri!!, "tls", 853)
            "quic" -> parseUriHostPort(uri!!, "quic", 853)
            "https", "h3" -> parseUriHostPort(uri, scheme, 443).copy(
                path = uri.path.takeUnless { it.isNullOrBlank() || it == "/dns-query" }
            )
            else -> throw IllegalArgumentException("Unsupported DNS server scheme: $scheme")
        }
    }

    private fun parseUriHostPort(uri: URI, type: String, defaultPort: Int): ParsedDnsAddress {
        val host = uri.host ?: throw IllegalArgumentException("Invalid DNS server address")
        val bare = host.removePrefix("[").removeSuffix("]")
        return ParsedDnsAddress(
            type = type,
            server = bare,
            serverPort = uri.port.takeIf { it >= 0 && it != defaultPort },
            serverIsIpLiteral = isIpLiteral(bare),
        )
    }

    private fun parseHostPort(value: String, type: String, defaultPort: Int): ParsedDnsAddress {
        val trimmed = value.trim()
        if (trimmed.isBlank()) throw IllegalArgumentException("DNS server address is required")

        val splitPort = trimmed.lastIndexOf(':')
        val hasSingleColon = splitPort > 0 && trimmed.indexOf(':') == splitPort
        val host = if (hasSingleColon) trimmed.substring(0, splitPort) else trimmed
        val port = if (hasSingleColon) trimmed.substring(splitPort + 1).toIntOrNull() else null
        val bare = host.removePrefix("[").removeSuffix("]")

        return ParsedDnsAddress(
            type = type,
            server = bare,
            serverPort = port?.takeUnless { it == defaultPort },
            serverIsIpLiteral = isIpLiteral(bare),
        )
    }

    private fun isIpLiteral(host: String): Boolean {
        if (host.matches(IPV4_LITERAL)) return true
        if (host.contains(":") && host.matches(IPV6_LITERAL)) return true
        return false
    }

    private data class ParsedDnsAddress(
        val type: String,
        val server: String? = null,
        val serverPort: Int? = null,
        val path: String? = null,
        val serverIsIpLiteral: Boolean = false,
    )

    private fun buildOutbound(profile: SingboxProxyProfile): JSONObject {
        val outbound = JSONObject(profile.configJson)
        profile.secretJson?.takeIf { it.isNotBlank() }?.let { secretJson ->
            deepMerge(outbound, JSONObject(secretJson))
        }

        expectedOutboundType(profile.type)?.let { expectedType ->
            val actualType = outbound.optString("type")
            if (actualType.isBlank()) {
                outbound.put("type", expectedType)
            }
        }

        return outbound
    }

    private fun buildWireGuardEndpoint(profile: SingboxProxyProfile, tag: String): JSONObject {
        val endpoint = buildOutbound(profile)
        endpoint.put("tag", tag)

        endpoint.remove("server")?.let { server ->
            val peer = JSONObject().apply {
                put("address", server)
                endpoint.remove("server_port")?.let { put("port", it) }
                endpoint.remove("peer_public_key")?.let { put("public_key", it) }
                endpoint.remove("pre_shared_key")?.let { put("pre_shared_key", it) }
                endpoint.remove("reserved")?.let { put("reserved", it) }
                endpoint.remove("persistent_keepalive_interval")?.let {
                    put("persistent_keepalive_interval", it)
                }
                put("allowed_ips", endpoint.remove("allowed_ips") ?: JSONArray().apply {
                    put("0.0.0.0/0")
                    put("::/0")
                })
            }
            endpoint.put("peers", JSONArray().put(peer))
        }

        endpoint.remove("local_address")?.let { endpoint.put("address", withCidrPrefixes(it)) }
        endpoint.remove("system_interface")?.let { endpoint.put("system", it) }
        endpoint.remove("interface_name")?.let { endpoint.put("name", it) }
        endpoint.remove("gso")

        // Let the encrypted packets be fragmented, as WireGuard itself does —
        // the kernel module and the reference wireguard-go both leave
        // fragmentation on. sing-box instead sets "don't fragment" on every UDP
        // socket but direct and hysteria ones, so an encrypted packet bigger
        // than the path allows is dropped at the socket ("sendmsg: message too
        // long") and the tunnel's TCP resends the same full-size segment until
        // it gives up. Lowering the MTU is no way around that here: below 1280
        // the tunnel's gVisor stack refuses IPv6 altogether, and 1280 itself
        // needs a 1360-byte path, which mobile networks and a device already
        // on another VPN routinely do not have. A profile that sets the field
        // keeps its choice.
        if (!endpoint.has("udp_fragment")) {
            endpoint.put("udp_fragment", true)
        }

        return endpoint
    }

    /**
     * The one IP family the WireGuard [endpoint] can carry, or null when it
     * carries both — or when that cannot be told from the config.
     *
     * A family needs both an address of the tunnel's own and a peer that
     * routes it: an IPv6 address with `AllowedIPs = 0.0.0.0/0` sends nothing
     * over IPv6 either. Anything that is not plainly an address or a prefix
     * (a malformed entry, a peer without `allowed_ips`) answers null, which
     * leaves the tunnel unrestricted; guessing wrong here would hide a family
     * the tunnel does carry.
     */
    internal fun tunnelFamily(endpoint: JSONObject): IpFamily? {
        val own = prefixFamilies(endpoint.opt("address")) ?: return null
        val peers = endpoint.optJSONArray("peers") ?: return null
        if (peers.length() == 0) return null

        val routed = mutableSetOf<IpFamily>()
        for (index in 0 until peers.length()) {
            val peer = peers.optJSONObject(index) ?: return null
            routed += prefixFamilies(peer.opt("allowed_ips")) ?: return null
        }

        return own.intersect(routed).singleOrNull()
    }

    /** The families of [prefixes], or null when one of them is not a prefix. */
    private fun prefixFamilies(prefixes: Any?): Set<IpFamily>? {
        val values = when (prefixes) {
            is JSONArray -> (0 until prefixes.length()).map { prefixes.opt(it) }
            is String -> listOf(prefixes)
            else -> return null
        }
        if (values.isEmpty()) return null

        return values.map { value ->
            val address = (value as? String)?.trim()?.substringBefore('/')
                ?.removeSurrounding("[", "]")
                ?: return null
            when {
                address.matches(IPV4_LITERAL) -> IpFamily.IPV4
                address.contains(':') && address.matches(IPV6_LITERAL) -> IpFamily.IPV6
                else -> return null
            }
        }.toSet()
    }

    /**
     * The tunnel's own addresses, every one of them carrying a prefix length.
     *
     * sing-box reads `address` as a list of prefixes and refuses to parse a bare
     * one, which is a start-up failure naming a field the user never typed. The
     * importer and the profile form both fill the prefix in now, so this only
     * catches profiles saved before they did — but those are exactly the ones
     * that fail, and nothing else here can repair them.
     *
     * Anything that is not an address is passed through untouched: sing-box's
     * own error names the value, and a guess made here would only replace it
     * with a worse one.
     */
    private fun withCidrPrefixes(addresses: Any): Any {
        if (addresses !is JSONArray) return withCidrPrefix(addresses)

        return JSONArray().apply {
            for (index in 0 until addresses.length()) {
                put(withCidrPrefix(addresses.get(index)))
            }
        }
    }

    private fun withCidrPrefix(address: Any): Any {
        if (address !is String) return address

        val value = address.trim()
        if (value.isEmpty()) return address

        val separatorIndex = value.lastIndexOf('/')
        val addressPart = if (separatorIndex < 0) value else value.substring(0, separatorIndex)
        // Kept with its slash so it can be re-attached verbatim; whether the
        // prefix is in range is sing-box's to say, not ours to guess at.
        val prefixPart = if (separatorIndex < 0) null else value.substring(separatorIndex)

        // Brackets are endpoint syntax (`[fd00::1]:443`), and an address list
        // never needs them — sing-box refuses one that carries them. A profile
        // written by hand from an endpoint is exactly where they turn up, and
        // that is the population this whole function exists for. Stripped
        // before the prefix question, because a bracketed address that already
        // has one is just as unparseable as one that has not.
        val bare = addressPart.removeSurrounding("[", "]")
        if (bare.isEmpty()) return address

        if (prefixPart != null) return bare + prefixPart

        return when {
            bare.contains(':') -> "$bare/128"
            bare.count { it == '.' } == 3 -> "$bare/32"
            else -> address
        }
    }

    private fun deepMerge(target: JSONObject, source: JSONObject) {
        val keys = source.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val value = source.get(key)
            if (value is JSONObject && target.opt(key) is JSONObject) {
                deepMerge(target.getJSONObject(key), value)
            } else {
                target.put(key, value)
            }
        }
    }

    private fun generateToken(prefix: String): String {
        val bytes = ByteArray(18)
        random.nextBytes(bytes)
        return prefix + base64UrlNoPadding(bytes)
    }

    private fun base64UrlNoPadding(bytes: ByteArray): String {
        val output = StringBuilder((bytes.size * 4 + 2) / 3)
        var index = 0
        while (index < bytes.size) {
            val b0 = bytes[index++].toInt() and 0xff
            val b1 = if (index < bytes.size) bytes[index++].toInt() and 0xff else -1
            val b2 = if (index < bytes.size) bytes[index++].toInt() and 0xff else -1

            output.append(BASE64_URL_ALPHABET[b0 ushr 2])
            if (b1 < 0) {
                output.append(BASE64_URL_ALPHABET[(b0 and 0x03) shl 4])
            } else {
                output.append(BASE64_URL_ALPHABET[((b0 and 0x03) shl 4) or (b1 ushr 4)])
                if (b2 < 0) {
                    output.append(BASE64_URL_ALPHABET[(b1 and 0x0f) shl 2])
                } else {
                    output.append(BASE64_URL_ALPHABET[((b1 and 0x0f) shl 2) or (b2 ushr 6)])
                    output.append(BASE64_URL_ALPHABET[b2 and 0x3f])
                }
            }
        }
        return output.toString()
    }

    private fun inboundTag(profileId: String) = SingboxTagFormat.inboundTag(profileId)

    private fun outboundTag(profileId: String) = SingboxTagFormat.outboundTag(profileId)

    private fun expectedOutboundType(type: SingboxProxyProfileType): String? = when (type) {
        SingboxProxyProfileType.SOCKS -> "socks"
        SingboxProxyProfileType.HTTP -> "http"
        SingboxProxyProfileType.SHADOWSOCKS -> "shadowsocks"
        SingboxProxyProfileType.VMESS -> "vmess"
        SingboxProxyProfileType.VLESS -> "vless"
        SingboxProxyProfileType.TROJAN -> "trojan"
        SingboxProxyProfileType.NAIVE -> "naive"
        SingboxProxyProfileType.HYSTERIA -> "hysteria"
        SingboxProxyProfileType.HYSTERIA2 -> "hysteria2"
        SingboxProxyProfileType.TUIC -> "tuic"
        SingboxProxyProfileType.SSH -> "ssh"
        SingboxProxyProfileType.WIREGUARD -> "wireguard"
        SingboxProxyProfileType.SHADOW_TLS -> "shadowtls"
        SingboxProxyProfileType.ANY_TLS -> "anytls"
        SingboxProxyProfileType.CUSTOM_OUTBOUND -> null
    }
}
