/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components

import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNotSame
import kotlin.test.assertSame
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Custom tabs moving from an outgoing component set's store to a new one, as
 * when the app half starts behind an open Custom Tab or PWA window.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class CustomTabHandoverTest {
    private val engine: Engine = mock(Engine::class.java)

    /** With the engine middleware, which is what links engine sessions. */
    private fun store() = BrowserStore(
        middleware = EngineMiddleware.create(
            engine,
            scope = CoroutineScope(Dispatchers.Unconfined),
            trimMemoryAutomatically = false,
        ),
    )

    private val session: EngineSession = mock(EngineSession::class.java)

    private val outgoing = store().apply {
        dispatch(CustomTabListAction.AddCustomTabAction(createCustomTab("https://a.example", id = "ct")))
        dispatch(EngineAction.LinkEngineSessionAction("ct", session, skipLoading = true))
    }

    private val current = store()

    private val outgoingObserver = assertNotNull(
        outgoing.state.findCustomTab("ct")?.engineState?.engineObserver,
    )

    @Test
    fun thePageReportsToTheNewStoreAndNoLongerToTheOldOne() {
        handOverCustomTabs(from = outgoing, to = current)

        val handedOver = assertNotNull(current.state.findCustomTab("ct"))
        assertSame(session, handedOver.engineState.engineSession)

        val observer = assertNotNull(handedOver.engineState.engineObserver)
        assertNotSame(outgoingObserver, observer)
        verify(session).unregister(outgoingObserver)
        verify(session).register(observer)
    }

    @Test
    fun theTabIsTakenAsItIsNowNotAsItWasWhenTheRebuildBegan() {
        // The page kept updating the outgoing store until the handover.
        outgoing.dispatch(ContentAction.UpdateUrlAction("ct", "https://a.example/next"))

        handOverCustomTabs(from = outgoing, to = current)

        assertEquals("https://a.example/next", current.state.findCustomTab("ct")?.content?.url)
    }

    @Test
    fun aTabTheNewStoreAlreadyHasIsLeftAlone() {
        current.dispatch(CustomTabListAction.AddCustomTabAction(createCustomTab("https://b.example", id = "ct")))

        handOverCustomTabs(from = outgoing, to = current)

        assertEquals("https://b.example", current.state.findCustomTab("ct")?.content?.url)
        verify(session, never()).unregister(outgoingObserver)
    }

    @Test
    fun aTabRemovedFromTheOutgoingStoreIsNotBroughtBack() {
        // Its window closed mid-handover.
        outgoing.dispatch(CustomTabListAction.RemoveCustomTabAction("ct"))

        handOverCustomTabs(from = outgoing, to = current)

        assertEquals(null, current.state.findCustomTab("ct"))
    }
}
