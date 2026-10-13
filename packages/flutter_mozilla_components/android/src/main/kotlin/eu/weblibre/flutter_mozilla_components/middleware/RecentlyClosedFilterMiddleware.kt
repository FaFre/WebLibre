/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import java.util.concurrent.ConcurrentHashMap
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.RecentlyClosedAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.recentlyclosed.RecentlyClosedMiddleware
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * The prefix of an isolated tab's contextId. Mirrors `_isolatedPrefix` in the
 * app's `isolation_context.dart`.
 */
private const val ISOLATED_CONTEXT_ID_PREFIX = "iso1_"

internal fun isIsolatedContextId(contextId: String?): Boolean =
    contextId?.startsWith(ISOLATED_CONTEXT_ID_PREFIX) == true

/**
 * Keeps out of the recently closed list what WebLibre must not bring back.
 * [RecentlyClosedMiddleware] already leaves out private tabs. This also drops:
 *
 * - isolated tabs. Closing the last tab of an isolation context deletes the
 *   context's data, so a restored one would come back in an empty jar.
 * - tabs of a container excluded from history. The list is history.
 * - tabs WebLibre removed itself, named in [discard] before the removal: the
 *   previous session's tabs deleted at startup, tabs recreated in another
 *   container, the tabs of a deleted container. Also tabs whose undo is still
 *   pending when the history is deleted, which would land on the cleared list.
 *
 * The history exclusion is read when the tab is removed. The list only gets
 * the tab once its undo has expired, and by then the snapshot no longer has it.
 *
 * Must run before [RecentlyClosedMiddleware]: it filters the
 * [RecentlyClosedAction.AddClosedTabsAction] that one dispatches.
 */
class RecentlyClosedFilterMiddleware(
    private val isExcludedFromHistory: (tabId: String, contextId: String?) -> Boolean =
        HistoryExclusions::isExcluded,
) : Middleware<BrowserState, BrowserAction> {
    private val keptOutTabIds: MutableSet<String> = ConcurrentHashMap.newKeySet()

    /**
     * Keeps [tabIds] out of the list when they are removed next, or when their
     * pending undo expires.
     */
    fun discard(tabIds: Collection<String>) {
        keptOutTabIds.addAll(tabIds)
    }

    /**
     * Keeps out the tabs whose close can still be undone. They join the list
     * when the undo expires, which after clearing it would be too late.
     */
    fun discardPendingUndo(state: BrowserState) {
        discard(state.undoHistory.tabs.map { it.state.id })
    }

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is TabListAction.RemoveTabAction ->
                keepOutExcluded(store.state, listOf(action.tabId))
            is TabListAction.RemoveTabsAction ->
                keepOutExcluded(store.state, action.tabIds)
            is TabListAction.RemoveAllNormalTabsAction ->
                keepOutExcluded(store.state, store.state.tabs.map { it.id })
            // A removal that can't be undone never reaches the list.
            is TabListAction.RemoveAllTabsAction -> if (action.recoverable) {
                keepOutExcluded(store.state, store.state.tabs.map { it.id })
            }
            // Undone: decided afresh if the tab is closed again.
            is TabListAction.RestoreAction ->
                keptOutTabIds.removeAll(action.tabs.map { it.state.id }.toSet())
            is RecentlyClosedAction.AddClosedTabsAction -> {
                val kept = action.tabs.filter {
                    it.state.id !in keptOutTabIds && !isIsolatedContextId(it.state.contextId)
                }
                keptOutTabIds.removeAll(action.tabs.map { it.state.id }.toSet())

                if (kept.isNotEmpty()) {
                    next(RecentlyClosedAction.AddClosedTabsAction(kept))
                }
                return
            }
            else -> Unit
        }

        next(action)
    }

    private fun keepOutExcluded(state: BrowserState, tabIds: List<String>) {
        for (tabId in tabIds) {
            val tab = state.findTab(tabId) ?: continue
            if (isExcludedFromHistory(tab.id, tab.contextId)) {
                keptOutTabIds.add(tab.id)
            }
        }
    }
}
