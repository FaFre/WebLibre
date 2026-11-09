/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPaneMode
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore

class SplitSurvivorMiddlewareTest {
    private val pair = SplitPairState(
        pairId = "p",
        firstTabId = "a",
        secondTabId = "c",
        mode = SplitPaneMode.SIDE_BY_SIDE,
        ratio = 0.5,
        dividerDp = 8.0,
        draggable = true,
        firstAccentArgb = 0,
        secondAccentArgb = 0,
    )

    private fun store(selected: String, split: SplitPairState? = pair) = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
                createTab("https://c.example", id = "c"),
                createTab("https://d.example", id = "d"),
            ),
            selectedTabId = selected,
        ),
        middleware = listOf(SplitSurvivorMiddleware { split }),
    )

    @Test
    fun removingTheSelectedMemberSelectsItsPartner() {
        val store = store(selected = "a")
        store.dispatch(TabListAction.RemoveTabAction("a"))
        assertEquals("c", store.state.selectedTabId)
    }

    @Test
    fun removingBothMembersLeavesTheReducersChoice() {
        val store = store(selected = "a")
        store.dispatch(TabListAction.RemoveTabsAction(listOf("a", "c")))
        assertNotEquals("c", store.state.selectedTabId)
        assertNotEquals("a", store.state.selectedTabId)
    }

    @Test
    fun removingTheUnselectedMemberChangesNothing() {
        val store = store(selected = "a")
        store.dispatch(TabListAction.RemoveTabAction("c"))
        assertEquals("a", store.state.selectedTabId)
    }

    @Test
    fun withoutAPairTheReducerDecides() {
        val store = store(selected = "a", split = null)
        store.dispatch(TabListAction.RemoveTabAction("a"))
        // AC picks the neighbour.
        assertEquals("b", store.state.selectedTabId)
    }
}
