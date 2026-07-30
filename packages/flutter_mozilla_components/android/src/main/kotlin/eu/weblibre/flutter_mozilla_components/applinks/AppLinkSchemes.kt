/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import java.util.Locale

/**
 * Frozen scheme classification tables for the WebLibre-owned app-links implementation
 * (see APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.2).
 *
 * These tables initially match Mozilla Android Components
 * ([mozilla.components.feature.app.links.AppLinksUseCases] companion,
 * [mozilla.components.feature.app.links.AppLinksInterceptor]). All comparisons are
 * case-insensitive via [Locale.ROOT] lowercase — AC lowercases only the denied set;
 * making the engine-supported comparison case-insensitive too is a deliberate small
 * correctness improvement. `JavaScript:` must be denied as surely as `javascript:`.
 *
 * These tables describe what Gecko can load, not what the user wants, and are consumed
 * on the synchronous interception path — they stay in Kotlin.
 */
object AppLinkSchemes {
    // Schemes the Gecko engine can load itself.
    // https://searchfox.org/firefox-main/source/netwerk/build/components.conf
    val ENGINE_SUPPORTED: Set<String> = setOf(
        "about",
        "data",
        "file",
        "ftp",
        "http",
        "https",
        "moz-extension",
        "moz-safe-about",
        "resource",
        "view-source",
        "ws",
        "wss",
        "blob",
    )

    // Schemes that must never be resolved or launched in a third-party app.
    val ALWAYS_DENIED: Set<String> = setOf(
        "jar",
        "file",
        "javascript",
        "data",
        "about",
        "content",
        "fido",
    )

    // Schemes allowed to open an external application from a subframe.
    val SUBFRAME_ALLOWED: Set<String> = setOf(
        "msteams",
    )

    // Wallet schemes — always prompt, never remembered (§2.4).
    val WALLET: Set<String> = setOf(
        "openid4vp",
        "mdoc",
        "mdoc-openid4vp",
        "haip",
        "eudi-wallet",
        "eudi-openid4vp",
        "openid-credential-offer",
    )

    private fun normalize(scheme: String?): String? = scheme?.lowercase(Locale.ROOT)

    fun isEngineSupported(scheme: String?): Boolean = normalize(scheme) in ENGINE_SUPPORTED

    fun isAlwaysDenied(scheme: String?): Boolean = normalize(scheme) in ALWAYS_DENIED

    fun isSubframeAllowed(scheme: String?): Boolean = normalize(scheme) in SUBFRAME_ALLOWED

    fun isWallet(scheme: String?): Boolean = normalize(scheme) in WALLET

    fun isHttpOrHttps(scheme: String?): Boolean = normalize(scheme).let { it == "http" || it == "https" }
}
