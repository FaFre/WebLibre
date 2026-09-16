/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

class AppLinkHostNormalizerTest {
    @Test
    fun lowercasesAndStripsTrailingDot() {
        assertEquals("youtube.com", AppLinkHostNormalizer.normalizeHost("YouTube.com"))
        assertEquals("youtube.com", AppLinkHostNormalizer.normalizeHost("youtube.com."))
        assertEquals("youtube.com", AppLinkHostNormalizer.normalizeHost("YOUTUBE.COM."))
    }

    @Test
    fun convertsNonAsciiHostsToPunycode() {
        // bücher.example → xn--bcher-kva.example
        assertEquals(
            "xn--bcher-kva.example",
            AppLinkHostNormalizer.normalizeHost("bücher.example"),
        )
    }

    @Test
    fun rejectsEmptyAndInvalidHosts() {
        assertNull(AppLinkHostNormalizer.normalizeHost(null))
        assertNull(AppLinkHostNormalizer.normalizeHost(""))
        assertNull(AppLinkHostNormalizer.normalizeHost("."))
    }

    @Test
    fun rejectsIpv6ZoneIds() {
        assertNull(AppLinkHostNormalizer.normalizeHost("fe80::1%eth0"))
        assertNull(AppLinkHostNormalizer.normalizeHost("[fe80::1%eth0]"))
    }

    @Test
    fun equivalentIpv6SpellingsCollapseToOneKey() {
        // One address has many spellings, and a remembered rule written one way has to match a
        // navigation written the other.
        val compressed = AppLinkHostNormalizer.normalizeHost("[::1]")
        assertEquals(compressed, AppLinkHostNormalizer.normalizeHost("[0:0:0:0:0:0:0:1]"))
        assertEquals(compressed, AppLinkHostNormalizer.normalizeHost("[0000:0000:0000:0000:0000:0000:0000:0001]"))
        assertEquals(
            AppLinkHostNormalizer.normalizeHost("[fe80::1]"),
            AppLinkHostNormalizer.normalizeHost("[FE80::1]"),
        )
    }

    @Test
    fun ipv4MappedIpv6StillNormalises() {
        // These parse to an Inet4Address, so a check that insisted on Inet6Address rejected them —
        // losing the host scope entirely and taking target protection with it.
        val mapped = AppLinkHostNormalizer.normalizeHost("[::ffff:192.0.2.1]")
        assertNotNull(mapped)
        assertEquals(mapped, AppLinkHostNormalizer.normalizeHost("[::ffff:c000:201]"))
        assertEquals("host:$mapped", AppLinkHostNormalizer.hostScopeKey("[::FFFF:192.0.2.1]"))
    }

    @Test
    fun ipv4AndNumericHostsAreLeftAlone() {
        // Deliberately not run through InetAddress, whose legacy parsing reads `1.2.3` as `1.2.0.3`
        // and treats a purely numeric hostname as an address.
        assertEquals("127.0.0.1", AppLinkHostNormalizer.normalizeHost("127.0.0.1"))
        assertEquals("1.2.3", AppLinkHostNormalizer.normalizeHost("1.2.3"))
    }

    @Test
    fun buildsScopeKeys() {
        assertEquals("host:youtube.com", AppLinkHostNormalizer.hostScopeKey("YouTube.com"))
        assertNull(AppLinkHostNormalizer.hostScopeKey(""))
        assertEquals(
            "pkg:us.zoom.videomeetings",
            AppLinkHostNormalizer.packageScopeKey("us.zoom.videomeetings"),
        )
        assertNull(AppLinkHostNormalizer.packageScopeKey(null))
    }
}
