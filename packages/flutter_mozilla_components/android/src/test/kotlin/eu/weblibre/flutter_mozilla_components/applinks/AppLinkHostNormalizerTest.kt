/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import kotlin.test.Test
import kotlin.test.assertEquals
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
    fun canonicalisesIpLiterals() {
        assertEquals("127.0.0.1", AppLinkHostNormalizer.normalizeHost("127.0.0.1"))
        // Leading zeros / equivalent forms normalise to canonical dotted-quad.
        assertEquals("[::1]", AppLinkHostNormalizer.normalizeHost("[::1]"))
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
