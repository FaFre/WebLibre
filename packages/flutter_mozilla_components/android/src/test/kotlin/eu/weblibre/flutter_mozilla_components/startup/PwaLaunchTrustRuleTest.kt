/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.startup

import eu.weblibre.flutter_mozilla_components.PwaConstants
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"
private const val URL = "https://pwa.test/app"
private const val TOKEN = "tok-abc"
private const val VIEW = "android.intent.action.VIEW"

class PwaLaunchTrustRuleTest {

    private fun tokens(vararg entries: Pair<String, String>): PwaTokenSource {
        val map = entries.toMap()
        return PwaTokenSource { key -> map[key] }
    }

    private fun key(url: String, profileId: String, contextId: String = "") =
        "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}$url::$profileId::$contextId"

    private fun legacyKey(url: String, profileId: String) =
        "${PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX}$url::$profileId"

    private fun claim(
        action: String? = VIEW,
        intentUrl: String? = URL,
        profileUuid: String = PROFILE_A,
        token: String? = TOKEN,
        contextId: String = "",
        installStartUrl: String? = null,
    ) = PwaTrustClaim(action, intentUrl, profileUuid, token, contextId, installStartUrl)

    private fun isTrusted(
        claim: PwaTrustClaim,
        tokens: PwaTokenSource = tokens(),
        shortcuts: List<PinnedShortcutClaim> = emptyList(),
    ) = PwaLaunchTrustRule.isTrusted(claim, tokens) { shortcuts }

    // --- the rule that matters --------------------------------------------------

    @Test
    fun `extras alone never establish trust`() {
        // The whole point. `pwa_profile_uuid` and `pwa_token` are ordinary extras
        // any app on the device can put on an intent; only a token this app
        // recorded counts.
        assertFalse(isTrusted(claim()))
    }

    @Test
    fun `a token recorded for this url and profile is trusted`() {
        assertTrue(isTrusted(claim(), tokens(key(URL, PROFILE_A) to TOKEN)))
    }

    @Test
    fun `a token recorded for a different profile is not trusted`() {
        // The attack this blocks: naming profile A while presenting a token that
        // only authenticates B.
        assertFalse(isTrusted(claim(), tokens(key(URL, PROFILE_B) to TOKEN)))
    }

    @Test
    fun `a token recorded for a different url is not trusted`() {
        assertFalse(
            isTrusted(claim(), tokens(key("https://other.test", PROFILE_A) to TOKEN)),
        )
    }

    @Test
    fun `a wrong token value is not trusted`() {
        assertFalse(isTrusted(claim(token = "guessed"), tokens(key(URL, PROFILE_A) to TOKEN)))
    }

    @Test
    fun `an empty token is not trusted`() {
        // Otherwise a launch carrying no token at all would match an unset entry.
        assertFalse(isTrusted(claim(token = ""), tokens(key(URL, PROFILE_A) to "")))
        assertFalse(isTrusted(claim(token = null), tokens(key(URL, PROFILE_A) to TOKEN)))
    }

    @Test
    fun `only a launching action can be trusted`() {
        // A trusted token must not turn an arbitrary action into a profile
        // selection.
        assertFalse(
            isTrusted(
                claim(action = "android.intent.action.SEND"),
                tokens(key(URL, PROFILE_A) to TOKEN),
            ),
        )
        assertTrue(
            isTrusted(
                claim(action = "mozilla.components.feature.pwa.VIEW_PWA"),
                tokens(key(URL, PROFILE_A) to TOKEN),
            ),
        )
    }

    @Test
    fun `a launch with no url is not trusted`() {
        assertFalse(isTrusted(claim(intentUrl = null), tokens(key(URL, PROFILE_A) to TOKEN)))
    }

    // --- context scoping and the legacy key ------------------------------------

    @Test
    fun `a context-scoped token is matched under its context`() {
        assertTrue(
            isTrusted(
                claim(contextId = "work"),
                tokens(key(URL, PROFILE_A, "work") to TOKEN),
            ),
        )
    }

    @Test
    fun `a context-scoped token does not match another context`() {
        assertFalse(
            isTrusted(
                claim(contextId = "personal"),
                tokens(key(URL, PROFILE_A, "work") to TOKEN),
            ),
        )
    }

    @Test
    fun `a shortcut pinned before context scoping still works`() {
        // The legacy (url, profile) key, which is why it is still consulted.
        assertTrue(
            isTrusted(claim(contextId = "work"), tokens(legacyKey(URL, PROFILE_A) to TOKEN)),
        )
    }

    // --- install start url ------------------------------------------------------

    @Test
    fun `a deep link into an installed app matches the install url token`() {
        // The PWA was installed at its start url; the launch is a deeper page in
        // the same app, so the token is recorded against the start url.
        assertTrue(
            isTrusted(
                claim(intentUrl = "https://pwa.test/app/page", installStartUrl = URL),
                tokens(key(URL, PROFILE_A) to TOKEN),
            ),
        )
    }

    @Test
    fun `an install url the caller made up does not help`() {
        assertFalse(
            isTrusted(
                claim(
                    intentUrl = "https://pwa.test/app/page",
                    installStartUrl = "https://attacker.test",
                ),
                tokens(key(URL, PROFILE_A) to TOKEN),
            ),
        )
    }

    // --- the pinned-shortcut fallback -------------------------------------------

    @Test
    fun `a pinned shortcut carrying the token is trusted`() {
        assertTrue(
            isTrusted(
                claim(),
                shortcuts = listOf(
                    PinnedShortcutClaim(PROFILE_A, TOKEN, URL, installStartUrl = null),
                ),
            ),
        )
    }

    @Test
    fun `a pinned shortcut for another profile is not trusted`() {
        assertFalse(
            isTrusted(
                claim(),
                shortcuts = listOf(
                    PinnedShortcutClaim(PROFILE_B, TOKEN, URL, installStartUrl = null),
                ),
            ),
        )
    }

    @Test
    fun `a pinned shortcut with a different token is not trusted`() {
        assertFalse(
            isTrusted(
                claim(),
                shortcuts = listOf(
                    PinnedShortcutClaim(PROFILE_A, "other", URL, installStartUrl = null),
                ),
            ),
        )
    }

    @Test
    fun `a pinned shortcut is matched by its own install url`() {
        // Guarded on the *shortcut's* install url rather than the launch's — the
        // two are different values, and reading the wrong one widens the match.
        assertTrue(
            isTrusted(
                claim(intentUrl = URL, installStartUrl = null),
                shortcuts = listOf(
                    PinnedShortcutClaim(
                        PROFILE_A,
                        TOKEN,
                        url = "https://pwa.test/app/start",
                        installStartUrl = URL,
                    ),
                ),
            ),
        )
    }

    @Test
    fun `an unrelated pinned shortcut does not grant trust`() {
        assertFalse(
            isTrusted(
                claim(),
                shortcuts = listOf(
                    PinnedShortcutClaim(
                        PROFILE_A,
                        TOKEN,
                        url = "https://elsewhere.test",
                        installStartUrl = null,
                    ),
                ),
            ),
        )
    }
}
