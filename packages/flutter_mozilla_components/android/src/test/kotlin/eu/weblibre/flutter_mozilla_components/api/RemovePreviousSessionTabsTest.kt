/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
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
    fun `only the listed restored tabs go when a list is given`() {
        // An earlier Quit's deletion names its tabs; "kept" was restored too but
        // is not one of them, and "new" was opened since.
        val store = storeWith("quit-1", "kept", "new")

        store.removePreviousSessionTabs(
            setOf("quit-1", "kept"),
            onlyTabIds = setOf("quit-1", "new"),
        )

        assertEquals(listOf("kept", "new"), store.state.tabs.map { it.id })
    }

    @Test
    fun `nothing restored means nothing removed and no undo entry touched`() {
        val store = storeWith("a", "b")

        store.removePreviousSessionTabs(emptySet())

        assertEquals(listOf("a", "b"), store.state.tabs.map { it.id })
    }
}

class RestorableTabIdsTest {
    private fun saved(vararg tabIds: String) = RecoverableBrowserState(
        tabs = tabIds.map {
            RecoverableTab(engineSessionState = null, state = TabState(id = it, url = "https://$it.example"))
        },
        selectedTabId = null,
    )

    @Test
    fun `includes a tab closed since the session was last saved`() {
        // Autosave is debounced: "closed" is gone from the store but still on disk,
        // and a restore would bring it back.
        val state = BrowserState(tabs = listOf(createTab(url = "https://open.example", id = "open")))

        assertEquals(listOf("open", "closed"), state.restorableTabIds(saved("open", "closed")))
    }

    @Test
    fun `leaves out private tabs, which are never saved`() {
        val state = BrowserState(
            tabs = listOf(
                createTab(url = "https://open.example", id = "open"),
                createTab(url = "https://private.example", id = "private", private = true),
            ),
        )

        assertEquals(listOf("open"), state.restorableTabIds(saved = null))
    }
}
