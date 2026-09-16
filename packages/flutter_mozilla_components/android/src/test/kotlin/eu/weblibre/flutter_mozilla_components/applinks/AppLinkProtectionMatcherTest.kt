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

/** §2.3: when a navigation must be prompted because leaving the browser would leave protection. */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AppLinkProtectionMatcherTest {

    private fun policy(
        protectGeneralContext: Boolean = false,
        protectedContextIds: Set<String> = emptySet(),
        strictContextIds: Set<String> = emptySet(),
        patterns: List<ProtectedTargetPattern> = emptyList(),
    ) = AppLinkPolicy.SAFE_DEFAULT.copy(
        protectGeneralContext = protectGeneralContext,
        protectedContextIds = protectedContextIds,
        strictContextIds = strictContextIds,
        protectedTargetPatterns = patterns,
    )

    private fun exact(host: String, port: Int? = null, scheme: String = "https") =
        ProtectedTargetPattern(scheme, host, includeSubdomains = false, port = port)

    private fun wildcard(suffix: String, scheme: String = "https") =
        ProtectedTargetPattern(scheme, suffix, includeSubdomains = true, port = null)

    // ---- Source protection ----

    @Test
    fun `a proxied or strict container protects its tabs`() {
        val p = policy(protectedContextIds = setOf("ctx-proxy"), strictContextIds = setOf("ctx-strict"))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, "ctx-proxy", "https://a.example/", null))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, "ctx-strict", "https://a.example/", null))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, "ctx-other", "https://a.example/", null))
    }

    @Test
    fun `a tab outside any container follows the general routing flag`() {
        assertTrue(
            AppLinkProtectionMatcher.isProtected(
                policy(protectGeneralContext = true), null, "https://a.example/", null,
            ),
        )
        assertFalse(
            AppLinkProtectionMatcher.isProtected(policy(), null, "https://a.example/", null),
        )
    }

    // ---- Target protection ----

    @Test
    fun `an exact pattern compares scheme host and effective port`() {
        val p = policy(patterns = listOf(exact("secret.example")))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://secret.example/x", null))
        // The default port is implied on both sides.
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://secret.example:443/x", null))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "https://secret.example:8443/x", null))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "http://secret.example/x", null))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "https://other.example/x", null))
        // Exact means exact: a subdomain is a different site.
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "https://a.secret.example/x", null))
    }

    @Test
    fun `a wildcard pattern covers apex and subdomains and ignores the port`() {
        val p = policy(patterns = listOf(wildcard("secret.example")))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://secret.example/", null))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://a.b.secret.example/", null))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://secret.example:8443/", null))
        // A suffix that is not a label boundary is a different domain.
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "https://notsecret.example/", null))
    }

    @Test
    fun `pattern hosts are normalised before comparison`() {
        val p = policy(patterns = listOf(exact("XN--BCHER-KVA.example")))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://bücher.example/", null))
        assertTrue(AppLinkProtectionMatcher.isProtected(p, null, "https://XN--Bcher-kva.EXAMPLE./", null))
    }

    /**
     * The gap this closes: an `intent:` URL hides its real target in the intent's data URI, so the
     * navigation URI carries scheme `intent` and matches no site pattern. Matching only the raw URI
     * let a site assigned to a proxied container escape protection through an app link.
     */
    @Test
    fun `an intent url is matched on its data uri, not its own scheme`() {
        val p = policy(patterns = listOf(exact("secret.example")))
        val intentUrl = "intent://secret.example/path#Intent;scheme=https;end"

        assertFalse(
            AppLinkProtectionMatcher.matchesProtectedTarget(p.protectedTargetPatterns, intentUrl),
            "the raw intent: URI alone can never match an http pattern",
        )
        assertTrue(
            AppLinkProtectionMatcher.isProtected(p, null, intentUrl, "https://secret.example/path"),
        )
    }

    @Test
    fun `an intent url to an unassigned site is still unprotected`() {
        val p = policy(patterns = listOf(exact("secret.example")))
        assertFalse(
            AppLinkProtectionMatcher.isProtected(
                p, null,
                "intent://other.example/#Intent;scheme=https;end",
                "https://other.example/",
            ),
        )
    }

    @Test
    fun `no patterns and no protected context means no protection`() {
        assertFalse(
            AppLinkProtectionMatcher.isProtected(
                policy(), "ctx", "https://a.example/", "https://a.example/",
            ),
        )
    }

    @Test
    fun `an unparseable or hostless target does not match`() {
        val p = policy(patterns = listOf(wildcard("secret.example")))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "zoommtg:join", null))
        assertFalse(AppLinkProtectionMatcher.isProtected(p, null, "", null))
    }
}
