/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.tabs.TabCloseProtection
import eu.weblibre.flutter_mozilla_components.tabs.removeTabsNonRecoverably
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Never lets a locked tab ([TabCloseProtection]) be removed from the store.
 *
 * Must be first in the store's middleware: everything after it, the undo and
 * recently-closed middleware and WebLibre's own removal reactions included, has
 * to see the removal as it actually happens. A removal is dropped or rewritten
 * to leave the locked tabs out:
 *
 * - [TabListAction.RemoveTabAction] of a locked tab: dropped.
 * - [TabListAction.RemoveTabsAction]: forwarded without the locked ids, or
 *   dropped when none is left.
 * - [TabListAction.RemoveAllNormalTabsAction] while a normal tab is locked: the
 *   unlocked normal tabs, as a [TabListAction.RemoveTabsAction].
 * - [TabListAction.RemoveAllTabsAction] while any tab is locked: every unlocked
 *   tab, private ones included. A non-recoverable one stays non-recoverable,
 *   through [removeTabsNonRecoverably] with [beforeNonRecoverableRemoval].
 *
 * Private and custom tabs are never locked, so their actions pass unchanged, and
 * so do undo, restore and the engine-session actions: a locked tab can still be
 * unloaded.
 *
 * Removal is what it guards, not closing in general: a page's `window.close()`
 * and an add-on's `tabs.remove` both end in one of these actions.
 */
class TabCloseGuardMiddleware(
    private val isLocked: (String) -> Boolean = TabCloseProtection::isLocked,
    private val beforeNonRecoverableRemoval: (List<String>) -> Unit = {},
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is TabListAction.RemoveTabAction ->
                if (isLocked(action.tabId)) return

            is TabListAction.RemoveTabsAction -> {
                val unlocked = action.tabIds.filterNot(isLocked)
                if (unlocked.size != action.tabIds.size) {
                    if (unlocked.isNotEmpty()) next(action.copy(tabIds = unlocked))
                    return
                }
            }

            is TabListAction.RemoveAllNormalTabsAction -> {
                val normalTabIds = store.state.tabs.filterNot { it.content.private }.map { it.id }
                val unlocked = normalTabIds.filterNot(isLocked)
                if (unlocked.size != normalTabIds.size) {
                    if (unlocked.isNotEmpty()) next(TabListAction.RemoveTabsAction(unlocked))
                    return
                }
            }

            is TabListAction.RemoveAllTabsAction -> {
                val tabIds = store.state.tabs.map { it.id }
                val unlocked = tabIds.filterNot(isLocked)
                if (unlocked.size != tabIds.size) {
                    when {
                        unlocked.isEmpty() -> Unit
                        action.recoverable -> next(TabListAction.RemoveTabsAction(unlocked))
                        // Through the store, so the removal is seen by every
                        // middleware like any other; it holds no locked id.
                        else -> store.removeTabsNonRecoverably(
                            unlocked,
                            beforeRemoval = beforeNonRecoverableRemoval,
                            isLocked = isLocked,
                        )
                    }
                    return
                }
            }

            else -> Unit
        }

        next(action)
    }
}
