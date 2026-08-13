/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.history

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.concept.storage.PageVisit

/**
 * The [HistoryTrackingDelegate] a single engine session runs.
 *
 * Android Components installs one delegate engine-wide, and by the time a visit
 * reaches it the session is gone — leaving only the visited URL to guess the
 * producing tab from. WebLibre instead binds one of these per session (see
 * [eu.weblibre.flutter_mozilla_components.middleware.HistoryDelegateBindingMiddleware]),
 * so both things WebLibre needs are exact rather than inferred:
 *
 *  - **Exclude from History**: [HistoryExclusions] is asked about *this* tab, so a
 *    container opted out of history recording never reaches Places — including
 *    containers without cookie isolation, which no contextId could distinguish.
 *  - **Container tagging**: the visit is reported to Dart with its real [tabId],
 *    which maps to a WebLibre container through the tab store.
 *
 * Everything else delegates to [wrapped] (Places), which stays the source of
 * truth for the visit itself: url, title, visit type and time.
 */
class TabScopedHistoryDelegate(
    private val tabId: String,
    private val contextId: String?,
    private val wrapped: HistoryTrackingDelegate,
) : HistoryTrackingDelegate {

    private val isExcluded: Boolean
        get() = HistoryExclusions.isExcluded(tabId, contextId)

    override suspend fun onVisited(uri: String, visit: PageVisit) {
        if (isExcluded) {
            return
        }

        wrapped.onVisited(uri, visit)

        // Timestamp near the Places record time; Dart joins to the actual Places
        // visit by (url, nearest visit_time), tolerating the small skew.
        val visitTime = System.currentTimeMillis()

        // Null on the headless path (no Flutter engine): the visit is still
        // recorded in Places, only the container tag is skipped.
        val events = GlobalComponents.historyEvents ?: return

        // Flutter's binary messenger must be used on the platform (main) thread.
        withContext(Dispatchers.Main) {
            events.onVisitRecorded(uri, visitTime, tabId) {}
        }
    }

    override suspend fun onTitleChanged(uri: String, title: String) {
        // A title observation creates the page in Places even without a visit, so
        // an excluded container has to skip it too.
        if (isExcluded) {
            return
        }

        wrapped.onTitleChanged(uri, title)
    }

    override suspend fun onPreviewImageChange(uri: String, previewImageUrl: String) {
        if (isExcluded) {
            return
        }

        wrapped.onPreviewImageChange(uri, previewImageUrl)
    }

    /**
     * Answers "have I been here?" for link colouring. An excluded container is
     * told nothing was visited: the pages it loads are absent from history, and
     * pages visited elsewhere must not become observable through :visited styling.
     */
    override suspend fun getVisited(uris: List<String>): List<Boolean> =
        if (isExcluded) List(uris.size) { false } else wrapped.getVisited(uris)

    override suspend fun getVisited(): List<String> =
        if (isExcluded) emptyList() else wrapped.getVisited()

    /**
     * The engine's cheap pre-check, consulted before [onVisited], [onTitleChanged]
     * and [onPreviewImageChange]. Refusing here means an excluded session skips
     * recording even if a future AC change adds another recording path.
     */
    override fun shouldStoreUri(uri: String): Boolean =
        !isExcluded && wrapped.shouldStoreUri(uri)
}
