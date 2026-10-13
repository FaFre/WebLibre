/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.api.removePreviousSessionTabs
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.recentlyclosed.RecentlyClosedMiddleware
import mozilla.components.feature.session.middleware.undo.UndoMiddleware

/** The list as [RecentlyClosedMiddleware] saves it, in memory. */
private class FakeStorage : RecentlyClosedMiddleware.Storage {
    val tabs = MutableStateFlow<List<TabState>>(emptyList())

    /** When set, saves wait for it: a save still writing its engine state. */
    var saveGate: CompletableDeferred<Unit>? = null

    override suspend fun getTabs(): Flow<List<TabState>> = tabs

    override suspend fun removeTab(recentlyClosedTab: TabState) {
        tabs.value = tabs.value.filter { it.id != recentlyClosedTab.id }
    }

    override suspend fun removeAllTabs() {
        tabs.value = emptyList()
    }

    override suspend fun addTabsToCollectionWithMax(tabs: List<RecoverableTab>, maxTabs: Int) {
        saveGate?.await()
        this.tabs.value = (tabs.map { it.state } + this.tabs.value).take(maxTabs)
    }
}

class RecentlyClosedFilterMiddlewareTest {
    private val storage = FakeStorage()
    private var excludedTabIds = emptySet<String>()
    private val filter = RecentlyClosedFilterMiddleware(
        isExcludedFromHistory = { tabId, _ -> tabId in excludedTabIds },
    )

    private fun store(vararg tabs: TabSessionState) =
        BrowserStore(
            initialState = BrowserState(tabs = tabs.toList(), selectedTabId = tabs.first().id),
            middleware = listOf(
                filter,
                RecentlyClosedMiddleware(
                    lazy { storage },
                    maxSavedTabs = 10,
                    scope = CoroutineScope(Dispatchers.Unconfined),
                ),
                // Unconfined so an undo restores in place; the undo never
                // expires on its own here, the tests expire it.
                UndoMiddleware(
                    clearAfterMillis = Long.MAX_VALUE,
                    mainScope = CoroutineScope(Dispatchers.Unconfined),
                ),
            ),
        )

    private fun BrowserStore.expireUndo() {
        dispatch(UndoAction.ClearRecoverableTabs(state.undoHistory.tag))
    }

    private val saved get() = storage.tabs.value.map { it.id }

    @Test
    fun `a closed tab is saved once its undo expires`() {
        val store = store(createTab("https://a.example", id = "a"), createTab("https://b.example", id = "b"))

        store.dispatch(TabListAction.RemoveTabAction("a"))
        assertEquals(emptyList(), saved)

        store.expireUndo()
        assertEquals(listOf("a"), saved)
    }

    @Test
    fun `isolated and private tabs are never saved`() {
        val store = store(
            createTab("https://iso.example", id = "iso", contextId = "iso1_1234"),
            createTab("https://private.example", id = "private", private = true),
            createTab("https://container.example", id = "container", contextId = "container-1"),
            createTab("https://keep.example", id = "keep"),
        )

        store.dispatch(TabListAction.RemoveTabsAction(listOf("iso", "private", "container")))
        store.expireUndo()

        assertEquals(listOf("container"), saved)
    }

    @Test
    fun `a tab excluded from history when closed stays off the list`() {
        val store = store(createTab("https://a.example", id = "a"), createTab("https://b.example", id = "b"))
        excludedTabIds = setOf("a")

        store.dispatch(TabListAction.RemoveTabAction("a"))
        // Dart's next snapshot no longer lists the closed tab.
        excludedTabIds = emptySet()
        store.expireUndo()

        assertEquals(emptyList(), saved)
    }

    @Test
    fun `an undone tab is judged again when it is closed again`() {
        val store = store(createTab("https://a.example", id = "a"), createTab("https://b.example", id = "b"))
        excludedTabIds = setOf("a")

        store.dispatch(TabListAction.RemoveTabAction("a"))
        store.dispatch(UndoAction.RestoreRecoverableTabs)
        // The container stopped being excluded since.
        excludedTabIds = emptySet()
        store.dispatch(TabListAction.RemoveTabAction("a"))
        store.expireUndo()

        assertEquals(listOf("a"), saved)
    }

    @Test
    fun `the previous session's tabs deleted at startup are not saved`() {
        val store = store(createTab("https://old.example", id = "old"), createTab("https://new.example", id = "new"))

        store.removePreviousSessionTabs(setOf("old"), beforeRemoval = filter::discard)

        assertEquals(listOf("new"), store.state.tabs.map { it.id })
        assertEquals(emptyList(), saved)
    }

    @Test
    fun `a tab WebLibre closes itself is not saved, also when a later close supersedes its undo`() {
        val store = store(
            createTab("https://moved.example", id = "moved"),
            createTab("https://closed.example", id = "closed"),
            createTab("https://keep.example", id = "keep"),
        )

        filter.discard(listOf("moved"))
        store.dispatch(TabListAction.RemoveTabAction("moved"))
        // Files "moved" under recently closed right away.
        store.dispatch(TabListAction.RemoveTabAction("closed"))
        store.expireUndo()

        assertEquals(listOf("closed"), saved)
    }

    @Test
    fun `a close whose undo is pending can still be kept off the list`() {
        val store = store(createTab("https://a.example", id = "a"), createTab("https://b.example", id = "b"))

        store.dispatch(TabListAction.RemoveTabAction("a"))
        // As clearing the list and deleting the history do.
        filter.discardPendingUndo(store.state)
        store.expireUndo()

        assertEquals(emptyList(), saved)
    }

    @Test
    fun `tabs closed without undo are not saved`() {
        val store = store(createTab("https://a.example", id = "a"))

        store.dispatch(TabListAction.RemoveAllTabsAction(recoverable = false))

        assertEquals(emptyList(), saved)
    }

    @Test
    fun `clearing the list waits for a save already under way`() = runBlocking {
        val ordered = OrderedRecentlyClosedStorage(lazyOf(storage))
        val store = BrowserStore(
            initialState = BrowserState(
                tabs = listOf(createTab("https://a.example", id = "a"), createTab("https://b.example", id = "b")),
                selectedTabId = "b",
            ),
            middleware = listOf(
                filter,
                RecentlyClosedMiddleware(lazyOf(ordered), maxSavedTabs = 10, scope = ordered.scope),
                UndoMiddleware(
                    clearAfterMillis = Long.MAX_VALUE,
                    mainScope = CoroutineScope(Dispatchers.Unconfined),
                ),
            ),
        )
        val gate = CompletableDeferred<Unit>()
        storage.saveGate = gate

        store.dispatch(TabListAction.RemoveTabAction("a"))
        // The save starts and holds at the gate.
        store.expireUndo()

        val clearing = async { store.clearRecentlyClosedTabs(filter, ordered) }
        assertNull(withTimeoutOrNull(200) { clearing.await() })

        gate.complete(Unit)
        clearing.await()

        assertEquals(emptyList(), saved)
        ordered.scope.cancel()
    }
}
