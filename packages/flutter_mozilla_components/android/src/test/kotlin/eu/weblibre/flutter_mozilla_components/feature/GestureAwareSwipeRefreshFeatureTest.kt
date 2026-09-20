/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.widget.ZoomAwareSwipeRefreshLayout
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.lib.state.Middleware
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * Covers what this feature adds to android-components' `SwipeRefreshFeature`:
 * which tab a completed pull resolves to, and the two cases where it must not
 * reload after all.
 *
 * `sdk = 28` deliberately: the haptic tick in `onRefresh` is API 30+, and
 * nothing here is about the tick.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class GestureAwareSwipeRefreshFeatureTest {
    private val dispatched = CopyOnWriteArrayList<BrowserAction>()
    private val dispatchSeen = CountDownLatch(1)

    private lateinit var store: BrowserStore
    private lateinit var layout: ZoomAwareSwipeRefreshLayout
    private val events = mutableListOf<MotionEvent>()

    /**
     * Records and swallows: no engine is attached here, so an [EngineAction] has
     * nothing to reduce against, and everything asserted below happens before
     * the reducer would run anyway.
     */
    private val recorder: Middleware<BrowserState, BrowserAction> = { _, _, action ->
        dispatched.add(action)
        dispatchSeen.countDown()
    }

    @Before
    fun setUp() {
        val context = RuntimeEnvironment.getApplication()
        layout = ZoomAwareSwipeRefreshLayout(context)
        // Stands in for the engine view: SwipeRefreshLayout resolves its scroll
        // target to the first child that is not its own throbber.
        layout.addView(View(context))
        // And it asks its own parent for a disallow once a drag starts, so it
        // needs one — as it has in the app.
        FrameLayout(context).addView(layout)

        store = BrowserStore(
            BrowserState(
                tabs = listOf(createTab(url = "https://example.org", id = SELECTED_TAB)),
                selectedTabId = SELECTED_TAB,
                customTabs = listOf(createCustomTab(url = "https://example.com", id = CUSTOM_TAB)),
            ),
            middleware = listOf(recorder),
        )

        GlobalComponents.touchConsumedByGesture = false
    }

    @After
    fun tearDown() {
        GlobalComponents.touchConsumedByGesture = false
        events.forEach { it.recycle() }
        events.clear()
    }

    @Test
    fun `a pull reloads the tab the feature was bound to, not the selected one`() {
        // The Custom Tab / PWA case: the window shows CUSTOM_TAB while the
        // browser's own SELECTED_TAB is still the selected one in the store.
        feature(tabId = CUSTOM_TAB).onRefresh()

        assertEquals(CUSTOM_TAB, awaitReload().tabId)
    }

    @Test
    fun `a pull with no bound tab falls back to the selected one`() {
        feature(tabId = null).onRefresh()

        assertEquals(SELECTED_TAB, awaitReload().tabId)
    }

    @Test
    fun `a stroke already claimed by a touch gesture does not also reload`() {
        val feature = feature(tabId = CUSTOM_TAB)
        layout.isRefreshing = true
        // What the gesture container sets on the terminating ACTION_UP, before
        // this layout runs its own up-handling.
        GlobalComponents.touchConsumedByGesture = true

        feature.onRefresh()

        assertNoReload()
        // The throbber the pull put up is retracted rather than left spinning.
        assertFalse(layout.isRefreshing)
    }

    @Test
    fun `a pull that turned out to be a zoom does not reload`() {
        val feature = feature(tabId = CUSTOM_TAB)
        layout.isRefreshing = true
        // A pull already intercepted before the second finger landed keeps
        // running in the layout's own onTouchEvent, which never consults
        // canChildScrollUp again — so onRefresh is the line of defence.
        beginPinch()

        feature.onRefresh()

        assertNoReload()
        assertFalse(layout.isRefreshing)
    }

    private fun feature(tabId: String?) =
        GestureAwareSwipeRefreshFeature(
            store = store,
            reloadUrlUseCase = SessionUseCases(store).reload,
            swipeRefreshLayout = layout,
            tabId = tabId,
        )

    /** A single-pointer down followed by a second finger landing. */
    private fun beginPinch() {
        dispatch(MotionEvent.ACTION_DOWN, listOf(100f to 100f))
        dispatch(
            MotionEvent.ACTION_POINTER_DOWN or (1 shl MotionEvent.ACTION_POINTER_INDEX_SHIFT),
            listOf(100f to 100f, 300f to 100f),
        )
    }

    private fun dispatch(action: Int, points: List<Pair<Float, Float>>) {
        val properties = Array(points.size) { index ->
            MotionEvent.PointerProperties().apply {
                id = index
                toolType = MotionEvent.TOOL_TYPE_FINGER
            }
        }
        val coords = Array(points.size) { index ->
            MotionEvent.PointerCoords().apply {
                x = points[index].first
                y = points[index].second
                pressure = 1f
                size = 1f
            }
        }
        val event = MotionEvent.obtain(
            0L, 0L, action, points.size, properties, coords,
            0, 0, 1f, 1f, 0, 0, 0, 0,
        )
        events.add(event)
        layout.dispatchTouchEvent(event)
    }

    private fun awaitReload(): EngineAction.ReloadAction {
        assertTrue(
            dispatchSeen.await(DISPATCH_TIMEOUT_MS, TimeUnit.MILLISECONDS),
            "no action reached the store",
        )
        val reloads = dispatched.filterIsInstance<EngineAction.ReloadAction>()
        assertEquals(1, reloads.size, "expected exactly one reload, got $dispatched")
        return reloads.single()
    }

    private fun assertNoReload() {
        // Dispatch is asynchronous, so give one that should not happen a chance
        // to arrive before concluding that it did not.
        dispatchSeen.await(NO_DISPATCH_GRACE_MS, TimeUnit.MILLISECONDS)
        assertTrue(
            dispatched.filterIsInstance<EngineAction.ReloadAction>().isEmpty(),
            "expected no reload, got $dispatched",
        )
    }

    private companion object {
        const val SELECTED_TAB = "selected-tab"
        const val CUSTOM_TAB = "custom-tab"
        const val DISPATCH_TIMEOUT_MS = 2_000L
        const val NO_DISPATCH_GRACE_MS = 250L
    }
}
