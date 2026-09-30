/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.lib.state.Middleware
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyBoolean
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Runs against the real Android Components engine middleware, since the bug
 * being covered (issue #542) lives in its `WebExtensionMiddleware`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class WebExtensionActiveTabMiddlewareTest {
    private fun createStore(vararg extra: Middleware<BrowserState, BrowserAction>) =
        BrowserStore(
            initialState = BrowserState(
                tabs = listOf(
                    createTab("https://www.mozilla.org", id = SELECTED_TAB),
                    createTab("https://www.firefox.com", id = OTHER_TAB),
                ),
                selectedTabId = SELECTED_TAB,
            ),
            middleware = extra.toList() + EngineMiddleware.create(
                engine = mock(Engine::class.java),
                scope = CoroutineScope(Dispatchers.Unconfined),
                trimMemoryAutomatically = false,
            ),
        )

    @Test
    fun `marks the replacement session of the selected tab active`() {
        val store = createStore(WebExtensionActiveTabMiddleware)
        val killed = mock(EngineSession::class.java)
        val replacement = mock(EngineSession::class.java)

        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, killed, skipLoading = true))
        verify(killed).markActiveForWebExtensions(true)

        store.dispatch(EngineAction.UnlinkEngineSessionAction(SELECTED_TAB))
        verify(killed).markActiveForWebExtensions(false)
        assertNull(store.state.activeWebExtensionTabId)

        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, replacement, skipLoading = true))
        verify(replacement).markActiveForWebExtensions(true)
        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
    }

    @Test
    fun `without it the replacement session is never marked active`() {
        // Pins the upstream behaviour this middleware exists for; when this
        // starts failing, Android Components fixed it and the middleware can go.
        val store = createStore()
        val killed = mock(EngineSession::class.java)
        val replacement = mock(EngineSession::class.java)

        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, killed, skipLoading = true))
        store.dispatch(EngineAction.UnlinkEngineSessionAction(SELECTED_TAB))
        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, replacement, skipLoading = true))

        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
        verify(replacement, never()).markActiveForWebExtensions(anyBoolean())
    }

    @Test
    fun `leaves the active tab alone when another tab is unlinked`() {
        val store = createStore(WebExtensionActiveTabMiddleware)
        val selected = mock(EngineSession::class.java)
        val other = mock(EngineSession::class.java)

        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, selected, skipLoading = true))
        store.dispatch(EngineAction.LinkEngineSessionAction(OTHER_TAB, other, skipLoading = true))
        store.dispatch(EngineAction.UnlinkEngineSessionAction(OTHER_TAB))

        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
    }

    @Test
    fun `switching tabs after an unlink still activates the new selection`() {
        val store = createStore(WebExtensionActiveTabMiddleware)
        val selected = mock(EngineSession::class.java)
        val other = mock(EngineSession::class.java)

        store.dispatch(EngineAction.LinkEngineSessionAction(SELECTED_TAB, selected, skipLoading = true))
        store.dispatch(EngineAction.LinkEngineSessionAction(OTHER_TAB, other, skipLoading = true))
        store.dispatch(EngineAction.UnlinkEngineSessionAction(SELECTED_TAB))
        store.dispatch(TabListAction.SelectTabAction(OTHER_TAB))

        verify(other).markActiveForWebExtensions(true)
        assertEquals(OTHER_TAB, store.state.activeWebExtensionTabId)
    }

    private companion object {
        const val SELECTED_TAB = "selected"
        const val OTHER_TAB = "other"
    }
}
