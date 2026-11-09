/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.engine.middleware.SessionPrioritizationMiddleware
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.SessionPriority
import org.junit.Test
import org.mockito.Mockito

class PresentedPanePriorityMiddlewareTest {
    private val sessionA = Mockito.mock(EngineSession::class.java)
    private val sessionC = Mockito.mock(EngineSession::class.java)

    /** 'a' is on screen beside the selected 'b'; 'c' is not shown. */
    private fun store() = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a", engineSession = sessionA),
                createTab("https://b.example", id = "b"),
                createTab("https://c.example", id = "c", engineSession = sessionC),
            ),
            selectedTabId = "b",
        ),
        middleware = listOf(
            PresentedPanePriorityMiddleware(presentedTabIds = { setOf("a", "b") }),
            SessionPrioritizationMiddleware(
                mainScope = CoroutineScope(Dispatchers.Unconfined),
                waitScope = CoroutineScope(Dispatchers.Unconfined),
            ),
        ),
    )

    @Test
    fun acLoweringAPageOnScreenIsUndone() {
        val store = store()

        store.dispatch(
            ContentAction.UpdateHasFormDataAction("a", containsFormData = false, adjustPriority = true),
        )

        val order = Mockito.inOrder(sessionA)
        order.verify(sessionA).updateSessionPriority(SessionPriority.DEFAULT)
        order.verify(sessionA).updateSessionPriority(SessionPriority.HIGH)
    }

    @Test
    fun theTimeoutBackToDefaultIsUndoneForAPageOnScreen() {
        val store = store()

        // AC consumes this action; only a middleware ahead of it sees it.
        store.dispatch(ContentAction.UpdatePriorityToDefaultAfterTimeoutAction("a"))

        val order = Mockito.inOrder(sessionA)
        order.verify(sessionA).updateSessionPriority(SessionPriority.DEFAULT)
        order.verify(sessionA).updateSessionPriority(SessionPriority.HIGH)
    }

    @Test
    fun aPageNotOnScreenIsLeftLowered() {
        val store = store()

        store.dispatch(
            ContentAction.UpdateHasFormDataAction("c", containsFormData = false, adjustPriority = true),
        )
        store.dispatch(ContentAction.UpdatePriorityToDefaultAfterTimeoutAction("c"))

        Mockito.verify(sessionC, Mockito.times(2)).updateSessionPriority(SessionPriority.DEFAULT)
        Mockito.verify(sessionC, Mockito.never()).updateSessionPriority(SessionPriority.HIGH)
    }
}
