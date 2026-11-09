/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.EngineSession.SessionPriority
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Keeps a page that is on screen at HIGH priority when AC's
 * `SessionPrioritizationMiddleware` lowers it.
 *
 * AC lowers the tab selected before the current one, at once or three minutes
 * later if it holds form data, assuming it went off screen. In split view it
 * may still be on screen beside the selected tab, and at DEFAULT its content
 * process falls to a background binding where it stops loading. The split
 * coordinator raises such pages when they come on screen; this undoes AC
 * lowering them afterwards.
 *
 * Must come before `SessionPrioritizationMiddleware`: AC consumes its timeout
 * action without passing it on, so only a middleware ahead of it sees the
 * action, and only after `next` has AC's DEFAULT already been applied.
 */
class PresentedPanePriorityMiddleware(
    private val presentedTabIds: () -> Set<String> = {
        GlobalComponents.components?.browserPanes?.lastPresentedTabIds.orEmpty()
    },
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        next(action)

        val tabId = when (action) {
            is ContentAction.UpdateHasFormDataAction ->
                action.tabId.takeIf { action.adjustPriority }
            is ContentAction.UpdatePriorityToDefaultAfterTimeoutAction -> action.tabId
            else -> null
        } ?: return

        if (tabId !in presentedTabIds()) return
        store.state.findTab(tabId)?.engineState?.engineSession
            ?.updateSessionPriority(SessionPriority.HIGH)
    }
}
