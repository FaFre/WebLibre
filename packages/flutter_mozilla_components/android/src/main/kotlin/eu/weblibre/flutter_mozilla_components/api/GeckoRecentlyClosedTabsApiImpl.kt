/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.history.HistoryExclusions
import eu.weblibre.flutter_mozilla_components.middleware.clearRecentlyClosedTabs
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoRecentlyClosedTabsApi
import eu.weblibre.flutter_mozilla_components.pigeons.RecentlyClosedTab
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.RecentlyClosedAction
import mozilla.components.browser.state.state.recover.TabState

/**
 * The recently closed list, kept by
 * [mozilla.components.feature.recentlyclosed.RecentlyClosedMiddleware].
 *
 * Reads go to the storage rather than the store: the store loads the list in
 * the background after the engine starts. Removals also wait for the storage,
 * which the middleware only updates in a coroutine nobody can await, and go
 * through [eu.weblibre.flutter_mozilla_components.middleware.OrderedRecentlyClosedStorage]
 * so they are ordered with its saves.
 */
class GeckoRecentlyClosedTabsApiImpl : GeckoRecentlyClosedTabsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private val storage get() = components.core.recentlyClosedTabsStorage.value

    private suspend fun closedTabs(): List<TabState> = storage.getTabs().first()

    override suspend fun getRecentlyClosedTabs(): List<RecentlyClosedTab> =
        closedTabs().map { it.toRecentlyClosedTab() }

    override suspend fun restoreRecentlyClosedTab(
        id: String,
        contextId: String?,
        selectTab: Boolean,
        excludeFromHistory: Boolean,
    ): String? {
        val tab = closedTabs().find { it.id == id } ?: return null

        // Before the tab exists, as addTab does: it starts loading right away.
        if (excludeFromHistory) {
            HistoryExclusions.markProvisional(id)
        }

        // Reads the engine state, so it must run before the removal below
        // deletes it.
        components.useCases.tabsUseCases.restore(
            tab.copy(contextId = contextId),
            storage.engineStateStorage(),
            updateSelection = selectTab,
        )
        remove(tab)

        return id
    }

    override suspend fun removeRecentlyClosedTab(id: String) {
        closedTabs().find { it.id == id }?.let { remove(it) }
    }

    override suspend fun removeAllRecentlyClosedTabs() {
        components.core.store.clearRecentlyClosedTabs(
            components.core.recentlyClosedFilterMiddleware,
            components.core.orderedRecentlyClosedStorage,
        )
    }

    override fun keepOffRecentlyClosed(ids: List<String>) {
        components.core.recentlyClosedFilterMiddleware.discard(ids)
    }

    private suspend fun remove(tab: TabState) {
        components.core.store.dispatch(RecentlyClosedAction.RemoveClosedTabAction(tab))
        withContext(Dispatchers.IO) { components.core.orderedRecentlyClosedStorage.removeTab(tab) }
    }
}

internal fun TabState.toRecentlyClosedTab() = RecentlyClosedTab(
    id = id,
    url = url,
    title = title,
    lastAccess = lastAccess,
)
