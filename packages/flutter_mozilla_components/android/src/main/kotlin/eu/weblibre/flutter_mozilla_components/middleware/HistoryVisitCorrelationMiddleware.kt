/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.history.HistoryVisitCorrelationCache
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.selector.findNormalTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Records a short-lived `url -> contextId` correlation whenever a normal tab or
 * custom tab/PWA URL changes, so
 * [eu.weblibre.flutter_mozilla_components.history.WebLibreHistoryDelegate] can
 * resolve the tab's Gecko contextual identity (and hence its WebLibre container)
 * at visit time — the delegate itself only receives the visited URL.
 *
 * See [HistoryVisitCorrelationCache].
 */
class HistoryVisitCorrelationMiddleware :
    Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        // Record the correlation BEFORE forwarding the action. A tab's contextId
        // is stable across a URL change, so it is already readable here — and Gecko
        // can fire the delegate's onVisited for this navigation as soon as the store
        // updates. Recording first closes the window where onVisited could resolve
        // the visit before its correlation exists (and mis-attribute or leak it).
        if (action is ContentAction.UpdateUrlAction) {
            val normalTab = store.state.findNormalTab(action.sessionId)
            if (normalTab != null) {
                HistoryVisitCorrelationCache.record(action.url, normalTab.contextId)
            } else {
                store.state.findCustomTab(action.sessionId)?.let { customTab ->
                    HistoryVisitCorrelationCache.record(action.url, customTab.contextId)
                }
            }
        }

        next(action)
    }
}
