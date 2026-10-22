package eu.weblibre.flutter_singbox_proxy

import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfile
import eu.weblibre.flutter_singbox_proxy.generated.SingboxProxyProfileType
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

internal class PeerHostProbeTest {
    @Test
    fun hostsOf_takesNamesFromServerAndPeers() {
        val profile = SingboxProxyProfile(
            id = "wg",
            name = "wg",
            type = SingboxProxyProfileType.WIREGUARD,
            configJson = """
                {"server":"vpn.example","peers":[
                  {"address":"peer.example"},{"address":"2001:db8::1"},
                  {"address":"198.51.100.7"},{"address":"vpn.example"}
                ]}
            """.trimIndent(),
            secretJson = null,
        )

        assertEquals(listOf("vpn.example", "peer.example"), PeerHostProbe.hostsOf(profile))
    }

    @Test
    fun query_asksForTheNameWithRecursion() {
        val query = DnsWire.query("a.example", DnsWire.TYPE_AAAA)

        // Header, then 1 a 7 example 0, then type and class.
        assertEquals(12 + 11 + 4, query.size)
        assertEquals(0x01, query[2].toInt())
        assertEquals(1, query[5].toInt())
        assertEquals(
            listOf(1, 'a'.code, 7),
            listOf(query[12].toInt(), query[13].toInt(), query[14].toInt()),
        )
        assertEquals(DnsWire.TYPE_AAAA, query[query.size - 3].toInt())
    }

    @Test
    fun hasAnswer_needsNoErrorAndARecord() {
        fun header(rcode: Int, answers: Int) = ByteArray(12).also {
            it[3] = rcode.toByte()
            it[7] = answers.toByte()
        }

        assertTrue(DnsWire.hasAnswer(header(rcode = 0, answers = 1)))
        assertFalse(DnsWire.hasAnswer(header(rcode = 0, answers = 0)))
        assertFalse(DnsWire.hasAnswer(header(rcode = 3, answers = 1)))
        assertFalse(DnsWire.hasAnswer(ByteArray(4)))
    }
}
