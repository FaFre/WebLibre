/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptRequest
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkTarget
import mozilla.components.support.base.log.logger.Logger
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

/** The §2.2 URL class a pending request belongs to; part of the dedupe key. */
enum class AppLinkUrlClass {
    BANNER,
    MODAL,
    MARKETPLACE,
}

/**
 * A pending prompt, stored until resolved/invalidated/expired (§2.6). Holds only
 * stable identifiers and sanitised data — never a Components/EngineSession/store
 * reference. Carries everything needed both to render the prompt and to perform
 * the resolution side effect (re-resolve + launch, or load a validated fallback).
 */
data class PendingAppLinkRequest(
    val requestId: Long,
    val owner: AppLinkPromptOwner,
    val tabId: String,
    val contextId: String?,
    val sourceUrl: String?,
    val isPrivate: Boolean,
    val isWallet: Boolean,
    val isProtectedContext: Boolean,
    val canRemember: Boolean,
    val isModal: Boolean,
    val urlClass: AppLinkUrlClass,
    // Resolution data:
    val url: String,
    val expectedPackage: String?,
    val fallbackUrl: String?,
    val engineSupportsScheme: Boolean,
    val isMarketplace: Boolean,
    // Full sanitised-target fingerprint (URL + intent payload), the dedupe/invalidation key.
    val targetFingerprint: String,
    val appName: String?,
    val packageName: String?,
    val scopeKey: String,
    val createdAt: Long,
) {
    fun toPigeon(): AppLinkPromptRequest = AppLinkPromptRequest(
        requestId = requestId,
        owner = owner,
        tabId = tabId,
        contextId = contextId,
        sourceUrl = sourceUrl,
        isPrivate = isPrivate,
        isWallet = isWallet,
        isProtectedContext = isProtectedContext,
        canRemember = canRemember,
        isModal = isModal,
        target = AppLinkTarget(
            url = url,
            appName = appName,
            packageName = packageName,
            fallbackUrl = fallbackUrl,
            isMarketplace = isMarketplace,
            isAmbiguous = !canRemember,
            engineSupportsScheme = engineSupportsScheme,
            scopeKey = scopeKey,
        ),
    )
}

/** Everything needed to create a request; the store assigns the id and timestamp. */
data class NewAppLinkRequest(
    val owner: AppLinkPromptOwner,
    val tabId: String,
    val contextId: String?,
    val sourceUrl: String?,
    val isPrivate: Boolean,
    val isWallet: Boolean,
    val isProtectedContext: Boolean,
    val canRemember: Boolean,
    val isModal: Boolean,
    val urlClass: AppLinkUrlClass,
    val url: String,
    val expectedPackage: String?,
    val fallbackUrl: String?,
    val engineSupportsScheme: Boolean,
    val isMarketplace: Boolean,
    val targetFingerprint: String,
    val appName: String?,
    val packageName: String?,
    val scopeKey: String,
    /** A user-gesture attempt is never deduped into an older request (§2.6). */
    val isUserGesture: Boolean = false,
)

/**
 * Process-level registry of profile-scoped [PendingAppLinkStore] singletons (§2.10).
 * Keyed by native's canonical profile relative path; survives `GlobalComponents.setUp()`.
 */
object PendingAppLinkStores {
    private val stores = ConcurrentHashMap<String, PendingAppLinkStore>()

    fun forProfile(relativePath: String): PendingAppLinkStore =
        stores.getOrPut(relativePath) { PendingAppLinkStore() }

    fun remove(relativePath: String) {
        stores.remove(relativePath)
    }
}

/**
 * Holds pending prompts, dedupe, suppression, and the fallback re-entry map (§2.6).
 * Query + consume: requests stay until resolved, invalidated, or expired. The store
 * never holds its lock across a side effect — [consume] returns the request and the
 * caller performs launch/fallback after the lock is released.
 */
class PendingAppLinkStore(
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val requestExpiryMs: Long = REQUEST_EXPIRY_MS,
    private val suppressionExpiryMs: Long = SUPPRESSION_EXPIRY_MS,
    private val dedupeWindowMs: Long = DEDUPE_WINDOW_MS,
    private val fallbackReentryMs: Long = FALLBACK_REENTRY_MS,
) {
    private val logger = Logger("PendingAppLinkStore")
    private val lock = Any()
    private val idGenerator = AtomicLong(0L)

    private val requests = LinkedHashMap<Long, PendingAppLinkRequest>()
    private val suppression = HashMap<String, Long>()
    private val fallbackReentry = HashMap<String, Long>()

    private fun suppressionKey(tabId: String, fingerprint: String) = "$tabId\u0000$fingerprint"

    /**
     * Create a request, collapsing a matching non-user-gesture request that arrived
     * within the dedupe window into the existing one (§2.6).
     */
    fun createRequest(input: NewAppLinkRequest): PendingAppLinkRequest {
        synchronized(lock) {
            sweepExpiredLocked()

            if (!input.isUserGesture) {
                val existing = requests.values.firstOrNull { candidate ->
                    candidate.tabId == input.tabId &&
                        candidate.targetFingerprint == input.targetFingerprint &&
                        candidate.owner == input.owner &&
                        candidate.urlClass == input.urlClass &&
                        clock.elapsedRealtime() <= candidate.createdAt + dedupeWindowMs
                }
                if (existing != null) return existing
            }

            val request = PendingAppLinkRequest(
                requestId = idGenerator.incrementAndGet(),
                owner = input.owner,
                tabId = input.tabId,
                contextId = input.contextId,
                sourceUrl = input.sourceUrl,
                isPrivate = input.isPrivate,
                isWallet = input.isWallet,
                isProtectedContext = input.isProtectedContext,
                canRemember = input.canRemember,
                isModal = input.isModal,
                urlClass = input.urlClass,
                url = input.url,
                expectedPackage = input.expectedPackage,
                fallbackUrl = input.fallbackUrl,
                engineSupportsScheme = input.engineSupportsScheme,
                isMarketplace = input.isMarketplace,
                targetFingerprint = input.targetFingerprint,
                appName = input.appName,
                packageName = input.packageName,
                scopeKey = input.scopeKey,
                createdAt = clock.elapsedRealtime(),
            )
            requests[request.requestId] = request
            return request
        }
    }

    /** Non-consuming query of live requests for [owner]. */
    fun getPending(owner: AppLinkPromptOwner): List<PendingAppLinkRequest> {
        synchronized(lock) {
            sweepExpiredLocked()
            return requests.values.filter { it.owner == owner }.toList()
        }
    }

    /** Atomically remove and return a request; null if already resolved/expired. */
    fun consume(requestId: Long): PendingAppLinkRequest? {
        synchronized(lock) {
            sweepExpiredLocked()
            return requests.remove(requestId)
        }
    }

    fun peek(requestId: Long): PendingAppLinkRequest? {
        synchronized(lock) {
            sweepExpiredLocked()
            return requests[requestId]
        }
    }

    fun invalidate(requestId: Long) {
        synchronized(lock) { requests.remove(requestId) }
    }

    /** Invalidate every pending request for a tab (tab close / replacement). */
    fun invalidateTab(tabId: String) {
        synchronized(lock) {
            requests.values.removeAll { it.tabId == tabId }
            suppression.keys.removeAll { it.startsWith("$tabId\u0000") }
        }
    }

    /**
     * A committed top-level navigation in [tabId]. A request whose own page committed
     * stays alive (that commit is the page the prompt sits on); a commit to a
     * *different site* invalidates the tab's pending requests (§2.6).
     *
     * Matching is by **normalised host**, not exact URL: the initial load a banner
     * rides on almost always commits at a redirected/normalised URL (`www`, trailing
     * slash, tracking params) that never equals the intercepted URL, so an exact-URL
     * check would invalidate every banner on its own page load. The anchor is the
     * target host for a banner (the page it loads) and the source host for a modal
     * (the page it is shown over, since the modal's own navigation was denied). When
     * no host can be derived, the request is kept and left to expiry/tab-close.
     */
    fun onCommittedNavigation(tabId: String, committedUrl: String) {
        val committedHost = siteKey(committedUrl)
        synchronized(lock) {
            val removed = mutableListOf<Long>()
            requests.values.removeAll { request ->
                if (request.tabId != tabId) return@removeAll false
                val anchorHost = siteKey(if (request.isModal) request.sourceUrl else request.url)
                val invalidate = anchorHost != null && committedHost != null && anchorHost != committedHost
                if (invalidate) removed.add(request.requestId)
                invalidate
            }
            if (removed.isNotEmpty()) {
                logger.info(
                    "onCommittedNavigation tab=$tabId committedHost=$committedHost invalidated=$removed",
                )
            }
        }
    }

    /** Normalised, subdomain-stripped host for same-site comparison; null if underivable. */
    private fun siteKey(url: String?): String? {
        val rawHost = extractHost(url) ?: return null
        val normalized = AppLinkHostNormalizer.normalizeHost(rawHost) ?: return null
        return stripCommonSubDomains(normalized)
    }

    private fun extractHost(url: String?): String? {
        if (url.isNullOrEmpty()) return null
        val schemeSep = url.indexOf("://")
        if (schemeSep < 0) return null
        val afterScheme = url.substring(schemeSep + 3)
        val end = afterScheme.indexOfFirst { it == '/' || it == '?' || it == '#' }
        var authority = if (end >= 0) afterScheme.substring(0, end) else afterScheme
        val at = authority.lastIndexOf('@')
        if (at >= 0) authority = authority.substring(at + 1)
        // Preserve a bracketed IPv6 literal; AppLinkHostNormalizer canonicalises it.
        if (authority.startsWith("[")) {
            val close = authority.indexOf(']')
            return if (close >= 0) authority.substring(0, close + 1) else null
        }
        val colon = authority.lastIndexOf(':')
        if (colon >= 0) authority = authority.substring(0, colon)
        return authority.ifEmpty { null }
    }

    private fun stripCommonSubDomains(host: String): String = when {
        host.startsWith("www.") -> host.removePrefix("www.")
        host.startsWith("m.") -> host.removePrefix("m.")
        host.startsWith("mobile.") -> host.removePrefix("mobile.")
        host.startsWith("maps.") -> host.removePrefix("maps.")
        else -> host
    }

    // ---- Suppression (§2.6) ----

    fun recordSuppression(tabId: String, fingerprint: String) {
        synchronized(lock) {
            suppression[suppressionKey(tabId, fingerprint)] =
                clock.elapsedRealtime() + suppressionExpiryMs
        }
    }

    fun isSuppressed(tabId: String, fingerprint: String): Boolean {
        synchronized(lock) {
            sweepExpiredLocked()
            val expiresAt = suppression[suppressionKey(tabId, fingerprint)] ?: return false
            return clock.elapsedRealtime() <= expiresAt
        }
    }

    /** Clear a tab's suppression on a new user-initiated/direct navigation (§2.6). */
    fun clearSuppressionForTab(tabId: String) {
        synchronized(lock) {
            suppression.keys.removeAll { it.startsWith("$tabId\u0000") }
        }
    }

    // ---- Fallback re-entry map (§2.7) ----

    fun recordFallbackReentry(canonicalUrl: String) {
        synchronized(lock) {
            fallbackReentry[canonicalUrl] = clock.elapsedRealtime() + fallbackReentryMs
        }
    }

    fun isFallbackReentry(canonicalUrl: String): Boolean {
        synchronized(lock) {
            sweepExpiredLocked()
            val expiresAt = fallbackReentry[canonicalUrl] ?: return false
            return clock.elapsedRealtime() <= expiresAt
        }
    }

    private fun sweepExpiredLocked() {
        val now = clock.elapsedRealtime()
        requests.values.removeAll { now > it.createdAt + requestExpiryMs }
        suppression.values.removeAll { now > it }
        fallbackReentry.values.removeAll { now > it }
    }

    companion object {
        const val REQUEST_EXPIRY_MS = 10 * 60 * 1000L
        const val SUPPRESSION_EXPIRY_MS = 10 * 60 * 1000L
        const val DEDUPE_WINDOW_MS = 2000L
        const val FALLBACK_REENTRY_MS = 10 * 1000L
    }
}
