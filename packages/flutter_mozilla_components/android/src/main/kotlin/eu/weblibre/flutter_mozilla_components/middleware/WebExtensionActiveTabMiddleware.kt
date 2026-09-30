/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Forgets the web extension active tab once its engine session is unlinked, so
 * the session that replaces it is marked active again (issue #542).
 *
 * Android Components' `WebExtensionMiddleware` marks the outgoing session
 * inactive on unlink but leaves `activeWebExtensionTabId` pointing at the tab.
 * When the *same* tab is linked to a new session — the selected tab coming back
 * after its content process was killed in the background, a crash restore, or
 * clearing browsing data — it sees the id still matching the selection and
 * returns early, so the new session is never marked active.
 *
 * Gecko then keeps resolving `tabTracker.activeTab` to the window of the closed
 * session (`MobileWindowTracker` never drops `_topWindow` on close), and every
 * browser/page action click fails with `Invalid window ID` until another tab is
 * selected. No popup opens.
 *
 * Must be installed ahead of `EngineMiddleware.create`: the reset runs after
 * `next`, once `WebExtensionMiddleware` has already marked the old session
 * inactive against the id it expects.
 */
val WebExtensionActiveTabMiddleware: Middleware<BrowserState, BrowserAction> =
    { store, next, action ->
        next(action)

        if (action is EngineAction.UnlinkEngineSessionAction) {
            clearIfActive(store, action.tabId)
        }
    }

private fun clearIfActive(store: Store<BrowserState, BrowserAction>, tabId: String) {
    if (store.state.activeWebExtensionTabId == tabId) {
        store.dispatch(WebExtensionAction.UpdateActiveWebExtensionTabAction(null))
    }
}
