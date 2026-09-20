/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import androidx.annotation.VisibleForTesting
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import kotlin.math.abs

/**
 * [SwipeRefreshLayout] that only pulls to refresh for a plain vertical drag.
 *
 * Replaces android-components' `VerticalSwipeRefreshLayout`, which is `final`
 * and cannot be extended. The parts that matter are kept: horizontal-dominant
 * drags do not pull, nested scrolls from descendants are ignored, and a
 * descendant's `requestDisallowInterceptTouchEvent` is recorded here rather
 * than propagated to the parent (which uses the gesture for other purposes).
 *
 * What changes is *where* zoom gestures are detected. Upstream watches for the
 * second pointer and for the double tap that starts a quick scale inside
 * [onInterceptTouchEvent] — and that hook is skipped for most of a stroke here,
 * because `NestedGeckoView` calls `requestDisallowInterceptTouchEvent(true)` on
 * every ACTION_DOWN, which returns before either check runs. APZ answers
 * asynchronously and lifts the disallow again part-way through the stroke, so
 * what this layout ends up seeing is the *trailing* single-pointer part of a
 * pinch, measured against the ACTION_DOWN that started the pinch. That looks
 * exactly like a plain downward pull from the top of the page, and reloads it
 * on release.
 *
 * [dispatchTouchEvent] has no such gap: it runs for every event of every stroke
 * that reaches the browser content, disallow or not, and before this layout's
 * own intercept handling for the same event. Classifying there and latching the
 * verdict for the whole stroke is what makes the guard hold.
 *
 * See https://github.com/FaFre/WebLibre/issues/356.
 *
 * Derived from android-components `VerticalSwipeRefreshLayout` (MPL-2.0).
 */
class ZoomAwareSwipeRefreshLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : SwipeRefreshLayout(context, attrs) {

    /**
     * Whether the touch sequence currently in flight is a zoom gesture: two or
     * more pointers down at any point (pinch), or an ACTION_DOWN that is the
     * second tap of a double tap (quick-scale drag-zoom, and plain double-tap
     * zoom).
     *
     * Cleared on ACTION_DOWN rather than on ACTION_UP, so it is still readable
     * while this layout runs its own up-handling — which is where a pull past
     * the threshold turns into a reload. ACTION_CANCEL clears it too: that
     * event can never reach [OnRefreshListener.onRefresh] (SwipeRefreshLayout
     * finishes the spinner from ACTION_UP only), so there is nothing left to
     * guard and the flag should not read `true` between strokes.
     */
    var strokeIsZoomGesture: Boolean = false
        private set

    private val doubleTapTimeoutMs = ViewConfiguration.getDoubleTapTimeout().toLong()
    private val doubleTapSlopSquare =
        ViewConfiguration.get(context).scaledDoubleTapSlop.toLong().let { it * it }
    private val touchSlopSquare =
        ViewConfiguration.get(context).scaledTouchSlop.toLong().let { it * it }

    // Where the stroke in flight started, whether it has had a second pointer
    // down, and whether it has travelled far enough to be a drag rather than a
    // tap. Promoted to the `previous*` fields below once it ends.
    private var downX = 0f
    private var downY = 0f
    private var strokeHadMultiplePointers = false
    private var strokeLeftTapRegion = false

    // The last stroke that ended in an ACTION_UP as a single-pointer *tap*:
    // where it started, and when it ended.
    private var previousDownX = 0f
    private var previousDownY = 0f
    private var previousUpTime = 0L
    private var hasPreviousStroke = false

    private var previousX = 0f
    private var previousY = 0f

    @VisibleForTesting
    internal var disallowInterceptTouchEvent = false

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        // Any multi-pointer event marks the stroke, not just the
        // ACTION_POINTER_DOWN that introduced the second finger — upstream
        // checks `pointerCount` for the same reason. A stroke can reach this
        // layout already carrying two pointers when the stream was
        // re-dispatched or synthesised further up (which the browser container
        // above does), and then the ACTION_POINTER_DOWN never arrives here at
        // all. Runs before the branches below so ACTION_DOWN — always a single
        // pointer — still resets, and so a cancelled pinch still clears.
        if (ev.pointerCount > 1) {
            strokeIsZoomGesture = true
            strokeHadMultiplePointers = true
        }

        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                // Against the previous stroke, before this one overwrites it.
                strokeIsZoomGesture = isSecondTapOfDoubleTap(ev)
                downX = ev.x
                downY = ev.y
                strokeHadMultiplePointers = false
                strokeLeftTapRegion = false
                // A new stroke cannot inherit the previous one's disallow.
                // NestedGeckoView lifts its own on the terminating ACTION_UP /
                // ACTION_CANCEL, but that event does not always arrive here:
                // Flutter's platform-view pipeline drops ACTION_CANCEL on some
                // devices, which is the whole reason BackGestureFilterFrameLayout
                // exists. Left latched, the flag would silently kill
                // pull-to-refresh for every later stroke, with nothing on screen
                // to explain it.
                disallowInterceptTouchEvent = false
            }

            MotionEvent.ACTION_MOVE -> {
                // Past touch slop this stroke is a drag, and a drag is not a
                // tap — see [strokeLeftTapRegion]'s use at ACTION_UP.
                if (!strokeLeftTapRegion) {
                    val dx = (ev.x - downX).toLong()
                    val dy = (ev.y - downY).toLong()
                    if (dx * dx + dy * dy > touchSlopSquare) {
                        strokeLeftTapRegion = true
                    }
                }
            }

            MotionEvent.ACTION_UP -> {
                // Only a single-pointer *tap* can be the first tap of a double
                // tap. A pinch is not one, and neither is a drag: without the
                // tap-region check, every completed scroll would seed a
                // candidate, and a second pull starting near where the first one
                // started — a perfectly ordinary way to retry a pull-to-refresh
                // — would be read as a double tap and silently suppressed.
                // GestureDetector drops its own double-tap candidacy the moment
                // a stroke starts scrolling, for the same reason.
                hasPreviousStroke = !strokeHadMultiplePointers && !strokeLeftTapRegion
                previousDownX = downX
                previousDownY = downY
                previousUpTime = ev.eventTime
            }

            MotionEvent.ACTION_CANCEL -> {
                // A cancelled stroke never produced a tap either, and it can no
                // longer reach onRefresh, so the zoom verdict is released here
                // rather than held until the next ACTION_DOWN.
                hasPreviousStroke = false
                strokeIsZoomGesture = false
                strokeHadMultiplePointers = false
                strokeLeftTapRegion = false
            }
        }

        return super.dispatchTouchEvent(ev)
    }

    override fun onInterceptTouchEvent(event: MotionEvent): Boolean {
        // Setting "isEnabled = false" is how users of this ViewGroup turn pull
        // to refresh off; check it first so nothing below runs needlessly.
        if (!isEnabled || disallowInterceptTouchEvent || strokeIsZoomGesture) {
            return false
        }

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                previousX = event.x
                previousY = event.y
            }

            MotionEvent.ACTION_MOVE -> {
                val xDistance = abs(event.x - previousX)
                val yDistance = abs(event.y - previousY)
                previousX = event.x
                previousY = event.y
                // Moving more on the X axis than on the Y axis is a sideways
                // swipe, not a pull.
                if (xDistance > yDistance) {
                    return false
                }
            }
        }

        return super.onInterceptTouchEvent(event)
    }

    override fun onStartNestedScroll(child: View, target: View, nestedScrollAxes: Int): Boolean {
        // Ignore nested scrolls from descendants. Honouring them would defeat
        // the filtering above and pull to refresh for every Y-axis movement
        // (scale gestures included), while doubling the throbber with the
        // overscroll shadow.
        return if (isEnabled) {
            false
        } else {
            super.onStartNestedScroll(child, target, nestedScrollAxes)
        }
    }

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // Record it for [onInterceptTouchEvent] but do not pass it up: the
        // parent may use the gesture for something else.
        disallowInterceptTouchEvent = disallowIntercept
    }

    /**
     * Whether `ev` is the second tap of a double tap, following
     * `GestureDetectorCompat#isConsideredDoubleTap`: the gap is measured from
     * the previous stroke's ACTION_UP, but the distance is measured between the
     * two ACTION_DOWNs — and the previous stroke has to have been a tap at all,
     * which is what `hasPreviousStroke` records.
     *
     * Comparing against where the previous stroke *ended* instead would call
     * any touch that lands near the end of a scroll or a pinch a double tap,
     * and silently suppress pull-to-refresh for it — a finger put back down
     * where it was lifted, which is exactly how a fling to the top of a page is
     * followed by a pull.
     */
    private fun isSecondTapOfDoubleTap(ev: MotionEvent): Boolean {
        if (!hasPreviousStroke) return false
        if (ev.eventTime - previousUpTime > doubleTapTimeoutMs) return false

        val dx = (ev.x - previousDownX).toLong()
        val dy = (ev.y - previousDownY).toLong()
        return dx * dx + dy * dy < doubleTapSlopSquare
    }
}
