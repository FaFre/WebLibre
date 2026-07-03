package eu.weblibre.flutter_mozilla_components.history

/**
 * Short-lived `url -> contextId` correlation captured at navigation time.
 *
 * Android Components strips the session before it reaches
 * [mozilla.components.concept.engine.history.HistoryTrackingDelegate.onVisited],
 * so the delegate only sees the visited URL — not which tab (and therefore which
 * Gecko contextual identity / WebLibre container) produced it. The
 * [eu.weblibre.flutter_mozilla_components.middleware.HistoryVisitCorrelationMiddleware]
 * records the navigating tab's contextId here on every `UpdateUrlAction`; the
 * delegate reads it back when the matching visit is recorded moments later.
 *
 * This is the primary signal: the delegate trusts a live correlation before
 * falling back to the selected tab (see
 * [eu.weblibre.flutter_mozilla_components.history.WebLibreHistoryDelegate]). The
 * TTL is deliberately short — a record and its visit are milliseconds apart, so
 * anything older is an orphan (e.g. recorded on a reload that fired its
 * `onVisited` before the record) and must expire quickly, or it can leak onto a
 * later same-URL visit in a different container.
 */
object HistoryVisitCorrelationCache {
    private const val TTL_MS = 3_000L
    private const val MAX_ENTRIES = 64

    private data class Entry(val contextId: String?, val timestamp: Long)

    // Insertion-ordered so we can drop the oldest entry when over capacity.
    private val entries = LinkedHashMap<String, Entry>()

    /** Record the [contextId] (nullable = uncontained tab) that navigated to [url]. */
    @Synchronized
    fun record(url: String, contextId: String?) {
        val now = System.currentTimeMillis()
        evictExpired(now)
        // Re-insert so the most recent navigation to a URL wins and stays newest.
        entries.remove(url)
        entries[url] = Entry(contextId, now)
        while (entries.size > MAX_ENTRIES) {
            val oldest = entries.keys.firstOrNull() ?: break
            entries.remove(oldest)
        }
    }

    /** A live correlation for a URL: present in the cache, its [contextId]
     * possibly null (the producing tab was uncontained). Distinct from a cache
     * miss (`resolve` returns null), so the caller can tell a known-uncontained
     * navigation apart from an unknown one. */
    data class Resolution(val contextId: String?)

    /**
     * The correlation most recently recorded for [url] within the TTL, or null
     * if there is no live entry. A non-null [Resolution] with a null contextId
     * means the producing tab was uncontained — the caller must treat that as an
     * authoritative "uncontained" answer, NOT as a miss, so it does not fall
     * back to a less specific signal (e.g. a merely-loading foreground tab).
     *
     * Consume-on-read: the entry is removed so a stale correlation can NEVER be
     * reused for a later, unrelated visit of the same URL — e.g. a page first
     * visited in a container and later reopened uncontained (or in a different
     * container) must not inherit the earlier container. A repeat navigation
     * re-records it via the middleware.
     */
    @Synchronized
    fun resolve(url: String): Resolution? {
        val now = System.currentTimeMillis()
        evictExpired(now)
        val entry = entries.remove(url) ?: return null
        return Resolution(entry.contextId)
    }

    private fun evictExpired(now: Long) {
        val iterator = entries.entries.iterator()
        while (iterator.hasNext()) {
            if (now - iterator.next().value.timestamp > TTL_MS) {
                iterator.remove()
            }
        }
    }
}
