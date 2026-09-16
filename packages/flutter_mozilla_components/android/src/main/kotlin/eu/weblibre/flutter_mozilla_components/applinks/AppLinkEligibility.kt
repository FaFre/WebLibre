/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import mozilla.components.support.ktx.kotlin.tryGetHostFromUrl

private const val WWW = "www."
private const val M = "m."
private const val MOBILE = "mobile."
private const val MAPS = "maps."

/**
 * §2.4 step 2: which navigations are even candidates for an app link.
 *
 * Pure, and separated from [WebLibreAppLinksInterceptor] for that reason — it decides whether the
 * expensive part (a PackageManager resolution on the engine's navigation path) runs at all, so it
 * is worth being able to test the table directly.
 */
object AppLinkEligibility {

    /**
     * @param authExceptionsAllowed this tab was opened by another app *and* the user has left login
     * callbacks enabled, so a same-domain http navigation might be a sign-in round trip. Provisional:
     * it only knows the tab came from *some* app, not that this navigation targets it, so the caller
     * re-applies the same-domain guard once resolution reveals the actual package.
     * @return true when the navigation should be resolved and classified; false to let the engine
     * proceed untouched.
     */
    @Suppress("LongParameterList", "ReturnCount")
    fun isEligible(
        uriScheme: String?,
        engineSupportsScheme: Boolean,
        hasUserGesture: Boolean,
        isRedirect: Boolean,
        isDirectNavigation: Boolean,
        isSubframeRequest: Boolean,
        isSameDomainNavigation: Boolean,
        authExceptionsAllowed: Boolean,
    ): Boolean {
        if (uriScheme == null) return false
        // A subframe request not triggered by the user and outside the allowlist stays in-page.
        if (!hasUserGesture && isSubframeRequest && !AppLinkSchemes.isSubframeAllowed(uriScheme)) return false

        val isAllowedRedirect = isRedirect && !isSubframeRequest
        val isIntentionalNavigation = hasUserGesture || isAllowedRedirect || isDirectNavigation
        // Unintentional engine-supported navigation continues in the browser.
        if (engineSupportsScheme && !isIntentionalNavigation) return false
        // Same-domain engine-supported navigation continues in the browser (AC subdomain stripping),
        // unless this tab could be hosting an authentication round trip whose callback is an http
        // app link on the same site.
        if (engineSupportsScheme && isSameDomainNavigation && !authExceptionsAllowed) return false
        // Always-denied schemes never resolve or launch externally.
        if (AppLinkSchemes.isAlwaysDenied(uriScheme)) return false
        return true
    }

    /**
     * Whether the two URLs belong to the same site, ignoring the subdomains AC ignores. Determines
     * whether a navigation is "within the site the user is already on" and so not an app link.
     */
    fun isSameDomain(url1: String?, url2: String?): Boolean {
        return stripCommonSubDomains(url1?.tryGetHostFromUrl()) ==
            stripCommonSubDomains(url2?.tryGetHostFromUrl())
    }

    private fun stripCommonSubDomains(host: String?): String? {
        return when {
            host == null -> null
            host.startsWith(WWW) -> host.replaceFirst(WWW, "")
            host.startsWith(M) -> host.replaceFirst(M, "")
            host.startsWith(MOBILE) -> host.replaceFirst(MOBILE, "")
            host.startsWith(MAPS) -> host.replaceFirst(MAPS, "")
            else -> host
        }
    }
}
