/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertSame
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSessionState
import org.json.JSONObject
import org.mockito.Mockito

/**
 * Spike S1 found that a session linked into a tab of a restricted context
 * (E8 refuses its restore, so it holds an empty page) overwrote the tab's saved
 * state with nothing. Its state updates are dropped; a session that existed
 * before the restriction, such as the one a freeze flushes, still saves.
 */
class RestrictedSessionStateTest {
    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    private val good = Mockito.mock(EngineSessionState::class.java)
    private val empty = Mockito.mock(EngineSessionState::class.java)
    private val restricted = RestrictedSessions

    private lateinit var store: BrowserStore

    private fun session(): EngineSession = Mockito.mock(EngineSession::class.java)

    private fun savedState(tabId: String) = store.state.findTab(tabId)?.engineState?.engineSessionState

    @BeforeTest
    fun setUp() {
        TabLifecycleRegistry.setStorageForTest(NoStorage)
        store = BrowserStore(
            initialState = BrowserState(
                tabs = listOf(
                    createTab("https://f.example", id = "f", contextId = "frozen", engineSessionState = good),
                    createTab("https://o.example", id = "o", contextId = "other", engineSessionState = good),
                ),
                selectedTabId = "o",
            ),
            middleware = listOf(TabLifecycleGuardMiddleware()),
        )
    }

    @AfterTest
    fun tearDown() {
        restricted.resetForTest()
        TabLifecycleRegistry.resetForTest()
    }

    @Test
    fun `a session linked while its context is restricted does not replace the saved state`() {
        restricted.restrict(listOf("frozen"))
        store.dispatch(EngineAction.LinkEngineSessionAction("f", session()))

        store.dispatch(EngineAction.UpdateEngineSessionStateAction("f", empty))

        assertSame(good, savedState("f"))
    }

    @Test
    fun `other contexts save as before`() {
        restricted.restrict(listOf("frozen"))
        store.dispatch(EngineAction.LinkEngineSessionAction("o", session()))

        store.dispatch(EngineAction.UpdateEngineSessionStateAction("o", empty))

        assertSame(empty, savedState("o"))
    }

    @Test
    fun `a session that existed before the restriction still saves, as a freeze's flush needs`() {
        store.dispatch(EngineAction.LinkEngineSessionAction("f", session()))
        restricted.restrict(listOf("frozen"))

        store.dispatch(EngineAction.UpdateEngineSessionStateAction("f", empty))

        assertSame(empty, savedState("f"))
    }

    @Test
    fun `the lift names the tab, which stays protected until its session goes`() {
        restricted.restrict(listOf("frozen"))
        store.dispatch(EngineAction.LinkEngineSessionAction("f", session()))

        assertEquals(listOf("f"), restricted.release(listOf("frozen")))
        store.dispatch(EngineAction.UpdateEngineSessionStateAction("f", empty))
        assertSame(good, savedState("f"))

        // Unloaded and created again after the lift: a normal session.
        store.dispatch(EngineAction.UnlinkEngineSessionAction("f"))
        assertSame(good, savedState("f"))
        store.dispatch(EngineAction.LinkEngineSessionAction("f", session()))
        store.dispatch(EngineAction.UpdateEngineSessionStateAction("f", empty))
        assertSame(empty, savedState("f"))
        assertEquals(emptyList(), restricted.release(listOf("frozen")))
    }

    @Test
    fun `a closed tab is forgotten`() {
        restricted.restrict(listOf("frozen"))
        store.dispatch(EngineAction.LinkEngineSessionAction("f", session()))

        store.dispatch(TabListAction.RemoveTabAction("f"))

        assertEquals(emptyList(), restricted.release(listOf("frozen")))
    }
}
