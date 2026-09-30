/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.yield
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.engine.EngineMiddleware
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyBoolean
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Issue #542: a browser/page action clicked before any tab was painted, or
 * with no tab selected at all, must first get a tab Gecko can resolve it
 * against.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class WebExtensionActionTargetTest {
    private val tabSession = mock(EngineSession::class.java)
    private val engine = mock(Engine::class.java).also {
        `when`(it.createSession(anyBoolean(), any())).thenReturn(tabSession)
    }
    private val blankSessions = mutableListOf<EngineSession>()

    private fun createStore(selectedTabId: String? = SELECTED_TAB) = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(createTab("https://www.mozilla.org", id = SELECTED_TAB)),
            selectedTabId = selectedTabId,
        ),
        middleware = EngineMiddleware.create(
            engine = engine,
            scope = CoroutineScope(Dispatchers.Unconfined),
            trimMemoryAutomatically = false,
        ),
    )

    private fun createTarget(store: BrowserStore, timeoutMillis: Long = 5_000) =
        WebExtensionActionTarget(
            store = store,
            createBlankSession = { mock(EngineSession::class.java).also { blankSessions += it } },
            timeoutMillis = timeoutMillis,
            mainDispatcher = Dispatchers.Unconfined,
        ).also { it.start() }

    private fun EngineSession.capturedObserver(): EngineSession.Observer {
        val captor = ArgumentCaptor.forClass(EngineSession.Observer::class.java)
        // capture() returns null, which Kotlin rejects for a non-null parameter.
        verify(this).register(captor.capture() ?: object : EngineSession.Observer {})
        return captor.value
    }

    @Test
    fun `creates and activates a session for a selected tab without one`() = runBlocking<Unit> {
        val store = createStore()
        val target = createTarget(store)

        val prepared = async(Dispatchers.Unconfined) { target.prepare() }
        yield()

        assertSame(tabSession, store.state.findTab(SELECTED_TAB)?.engineState?.engineSession)
        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
        verify(tabSession).markActiveForWebExtensions(true)
        // Gecko applies the activation once the session's window exists; the
        // click has to wait for the load that proves it.
        assertTrue(prepared.isActive)

        store.dispatch(ContentAction.UpdateLoadingStateAction(SELECTED_TAB, true))
        prepared.await()
        assertTrue(blankSessions.isEmpty())
    }

    @Test
    fun `sends the click anyway when the tab's load never starts`() = runBlocking<Unit> {
        val store = createStore()

        createTarget(store, timeoutMillis = 50).prepare()

        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
    }

    @Test
    fun `leaves an already active tab alone`() = runBlocking<Unit> {
        val store = createStore()
        store.dispatch(
            EngineAction.LinkEngineSessionAction(SELECTED_TAB, mock(EngineSession::class.java), skipLoading = true),
        )

        createTarget(store).prepare()

        verify(engine, never()).createSession(anyBoolean(), any())
        assertTrue(blankSessions.isEmpty())
    }

    @Test
    fun `without a selected tab activates a blank session instead of a restored tab`() = runBlocking<Unit> {
        val store = createStore(selectedTabId = null)
        val target = createTarget(store)

        val prepared = async(Dispatchers.Unconfined) { target.prepare() }
        yield()

        // The restored tab stays asleep: the user is on the home surface.
        verify(engine, never()).createSession(anyBoolean(), any())
        assertNull(store.state.activeWebExtensionTabId)

        val blank = blankSessions.single()
        inOrder(blank).apply {
            verify(blank).markActiveForWebExtensions(true)
            verify(blank).loadUrl("about:blank")
        }
        assertTrue(prepared.isActive)

        blank.capturedObserver().onLoadingStateChange(true)
        prepared.await()
    }

    @Test
    fun `reuses the blank session while no tab becomes active`() = runBlocking<Unit> {
        val target = createTarget(createStore(selectedTabId = null), timeoutMillis = 50)

        target.prepare()
        target.prepare()

        val blank = blankSessions.single()
        verify(blank, never()).close()
    }

    @Test
    fun `closes the blank session once a real tab becomes active`() = runBlocking<Unit> {
        val store = createStore(selectedTabId = null)
        createTarget(store, timeoutMillis = 50).prepare()
        val blank = blankSessions.single()

        store.dispatch(TabListAction.SelectTabAction(SELECTED_TAB))
        store.dispatch(
            EngineAction.LinkEngineSessionAction(SELECTED_TAB, mock(EngineSession::class.java), skipLoading = true),
        )

        assertEquals(SELECTED_TAB, store.state.activeWebExtensionTabId)
        verify(blank).close()
    }

    @Test
    fun `stop closes the blank session`() = runBlocking<Unit> {
        val target = createTarget(createStore(selectedTabId = null), timeoutMillis = 50)
        target.prepare()

        target.stop()

        verify(blankSessions.single()).close()
    }

    private companion object {
        const val SELECTED_TAB = "selected"
    }
}
