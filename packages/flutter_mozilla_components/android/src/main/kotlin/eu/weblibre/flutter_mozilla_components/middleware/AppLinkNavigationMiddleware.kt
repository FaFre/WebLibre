/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStore
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Observes the [BrowserStore] and drives [PendingAppLinkStore] invalidation and
 * suppression clearing (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.6):
 *
 * - a committed top-level navigation whose URL is not a request's own target
 *   invalidates that request (a banner-class request's target committing keeps it
 *   alive — that commit is the page the banner sits on);
 * - tab close / Custom Tab removal invalidates the tab's pending requests and
 *   suppression;
 * - a new user-initiated/direct navigation (omnibar, bookmark, typed URL — which
 *   dispatch a `LoadUrlAction`) clears the tab's suppression. In-page redirects
 *   do not dispatch these actions, so the redirect-loop defence stays intact.
 */
class AppLinkNavigationMiddleware(
    private val store: PendingAppLinkStore,
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdateUrlAction -> {
                // A committed top-level navigation.
                this.store.onCommittedNavigation(action.sessionId, action.url)
            }

            is EngineAction.LoadUrlAction -> {
                // App-initiated (direct) navigation — clears suppression.
                this.store.clearSuppressionForTab(action.tabId)
            }

            is EngineAction.OptimizedLoadUrlTriggeredAction -> {
                this.store.clearSuppressionForTab(action.tabId)
            }

            is TabListAction.RemoveTabAction -> {
                this.store.invalidateTab(action.tabId)
            }

            is TabListAction.RemoveTabsAction -> {
                action.tabIds.forEach(this.store::invalidateTab)
            }

            is CustomTabListAction.RemoveCustomTabAction -> {
                this.store.invalidateTab(action.tabId)
            }

            else -> {}
        }

        next(action)
    }
}
