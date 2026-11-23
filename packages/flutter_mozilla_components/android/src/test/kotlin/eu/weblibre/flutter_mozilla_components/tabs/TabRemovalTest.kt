/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.tabs

import eu.weblibre.flutter_mozilla_components.middleware.TabCloseGuardMiddleware
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.session.middleware.undo.UndoMiddleware
import mozilla.components.feature.tabs.TabsUseCases

/**
 * The removal report Dart's close transaction reads, and the non-recoverable
 * removal the Quit cleanup uses, both with the guard in the store as in `Core`.
 */
class TabRemovalTest {
    private val locked = mutableSetOf<String>()

    private val store = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
                createTab("https://p.example", id = "p", private = true),
                createTab("https://w.example", id = "w", contextId = "ctx-work"),
            ),
            selectedTabId = "a",
        ),
        middleware = listOf(
            TabCloseGuardMiddleware(isLocked = { it in locked }),
            UndoMiddleware(mainScope = CoroutineScope(Dispatchers.Unconfined)),
        ),
    )
    private val tabsUseCases = TabsUseCases(store)

    @Test
    fun `the report separates removed, locked and missing tabs`() {
        locked += "b"
        val ids = listOf("a", "b", "gone")

        val result = store.reportRemoval(ids, isLocked = { it in locked }) {
            tabsUseCases.removeTabs(ids)
        }

        assertEquals(listOf("a"), result.removedTabIds)
        assertEquals(listOf("b"), result.lockedTabIds)
        assertEquals(listOf("gone"), result.missingTabIds)
    }

    @Test
    fun `a single locked tab is reported as kept`() {
        locked += "a"

        val result = store.reportRemoval(listOf("a"), isLocked = { it in locked }) {
            tabsUseCases.removeTab("a")
        }

        assertTrue(result.removedTabIds.isEmpty())
        assertEquals(listOf("a"), result.lockedTabIds)
    }

    @Test
    fun `quit cleanup removes every unlocked tab, private ones included, without undo`() {
        locked += "a"
        val discarded = mutableListOf<List<String>>()

        val removed = store.removeTabsNonRecoverably(
            store.state.tabs.map { it.id },
            beforeRemoval = { discarded += it },
            isLocked = { it in locked },
        )

        assertEquals(listOf("b", "p", "w"), removed)
        assertEquals(listOf("a"), store.state.tabs.map { it.id })
        assertEquals(listOf(listOf("b", "p", "w")), discarded)
        store.dispatch(UndoAction.RestoreRecoverableTabs)
        assertEquals(listOf("a"), store.state.tabs.map { it.id })
    }

    @Test
    fun `a non-recoverable removal with nothing removable touches no undo entry`() {
        store.dispatch(TabListAction.RemoveTabAction("b"))
        val tag = store.state.undoHistory.tag
        locked += "a"
        var discardCalled = false

        val removed = store.removeTabsNonRecoverably(
            listOf("a", "missing"),
            beforeRemoval = { discardCalled = true },
            isLocked = { it in locked },
        )

        assertTrue(removed.isEmpty())
        assertTrue(!discardCalled)
        assertEquals(tag, store.state.undoHistory.tag)
        assertEquals(listOf("b"), store.state.undoHistory.tabs.map { it.state.id })
    }

    @Test
    fun `an undo that would reopen a tab of a deleted container's context is dropped`() {
        tabsUseCases.removeTabs(listOf("b", "w"))

        val discarded = store.discardUndoOf(tabIds = emptySet(), contextIds = setOf("ctx-work"))

        assertTrue(discarded)
        assertTrue(store.state.undoHistory.tabs.isEmpty())
        store.dispatch(UndoAction.RestoreRecoverableTabs)
        assertEquals(listOf("a", "p"), store.state.tabs.map { it.id })
    }

    @Test
    fun `an undo that would reopen one of the named tabs is dropped`() {
        tabsUseCases.removeTab("b")

        assertTrue(store.discardUndoOf(tabIds = setOf("b"), contextIds = emptySet()))
        assertTrue(store.state.undoHistory.tabs.isEmpty())
    }

    @Test
    fun `an unrelated undo is kept`() {
        tabsUseCases.removeTab("b")
        val tag = store.state.undoHistory.tag

        assertFalse(store.discardUndoOf(tabIds = setOf("w"), contextIds = setOf("ctx-work")))
        assertEquals(tag, store.state.undoHistory.tag)
        assertEquals(listOf("b"), store.state.undoHistory.tabs.map { it.state.id })
    }
}
