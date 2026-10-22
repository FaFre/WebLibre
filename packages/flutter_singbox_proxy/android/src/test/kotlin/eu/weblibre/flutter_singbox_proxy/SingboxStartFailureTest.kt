package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull

internal class SingboxStartFailureTest {
    private val home = SingboxProxyProfile(
        id = "singbox:home-id",
        name = "Home VPN",
        type = SingboxProxyProfileType.WIREGUARD,
        configJson = "{}",
        secretJson = null,
    )

    @Test
    fun from_namesTheProfileAndKeepsOnlyTheReason() {
        val tag = SingboxTagFormat.outboundTag(home.id)
        val error = RuntimeException(
            "start service: post-start endpoint/wireguard[$tag]: " +
                "resolve endpoint: lookup vpn.example: no such host",
        )

        val failure = SingboxStartFailure.from(error, listOf(home))

        assertEquals(SingboxStartFailure.CODE, failure.code)
        assertEquals("resolve endpoint: lookup vpn.example: no such host", failure.message)
        assertEquals(
            mapOf("profileId" to home.id, "profileName" to "Home VPN"),
            failure.details,
        )
    }

    /** Device setup errors carry WireGuard's IPC config, private key and all. */
    @Test
    fun from_dropsTheWireguardConfigFromTheReason() {
        val tag = SingboxTagFormat.outboundTag(home.id)
        val error = RuntimeException(
            "start endpoint/wireguard[$tag]: setup wireguard: \n" +
                "private_key=0123456789abcdef\n" +
                "public_key=fedcba9876543210\n" +
                "endpoint=203.0.113.1:51820\n" +
                ": invalid argument",
        )

        val failure = SingboxStartFailure.from(error, listOf(home))

        assertEquals("setup wireguard: invalid argument", failure.message)
        assertFalse(failure.message!!.contains("0123456789abcdef"))
    }

    /** Closing the gap the dump leaves must not touch an IPv6 address's "::". */
    @Test
    fun from_keepsAnIpv6AddressIntact() {
        val tag = SingboxTagFormat.outboundTag(home.id)
        val error = RuntimeException(
            "start endpoint/wireguard[$tag]: " +
                "dial udp [2001:db8::1]:51820: connect: network is unreachable",
        )

        val failure = SingboxStartFailure.from(error, listOf(home))

        assertEquals(
            "dial udp [2001:db8::1]:51820: connect: network is unreachable",
            failure.message,
        )
    }

    /** A DNS server the app scopes to a profile names that profile too. */
    @Test
    fun from_namesTheProfileOfItsDnsServer() {
        val error = RuntimeException(
            "start dns/https[override-home-id]: parse server address: missing port",
        )

        val failure = SingboxStartFailure.from(error, listOf(home))

        assertEquals("parse server address: missing port", failure.message)
        assertEquals(
            mapOf("profileId" to home.id, "profileName" to "Home VPN"),
            failure.details,
        )
    }

    @Test
    fun describe_keepsOnlyTheReasonOfARejection() {
        assertEquals(
            "decode private key: illegal base64 data at input byte 4",
            SingboxStartFailure.describe(
                "initialize endpoint/wireguard[out-x]: decode private key: " +
                    "illegal base64 data at input byte 4",
            ),
        )
    }

    @Test
    fun from_keepsAnErrorThatNamesNoComponent() {
        val failure = SingboxStartFailure.from(
            IllegalStateException("sing-box libbox runtime is not linked"),
            listOf(home),
        )

        assertEquals("sing-box libbox runtime is not linked", failure.message)
        assertNull(failure.details)
    }

    @Test
    fun from_leavesAnUnknownTagUnnamed() {
        val failure = SingboxStartFailure.from(
            RuntimeException("start inbound/socks[in-other]: listen tcp: address already in use"),
            listOf(home),
        )

        assertEquals("listen tcp: address already in use", failure.message)
        assertNull(failure.details)
    }
}
