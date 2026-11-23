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
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.RestoreCompleteAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import org.json.JSONObject
import org.mockito.Mockito

/**
 * B1: a held tab gets no session from the store, whatever asked for one, and
 * holds follow the tabs they belong to.
 */
class TabLifecycleGuardMiddlewareTest {
    /** Records what got past the guard. */
    private class Recorder : Middleware<BrowserState, BrowserAction> {
        val actions = mutableListOf<BrowserAction>()

        override fun invoke(
            store: Store<BrowserState, BrowserAction>,
            next: (BrowserAction) -> Unit,
            action: BrowserAction,
        ) {
            actions += action
            next(action)
        }

        fun creations() = actions.filterIsInstance<EngineAction.CreateEngineSessionAction>()
    }

    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    private val registry = TabLifecycleRegistry
    private val recorder = Recorder()

    @BeforeTest
    fun setUp() = registry.setStorageForTest(NoStorage)

    @AfterTest
    fun tearDown() {
        registry.resetForTest()
        RestrictedSessions.resetForTest()
    }

    private fun store(assertInvariants: Boolean = false) = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
            ),
            selectedTabId = "a",
        ),
        middleware = listOf(TabLifecycleGuardMiddleware(registry, assertInvariants), recorder),
    )

    private fun hold(tabId: String) =
        registry.completeSleep(tabId, registry.beginSleep(tabId, SleepHoldKind.MANUAL, private = false))

    @Test
    fun `a held tab's creation is dropped with the action it was to run`() {
        val store = store()
        hold("a")

        store.dispatch(
            EngineAction.CreateEngineSessionAction(
                "a",
                followupAction = EngineAction.ReloadAction("a"),
            ),
        )

        assertTrue(recorder.creations().isEmpty())
    }

    @Test
    fun `a desktop mode asked for while a tab is held is kept for when its session is created`() {
        val store = store()
        hold("a")

        store.dispatch(
            EngineAction.CreateEngineSessionAction(
                "a",
                followupAction = EngineAction.ToggleDesktopModeAction("a", enable = true),
            ),
        )

        assertTrue(recorder.creations().isEmpty())
        // AC's session creation applies the tab's own mode.
        assertTrue(store.state.findTab("a")!!.content.desktopMode)
    }

    @Test
    fun `a tab that is not held is created as before`() {
        val store = store()
        hold("a")

        store.dispatch(EngineAction.CreateEngineSessionAction("b"))

        assertEquals(listOf(EngineAction.CreateEngineSessionAction("b")), recorder.creations())
    }

    @Test
    fun `a woken tab is created again`() {
        val store = store()
        hold("a")
        registry.wake("a")

        store.dispatch(EngineAction.CreateEngineSessionAction("a"))

        assertEquals(listOf(EngineAction.CreateEngineSessionAction("a")), recorder.creations())
    }

    @Test
    fun `a link into a held tab fails in debug builds`() {
        val store = store(assertInvariants = true)
        hold("a")

        assertFailsWith<IllegalStateException> {
            store.dispatch(EngineAction.LinkEngineSessionAction("a", Mockito.mock(EngineSession::class.java)))
        }
    }

    @Test
    fun `a closed tab loses its hold`() {
        val store = store()
        hold("a")
        hold("b")

        store.dispatch(TabListAction.RemoveTabAction("a"))

        assertFalse(registry.isHeld("a"))
        assertTrue(registry.isHeld("b"))
    }

    @Test
    fun `a closed custom tab is no longer tracked`() {
        val guarded = BrowserStore(
            initialState = BrowserState(
                customTabs = listOf(createCustomTab("https://w.example", id = "pwa", contextId = "ctx")),
            ),
            middleware = listOf(TabLifecycleGuardMiddleware(registry), recorder),
        )
        registry.beginFreeze("c1", listOf("ctx"))
        val session = Mockito.mock(EngineSession::class.java)
        guarded.dispatch(EngineAction.LinkEngineSessionAction("pwa", session))
        assertTrue(RestrictedSessions.wasLinkedWhileRestricted("pwa") { session })

        guarded.dispatch(CustomTabListAction.RemoveCustomTabAction("pwa"))

        assertFalse(RestrictedSessions.wasLinkedWhileRestricted("pwa") { session })
    }

    @Test
    fun `the end of the restore drops holds of tabs that did not come back`() {
        val store = store()
        hold("gone")
        hold("a")

        store.dispatch(RestoreCompleteAction)

        assertFalse(registry.isHeld("gone"))
        assertTrue(registry.isHeld("a"))
    }

    @Test
    fun `a tab of a frozen container gets no session, and the creation's follow-up is dropped with it`() {
        val guarded = BrowserStore(
            initialState = BrowserState(
                tabs = listOf(
                    createTab("https://f.example", id = "frozen", contextId = "ctx"),
                    createTab("https://o.example", id = "open", contextId = "other"),
                ),
                selectedTabId = "frozen",
            ),
            middleware = listOf(TabLifecycleGuardMiddleware(registry), recorder),
        )
        registry.beginFreeze("c1", listOf("ctx"))

        guarded.dispatch(EngineAction.CreateEngineSessionAction("frozen"))
        guarded.dispatch(EngineAction.CreateEngineSessionAction("open"))

        assertEquals(listOf("open"), recorder.creations().map { it.tabId })
    }
}
