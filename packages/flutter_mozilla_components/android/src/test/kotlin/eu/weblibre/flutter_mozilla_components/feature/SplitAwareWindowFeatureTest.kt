/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.tabs.TabsUseCases

class SplitAwareWindowFeatureTest {
    private val store = BrowserStore(
        BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
                createTab("https://c.example", id = "c"),
            ),
            selectedTabId = "a",
        ),
    )

    private val feature = SplitAwareWindowFeature(
        store,
        TabsUseCases(store),
        visibleTabIds = { setOf("a", "b") },
    )

    @Test
    fun aPopupFromTheFocusedPageIsSelected() {
        assertTrue(feature.shouldSelectPopupOf("a"))
    }

    @Test
    fun aPopupFromTheUnfocusedPaneOpensInTheBackground() {
        assertFalse(feature.shouldSelectPopupOf("b"))
    }

    @Test
    fun aPopupFromABackgroundTabBehavesAsBefore() {
        assertTrue(feature.shouldSelectPopupOf("c"))
    }
}
