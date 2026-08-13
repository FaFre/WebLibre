/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import eu.weblibre.flutter_mozilla_components.history.TabScopedHistoryDelegate
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.selector.normalTabs
import mozilla.components.browser.state.selector.privateTabs
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.history.HistoryTrackingDelegate
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import mozilla.components.support.base.log.logger.Logger

/**
 * Gives every engine session its own [TabScopedHistoryDelegate], so a recorded
 * visit carries the tab that produced it instead of being matched back to one by
 * URL.
 *
 * Android Components copies the engine-wide default delegate into each session's
 * settings when the session is created; this replaces it with a tab-scoped one at
 * the earliest point the store exposes the session — before [next] runs, so the
 * binding is in place before `LinkingMiddleware` (which sits downstream) starts
 * the tab's load. A session is re-bound whenever it is re-linked, e.g. after
 * being suspended or recovered from a crash.
 */
class HistoryDelegateBindingMiddleware(
    private val storageDelegate: HistoryTrackingDelegate,
) : Middleware<BrowserState, BrowserAction> {

    private val logger = Logger("HistoryDelegateBindingMiddleware")

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is EngineAction.LinkEngineSessionAction -> {
                val session = store.state.findTabOrCustomTab(action.tabId)
                bind(
                    store = store,
                    tabId = action.tabId,
                    contextId = session?.contextId,
                    parentId = (session as? TabSessionState)?.parentId,
                    engineSession = action.engineSession,
                )
            }

            // A session opened by the engine itself (`window.open`) arrives with
            // its engine session already attached and already navigating.
            is TabListAction.AddTabAction -> {
                action.tab.engineState.engineSession?.let { engineSession ->
                    bind(
                        store = store,
                        tabId = action.tab.id,
                        contextId = action.tab.contextId,
                        parentId = action.tab.parentId,
                        engineSession = engineSession,
                    )
                }
            }

            is TabListAction.RemoveTabAction -> HistoryExclusions.forget(action.tabId)
            is TabListAction.RemoveTabsAction ->
                action.tabIds.forEach { HistoryExclusions.forget(it) }
            is TabListAction.RemoveAllTabsAction -> HistoryExclusions.forgetAll()
            // Only the tabs actually being removed, read before [next] applies the
            // action. Forgetting the whole set would drop the provisional mark of a
            // surviving tab WebLibre has no row for yet — an excluded container's
            // `window.open` child — and its next visit would reach Places.
            is TabListAction.RemoveAllNormalTabsAction ->
                store.state.normalTabs.forEach { HistoryExclusions.forget(it.id) }
            is TabListAction.RemoveAllPrivateTabsAction ->
                store.state.privateTabs.forEach { HistoryExclusions.forget(it.id) }

            else -> { /* no-op */ }
        }

        next(action)
    }

    private fun bind(
        store: Store<BrowserState, BrowserAction>,
        tabId: String,
        contextId: String?,
        parentId: String?,
        engineSession: EngineSession,
    ) {
        inheritExclusion(store.state, tabId, parentId)

        try {
            engineSession.settings.historyTrackingDelegate =
                TabScopedHistoryDelegate(tabId, contextId, storageDelegate)
        } catch (e: UnsupportedOperationException) {
            // Only an engine that doesn't support per-session history settings can
            // land here; the engine-wide default keeps recording for it.
            logger.error("Failed to bind tab-scoped history delegate for $tabId", e)
        }
    }

    /**
     * Carry the opener's exclusion over to a session WebLibre hasn't recorded yet.
     * The child inherits the parent's container in Dart moments later; until that
     * snapshot arrives this is the only thing standing between an excluded
     * container's popup and Places. Provisional — see [HistoryExclusions].
     */
    private fun inheritExclusion(state: BrowserState, tabId: String, parentId: String?) {
        // Once the snapshot covers the tab it is the authority, and a mark added
        // here would only be dead weight the next snapshot has to clear. Note the
        // check is "tracked", not "excluded": a *known non-excluded* tab must not
        // be re-marked on every re-link either.
        if (parentId == null || HistoryExclusions.isTracked(tabId)) {
            return
        }

        val parent: SessionState = state.findTabOrCustomTab(parentId) ?: return
        if (HistoryExclusions.isExcluded(parent.id, parent.contextId)) {
            HistoryExclusions.markProvisional(tabId)
        }
    }
}
