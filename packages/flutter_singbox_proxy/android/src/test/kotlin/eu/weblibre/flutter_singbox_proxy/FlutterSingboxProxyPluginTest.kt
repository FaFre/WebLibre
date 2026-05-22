package eu.weblibre.flutter_singbox_proxy

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
import org.json.JSONObject

internal class FlutterSingboxProxyPluginTest {
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
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true)
        )

        assertEquals(1, result.endpoints.size)
        assertEquals(12500, result.endpoints.single().port)
        assertContains(result.configJson, "\"type\": \"socks\"")
        assertContains(result.configJson, "\"type\": \"wireguard\"")
        assertContains(result.configJson, "\"endpoints\"")
        assertContains(result.configJson, "\"private_key\": \"secret\"")
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
            SingboxProxyRuntimeOptions(preferredBasePort = 12500, blockUnmatchedTraffic = true)
        )

        assertContains(result.configJson, "\"endpoints\"")
        assertContains(result.configJson, "\"address\": \"example.test\"")
        assertContains(result.configJson, "\"port\": 51820")
        assertContains(result.configJson, "\"address\": [")
        assertContains(result.configJson, "\"public_key\": \"peer\"")
        assertContains(result.configJson, "\"allowed_ips\": [")
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
                )
            )
        )

        val config = JSONObject(result.configJson)
        val dns = config.getJSONObject("dns")
        val servers = dns.getJSONArray("servers")
        val local = servers.getJSONObject(0)
        val corp = servers.getJSONObject(1)
        val rule = dns.getJSONArray("rules").getJSONObject(0)

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
                )
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
                    )
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
