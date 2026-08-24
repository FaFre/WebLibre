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
    /**
     * The interceptor denied an engine-supported load to raise this prompt (policy
     * `blockWhilePrompting`), so the tab is sitting on its previous page and [url] is owed to it if
     * the user explicitly declines opening the app. False for a prompt raised over a page that was
     * allowed to load, and for an unsupported scheme (there is nothing loadable to owe). Passive
     * dismissal and expiry intentionally leave the tab unchanged.
     */
    val heldNavigation: Boolean,
    /**
     * The URL the tab was committed to when [heldNavigation] was taken — the page the user is left
     * looking at while the prompt is up, and the proof that releasing is still safe.
     *
     * Checked again at release time rather than invalidated on navigation. Store actions cannot
     * express "the user has moved on": a direct load runs the interceptor *inside*
     * `engineSession.loadUrl()` (GeckoView short-circuits the delegate for direct navigation), so
     * the `LoadUrlAction` that follows would clear a hold created a moment earlier; and in-page
     * links, Back/Forward and reload dispatch no load action at all. Comparing where the tab
     * actually is closes both ends, and needs no ordering guarantee.
     */
    val heldAnchorUrl: String?,
    /**
     * The tab's navigation generation when the hold was taken (see
     * [PendingAppLinkStore.beginNavigation]). Releasing is only safe while the tab is still on that
     * navigation.
     *
     * This is what the committed-URL anchor cannot express. The anchor only changes when a load
     * *commits*, so a navigation the user has already started — but which has not painted yet —
     * leaves it matching, and the release lands on top of an in-flight page. The generation moves at
     * `onLoadRequest`, the moment a navigation is attempted.
     */
    val navGeneration: Long,
    val createdAt: Long,
) {
    fun toPigeon(expiresInMs: Long): AppLinkPromptRequest = AppLinkPromptRequest(
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
        expiresInMs = expiresInMs,
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
    /** See [PendingAppLinkRequest.heldNavigation]. */
    val heldNavigation: Boolean = false,
    /** See [PendingAppLinkRequest.heldAnchorUrl]. */
    val heldAnchorUrl: String? = null,
    /** See [PendingAppLinkRequest.navGeneration]. */
    val navGeneration: Long = 0L,
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
 *
 * **A request's lifetime is deliberately not derived from navigation.** Three attempts to infer
 * "the user has left the page this prompt belongs to" from the [mozilla.components.browser.state.store.BrowserStore]
 * action stream all failed the same way, because every available signal is *per document* while a
 * single user-visible navigation spans several:
 * - comparing the committed URL's host to the request's anchor killed a banner on its own redirect
 *   chain (`youtu.be` → `youtube.com`, shortener → destination) and killed a modal on the commit of
 *   the very load it had interrupted — leaving a denied navigation with no dialog to un-stall it;
 * - counting load starts ([mozilla.components.browser.state.action.ContentAction.UpdateLoadingStateAction])
 *   dismissed banners seconds in, because each redirected document starts its own load;
 * - settling on idle only moved that to the first `onPageStop`, which multi-document pages reach
 *   long before the user is done with them.
 *
 * So navigation is not consulted at all. A request ends when the user answers it, when its tab
 * closes, when a newer banner for the same tab replaces it, or when it expires ([BANNER_EXPIRY_MS]
 * for the passive banner, [REQUEST_EXPIRY_MS] for a modal that is holding a navigation). The
 * residual risk — a banner outliving the page it was raised on — is bounded by that expiry and is
 * strictly safer than the alternatives: a lingering banner still names its target and still opens
 * exactly that link, whereas the invalidation heuristics produced prompts that silently did
 * nothing. Do not reintroduce URL- or load-state-derived invalidation without a signal that is
 * per *navigation* rather than per document.
 */
class PendingAppLinkStore(
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val requestExpiryMs: Long = REQUEST_EXPIRY_MS,
    private val bannerExpiryMs: Long = BANNER_EXPIRY_MS,
    private val suppressionExpiryMs: Long = SUPPRESSION_EXPIRY_MS,
    private val dedupeWindowMs: Long = DEDUPE_WINDOW_MS,
    private val fallbackReentryMs: Long = FALLBACK_REENTRY_MS,
    private val fallbackIssueMs: Long = FALLBACK_ISSUE_MS,
    private val fallbackIssueBudget: Int = FALLBACK_ISSUE_BUDGET,
    private val fallbackBudgetWindowMs: Long = FALLBACK_BUDGET_WINDOW_MS,
) {
    /** Rolling per-tab allowance of fallback loads; see [claimFallbackIssue]. */
    private class FallbackBudget(var count: Int, var windowEndsAt: Long)

    private val logger = Logger("PendingAppLinkStore")
    private val lock = Any()
    private val idGenerator = AtomicLong(0L)

    private val requests = LinkedHashMap<Long, PendingAppLinkRequest>()
    private val suppression = HashMap<String, Long>()
    private val fallbackReentry = HashMap<String, Long>()
    private val fallbackIssued = HashMap<String, Long>()
    private val fallbackBudget = HashMap<String, FallbackBudget>()

    /** Per-tab navigation counter; see [beginNavigation]. */
    private val navGeneration = HashMap<String, Long>()

    private fun suppressionKey(tabId: String, fingerprint: String) = "$tabId\u0000$fingerprint"

    // Same tab-scoped composite shape as [suppressionKey]; a sessionless navigation keys under the
    // empty tab so its fallback is still bounded rather than unguarded.
    private fun fallbackIssueKey(tabId: String?, fallbackUrl: String) =
        suppressionKey(tabId.orEmpty(), fallbackIdentity(fallbackUrl))

    /**
     * The loop-detection identity of a fallback URL: everything before the query and fragment.
     *
     * The exact URL cannot serve as the key. Google Maps grows a `coh` query parameter by one
     * entry on every round trip (`coh=192189,230964` → `…,230964` → …), so an exact key made each
     * bounce a fresh claim and the tab kept reloading until that list happened to saturate. What
     * identifies *which* target a page keeps bouncing us to lives in the origin and path; the
     * query is where such round-trip bookkeeping accumulates.
     */
    private fun fallbackIdentity(fallbackUrl: String): String {
        val cut = fallbackUrl.indexOfFirst { it == '?' || it == '#' }
        return if (cut >= 0) fallbackUrl.substring(0, cut) else fallbackUrl
    }

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
                        // Collapsing across a change of held state would hand back a request whose
                        // obligation disagrees with the answer the interceptor is about to give:
                        // a denied load left un-owed (never released), or an allowed one carrying a
                        // debt that would later overwrite the page it just let through. The anchor
                        // has to agree too — the same target reattempted from a different page
                        // would otherwise inherit the first page's anchor, and the release check
                        // would then refuse a decline that deserves its load.
                        candidate.heldNavigation == input.heldNavigation &&
                        candidate.heldAnchorUrl == input.heldAnchorUrl &&
                        clock.elapsedRealtime() <= candidate.createdAt + dedupeWindowMs
                }
                if (existing != null) {
                    // Same offer, but this is a *later* navigation attempt: the interceptor has just
                    // denied another load and bumped the generation. Handing the request back with
                    // its original stamp would leave the newest hold answering for a navigation that
                    // no longer exists, and [claimRelease] would strand it. Re-stamp instead of
                    // splitting the request, so the surface keeps showing one unchanged prompt.
                    if (existing.navGeneration == input.navGeneration) return existing
                    val restamped = existing.copy(navGeneration = input.navGeneration)
                    requests[existing.requestId] = restamped
                    return restamped
                }
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
                heldNavigation = input.heldNavigation,
                heldAnchorUrl = input.heldAnchorUrl,
                navGeneration = input.navGeneration,
                createdAt = clock.elapsedRealtime(),
            )
            // At most one live banner per tab: the surface renders one anyway, and a second
            // app-link site visited in the same tab should replace the offer, not stack behind it.
            if (request.urlClass == AppLinkUrlClass.BANNER) {
                requests.values.removeAll {
                    it.tabId == request.tabId && it.urlClass == AppLinkUrlClass.BANNER
                }
            }
            requests[request.requestId] = request
            return request
        }
    }

    /**
     * How long [request] has left before [sweepExpiredLocked] drops it. Handed to the surface so it
     * can retire the prompt on time — expiry is lazy (it only runs on query/consume), so a prompt
     * left on screen past its deadline would still render buttons that resolve to `stale`.
     */
    fun expiresInMs(request: PendingAppLinkRequest): Long =
        (expiryFor(request) - (clock.elapsedRealtime() - request.createdAt)).coerceAtLeast(0L)

    /**
     * Record that a tab is going somewhere, and return the tab's new generation.
     *
     * Counts navigations that will actually *proceed*, not attempts. A denied load leaves the tab
     * where it was, so counting it would make a pending hold answer for a navigation that never
     * happened and [claimRelease] would refuse a release that was perfectly safe — the user's "stay
     * in the browser" silently doing nothing. The interceptor therefore bumps only once it knows the
     * outcome, and never for `Deny`; that is also what keeps a hold self-consistent, since raising
     * one denies the load and so leaves the generation it stamped current.
     *
     * Driven from the interceptor rather than from a store action wherever it can be, and that
     * placement is the point. GeckoView short-circuits the navigation delegate for direct loads, so
     * `onLoadRequest` runs inline inside `engineSession.loadUrl()` — *before* `SessionUseCases`
     * dispatches anything. A counter driven purely by those actions would always land one step after
     * the hold it was meant to protect and cancel it immediately.
     *
     * [AppLinkNavigationMiddleware] covers the engine-delegated navigations that never reach the
     * interceptor (history, reload, `loadData`, desktop-mode toggle), gated on the tab really having
     * somewhere to go for the same reason. Navigations that reach neither (a PWA/TWA scoped load, a
     * sandbox capture, `weblibre://`, FxA) do not bump at all; the committed-URL anchor stays the
     * backstop for those, which is why [claimRelease] checks both.
     */
    fun beginNavigation(tabId: String, reason: String = "?"): Long {
        synchronized(lock) {
            val next = (navGeneration[tabId] ?: 0L) + 1L
            navGeneration[tabId] = next
            val heldHere = requests.values.count { it.tabId == tabId && it.heldNavigation }
            logger.info(
                "nav bump tab=$tabId gen=${next - 1} -> $next reason=$reason " +
                    "(invalidates $heldHere live hold(s))",
            )
            return next
        }
    }

    /** Current generation, for a caller that needs to compare without advancing it. */
    fun currentNavGeneration(tabId: String): Long = synchronized(lock) { navGeneration[tabId] ?: 0L }

    /**
     * Decide, atomically, whether [request]'s held navigation may still be loaded.
     *
     * Consuming detaches a request *before* the load happens, which leaves a window the
     * store can no longer police from the outside: a newer prompt raised in that window cannot
     * cancel debt that is no longer in the map, and it leaves the tab on the same page, so the URL
     * anchor still agrees. Deciding here, under the lock, against state the store still owns, closes
     * both — this is the last word on whether the load may happen.
     *
     * @param currentUrl the tab's committed URL, read by the caller from the browser store.
     */
    fun claimRelease(request: PendingAppLinkRequest, currentUrl: String): Boolean {
        synchronized(lock) {
            sweepExpiredLocked()
            val liveGeneration = navGeneration[request.tabId] ?: 0L
            val newerHold = requests.values
                .firstOrNull { it.tabId == request.tabId && it.heldNavigation }
            if (!request.heldNavigation) return false
            // The tab has moved on since the hold was taken.
            if (liveGeneration != request.navGeneration) {
                logger.info(
                    "claimRelease id=${request.requestId} REFUSED: generation moved " +
                        "(${request.navGeneration} -> $liveGeneration)",
                )
                return false
            }
            // A newer hold is what this tab is waiting on now; the older debt is superseded even
            // though it was detached before this one existed.
            //
            // Deliberately narrower than the discard in [createRequest], which drops *queued* debt
            // for any newer request at all. The two are not the same debt. Queued debt belongs to a
            // prompt the user ignored, so a newer offer may quietly retire it. Debt in a caller's
            // hand belongs to a prompt the user just answered with "stay in the browser", and the
            // page they asked for is owed to them whatever else has since appeared over it — an
            // unheld banner (a subframe offer, or one raised after blocking was switched off) leaves
            // the tab exactly where the hold left it, so there is nothing to overwrite and cancelling
            // here would strand the answer instead.
            if (newerHold != null) {
                logger.info(
                    "claimRelease id=${request.requestId} REFUSED: newer hold ${newerHold.requestId}",
                )
                return false
            }
            // Backstop for navigations that never bumped the generation.
            if (!isSameDocumentTarget(currentUrl, request.heldAnchorUrl)) {
                logger.info(
                    "claimRelease id=${request.requestId} REFUSED: anchor mismatch " +
                        "(anchor=${request.heldAnchorUrl} now=$currentUrl)",
                )
                return false
            }
            logger.info("claimRelease id=${request.requestId} GRANTED -> will load ${request.url}")
            return true
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

    /**
     * Invalidate every pending request for a tab (tab close / replacement).
     *
     * @return the owners that had a request removed, so the caller can tell those surfaces to
     * re-query instead of leaving a dead prompt on screen.
     */
    fun invalidateTab(tabId: String): Set<AppLinkPromptOwner> {
        synchronized(lock) {
            val owners = requests.values
                .filter { it.tabId == tabId }
                .mapTo(mutableSetOf()) { it.owner }
            requests.values.removeAll { it.tabId == tabId }
            navGeneration.remove(tabId)
            suppression.keys.removeAll { it.startsWith("$tabId\u0000") }
            fallbackIssued.keys.removeAll { it.startsWith(fallbackIssueKey(tabId, "")) }
            fallbackBudget.remove(tabId)
            return owners
        }
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

    /**
     * Drop every request whose tab is gone, for the bulk close/restore actions that name no tab
     * (close-all, close-all-private, close-all-custom-tabs). Reconciling against the surviving tabs
     * avoids mirroring each reducer's notion of what it removed.
     *
     * @return the tabs that lost a request, mapped to the owners that were showing one.
     */
    fun retainTabs(liveTabIds: Set<String>): Map<String, Set<AppLinkPromptOwner>> {
        synchronized(lock) {
            val affected = requests.values
                .filterNot { it.tabId in liveTabIds }
                .groupBy({ it.tabId }, { it.owner })
                .mapValues { (_, owners) -> owners.toSet() }
            requests.values.removeAll { it.tabId !in liveTabIds }
            // Same cleanup a single-tab close does. "Close all" then "undo" restores the very same
            // tab ids, so anything keyed on them outlives the tabs and lands on their replacements:
            // a stale suppression silently swallows the next prompt, a stale fallback claim refuses
            // the next fallback.
            // The empty tab id is the sessionless-navigation bucket, not a closed tab; it belongs
            // to no tab and must survive.
            val dead = { key: String ->
                val tabId = key.substringBefore('\u0000')
                tabId.isNotEmpty() && tabId !in liveTabIds
            }
            suppression.keys.removeAll(dead)
            fallbackIssued.keys.removeAll(dead)
            fallbackBudget.keys.removeAll { it.isNotEmpty() && it !in liveTabIds }
            navGeneration.keys.removeAll { it !in liveTabIds }
            return affected
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

    /**
     * Claim the right to *issue* [fallbackUrl] as a load in [tabId].
     *
     * The sibling of [isFallbackReentry], guarding the other end of the same hop: that map lets an
     * already-issued fallback load past the app-links tail, this one bounds how often a fallback
     * may be issued at all. App-promotion pages re-fire their `intent:` URL on every load of their
     * own `browser_fallback_url` page (Google Maps place links do), so issuing the fallback
     * unconditionally reloads that page for as long as the tab is open.
     *
     * Two independent bounds, because the first one alone assumes more than the web provides:
     * 1. per [fallbackIdentity]: the first claim in a window wins, repeats are refused;
     * 2. per tab: at most [fallbackIssueBudget] fallback loads per budget window, whatever their
     *    identity — this one holds even against a page that mutates its fallback URL on every
     *    bounce, which is exactly how the identity bound was first defeated.
     *
     * A refused claim pushes both windows out, so a page firing on a timer cannot walk around
     * either by waiting. The escape hatch is a user-initiated navigation
     * ([clearFallbackIssuedForTab]), not the passage of time.
     *
     * @return true when the caller may issue the load; false when it must keep the current page.
     */
    fun claimFallbackIssue(tabId: String?, fallbackUrl: String): Boolean {
        synchronized(lock) {
            sweepExpiredLocked()
            val now = clock.elapsedRealtime()

            val key = fallbackIssueKey(tabId, fallbackUrl)
            val repeat = fallbackIssued[key]?.let { now <= it } ?: false
            fallbackIssued[key] = now + fallbackIssueMs

            val budget = fallbackBudget[tabId.orEmpty()]
                ?.takeIf { now <= it.windowEndsAt }
                ?: FallbackBudget(count = 0, windowEndsAt = now + fallbackBudgetWindowMs)
            fallbackBudget[tabId.orEmpty()] = budget

            if (repeat || budget.count >= fallbackIssueBudget) {
                budget.windowEndsAt = now + fallbackBudgetWindowMs
                return false
            }
            budget.count++
            return true
        }
    }

    /** Release a tab's fallback claims on a new user-initiated/direct navigation. */
    fun clearFallbackIssuedForTab(tabId: String) {
        synchronized(lock) {
            fallbackIssued.keys.removeAll { it.startsWith(fallbackIssueKey(tabId, "")) }
            fallbackBudget.remove(tabId)
        }
    }

    /**
     * A banner is a passive offer sitting over a page the user keeps reading, so it is bounded by
     * time rather than by navigation (see the class KDoc). A modal blocks a navigation until it is
     * answered, so it keeps the long window.
     */
    private fun expiryFor(request: PendingAppLinkRequest): Long =
        if (request.urlClass == AppLinkUrlClass.BANNER) bannerExpiryMs else requestExpiryMs

    private fun sweepExpiredLocked() {
        val now = clock.elapsedRealtime()
        requests.values.removeAll { request ->
            // `>=`, not `>`: at the exact deadline [expiresInMs] already reports zero, and a surface
            // that is told "no time left" drops the prompt and arms no further refresh.
            now >= request.createdAt + expiryFor(request)
        }
        suppression.values.removeAll { now > it }
        fallbackReentry.values.removeAll { now > it }
        fallbackIssued.values.removeAll { now > it }
        fallbackBudget.values.removeAll { now > it.windowEndsAt }
    }

    companion object {
        const val REQUEST_EXPIRY_MS = 10 * 60 * 1000L
        const val BANNER_EXPIRY_MS = 90 * 1000L
        const val SUPPRESSION_EXPIRY_MS = 10 * 60 * 1000L
        const val DEDUPE_WINDOW_MS = 2000L
        const val FALLBACK_REENTRY_MS = 10 * 1000L
        const val FALLBACK_ISSUE_MS = 10 * 1000L

        /**
         * Fallback loads one tab may trigger per [FALLBACK_BUDGET_WINDOW_MS]. Set well above what
         * ordinary browsing reaches (each one needs a distinct app-link target, and a user-initiated
         * navigation resets the count) and well below what a loop produces in the same window.
         */
        const val FALLBACK_ISSUE_BUDGET = 5
        const val FALLBACK_BUDGET_WINDOW_MS = 30 * 1000L
    }
}
