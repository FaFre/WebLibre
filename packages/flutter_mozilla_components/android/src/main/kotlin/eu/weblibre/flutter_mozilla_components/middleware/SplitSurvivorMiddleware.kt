/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState
import eu.weblibre.flutter_mozilla_components.split.SplitStateMirror
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * When the selected tab of a split pair is removed, selects its partner.
 *
 * Dart's own close path already selects the partner before it removes the
 * tab, so this does nothing there. It covers removals Dart did not start:
 * `window.close()`, an extension closing a tab, AC-internal removals. Without
 * it the reducer would pick an unrelated neighbour and the pair would vanish
 * from the screen although its other page is still open.
 */
class SplitSurvivorMiddleware(
    private val pair: () -> SplitPairState? = { SplitStateMirror.state.value?.pair },
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        val removed: Set<String> = when (action) {
            is TabListAction.RemoveTabAction -> setOf(action.tabId)
            is TabListAction.RemoveTabsAction -> action.tabIds.toSet()
            else -> emptySet()
        }
        if (removed.isEmpty()) {
            next(action)
            return
        }

        val selectedBefore = store.state.selectedTabId
        val split = pair()
        next(action)

        if (selectedBefore == null || selectedBefore !in removed || split == null) return
        val partner = when (selectedBefore) {
            split.firstTabId -> split.secondTabId
            split.secondTabId -> split.firstTabId
            else -> return
        }
        if (partner in removed) return
        if (store.state.findTab(partner) == null) return
        if (store.state.selectedTabId == partner) return

        store.dispatch(TabListAction.SelectTabAction(partner))
    }
}
