/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import org.junit.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import mozilla.components.browser.state.action.CrashAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

// Robolectric for the Android logger the middleware writes to.
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class CrashRecoveryMiddlewareSplitTest {
    private fun store(visible: Set<String>) = BrowserStore(
        initialState = BrowserState(
            tabs = listOf(
                createTab("https://a.example", id = "a"),
                createTab("https://b.example", id = "b"),
                createTab("https://c.example", id = "c"),
            ),
            selectedTabId = "a",
        ),
        middleware = listOf(
            CrashRecoveryMiddleware(
                scope = CoroutineScope(Dispatchers.Unconfined),
                visibleTabIds = { visible },
            ),
        ),
    )

    @Test
    fun theVisibleUnselectedMemberIsRestoredAtOnce() {
        val store = store(visible = setOf("a", "b"))
        store.dispatch(CrashAction.SessionCrashedAction("b"))
        assertFalse(store.state.findTab("b")!!.engineState.crashed)
    }

    @Test
    fun aBackgroundTabWaitsUntilItIsSelected() {
        val store = store(visible = setOf("a", "b"))
        store.dispatch(CrashAction.SessionCrashedAction("c"))
        assertTrue(store.state.findTab("c")!!.engineState.crashed)
    }

    @Test
    fun theLoopGuardHoldsForAVisibleMember() {
        val store = store(visible = setOf("a", "b"))
        store.dispatch(CrashAction.SessionCrashedAction("b"))
        store.dispatch(CrashAction.SessionCrashedAction("b"))
        assertTrue(store.state.findTab("b")!!.engineState.crashed)
    }
}
