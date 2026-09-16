/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** §2.4 step 2 — which navigations are candidates for an app link at all. */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AppLinkEligibilityTest {

    @Suppress("LongParameterList")
    private fun eligible(
        scheme: String? = "https",
        engineSupportsScheme: Boolean = true,
        hasUserGesture: Boolean = true,
        isRedirect: Boolean = false,
        isDirectNavigation: Boolean = false,
        isSubframeRequest: Boolean = false,
        isSameDomainNavigation: Boolean = false,
        authExceptionsAllowed: Boolean = false,
    ) = AppLinkEligibility.isEligible(
        scheme,
        engineSupportsScheme,
        hasUserGesture,
        isRedirect,
        isDirectNavigation,
        isSubframeRequest,
        isSameDomainNavigation,
        authExceptionsAllowed,
    )

    @Test
    fun `a schemeless url is never eligible`() {
        assertFalse(eligible(scheme = null))
    }

    @Test
    fun `always-denied schemes are never eligible`() {
        for (scheme in listOf("javascript", "JavaScript", "file", "data", "about", "content", "jar", "fido")) {
            assertFalse(eligible(scheme = scheme, engineSupportsScheme = false), scheme)
        }
    }

    @Test
    fun `an unintentional engine-supported navigation stays in the browser`() {
        assertFalse(
            eligible(hasUserGesture = false, isRedirect = false, isDirectNavigation = false),
        )
        // Any one of the three intentions is enough.
        assertTrue(eligible(hasUserGesture = true))
        assertTrue(eligible(hasUserGesture = false, isRedirect = true))
        assertTrue(eligible(hasUserGesture = false, isDirectNavigation = true))
    }

    @Test
    fun `a redirect inside a subframe is not an intentional navigation`() {
        assertFalse(
            eligible(hasUserGesture = false, isRedirect = true, isSubframeRequest = true),
        )
    }

    @Test
    fun `an unsupported scheme is eligible even without an intention`() {
        // There is no page to keep, so the reason for the guard does not apply.
        assertTrue(
            eligible(
                scheme = "zoommtg",
                engineSupportsScheme = false,
                hasUserGesture = false,
            ),
        )
    }

    @Test
    fun `an ungestured subframe request is confined to its frame unless allowlisted`() {
        assertFalse(
            eligible(scheme = "zoommtg", engineSupportsScheme = false, hasUserGesture = false, isSubframeRequest = true),
        )
        assertTrue(
            eligible(scheme = "msteams", engineSupportsScheme = false, hasUserGesture = false, isSubframeRequest = true),
        )
        // A user gesture lifts the restriction for any scheme.
        assertTrue(
            eligible(scheme = "zoommtg", engineSupportsScheme = false, hasUserGesture = true, isSubframeRequest = true),
        )
    }

    @Test
    fun `same-domain http navigation stays in the browser unless a login callback is possible`() {
        assertFalse(eligible(isSameDomainNavigation = true))
        assertTrue(eligible(isSameDomainNavigation = true, authExceptionsAllowed = true))
        // The waiver is only about engine-supported schemes; a custom scheme was never in scope.
        assertTrue(
            eligible(scheme = "zoommtg", engineSupportsScheme = false, isSameDomainNavigation = true),
        )
    }

    @Test
    fun `same-domain ignores the subdomains AC ignores`() {
        for (host in listOf("www", "m", "mobile", "maps")) {
            assertTrue(
                AppLinkEligibility.isSameDomain("https://$host.example.com/a", "https://example.com/b"),
                host,
            )
        }
        assertFalse(AppLinkEligibility.isSameDomain("https://a.example.com/", "https://example.com/"))
        assertFalse(AppLinkEligibility.isSameDomain(null, "https://example.com/"))
    }
}
