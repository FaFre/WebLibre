/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.session.middleware.undo.UndoMiddleware

private fun storeWith(vararg tabIds: String) = BrowserStore(
    initialState = BrowserState(
        tabs = tabIds.map { createTab(url = "https://$it.example", id = it) },
        selectedTabId = tabIds.firstOrNull(),
    ),
    middleware = listOf(
        // Unconfined so an undo restores in place instead of needing a main looper.
        UndoMiddleware(mainScope = CoroutineScope(Dispatchers.Unconfined)),
    ),
)

class RemovePreviousSessionTabsTest {
    @Test
    fun `removes the restored tabs and keeps the ones opened since`() {
        val store = storeWith("restored-1", "restored-2", "launch-link")

        store.removePreviousSessionTabs(setOf("restored-1", "restored-2"))

        assertEquals(listOf("launch-link"), store.state.tabs.map { it.id })
    }

    @Test
    fun `ignores restored tabs that are already gone`() {
        val store = storeWith("restored-1", "new")

        // A retry: restored-2 was removed by the first attempt.
        store.removePreviousSessionTabs(setOf("restored-1", "restored-2"))

        assertEquals(listOf("new"), store.state.tabs.map { it.id })
    }

    @Test
    fun `the removal cannot be undone`() {
        val store = storeWith("restored-1", "new")

        store.removePreviousSessionTabs(setOf("restored-1"))
        assertTrue(store.state.undoHistory.tabs.isEmpty())

        store.dispatch(UndoAction.RestoreRecoverableTabs)

        assertEquals(listOf("new"), store.state.tabs.map { it.id })
    }

    @Test
    fun `nothing restored means nothing removed and no undo entry touched`() {
        val store = storeWith("a", "b")

        store.removePreviousSessionTabs(emptySet())

        assertEquals(listOf("a", "b"), store.state.tabs.map { it.id })
    }
}
