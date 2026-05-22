package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyConfigResult
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsServerConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeEndpoint
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import java.net.URI
import java.security.SecureRandom
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

private const val LOCALHOST = "127.0.0.1"
private const val DEFAULT_BASE_PORT = 12000L
private const val BASE64_URL_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

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
        options: SingboxProxyRuntimeOptions
    ): SingboxProxyConfigResult {
        profiles.forEach { profile ->
            validateProfile(profile)?.let { throw IllegalArgumentException(it) }
        }

        val inbounds = JSONArray()
        val endpointsJson = JSONArray()
        val outbounds = JSONArray()
        val rules = JSONArray()
        val endpoints = mutableListOf<SingboxProxyRuntimeEndpoint>()
        val basePort = options.preferredBasePort ?: DEFAULT_BASE_PORT

        profiles.forEachIndexed { index, profile ->
            val inboundTag = inboundTag(profile.id)
            val outboundTag = outboundTag(profile.id)
            val port = basePort + index
            val username = generateToken("u")
            val password = generateToken("p")

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
                endpointsJson.put(buildWireGuardEndpoint(profile, outboundTag))
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

        val dnsBlock = options.dnsConfig?.let(::buildDnsBlock)
        if (dnsBlock != null && options.bootstrapDohUrl.isNullOrBlank()) {
            throw IllegalArgumentException(
                "bootstrapDohUrl is required when dnsConfig is provided."
            )
        }

        val config = JSONObject().apply {
            put("log", JSONObject().apply { put("level", "info") })
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

    private fun buildDnsBlock(dns: SingboxProxyDnsConfig): JSONObject? {
        if (dns.servers.isEmpty()) return null

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

        for (server in dns.servers) {
            serversJson.put(buildDnsServer(server))

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

    private fun buildDnsServer(server: SingboxProxyDnsServerConfig): JSONObject {
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
                put("domain_resolver", DNS_BOOTSTRAP_TAG)
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
        if (host.matches(Regex("^\\d{1,3}(\\.\\d{1,3}){3}$"))) return true
        if (host.contains(":") && host.matches(Regex("^[0-9A-Fa-f:.]+$"))) return true
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

        endpoint.remove("local_address")?.let { endpoint.put("address", it) }
        endpoint.remove("system_interface")?.let { endpoint.put("system", it) }
        endpoint.remove("interface_name")?.let { endpoint.put("name", it) }
        endpoint.remove("gso")

        return endpoint
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
