/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.HistoryMetadataAction
import mozilla.components.browser.state.action.MediaSessionAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findNormalTab
import mozilla.components.browser.state.selector.selectedNormalTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Records history metadata observations as the user browses.
 *
 * - On page load: records a [DocumentTypeObservation] so the page exists in metadata storage.
 * - On tab switch / removal / URL change: records a [ViewTimeObservation] for the outgoing page.
 *
 * This is a simplified version of Fenix's HistoryMetadataMiddleware without search-group tracking.
 */
class HistoryMetadataMiddleware(
    private val historyMetadataService: HistoryMetadataService,
) : Middleware<BrowserState, BrowserAction> {

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        // Pre-process: update view time for the currently selected tab before state changes.
        when (action) {
            is TabListAction.AddTabAction -> {
                if (action.select) {
                    store.state.selectedNormalTab?.let { updateHistoryMetadata(it) }
                }
            }
            is TabListAction.SelectTabAction -> {
                store.state.selectedNormalTab?.let { updateHistoryMetadata(it) }
            }
            is TabListAction.RemoveTabAction -> {
                if (action.tabId == store.state.selectedTabId) {
                    store.state.findNormalTab(action.tabId)?.let { updateHistoryMetadata(it) }
                }
            }
            is TabListAction.RemoveTabsAction -> {
                action.tabIds.find { it == store.state.selectedTabId }?.let {
                    store.state.findNormalTab(it)?.let { tab -> updateHistoryMetadata(tab) }
                }
            }
            is ContentAction.UpdateUrlAction -> {
                store.state.findNormalTab(action.sessionId)?.let { tab ->
                    if (tab.id == store.state.selectedTabId && action.url != tab.content.url) {
                        updateHistoryMetadata(tab)
                    }
                }
            }
            else -> { /* no-op */ }
        }

        next(action)

        // Post-process: create metadata for newly loaded pages (state is now up-to-date).
        when (action) {
            is TabListAction.AddTabAction -> {
                if (!action.tab.content.private) {
                    createHistoryMetadataIfNeeded(store, action.tab)
                }
            }
            is ContentAction.UpdateHistoryStateAction -> {
                store.state.findNormalTab(action.sessionId)?.let { tab ->
                    createHistoryMetadataIfNeeded(store, tab)
                }
            }
            is MediaSessionAction.UpdateMediaMetadataAction -> {
                store.state.findNormalTab(action.tabId)?.let { tab ->
                    createHistoryMetadata(store, tab)
                }
            }
            else -> { /* no-op */ }
        }
    }

    private fun createHistoryMetadataIfNeeded(
        store: Store<BrowserState, BrowserAction>,
        tab: TabSessionState,
    ) {
        val knownMetadata = tab.historyMetadata
        if (knownMetadata == null || knownMetadata.url != tab.content.url) {
            createHistoryMetadata(store, tab)
        }
    }

    private fun createHistoryMetadata(
        store: Store<BrowserState, BrowserAction>,
        tab: TabSessionState,
    ) {
        val key = historyMetadataService.createMetadata(tab)
        store.dispatch(HistoryMetadataAction.SetHistoryMetadataKeyAction(tab.id, key))
    }

    private fun updateHistoryMetadata(tab: TabSessionState) {
        tab.historyMetadata?.let {
            historyMetadataService.updateMetadata(it, tab)
        }
    }
}
