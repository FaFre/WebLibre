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

/** A launch's PWA trust claim, reduced to what can be reasoned about. */
data class PwaTrustClaim(
    val action: String?,
    val intentUrl: String?,
    val profileUuid: String,
    val token: String?,
    val contextId: String = "",
    val installStartUrl: String? = null,
)

/**
 * One pinned shortcut's own claim, as recorded when it was created.
 *
 * The shortcut list is the second source of truth for a token: shortcuts pinned
 * before the token was mirrored into preferences carry it only on themselves.
 */
data class PinnedShortcutClaim(
    val profileUuid: String?,
    val token: String?,
    val url: String?,
    val installStartUrl: String?,
)

/**
 * Where a token can be looked up. The two implementations are the preference
 * mirror and the pinned-shortcut list; a test supplies whatever it likes.
 */
fun interface PwaTokenSource {
    fun tokenFor(key: String): String?
}

/**
 * Whether a launch's `pwa_token` authenticates the profile it names.
 *
 * Split out of [LaunchTrust] with no Android types in it, for the same reason
 * `StartupIntentDescriptor` is split out of `Intent`: this is the rule that
 * decides whether a launch may select a profile, so it is the part that most
 * needs to be provable — and this module has no Robolectric, so anything holding
 * a `Context`, an `Intent` or a `ShortcutManager` cannot be unit tested at all.
 *
 * The presence of `pwa_profile_uuid` and `pwa_token` on an intent is worth
 * nothing on its own: both are ordinary extras that any app on the device can
 * put there. Only a token that matches one this app recorded counts.
 */
object PwaLaunchTrustRule {

    private const val ACTION_VIEW = "android.intent.action.VIEW"
    private const val ACTION_VIEW_PWA = "mozilla.components.feature.pwa.VIEW_PWA"

    fun isTrusted(
        claim: PwaTrustClaim,
        tokens: PwaTokenSource,
        pinnedShortcuts: () -> List<PinnedShortcutClaim>,
    ): Boolean {
        val intentUrl = claim.intentUrl ?: return false
        val token = claim.token
        val hasTrustedAction =
            claim.action == ACTION_VIEW || claim.action == ACTION_VIEW_PWA
        if (!hasTrustedAction || token.isNullOrEmpty()) return false

        // Tokens are keyed by (url, profile, contextId) since each install
        // variant gets its own. The legacy (url, profile) key covers shortcuts
        // pinned before context-scoping existed.
        if (tokens.matches(intentUrl, claim.profileUuid, claim.contextId, token)) {
            return true
        }

        val installStartUrl = claim.installStartUrl
        if (!installStartUrl.isNullOrEmpty() && installStartUrl != intentUrl &&
            tokens.matches(installStartUrl, claim.profileUuid, claim.contextId, token)
        ) {
            return true
        }

        return pinnedShortcuts().any { shortcut ->
            shortcut.matches(intentUrl, claim.profileUuid, token, installStartUrl)
        }
    }

    private fun PwaTokenSource.matches(
        url: String,
        profileUuid: String,
        contextId: String,
        token: String,
    ): Boolean {
        val prefix = PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX
        return tokenFor("$prefix$url::$profileUuid::$contextId") == token ||
            tokenFor("$prefix$url::$profileUuid") == token
    }

    private fun PinnedShortcutClaim.matches(
        intentUrl: String,
        profileUuid: String,
        token: String,
        installStartUrl: String?,
    ): Boolean {
        if (this.profileUuid != profileUuid) return false
        if (this.token != token) return false

        // Guarded on the *shortcut's* install URL, not the launch's. These are two
        // different values and swapping them silently widens the match.
        return url == intentUrl ||
            (this.installStartUrl != null && this.installStartUrl == intentUrl) ||
            (
                !installStartUrl.isNullOrEmpty() &&
                    this.installStartUrl == installStartUrl &&
                    (url == intentUrl || url == installStartUrl)
                )
    }
}
