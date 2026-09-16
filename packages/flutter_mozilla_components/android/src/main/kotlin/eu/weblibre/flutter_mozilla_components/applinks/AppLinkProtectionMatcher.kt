/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.net.Uri
import java.util.Locale

/**
 * Whether a navigation must be prompted regardless of the user's mode because leaving the browser
 * would leave protection behind (§2.3).
 *
 * Two independent reasons: the *source* — a container that routes through a proxy, or one in strict
 * mode — and the *target* — a site assigned to such a container, wherever the navigation started.
 *
 * Split out of [WebLibreAppLinksInterceptor] because it is the one part of the decision that is pure
 * and testable: everything here is derived from the replicated policy and the URL, with no
 * `Components`, session or engine involved.
 */
object AppLinkProtectionMatcher {

    /**
     * @param contextId the source tab's live contextId, or null for a tab outside any container.
     * @param uri the navigation target as the engine reported it.
     * @param intentDataUrl the intent's data URI when [uri] is an `intent:` URL; see [matchesTarget].
     */
    fun isProtected(
        policy: AppLinkPolicy,
        contextId: String?,
        uri: String,
        intentDataUrl: String?,
    ): Boolean {
        val protectedByContext = if (contextId == null) {
            policy.protectGeneralContext
        } else {
            contextId in policy.protectedContextIds || contextId in policy.strictContextIds
        }
        if (protectedByContext) return true
        return matchesTarget(policy.protectedTargetPatterns, uri, intentDataUrl)
    }

    /**
     * Whether either form of the target matches a protected-site pattern.
     *
     * An `intent:` URL keeps its real target in the intent's data URI, so the navigation URI itself
     * carries scheme `intent` and matches no pattern — every pattern comes from a site assignment
     * and is therefore http(s). Checking only [uri] would let a site assigned to a proxied or strict
     * container lose its protection the moment a page reached it through an app link. For an
     * ordinary http(s) link the two are the same string, so the second check is skipped.
     */
    fun matchesTarget(
        patterns: List<ProtectedTargetPattern>,
        uri: String,
        intentDataUrl: String?,
    ): Boolean {
        if (patterns.isEmpty()) return false
        if (matchesProtectedTarget(patterns, uri)) return true
        if (intentDataUrl == null || intentDataUrl == uri) return false
        return matchesProtectedTarget(patterns, intentDataUrl)
    }

    /**
     * Match one URL against the patterns, preserving `siteAssignmentMatches` semantics: a wildcard
     * entry covers apex plus subdomains and ignores the port; an exact entry compares scheme and
     * origin including the effective port.
     */
    fun matchesProtectedTarget(patterns: List<ProtectedTargetPattern>, uri: String): Boolean {
        if (patterns.isEmpty()) return false
        val parsed = runCatching { Uri.parse(uri) }.getOrNull() ?: return false
        val scheme = parsed.scheme?.lowercase(Locale.ROOT) ?: return false
        val host = AppLinkHostNormalizer.normalizeHost(parsed.host) ?: return false
        val effectivePort = if (parsed.port != -1) parsed.port else defaultPortForScheme(scheme)

        return patterns.any { pattern ->
            if (pattern.scheme.lowercase(Locale.ROOT) != scheme) return@any false
            val patternHost = AppLinkHostNormalizer.normalizeHost(pattern.hostOrSuffix) ?: return@any false
            if (pattern.includeSubdomains) {
                host == patternHost || host.endsWith(".$patternHost")
            } else {
                host == patternHost && effectivePort == (pattern.port ?: defaultPortForScheme(scheme))
            }
        }
    }

    fun defaultPortForScheme(scheme: String): Int = when (scheme) {
        "http", "ws" -> 80
        "https", "wss" -> 443
        "ftp" -> 21
        else -> -1
    }
}
