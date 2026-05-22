/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.widget

import android.app.Activity
import android.content.Context
// import android.util.Log
import android.view.MotionEvent
import android.widget.FrameLayout
import androidx.core.view.WindowInsetsCompat
import kotlin.math.abs

/**
 * Root container for the embedded browser fragment.
 *
 * Why: Flutter's platform-view motion-event pipeline does not reliably forward
 * ACTION_CANCEL when the Android system claims a back gesture mid-stream. On
 * affected devices (notably Samsung One UI) GeckoView's APZ receives the
 * leading touches of the back gesture and produces a short, unwanted page
 * scroll before the gesture is recognized.
 *
 * This view watches every touch in dispatchTouchEvent (rather than
 * onInterceptTouchEvent — NestedGeckoView calls requestDisallowInterceptTouchEvent
 * on ACTION_DOWN, which would suppress the intercept hook for the rest of the
 * gesture). When a horizontal drag begins inside the system back-gesture inset
 * and the gesture becomes unambiguous (horizontal travel exceeds touch slop and
 * dominates over vertical travel), it dispatches a synthetic ACTION_CANCEL to
 * children and swallows the remainder of the gesture. APZ resets cleanly on
 * the cancel.
 *
 * Taps and vertical drags that originate in the inset still reach the engine
 * view, so links and vertical scrolling continue to work at the edges.
 */
class BackGestureFilterFrameLayout(
    context: Context,
    private val activity: Activity,
) : FrameLayout(context) {
    private var downX = 0f
    private var downY = 0f
    private var startedInEdgeZone = false
    private var hasIntercepted = false

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downX = ev.x
                downY = ev.y
                hasIntercepted = false
                val (left, right) = currentGestureInsets()
                startedInEdgeZone = isInEdgeZone(ev.x, left, right)
            }

            MotionEvent.ACTION_MOVE -> {
                if (hasIntercepted) {
                    return true
                }
                if (startedInEdgeZone) {
                    val dx = abs(ev.x - downX)
                    val dy = abs(ev.y - downY)
                    when {
                        // Horizontal-dominant: this is a back-gesture pan. The OS will
                        // CANCEL shortly, but APZ's internal pan threshold is smaller
                        // than Android's touchSlop, so even the small leading MOVEs
                        // already scrolled the page. Cancel APZ now and swallow the rest.
                        dx > dy + 1 -> {
                            hasIntercepted = true
                            // Log.d(TAG, "INTERCEPT dx=$dx dy=$dy")
                            dispatchSyntheticCancel(ev)
                            return true
                        }
                        // Vertical-dominant: the gesture is a real in-page scroll;
                        // stop watching so subsequent MOVEs pass through.
                        dy > dx + 1 -> {
                            startedInEdgeZone = false
                        }
                    }
                }
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                val wasIntercepted = hasIntercepted
                resetGestureState()
                if (wasIntercepted) {
                    return true
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }

    private fun dispatchSyntheticCancel(source: MotionEvent) {
        val cancel = MotionEvent.obtain(source).apply {
            action = MotionEvent.ACTION_CANCEL
        }
        super.dispatchTouchEvent(cancel)
        cancel.recycle()
    }

    private fun resetGestureState() {
        startedInEdgeZone = false
        hasIntercepted = false
    }

    private fun currentGestureInsets(): Pair<Int, Int> {
        val rawInsets = activity.window.decorView.rootWindowInsets ?: return 0 to 0
        val gestureInsets = WindowInsetsCompat.toWindowInsetsCompat(rawInsets)
            .getInsets(WindowInsetsCompat.Type.systemGestures())
        return gestureInsets.left to gestureInsets.right
    }

    private fun isInEdgeZone(x: Float, left: Int, right: Int): Boolean {
        if (left == 0 && right == 0) {
            // 3-button navigation (or unknown): no system back gesture to defend
            // against, so all edge touches must reach the engine view normally.
            return false
        }
        return x <= left || x >= width - right
    }

    // companion object {
    //     private const val TAG = "BackGestureFilter"
    // }
}
