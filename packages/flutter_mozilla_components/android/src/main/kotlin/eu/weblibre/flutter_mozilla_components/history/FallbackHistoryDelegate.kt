/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.history

import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.concept.storage.PageVisit

/**
 * The engine-wide default history delegate: what a session records with before —
 * or without ever — being bound to a [TabScopedHistoryDelegate].
 *
 * It has no session to identify, so it cannot answer "is this tab excluded?".
 * Rather than assume "no", it records **only while nothing is excluded at all**.
 * Two kinds of session reach it:
 *
 *  - Sessions created outside the store (add-on popups, the headless push
 *    session). They load `moz-extension:`/`about:` URLs that Places rejects
 *    anyway, so refusing costs nothing.
 *  - A session the engine opened itself (`window.open`), in the window between
 *    Gecko starting its navigation and
 *    [eu.weblibre.flutter_mozilla_components.middleware.HistoryDelegateBindingMiddleware]
 *    binding it — the one gap the binding cannot close from inside the store,
 *    since the child is already navigating when `AddTabAction` is dispatched.
 *
 * Sessions the store creates are bound at `LinkEngineSessionAction`, before
 * their load is dispatched, so they never record through this.
 *
 * The cost is a visit dropped from a *non*-excluded popup that manages to record
 * before its binding lands, and only for users who have an excluded container at
 * all. That is the right way round: a dropped visit comes back on the next visit,
 * a leaked one does not.
 */
class FallbackHistoryDelegate(
    private val wrapped: HistoryTrackingDelegate,
) : HistoryTrackingDelegate {

    private val canRecord: Boolean
        get() = !HistoryExclusions.anyExclusionActive

    override suspend fun onVisited(uri: String, visit: PageVisit) {
        if (!canRecord) {
            return
        }

        wrapped.onVisited(uri, visit)
    }

    override suspend fun onTitleChanged(uri: String, title: String) {
        if (!canRecord) {
            return
        }

        wrapped.onTitleChanged(uri, title)
    }

    override suspend fun onPreviewImageChange(uri: String, previewImageUrl: String) {
        if (!canRecord) {
            return
        }

        wrapped.onPreviewImageChange(uri, previewImageUrl)
    }

    override suspend fun getVisited(uris: List<String>): List<Boolean> =
        if (canRecord) wrapped.getVisited(uris) else List(uris.size) { false }

    override suspend fun getVisited(): List<String> =
        if (canRecord) wrapped.getVisited() else emptyList()

    override fun shouldStoreUri(uri: String): Boolean =
        canRecord && wrapped.shouldStoreUri(uri)
}
