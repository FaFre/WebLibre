/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class AppLinkSchemesTest {
    @Test
    fun engineSupportedSchemesMatchTheFrozenTable() {
        for (scheme in listOf(
            "about", "data", "file", "ftp", "http", "https", "moz-extension",
            "moz-safe-about", "resource", "view-source", "ws", "wss", "blob",
        )) {
            assertTrue(AppLinkSchemes.isEngineSupported(scheme), "$scheme should be engine-supported")
            // Case-insensitive: a mixed-case spelling matches too.
            assertTrue(
                AppLinkSchemes.isEngineSupported(scheme.uppercase()),
                "${scheme.uppercase()} should be engine-supported (case-insensitive)",
            )
        }
        assertFalse(AppLinkSchemes.isEngineSupported("zoommtg"))
        assertFalse(AppLinkSchemes.isEngineSupported(null))
    }

    @Test
    fun alwaysDeniedSchemesMatchTheFrozenTable() {
        for (scheme in listOf("jar", "file", "javascript", "data", "about", "content", "fido")) {
            assertTrue(AppLinkSchemes.isAlwaysDenied(scheme), "$scheme should be always-denied")
        }
        // JavaScript: must be denied as surely as javascript:.
        assertTrue(AppLinkSchemes.isAlwaysDenied("JavaScript"))
        assertTrue(AppLinkSchemes.isAlwaysDenied("FILE"))
        assertFalse(AppLinkSchemes.isAlwaysDenied("https"))
    }

    @Test
    fun subframeAllowedSchemes() {
        assertTrue(AppLinkSchemes.isSubframeAllowed("msteams"))
        assertTrue(AppLinkSchemes.isSubframeAllowed("MSTeams"))
        assertFalse(AppLinkSchemes.isSubframeAllowed("whatsapp"))
    }

    @Test
    fun walletSchemes() {
        for (scheme in listOf(
            "openid4vp", "mdoc", "mdoc-openid4vp", "haip", "eudi-wallet",
            "eudi-openid4vp", "openid-credential-offer",
        )) {
            assertTrue(AppLinkSchemes.isWallet(scheme), "$scheme should be a wallet scheme")
        }
        assertTrue(AppLinkSchemes.isWallet("OpenID4VP"))
        assertFalse(AppLinkSchemes.isWallet("https"))
    }

    @Test
    fun httpOrHttpsIsCaseInsensitive() {
        assertTrue(AppLinkSchemes.isHttpOrHttps("http"))
        assertTrue(AppLinkSchemes.isHttpOrHttps("HTTPS"))
        assertFalse(AppLinkSchemes.isHttpOrHttps("ftp"))
        assertFalse(AppLinkSchemes.isHttpOrHttps(null))
    }
}
