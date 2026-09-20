/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.widget.FrameLayout
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * Covers the stroke classification in [ZoomAwareSwipeRefreshLayout]: which
 * touch sequences it reports as a zoom (and so refuses to pull for), and the
 * state it must not carry from one stroke into the next.
 *
 * Stands in for android-components' `VerticalSwipeRefreshLayoutTest`, which
 * does not apply to this rewrite — upstream classifies in `onInterceptTouchEvent`
 * and holds the raw `MotionEvent`s, this one classifies in `dispatchTouchEvent`
 * and holds only the derived values.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class ZoomAwareSwipeRefreshLayoutTest {
    private lateinit var layout: ZoomAwareSwipeRefreshLayout
    private lateinit var parent: RecordingParent
    private val events = mutableListOf<MotionEvent>()

    /** Notes whether a disallow made it past the layout under test. */
    private class RecordingParent(context: Context) : FrameLayout(context) {
        var sawDisallow = false

        override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
            sawDisallow = true
            super.requestDisallowInterceptTouchEvent(disallowIntercept)
        }
    }

    private val doubleTapTimeout = ViewConfiguration.getDoubleTapTimeout().toLong()

    /** Arbitrary; every event of a run is offset from it. */
    private val downTime = 1_000L

    @Before
    fun setUp() {
        val context = RuntimeEnvironment.getApplication()
        layout = ZoomAwareSwipeRefreshLayout(context)
        // SwipeRefreshLayout resolves its scroll target to the first child that
        // is not its own throbber, and dereferences it while intercepting. In
        // the app that child is the engine view; here anything will do.
        layout.addView(View(context))
        // And it asks its own parent for a disallow once a drag starts, so it
        // needs one — as it has in the app.
        parent = RecordingParent(context)
        parent.addView(layout)
    }

    @After
    fun tearDown() {
        events.forEach { it.recycle() }
        events.clear()
    }

    @Test
    fun `a plain vertical drag is not a zoom`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_MOVE, 100f, 200f, at = 20)
        dispatch(MotionEvent.ACTION_MOVE, 100f, 300f, at = 40)
        dispatch(MotionEvent.ACTION_UP, 100f, 300f, at = 60)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a second pointer marks the whole stroke, up included`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatchMulti(pointerDownAction(1), listOf(100f to 100f, 300f to 100f), at = 20)
        // The pinch spreads, then the second finger lifts and the stroke
        // finishes single-pointer — the part upstream reads as a plain pull.
        dispatchMulti(MotionEvent.ACTION_MOVE, listOf(80f to 140f, 320f to 260f), at = 40)
        dispatchMulti(pointerUpAction(1), listOf(80f to 140f, 320f to 260f), at = 60)
        dispatch(MotionEvent.ACTION_MOVE, 80f, 200f, at = 80)
        dispatch(MotionEvent.ACTION_UP, 80f, 240f, at = 100)

        // Still true while the layout runs its own up-handling, which is where
        // a pull past the threshold would turn into a reload.
        assertTrue(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a stroke that goes multi-pointer without an ACTION_POINTER_DOWN is a zoom`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        // The second finger's ACTION_POINTER_DOWN never reaches this layout —
        // what a re-dispatched or synthesised sequence from the container above
        // can look like — so only the pointer count gives the pinch away.
        dispatchMulti(MotionEvent.ACTION_MOVE, listOf(100f to 140f, 300f to 60f), at = 20)

        assertTrue(layout.strokeIsZoomGesture)
    }

    @Test
    fun `the second tap of a double tap is a zoom`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_UP, 100f, 100f, at = 20)
        // Within the double-tap window and slop: a quick-scale drag-zoom starts
        // exactly like this.
        dispatch(MotionEvent.ACTION_DOWN, 102f, 101f, at = 60)

        assertTrue(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a tap after the double tap timeout is not a zoom`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_UP, 100f, 100f, at = 20)
        dispatch(MotionEvent.ACTION_DOWN, 102f, 101f, at = 20 + doubleTapTimeout + 1)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a touch far from the previous down is not a double tap`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_UP, 100f, 100f, at = 20)
        dispatch(MotionEvent.ACTION_DOWN, 100f, 1_000f, at = 40)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a fling measured from where it ended does not suppress the pull that follows`() {
        // The regression the DOWN-to-DOWN distance guards: a scroll that ends
        // where the next touch begins must not read as a double tap, because
        // that is exactly how a fling to the top is followed by a pull.
        dispatch(MotionEvent.ACTION_DOWN, 100f, 900f, at = 0)
        dispatch(MotionEvent.ACTION_MOVE, 100f, 500f, at = 20)
        dispatch(MotionEvent.ACTION_UP, 100f, 100f, at = 40)
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 60)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a drag does not seed a double tap, even when the next touch lands on its start`() {
        // Two pulls in quick succession from roughly the same spot — the
        // ordinary way to retry a pull-to-refresh that did not take. Only the
        // *start* of the first stroke is remembered, so without the tap-region
        // check the second one reads as a double tap and never pulls.
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_MOVE, 100f, 300f, at = 20)
        dispatch(MotionEvent.ACTION_UP, 100f, 400f, at = 40)

        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 60)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a tap that jitters within touch slop still seeds a double tap`() {
        // The quick-scale path has to keep working: a real first tap wobbles a
        // pixel or two before it lifts.
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatch(MotionEvent.ACTION_MOVE, 101f, 101f, at = 10)
        dispatch(MotionEvent.ACTION_UP, 101f, 101f, at = 20)

        dispatch(MotionEvent.ACTION_DOWN, 102f, 101f, at = 60)

        assertTrue(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a pinch does not seed a double tap for the next stroke`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatchMulti(pointerDownAction(1), listOf(100f to 100f, 300f to 100f), at = 20)
        dispatchMulti(pointerUpAction(1), listOf(100f to 100f, 300f to 100f), at = 40)
        dispatch(MotionEvent.ACTION_UP, 100f, 100f, at = 60)

        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 80)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a cancelled stroke releases the zoom verdict`() {
        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)
        dispatchMulti(pointerDownAction(1), listOf(100f to 100f, 300f to 100f), at = 20)
        assertTrue(layout.strokeIsZoomGesture)

        dispatchMulti(MotionEvent.ACTION_CANCEL, listOf(100f to 100f, 300f to 100f), at = 40)

        assertFalse(layout.strokeIsZoomGesture)
    }

    @Test
    fun `a new stroke does not inherit a disallow from the previous one`() {
        // NestedGeckoView asks for this on every ACTION_DOWN and lifts it again
        // on the terminating ACTION_UP / ACTION_CANCEL — which does not always
        // arrive through Flutter's platform-view pipeline. Left latched, it
        // would kill pull-to-refresh for every later stroke.
        layout.requestDisallowInterceptTouchEvent(true)
        assertTrue(layout.disallowInterceptTouchEvent)

        dispatch(MotionEvent.ACTION_DOWN, 100f, 100f, at = 0)

        assertFalse(layout.disallowInterceptTouchEvent)
    }

    @Test
    fun `a disallow is recorded but not propagated to the parent`() {
        // The parent uses the gesture for other purposes — forwarding would
        // take pull-to-refresh's own suppression out of its hands.
        layout.requestDisallowInterceptTouchEvent(true)

        assertTrue(layout.disallowInterceptTouchEvent)
        assertFalse(parent.sawDisallow)
    }

    private fun pointerDownAction(index: Int) =
        MotionEvent.ACTION_POINTER_DOWN or (index shl MotionEvent.ACTION_POINTER_INDEX_SHIFT)

    private fun pointerUpAction(index: Int) =
        MotionEvent.ACTION_POINTER_UP or (index shl MotionEvent.ACTION_POINTER_INDEX_SHIFT)

    private fun dispatch(action: Int, x: Float, y: Float, at: Long) {
        dispatchMulti(action, listOf(x to y), at)
    }

    private fun dispatchMulti(action: Int, points: List<Pair<Float, Float>>, at: Long) {
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
            downTime,
            downTime + at,
            action,
            points.size,
            properties,
            coords,
            0,
            0,
            1f,
            1f,
            0,
            0,
            0,
            0,
        )
        events.add(event)
        layout.dispatchTouchEvent(event)
    }
}
