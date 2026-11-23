/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.window.WindowRequest
import mozilla.components.feature.tabs.TabsUseCases
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify

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

    @Test
    fun windowCloseLeavesALockedTabOpenAndConsumesTheRequest() {
        val (lockStore, session) = storeWithSession("locked")
        val closingFeature = SplitAwareWindowFeature(
            lockStore,
            TabsUseCases(lockStore),
            visibleTabIds = { emptySet() },
            mainDispatcher = Dispatchers.Unconfined,
            isLocked = { it == "locked" },
        )
        closingFeature.start()

        lockStore.dispatch(ContentAction.UpdateWindowRequestAction("locked", closeRequest(session)))

        assertNotNull(lockStore.state.findTab("locked"))
        assertNull(lockStore.state.findTab("locked")?.content?.windowRequest)
        closingFeature.stop()
    }

    @Test
    fun windowCloseStillClosesAnUnlockedTab() {
        val (closeStore, session) = storeWithSession("unlocked")
        val closingFeature = SplitAwareWindowFeature(
            closeStore,
            TabsUseCases(closeStore),
            visibleTabIds = { emptySet() },
            mainDispatcher = Dispatchers.Unconfined,
            isLocked = { false },
        )
        closingFeature.start()

        closeStore.dispatch(ContentAction.UpdateWindowRequestAction("unlocked", closeRequest(session)))

        assertNull(closeStore.state.findTab("unlocked"))
        closingFeature.stop()
    }

    @Test
    fun aWindowRequestConsumedAfterItsContainerFrozeOpensNothing() {
        val (frozenStore, _) = storeWithSession("opener")
        val popup = mock(EngineSession::class.java)
        val openingFeature = SplitAwareWindowFeature(
            frozenStore,
            TabsUseCases(frozenStore),
            visibleTabIds = { emptySet() },
            mainDispatcher = Dispatchers.Unconfined,
            isRestricted = { true },
        )
        openingFeature.start()

        frozenStore.dispatch(ContentAction.UpdateWindowRequestAction("opener", openRequest(popup)))

        // B4w: no tab, the prepared session closed, the request consumed.
        assertEquals(2, frozenStore.state.tabs.size)
        verify(popup).close()
        assertNull(frozenStore.state.findTab("opener")?.content?.windowRequest)
        openingFeature.stop()
    }

    @Test
    fun aWindowRequestOfAnUnrestrictedContextStillOpensATab() {
        val (openStore, _) = storeWithSession("opener")
        val popup = mock(EngineSession::class.java)
        val openingFeature = SplitAwareWindowFeature(
            openStore,
            TabsUseCases(openStore),
            visibleTabIds = { emptySet() },
            mainDispatcher = Dispatchers.Unconfined,
            isRestricted = { false },
        )
        openingFeature.start()

        openStore.dispatch(ContentAction.UpdateWindowRequestAction("opener", openRequest(popup)))

        assertEquals(3, openStore.state.tabs.size)
        openingFeature.stop()
    }

    private fun openRequest(session: EngineSession) = object : WindowRequest {
        override val type = WindowRequest.Type.OPEN
        override val url = "https://popup.example"
        override fun prepare() = session
    }

    private fun storeWithSession(tabId: String): Pair<BrowserStore, EngineSession> {
        val session = mock(EngineSession::class.java)
        val store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://$tabId.example", id = tabId),
                    createTab("https://other.example", id = "other"),
                ),
                selectedTabId = tabId,
            ),
        )
        store.dispatch(EngineAction.LinkEngineSessionAction(tabId, session, skipLoading = true))
        return store to session
    }

    private fun closeRequest(session: EngineSession) = object : WindowRequest {
        override val type = WindowRequest.Type.CLOSE
        override val url = ""
        override fun prepare() = session
    }
}
