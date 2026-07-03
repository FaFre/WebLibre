package eu.weblibre.flutter_mozilla_components.history

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryEvents
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.concept.storage.PageVisit

/**
 * Wraps the Android Components [HistoryTrackingDelegate] (which feeds Mozilla
 * Places / FxA sync) and, on each recorded visit, additionally notifies Dart of
 * the WebLibre container that produced it.
 *
 * Mozilla Places stays the source of truth for the visit itself (url, title,
 * visit type, visit time); WebLibre only needs the one thing Places can't store:
 * which container the visit belonged to. Places strips the session before
 * [onVisited], so the container is recovered from the `url -> contextId`
 * correlation cache populated by
 * [eu.weblibre.flutter_mozilla_components.middleware.HistoryVisitCorrelationMiddleware]
 * at navigation time; Dart maps the contextId to a WebLibre container and writes
 * the visit→container relation row.
 *
 * Purely additive for Places/sync: every call delegates to [wrapped]. The one
 * exception is hard exclude-from-history — for a container opted out of history
 * recording, the Places write is skipped too so the visit never lands anywhere.
 */
class WebLibreHistoryDelegate(
    private val wrapped: HistoryTrackingDelegate,
    private val events: GeckoHistoryEvents?,
) : HistoryTrackingDelegate by wrapped {

    override suspend fun onVisited(uri: String, visit: PageVisit) {
        // Resolve which container produced this visit once, and reuse it for
        // both the hard-exclude decision and the Dart relation emit.
        val resolution = resolveContextId(uri)

        // Hard exclude-from-history: for a visit whose container has
        // exclude-from-history enabled, skip BOTH the Places write and the Dart
        // relation emit — the visit must not land in either store.
        if (isHistoryExcluded(uri, resolution)) {
            return
        }

        wrapped.onVisited(uri, visit)

        // Timestamp near the Places record time; Dart joins to the actual Places
        // visit by (url, nearest visit_time), tolerating the small skew. Best
        // effort for tagging: even the non-authoritative guess is emitted, since
        // a wrong tag is recoverable (unlike the exclude decision above).
        val visitTime = System.currentTimeMillis()

        // Flutter's binary messenger must be used on the platform (main) thread.
        if (events != null) {
            withContext(Dispatchers.Main) {
                events.onVisitRecorded(uri, visitTime, resolution.contextId) {}
            }
        }
    }

    /**
     * Decide whether this visit belongs to a hard exclude-from-history
     * ("incognito") container and must therefore land nowhere.
     *
     * Fails **closed**: unlike tagging (where a missing tag is recoverable),
     * leaking an excluded container's visit to Places is not, so any ambiguity
     * that could involve an excluded container is resolved as "excluded".
     *
     * - When [resolution] is authoritative (steps 1–2 pinned the producing tab),
     *   trust it: excluded iff that tab's contextId is in the excluded set.
     * - Otherwise (the last-resort step-3 guess or a full miss), scan open tabs:
     *   if any non-private tab is currently on this exact URL in an excluded
     *   container, the visit may have originated there — drop it. This closes the
     *   window where a background-tab visit's correlation was evicted/expired.
     */
    private fun isHistoryExcluded(uri: String, resolution: ContextResolution): Boolean {
        val excluded = GlobalComponents.excludedHistoryContextIds
        if (excluded.isEmpty()) {
            return false
        }

        if (resolution.authoritative) {
            return resolution.contextId != null && resolution.contextId in excluded
        }

        val tabs = GlobalComponents.components?.core?.store?.state?.tabs ?: return false
        return tabs.any { tab ->
            !tab.content.private &&
                tab.content.url == uri &&
                tab.contextId != null &&
                tab.contextId in excluded
        }
    }

    /**
     * The producing Gecko [contextId] for a visit, plus whether it was pinned
     * [authoritative]ly (a definite producer) or is only a best-effort guess.
     */
    private data class ContextResolution(
        val contextId: String?,
        val authoritative: Boolean,
    )

    /**
     * Resolve the visited [uri] to the Gecko contextId that produced it.
     *
     * Resolution order, most specific first:
     *
     * 1. The per-navigation correlation recorded by
     *    [eu.weblibre.flutter_mozilla_components.middleware.HistoryVisitCorrelationMiddleware]
     *    for the tab that actually navigated to [uri]. This correctly attributes
     *    a **background-tab** visit and — crucially — stops a loading foreground
     *    tab from stealing another tab's same-URL visit. A live
     *    [HistoryVisitCorrelationCache.Resolution] (even with a null contextId,
     *    i.e. known-uncontained) is authoritative.
     * 2. On a cache miss, the selected tab only when it is **actively loading
     *    exactly [uri]** (`loading && url == uri`). With no recorded competing
     *    navigation, it is the best live producer signal. Authoritative.
     * 3. Otherwise, the loading selected tab as a last resort: redirect chains
     *    can fire `onVisited(uri)` before the selected tab's url settles on [uri]
     *    and before the middleware records it. Marked **not** authoritative — it
     *    may mis-attribute a background-tab visit, so the exclude decision does
     *    not trust it and re-checks via [isHistoryExcluded].
     *
     * A full miss returns a non-authoritative uncontained (null) result.
     */
    private fun resolveContextId(uri: String): ContextResolution {
        val selected = GlobalComponents.components?.core?.store?.state?.selectedTab

        val correlation = HistoryVisitCorrelationCache.resolve(uri)
        if (correlation != null) {
            return ContextResolution(correlation.contextId, authoritative = true)
        }

        if (selected != null && !selected.content.private &&
            selected.content.loading && selected.content.url == uri
        ) {
            return ContextResolution(selected.contextId, authoritative = true)
        }

        if (selected != null && !selected.content.private &&
            selected.content.loading
        ) {
            return ContextResolution(selected.contextId, authoritative = false)
        }

        return ContextResolution(null, authoritative = false)
    }
}
