/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.RecentlyClosedAction
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.recentlyclosed.RecentlyClosedMiddleware

/**
 * The recently closed [storage] with its writes run one after another, in the
 * order they were asked for.
 *
 * [RecentlyClosedMiddleware] saves a closed tab, with its back history, in a
 * coroutine nobody can await. A clear running beside a save could finish
 * first, and the save then put the tab back on the list the user cleared.
 *
 * The middleware runs its storage work in [scope], whose dispatcher starts one
 * coroutine at a time in the order they were dispatched. Each write takes a
 * fair mutex before it first suspends, so writes hold it in that same order.
 * [removeAllTabsAfterPendingSaves] joins the queue behind every save asked for
 * before it.
 */
class OrderedRecentlyClosedStorage(
    private val storage: Lazy<RecentlyClosedMiddleware.Storage>,
    private val dispatcher: CoroutineDispatcher = Dispatchers.IO.limitedParallelism(1),
) : RecentlyClosedMiddleware.Storage {
    private val writeLock = Mutex()

    /** For [RecentlyClosedMiddleware]'s `scope`. */
    val scope = CoroutineScope(SupervisorJob() + dispatcher)

    // Not a write, and the middleware keeps collecting it for good.
    override suspend fun getTabs(): Flow<List<TabState>> = storage.value.getTabs()

    override suspend fun addTabsToCollectionWithMax(tabs: List<RecoverableTab>, maxTabs: Int) {
        writeLock.withLock { storage.value.addTabsToCollectionWithMax(tabs, maxTabs) }
    }

    override suspend fun removeTab(recentlyClosedTab: TabState) {
        writeLock.withLock { storage.value.removeTab(recentlyClosedTab) }
    }

    override suspend fun removeAllTabs() {
        writeLock.withLock { storage.value.removeAllTabs() }
    }

    /** Removes every tab once the saves asked for before this call are done. */
    suspend fun removeAllTabsAfterPendingSaves() {
        withContext(dispatcher) { removeAllTabs() }
    }
}

/**
 * Empties the recently closed list for good: also of the tabs whose close can
 * still be undone, which would join it when their undo expires, and of saves
 * already under way.
 */
internal suspend fun BrowserStore.clearRecentlyClosedTabs(
    filter: RecentlyClosedFilterMiddleware,
    storage: OrderedRecentlyClosedStorage,
) {
    filter.discardPendingUndo(state)
    dispatch(RecentlyClosedAction.RemoveAllClosedTabAction)
    storage.removeAllTabsAfterPendingSaves()
}
