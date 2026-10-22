package eu.weblibre.flutter_singbox_proxy

import android.content.Context
import android.net.ConnectivityManager
import java.net.Inet6Address
import java.net.InetAddress
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal class PlatformNetworkMonitorTest {
    private val connectivity = mock(ConnectivityManager::class.java)

    private fun monitor(): PlatformNetworkMonitor {
        val context = mock(Context::class.java)
        `when`(context.applicationContext).thenReturn(context)
        `when`(context.getSystemService(ConnectivityManager::class.java))
            .thenReturn(connectivity)
        return PlatformNetworkMonitor(context)
    }

    /**
     * A reload starts the new instance's monitor; the previous instance's
     * close, should it come late, must not take that registration down.
     */
    @Test
    fun stop_fromAnotherListener_keepsTheRegistration() {
        val monitor = monitor()
        monitor.start(owner = 2) {}

        monitor.stop(owner = 1)
        verify(connectivity, never()).unregisterNetworkCallback(
            any(ConnectivityManager.NetworkCallback::class.java),
        )

        monitor.stop(owner = 2)
        verify(connectivity).unregisterNetworkCallback(
            any(ConnectivityManager.NetworkCallback::class.java),
        )
    }

    /** Without a way to tell listeners apart, a close stops what is there. */
    @Test
    fun stop_withoutAnOwner_stops() {
        val monitor = monitor()
        monitor.start(owner = null) {}

        monitor.stop(owner = 1)

        verify(connectivity).unregisterNetworkCallback(
            any(ConnectivityManager.NetworkCallback::class.java),
        )
    }
    @Test
    fun prefixOf_writesAnIpv4Prefix() {
        assertEquals(
            "192.168.1.23/24",
            PlatformNetworkMonitor.prefixOf(InetAddress.getByName("192.168.1.23"), 24),
        )
    }

    /**
     * libbox parses these with `netip.MustParsePrefix`, which panics on a zone
     * and takes the app with it. Android prints a link-local address with one.
     */
    @Test
    fun prefixOf_dropsTheZoneOfALinkLocalAddress() {
        val scoped = Inet6Address.getByAddress(
            null,
            InetAddress.getByName("fe80::1").address,
            3,
        )
        assertTrue(scoped.hostAddress!!.contains('%'), "test address must carry a zone")

        val prefix = PlatformNetworkMonitor.prefixOf(scoped, 64)

        assertEquals("fe80:0:0:0:0:0:0:1/64", prefix)
    }

    @Test
    fun prefixOf_rejectsAPrefixLengthTheAddressCannotHave() {
        assertNull(PlatformNetworkMonitor.prefixOf(InetAddress.getByName("10.0.0.1"), 33))
        assertNull(PlatformNetworkMonitor.prefixOf(InetAddress.getByName("2001:db8::1"), 129))
        assertNull(PlatformNetworkMonitor.prefixOf(InetAddress.getByName("10.0.0.1"), -1))
    }

    @Test
    fun hostOf_dropsTheZone() {
        val scoped = Inet6Address.getByAddress(
            null,
            InetAddress.getByName("fe80::53").address,
            3,
        )

        assertEquals("fe80:0:0:0:0:0:0:53", PlatformNetworkMonitor.hostOf(scoped))
        assertEquals("9.9.9.9", PlatformNetworkMonitor.hostOf(InetAddress.getByName("9.9.9.9")))
    }

    /** libbox keeps only interfaces with IFF_UP set. */
    @Test
    fun linkFlags_setsTheLinuxBitsLibboxDecodes() {
        assertEquals(
            0x1 or 0x40 or 0x2 or 0x1000,
            PlatformNetworkMonitor.linkFlags(
                up = true,
                broadcast = true,
                loopback = false,
                pointToPoint = false,
                multicast = true,
            ),
        )
        assertEquals(
            0x10,
            PlatformNetworkMonitor.linkFlags(
                up = false,
                broadcast = false,
                loopback = false,
                pointToPoint = true,
                multicast = false,
            ),
        )
    }

    @Test
    fun reporter_passesOnTheFirstInterfaceAndEveryChange() {
        val reports = mutableListOf<DefaultNetworkInterface?>()
        val reporter = DefaultInterfaceReporter { reports += it }
        val wifi = DefaultNetworkInterface(name = "wlan0", index = 30, expensive = false)
        val mobile = DefaultNetworkInterface(name = "rmnet_data0", index = 12, expensive = true)

        reporter.update(wifi)
        reporter.update(mobile)
        reporter.update(null)
        reporter.update(wifi)

        assertEquals(listOf(wifi, mobile, null, wifi), reports)
    }

    /**
     * Android repeats capability updates for the same network on every change
     * in signal strength. Each report makes libbox re-read every interface, and
     * one for the interface it already has changes nothing.
     */
    @Test
    fun reporter_dropsRepeatsOfTheSameInterface() {
        val reports = mutableListOf<DefaultNetworkInterface?>()
        val reporter = DefaultInterfaceReporter { reports += it }
        val wifi = DefaultNetworkInterface(name = "wlan0", index = 30, expensive = false)

        reporter.update(wifi)
        reporter.update(wifi.copy(expensive = true))
        reporter.update(wifi)

        assertEquals(listOf<DefaultNetworkInterface?>(wifi), reports)
    }

    @Test
    fun reporter_reportsLosingTheNetworkOnce() {
        val reports = mutableListOf<DefaultNetworkInterface?>()
        val reporter = DefaultInterfaceReporter { reports += it }

        reporter.update(DefaultNetworkInterface(name = "wlan0", index = 30, expensive = false))
        reporter.update(null)
        reporter.update(null)

        assertEquals(2, reports.size)
        assertNull(reports.last())
    }

    /** A callback still in flight must not reach a listener sing-box dropped. */
    @Test
    fun reporter_staysSilentOnceClosed() {
        val reports = mutableListOf<DefaultNetworkInterface?>()
        val reporter = DefaultInterfaceReporter { reports += it }

        reporter.close()
        reporter.update(DefaultNetworkInterface(name = "wlan0", index = 30, expensive = false))

        assertTrue(reports.isEmpty())
    }
}
