package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyLogLevel
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyDnsServerConfig
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyRuntimeOptions
import kotlin.test.Test
import kotlin.test.assertContains
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

internal class FlutterSingboxProxyPluginTest {
    @Test
    fun buildConfig_writesRequestedLogLevel() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = "{\"server\":\"example.test\"}",
            secretJson = null
        )

        val levels = mapOf(
            SingboxProxyLogLevel.WARN to "warn",
            SingboxProxyLogLevel.INFO to "info",
            SingboxProxyLogLevel.DEBUG to "debug",
            SingboxProxyLogLevel.TRACE to "trace",
        )

        for ((level, expected) in levels) {
            val result = builder.build(
                listOf(profile),
                SingboxProxyRuntimeOptions(
                    preferredBasePort = 12500,
                    blockUnmatchedTraffic = true,
                    logLevel = level
                )
            )

            val log = JSONObject(result.configJson).getJSONObject("log")
            assertEquals(expected, log.getString("level"))
        }
    }

    @Test
    fun buildConfig_wrapsProfileOutboundWithAuthenticatedSocksInbound() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = "{\"server\":\"example.test\"}",
            secretJson = "{\"private_key\":\"secret\"}"
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true, logLevel = SingboxProxyLogLevel.WARN)
        )

        assertEquals(1, result.endpoints.size)
        assertEquals(12500, result.endpoints.single().port)
        assertContains(result.configJson, "\"type\": \"socks\"")
        assertContains(result.configJson, "\"type\": \"wireguard\"")
        assertContains(result.configJson, "\"endpoints\"")
        assertContains(result.configJson, "\"private_key\": \"secret\"")
    }

    @Test
    fun buildConfig_usesRandomDistinctInboundPortsWhenNoPreferredBaseIsSet() {
        val builder = SingboxConfigBuilder()
        val profiles = listOf(
            SingboxProxyProfile(
                id = "proxy-a",
                name = "Proxy A",
                type = SingboxProxyProfileType.SOCKS,
                configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1080}",
                secretJson = null
            ),
            SingboxProxyProfile(
                id = "proxy-b",
                name = "Proxy B",
                type = SingboxProxyProfileType.SOCKS,
                configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1081}",
                secretJson = null
            )
        )

        val result = builder.build(
            profiles,
            SingboxProxyRuntimeOptions(preferredBasePort = null, blockUnmatchedTraffic = true, logLevel = SingboxProxyLogLevel.WARN)
        )

        val ports = result.endpoints.map { it.port }
        val inbounds = JSONObject(result.configJson).getJSONArray("inbounds")

        assertEquals(2, ports.size)
        assertEquals(2, ports.toSet().size)
        assertTrue(ports.all { it in 1L..65535L })
        assertEquals(ports[0], inbounds.getJSONObject(0).getLong("listen_port"))
        assertEquals(ports[1], inbounds.getJSONObject(1).getLong("listen_port"))
    }

    @Test
    fun buildConfig_migratesWireGuardOutboundProfileToEndpoint() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = """
                {
                  "type": "wireguard",
                  "server": "example.test",
                  "server_port": 51820,
                  "local_address": ["10.7.0.2/32"],
                  "peer_public_key": "peer",
                  "mtu": 1408
                }
            """.trimIndent(),
            secretJson = """
                {
                  "private_key": "secret",
                  "pre_shared_key": "psk"
                }
            """.trimIndent()
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true, logLevel = SingboxProxyLogLevel.WARN)
        )

        assertContains(result.configJson, "\"endpoints\"")
        assertContains(result.configJson, "\"address\": \"example.test\"")
        assertContains(result.configJson, "\"port\": 51820")
        assertContains(result.configJson, "\"address\": [")
        assertContains(result.configJson, "\"public_key\": \"peer\"")
        assertContains(result.configJson, "\"allowed_ips\": [")
    }

    @Test
    fun buildConfig_givesABareWireGuardAddressItsHostPrefix() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-legacy",
            name = "WireGuard Legacy",
            type = SingboxProxyProfileType.WIREGUARD,
            // Saved before the importer and the form filled the prefix in. Left
            // alone it fails the config parse, which is a start-up error naming
            // a field the user never typed.
            configJson = """
                {
                  "type": "wireguard",
                  "server": "example.test",
                  "server_port": 51820,
                  "local_address": ["10.7.0.2", "fd00::2"],
                  "peer_public_key": "peer"
                }
            """.trimIndent(),
            secretJson = """{"private_key": "secret"}"""
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true, logLevel = SingboxProxyLogLevel.WARN)
        )

        val addresses = JSONObject(result.configJson)
            .getJSONArray("endpoints")
            .getJSONObject(0)
            .getJSONArray("address")

        assertEquals(2, addresses.length())
        assertEquals("10.7.0.2/32", addresses.getString(0))
        assertEquals("fd00::2/128", addresses.getString(1))
    }

    /**
     * sing-box sets "don't fragment" on a WireGuard endpoint's socket unless
     * told otherwise, and then every encrypted packet bigger than the path is
     * dropped with `sendmsg: message too long` — at MTU 1280 too, on a mobile
     * network or behind another VPN. WireGuard itself lets them fragment.
     */
    @Test
    fun buildConfig_letsWireGuardPacketsFragment() {
        val endpoint = buildWireGuardEndpoint(
            """{"type": "wireguard", "server": "example.test", "server_port": 51820,
               "local_address": ["10.7.0.2/32"], "peer_public_key": "peer", "mtu": 1280}"""
        )

        assertEquals(true, endpoint.getBoolean("udp_fragment"))
    }

    @Test
    fun buildConfig_keepsAProfilesOwnFragmentationChoice() {
        val endpoint = buildWireGuardEndpoint(
            """{"type": "wireguard", "server": "example.test", "server_port": 51820,
               "local_address": ["10.7.0.2/32"], "peer_public_key": "peer",
               "udp_fragment": false}"""
        )

        assertEquals(false, endpoint.getBoolean("udp_fragment"))
    }

    private fun buildWireGuardEndpoint(configJson: String): JSONObject {
        val profile = SingboxProxyProfile(
            id = "wg",
            name = "WireGuard",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = configJson,
            secretJson = """{"private_key": "secret"}"""
        )
        val result = SingboxConfigBuilder().build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                logLevel = SingboxProxyLogLevel.WARN
            )
        )
        return JSONObject(result.configJson).getJSONArray("endpoints").getJSONObject(0)
    }

    @Test
    fun buildConfig_stripsEndpointBracketsFromWireGuardAddresses() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-bracketed",
            name = "WireGuard Bracketed",
            type = SingboxProxyProfileType.WIREGUARD,
            // Brackets are endpoint syntax that an address list must not carry.
            // Saved by hand, so both the prefixed and the bare form turn up.
            configJson = """
                {
                  "type": "wireguard",
                  "server": "example.test",
                  "server_port": 51820,
                  "local_address": ["[fd00::2]", "[fd00::3]/64"],
                  "peer_public_key": "peer"
                }
            """.trimIndent(),
            secretJson = """{"private_key": "secret"}"""
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true, logLevel = SingboxProxyLogLevel.WARN)
        )

        val addresses = JSONObject(result.configJson)
            .getJSONArray("endpoints")
            .getJSONObject(0)
            .getJSONArray("address")

        assertEquals("fd00::2/128", addresses.getString(0))
        assertEquals("fd00::3/64", addresses.getString(1))
    }

    @Test
    fun validateProfile_acceptsTypeSpecificConfigWithoutExplicitType() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "ss-main",
            name = "Shadowsocks",
            type = SingboxProxyProfileType.SHADOWSOCKS,
            configJson = "{\"server\":\"example.test\"}",
            secretJson = null
        )

        assertNull(builder.validateProfile(profile))
    }

    @Test
    fun buildConfig_emitsLocalBootstrapAndDomainResolverForHostnames() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "profile-1",
            name = "SOCKS",
            type = SingboxProxyProfileType.SOCKS,
            configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1080}",
            secretJson = null
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = SingboxProxyDnsConfig(
                    servers = listOf(
                        dnsServer(
                            tag = "corp",
                            address = "tls://dns.example",
                            detourTag = "out-profile-1",
                            matchInbounds = listOf("in-profile-1")
                        )
                    ),
                    finalServerTag = null,
                    domainStrategy = ""
                ),
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val config = JSONObject(result.configJson)
        val dns = config.getJSONObject("dns")
        val servers = dns.getJSONArray("servers")
        val local = servers.getJSONObject(0)
        val corp = servers.getJSONObject(1)
        val rules = dns.getJSONArray("rules")
        // rules[0] pins the server's own hostname to the bootstrap transport.
        val rule = rules.getJSONObject(1)

        // `local` is always emitted; LocalDNSTransport bridge backs it at runtime.
        assertEquals("local", local.getString("type"))
        assertEquals("local", local.getString("tag"))
        assertFalse(local.has("detour"))

        assertEquals("tls", corp.getString("type"))
        assertEquals("dns.example", corp.getString("server"))
        // Hostname target → bootstrap through `local`.
        assertEquals("local", corp.getString("domain_resolver"))
        assertEquals("out-profile-1", corp.getString("detour"))
        // The original `tls.server_name` plumbing is gone; SNI is derived
        // from the preserved hostname in `server`.
        assertFalse(corp.has("tls"))

        assertEquals("local", rules.getJSONObject(0).getString("server"))
        assertEquals("route", rule.getString("action"))
        assertEquals("corp", rule.getString("server"))
        assertEquals("local", dns.getString("final"))

        // route.default_domain_resolver ties WG peers and other outbound
        // hostnames into the same `local` bridge.
        val route = config.getJSONObject("route")
        assertEquals("local", route.getString("default_domain_resolver"))
    }

    @Test
    fun buildConfig_omitsDomainResolverForIpLiteralServers() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "profile-1",
            name = "SOCKS",
            type = SingboxProxyProfileType.SOCKS,
            configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1080}",
            secretJson = null
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = SingboxProxyDnsConfig(
                    servers = listOf(
                        dnsServer(
                            tag = "plain",
                            address = "udp://1.2.3.4",
                            matchInbounds = emptyList()
                        )
                    ),
                    finalServerTag = "plain",
                    domainStrategy = ""
                ),
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val dns = JSONObject(result.configJson).getJSONObject("dns")
        // `local` is still emitted unconditionally as the bootstrap anchor.
        assertEquals("local", dns.getJSONArray("servers").getJSONObject(0).getString("type"))
        val plain = dns.getJSONArray("servers").getJSONObject(1)
        assertEquals("udp", plain.getString("type"))
        assertEquals("1.2.3.4", plain.getString("server"))
        // IP literal: no domain_resolver needed.
        assertFalse(plain.has("domain_resolver"))
        assertFalse(plain.has("tls"))
    }

    @Test
    fun buildConfig_pinsDnsServerHostnamesToTheBootstrapTransport() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = "{\"server\":\"example.test\",\"server_port\":51820}",
            secretJson = null
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = SingboxProxyDnsConfig(
                    servers = listOf(
                        dnsServer(
                            tag = "browser-doh-wg-home",
                            address = "https://dns.example/dns-query",
                            detourTag = "out-singbox_wg-home",
                            matchInbounds = listOf("in-singbox_wg-home")
                        )
                    ),
                    finalServerTag = null,
                    domainStrategy = "prefer_ipv4"
                ),
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val dns = JSONObject(result.configJson).getJSONObject("dns")

        // The fallback must be the platform transport, never a server whose own
        // hostname has to be resolved through a tunnel that is not up yet.
        assertEquals("local", dns.getString("final"))

        // And the DoH endpoint's own name resolves through the bootstrap
        // before any inbound rule can route it back into a DoH server.
        val firstRule = dns.getJSONArray("rules").getJSONObject(0)
        assertEquals("local", firstRule.getString("server"))
        assertEquals("dns.example", firstRule.getJSONArray("domain").getString(0))
    }

    @Test
    fun buildConfig_routesAProfileResolverThroughItsOwnTunnel() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = "{\"server\":\"example.test\",\"server_port\":51820}",
            secretJson = null
        )

        // The shape a WireGuard import produces from `DNS = 10.64.0.1`.
        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = SingboxProxyDnsConfig(
                    servers = listOf(
                        dnsServer(
                            tag = "override-wg-home",
                            address = "udp://10.64.0.1",
                            detourTag = "out-singbox_wg-home",
                            matchInbounds = listOf("in-singbox_wg-home")
                        )
                    ),
                    finalServerTag = null,
                    domainStrategy = "prefer_ipv4"
                ),
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val dns = JSONObject(result.configJson).getJSONObject("dns")
        val override = dns.getJSONArray("servers").getJSONObject(1)
        val rule = dns.getJSONArray("rules").getJSONObject(0)

        assertEquals("udp", override.getString("type"))
        assertEquals("10.64.0.1", override.getString("server"))
        assertEquals("out-singbox_wg-home", override.getString("detour"))
        assertFalse(override.has("server_port"))
        // An IP literal needs nothing resolved to reach it.
        assertFalse(override.has("domain_resolver"))

        assertEquals("override-wg-home", rule.getString("server"))
        assertEquals("in-singbox_wg-home", rule.getJSONArray("inbound").getString(0))
        assertEquals("local", dns.getString("final"))
    }

    /**
     * Issue #694: an IPv4-only tunnel asked for AAAA records too and then
     * dialled the IPv6 addresses it got, each failing as `missing IPv6 local
     * address`.
     */
    @Test
    fun buildConfig_keepsAnIpv4OnlyTunnelsLookupsToIpv4() {
        val dns = buildDnsForWireGuard(
            addresses = """["10.64.0.2/32"]""",
            allowedIps = null,
        )
        val rules = dns.getJSONArray("rules")

        // The DoH endpoint's own name still comes first, then the family rule,
        // then the route into the tunnel's resolver — which would otherwise
        // answer the AAAA question itself.
        assertEquals("local", rules.getJSONObject(0).getString("server"))
        val familyRule = rules.getJSONObject(1)
        assertEquals("in-wg-v4", familyRule.getJSONArray("inbound").getString(0))
        assertEquals("AAAA", familyRule.getJSONArray("query_type").getString(0))
        assertEquals("predefined", familyRule.getString("action"))
        assertEquals("NOERROR", familyRule.getString("rcode"))
        assertEquals("browser-doh-wg-v4", rules.getJSONObject(2).getString("server"))
        // Not the rule action's `strategy`: deprecated in 1.14, gone in 1.16.
        for (index in 0 until rules.length()) {
            assertFalse(rules.getJSONObject(index).has("strategy"))
        }

        // The resolver reached through the tunnel resolves its own name to
        // the tunnel's family as well.
        val tunnelled = dnsServerTagged(dns, "browser-doh-wg-v4")
        val resolver = tunnelled.getJSONObject("domain_resolver")
        assertEquals("local", resolver.getString("server"))
        assertEquals("ipv4_only", resolver.getString("strategy"))
        // One outside the tunnel is not restricted.
        assertEquals("local", dnsServerTagged(dns, "browser-doh").getString("domain_resolver"))
    }

    @Test
    fun buildConfig_keepsAnIpv6OnlyTunnelsLookupsToIpv6() {
        val dns = buildDnsForWireGuard(
            addresses = """["fd00::2/128"]""",
            allowedIps = """["::/0"]""",
        )
        val familyRule = dns.getJSONArray("rules").getJSONObject(1)

        assertEquals("A", familyRule.getJSONArray("query_type").getString(0))
        assertEquals(
            "ipv6_only",
            dnsServerTagged(dns, "browser-doh-wg-v4")
                .getJSONObject("domain_resolver")
                .getString("strategy"),
        )
    }

    /** An IPv6 address the peer never routes carries nothing. */
    @Test
    fun buildConfig_treatsAFamilyThePeerDoesNotRouteAsMissing() {
        val dns = buildDnsForWireGuard(
            addresses = """["10.64.0.2/32", "fd00::2/128"]""",
            allowedIps = """["0.0.0.0/0"]""",
        )

        assertEquals(
            "AAAA",
            dns.getJSONArray("rules").getJSONObject(1).getJSONArray("query_type").getString(0),
        )
    }

    @Test
    fun buildConfig_leavesADualStackTunnelUnrestricted() {
        val dns = buildDnsForWireGuard(
            addresses = """["10.64.0.2/32", "fd00::2/128"]""",
            allowedIps = null,
        )
        val rules = dns.getJSONArray("rules")

        for (index in 0 until rules.length()) {
            assertFalse(rules.getJSONObject(index).has("query_type"))
        }
        assertEquals("local", dnsServerTagged(dns, "browser-doh-wg-v4").getString("domain_resolver"))
    }

    /** A value that is not an address leaves the tunnel as it is. */
    @Test
    fun buildConfig_leavesATunnelWithAnUnreadableAddressUnrestricted() {
        val dns = buildDnsForWireGuard(
            addresses = """["10.64.0.2/32", "not-an-address"]""",
            allowedIps = null,
        )
        val rules = dns.getJSONArray("rules")

        for (index in 0 until rules.length()) {
            assertFalse(rules.getJSONObject(index).has("query_type"))
        }
    }

    @Test
    fun buildConfig_keepsAnIpv4OnlyTunnelToIpv4WithTheBootstrapResolverAlone() {
        val profile = SingboxProxyProfile(
            id = "wg-v4",
            name = "WireGuard",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = """{"server": "example.test", "server_port": 51820,
                "local_address": ["10.64.0.2/32"], "peer_public_key": "peer"}""",
            secretJson = """{"private_key": "secret"}""",
        )

        val dns = JSONObject(
            SingboxConfigBuilder().build(
                listOf(profile),
                SingboxProxyRuntimeOptions(
                    preferredBasePort = 12500,
                    blockUnmatchedTraffic = true,
                    bootstrapDohUrl = "https://dns.example/dns-query",
                    logLevel = SingboxProxyLogLevel.WARN,
                ),
            ).configJson,
        ).getJSONObject("dns")

        val rule = dns.getJSONArray("rules").getJSONObject(0)
        assertEquals("AAAA", rule.getJSONArray("query_type").getString(0))
        assertEquals("in-wg-v4", rule.getJSONArray("inbound").getString(0))
    }

    /**
     * The DNS block for one WireGuard profile `wg-v4` with the given tunnel
     * [addresses] and peer [allowedIps] (absent: the full-tunnel default),
     * resolving through a browser DoH server mirrored into the tunnel.
     */
    private fun buildDnsForWireGuard(addresses: String, allowedIps: String?): JSONObject {
        val profile = SingboxProxyProfile(
            id = "wg-v4",
            name = "WireGuard",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = """{"server": "example.test", "server_port": 51820,
                "local_address": $addresses, "peer_public_key": "peer"
                ${allowedIps?.let { ", \"allowed_ips\": $it" } ?: ""}}""",
            secretJson = """{"private_key": "secret"}""",
        )
        val result = SingboxConfigBuilder().build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = SingboxProxyDnsConfig(
                    servers = listOf(
                        dnsServer(tag = "browser-doh", address = "https://dns.example/dns-query"),
                        dnsServer(
                            tag = "browser-doh-wg-v4",
                            address = "https://dns.example/dns-query",
                            detourTag = "out-wg-v4",
                            matchInbounds = listOf("in-wg-v4"),
                        ),
                    ),
                    finalServerTag = "browser-doh",
                    domainStrategy = "prefer_ipv4",
                ),
                logLevel = SingboxProxyLogLevel.WARN,
            ),
        )
        return JSONObject(result.configJson).getJSONObject("dns")
    }

    private fun dnsServerTagged(dns: JSONObject, tag: String): JSONObject {
        val servers = dns.getJSONArray("servers")
        for (index in 0 until servers.length()) {
            val server = servers.getJSONObject(index)
            if (server.getString("tag") == tag) return server
        }
        throw AssertionError("no DNS server tagged $tag")
    }

    @Test
    fun buildConfig_emitsBootstrapDnsBlockWhenNoDnsConfigIsGiven() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "wg-home",
            name = "WireGuard Home",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = "{\"server\":\"example.test\",\"server_port\":51820}",
            secretJson = null
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                bootstrapDohUrl = "https://dns.example/dns-query",
                dnsConfig = null,
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val config = JSONObject(result.configJson)
        val dns = config.getJSONObject("dns")
        val servers = dns.getJSONArray("servers")

        // Without a `dns` block sing-box resolves through /etc/resolv.conf,
        // which Android does not have — the WireGuard peer hostname would
        // never resolve.
        assertEquals(1, servers.length())
        assertEquals("local", servers.getJSONObject(0).getString("type"))
        assertEquals("local", dns.getString("final"))
        assertEquals(
            "local",
            config.getJSONObject("route").getString("default_domain_resolver")
        )
    }

    @Test
    fun buildConfig_omitsDnsBlockWithoutBootstrapDohUrl() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "profile-1",
            name = "SOCKS",
            type = SingboxProxyProfileType.SOCKS,
            configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1080}",
            secretJson = null
        )

        val result = builder.build(
            listOf(profile),
            SingboxProxyRuntimeOptions(
                preferredBasePort = 12500,
                blockUnmatchedTraffic = true,
                logLevel = SingboxProxyLogLevel.WARN
            )
        )

        val config = JSONObject(result.configJson)

        assertFalse(config.has("dns"))
        assertFalse(config.getJSONObject("route").has("default_domain_resolver"))
    }

    @Test
    fun buildConfig_rejectsDnsConfigWithoutBootstrapDohUrl() {
        val builder = SingboxConfigBuilder()
        val profile = SingboxProxyProfile(
            id = "profile-1",
            name = "SOCKS",
            type = SingboxProxyProfileType.SOCKS,
            configJson = "{\"server\":\"127.0.0.1\",\"server_port\":1080}",
            secretJson = null
        )

        val error = assertFailsWith<IllegalArgumentException> {
            builder.build(
                listOf(profile),
                SingboxProxyRuntimeOptions(
                    preferredBasePort = 12500,
                    blockUnmatchedTraffic = true,
                    dnsConfig = SingboxProxyDnsConfig(
                        servers = listOf(
                            dnsServer(tag = "plain", address = "udp://1.2.3.4")
                        ),
                        finalServerTag = "plain",
                        domainStrategy = ""
                    ),
                    logLevel = SingboxProxyLogLevel.WARN
                )
            )
        }

        assertEquals(
            "bootstrapDohUrl is required when dnsConfig is provided.",
            error.message
        )
    }
}

private fun dnsServer(
    tag: String,
    address: String,
    detourTag: String? = null,
    matchDomainSuffixes: List<String> = emptyList(),
    matchInbounds: List<String> = emptyList()
) = SingboxProxyDnsServerConfig(
    tag = tag,
    address = address,
    detourTag = detourTag,
    matchDomainSuffixes = matchDomainSuffixes,
    matchGeosites = emptyList(),
    matchOutbounds = emptyList(),
    matchInbounds = matchInbounds
)
