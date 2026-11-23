/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.session.middleware.undo.UndoMiddleware

/**
 * A locked tab never leaves the store, whichever removal action asks for it,
 * and the rest of each removal still happens as it would have.
 */
class TabCloseGuardMiddlewareTest {
    private val locked = mutableSetOf<String>()
    private val discarded = mutableListOf<List<String>>()

    private fun store(selected: String = "a") = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
                createTab("https://c.example", id = "c"),
                createTab("https://p.example", id = "p", private = true),
            ),
            selectedTabId = selected,
        ),
        middleware = listOf(
            TabCloseGuardMiddleware(
                isLocked = { it in locked },
                beforeNonRecoverableRemoval = { discarded += it },
            ),
            // Unconfined so an undo restores in place instead of needing a main looper.
            UndoMiddleware(mainScope = CoroutineScope(Dispatchers.Unconfined)),
        ),
    )

    private val BrowserStore.tabIds get() = state.tabs.map { it.id }

    @Test
    fun `removing a locked tab does nothing`() {
        locked += "a"
        val store = store()

        store.dispatch(TabListAction.RemoveTabAction("a"))

        assertEquals(listOf("a", "b", "c", "p"), store.tabIds)
        assertTrue(store.state.undoHistory.tabs.isEmpty())
    }

    @Test
    fun `removing several keeps the locked ones and removes the rest undoably`() {
        locked += "b"
        val store = store()

        store.dispatch(TabListAction.RemoveTabsAction(listOf("a", "b")))

        assertEquals(listOf("b", "c", "p"), store.tabIds)
        assertEquals(listOf("a"), store.state.undoHistory.tabs.map { it.state.id })
    }

    @Test
    fun `a removal of locked tabs only leaves an unrelated undo entry alone`() {
        val store = store()
        store.dispatch(TabListAction.RemoveTabAction("c"))
        val tag = store.state.undoHistory.tag
        locked += setOf("a", "b")

        store.dispatch(TabListAction.RemoveTabsAction(listOf("a", "b")))

        assertEquals(listOf("a", "b", "p"), store.tabIds)
        assertEquals(tag, store.state.undoHistory.tag)
        assertEquals(listOf("c"), store.state.undoHistory.tabs.map { it.state.id })
    }

    @Test
    fun `removing all normal tabs keeps the locked one and the private one`() {
        locked += "b"
        val store = store()

        store.dispatch(TabListAction.RemoveAllNormalTabsAction)

        assertEquals(listOf("b", "p"), store.tabIds)
    }

    @Test
    fun `the selection moves to the locked normal tab, never to a private one`() {
        // Spike S6: the rewrite is a RemoveTabsAction, whose reducer picks a
        // fallback of the removed selection's own kind.
        locked += "c"
        val store = store(selected = "a")

        store.dispatch(TabListAction.RemoveAllNormalTabsAction)

        assertEquals("c", store.state.selectedTabId)
    }

    @Test
    fun `removing all normal tabs without a lock is unchanged`() {
        val store = store(selected = "p")

        store.dispatch(TabListAction.RemoveAllNormalTabsAction)

        assertEquals(listOf("p"), store.tabIds)
        assertEquals("p", store.state.selectedTabId)
    }

    @Test
    fun `removing all tabs undoably removes every unlocked tab, private ones included`() {
        locked += "a"
        val store = store()

        store.dispatch(TabListAction.RemoveAllTabsAction(recoverable = true))

        assertEquals(listOf("a"), store.tabIds)
        assertEquals(
            setOf("b", "c", "p"),
            store.state.undoHistory.tabs.map { it.state.id }.toSet(),
        )
    }

    @Test
    fun `a non-recoverable removal of all tabs stays non-recoverable`() {
        locked += "a"
        val store = store()

        store.dispatch(TabListAction.RemoveAllTabsAction(recoverable = false))

        assertEquals(listOf("a"), store.tabIds)
        assertTrue(store.state.undoHistory.tabs.isEmpty())
        assertEquals(listOf(listOf("b", "c", "p")), discarded)

        store.dispatch(UndoAction.RestoreRecoverableTabs)
        assertEquals(listOf("a"), store.tabIds)
    }

    @Test
    fun `a non-recoverable removal of only locked tabs touches nothing`() {
        val store = BrowserStore(
            initialState = BrowserState(
                tabs = listOf(createTab("https://a.example", id = "a")),
                selectedTabId = "a",
            ),
            middleware = listOf(
                TabCloseGuardMiddleware(
                    isLocked = { true },
                    beforeNonRecoverableRemoval = { discarded += it },
                ),
                UndoMiddleware(mainScope = CoroutineScope(Dispatchers.Unconfined)),
            ),
        )

        store.dispatch(TabListAction.RemoveAllTabsAction(recoverable = false))

        assertEquals(listOf("a"), store.tabIds)
        assertTrue(discarded.isEmpty())
    }

    @Test
    fun `without a lock every removal passes unchanged`() {
        val store = store()

        store.dispatch(TabListAction.RemoveAllTabsAction(recoverable = false))

        assertTrue(store.tabIds.isEmpty())
        assertTrue(discarded.isEmpty())
    }
}
