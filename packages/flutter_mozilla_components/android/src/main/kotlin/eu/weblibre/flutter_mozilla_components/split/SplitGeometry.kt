/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import kotlin.math.abs
import kotlin.math.roundToInt

/** How the split layout arranges its panes. */
enum class PaneArrangement {
    /** One pane fills the layout. */
    SINGLE,

    SIDE_BY_SIDE,
    STACKED,
}

/** An integer rectangle, kept free of `android.graphics` so it tests on the JVM. */
internal data class PaneBounds(val left: Int, val top: Int, val right: Int, val bottom: Int) {
    val width: Int get() = right - left
    val height: Int get() = bottom - top

    fun contains(x: Float, y: Float): Boolean =
        x >= left && x < right && y >= top && y < bottom
}

/** Where the slots and the divider go for one layout pass. */
internal data class SplitRects(
    val arrangement: PaneArrangement,
    /** The first slot (left or top), or the only pane in [PaneArrangement.SINGLE]. */
    val first: PaneBounds,
    val second: PaneBounds?,
    val divider: PaneBounds?,
)

/**
 * The pure geometry of the split layout, unit tested.
 *
 * Every length is in pixels. Dart resolves the mode against its own idea of
 * the content size; this is what native does with it at its actual size.
 */
internal object SplitGeometry {
    /** A release this close to equal sizes snaps to equal sizes. */
    const val SNAP_DISTANCE = 0.03

    /**
     * The arrangement that is actually drawn.
     *
     * The stale-geometry rule: native relayouts on its own size before Dart has
     * seen the change, so a requested split that no longer fits is shown as the
     * focused pane alone until the next state arrives. Native never squeezes
     * panes below the minimum and never picks the other axis by itself.
     */
    fun effectiveArrangement(
        requested: PaneArrangement,
        width: Int,
        height: Int,
        dividerPx: Int,
        minWidthPx: Int,
        minHeightPx: Int,
    ): PaneArrangement = when (requested) {
        PaneArrangement.SINGLE -> PaneArrangement.SINGLE
        PaneArrangement.SIDE_BY_SIDE ->
            if (2 * minWidthPx + dividerPx <= width && height >= minHeightPx) {
                requested
            } else {
                PaneArrangement.SINGLE
            }
        PaneArrangement.STACKED ->
            if (2 * minHeightPx + dividerPx <= height && width >= minWidthPx) {
                requested
            } else {
                PaneArrangement.SINGLE
            }
    }

    /**
     * The first pane's length on the axis for [ratio], clamped so neither pane
     * drops below [minPx]. [available] is the axis length without the divider.
     */
    fun firstLength(available: Int, ratio: Double, minPx: Int): Int {
        if (available <= 0) return 0
        val wanted = (available * ratio).roundToInt()
        val low = minPx.coerceAtMost(available / 2)
        val high = (available - minPx).coerceAtLeast(available - available / 2)
        return wanted.coerceIn(low, high)
    }

    fun rects(
        arrangement: PaneArrangement,
        width: Int,
        height: Int,
        ratio: Double,
        dividerPx: Int,
        minWidthPx: Int,
        minHeightPx: Int,
    ): SplitRects = when (arrangement) {
        PaneArrangement.SINGLE ->
            SplitRects(arrangement, PaneBounds(0, 0, width, height), null, null)

        PaneArrangement.SIDE_BY_SIDE -> {
            val firstWidth = firstLength(width - dividerPx, ratio, minWidthPx)
            SplitRects(
                arrangement,
                first = PaneBounds(0, 0, firstWidth, height),
                second = PaneBounds(firstWidth + dividerPx, 0, width, height),
                divider = PaneBounds(firstWidth, 0, firstWidth + dividerPx, height),
            )
        }

        PaneArrangement.STACKED -> {
            val firstHeight = firstLength(height - dividerPx, ratio, minHeightPx)
            SplitRects(
                arrangement,
                first = PaneBounds(0, 0, width, firstHeight),
                second = PaneBounds(0, firstHeight + dividerPx, width, height),
                divider = PaneBounds(0, firstHeight, width, firstHeight + dividerPx),
            )
        }
    }

    /**
     * The ratio a divider dragged to [position] (the finger on the axis)
     * stands for, clamped to the minimum pane size.
     */
    fun ratioForPosition(position: Float, axisLength: Int, dividerPx: Int, minPx: Int): Double {
        val available = axisLength - dividerPx
        if (available <= 0) return 0.5
        val first = (position - dividerPx / 2f).roundToInt()
        val low = minPx.coerceAtMost(available / 2)
        val high = (available - minPx).coerceAtLeast(available - available / 2)
        return first.coerceIn(low, high).toDouble() / available
    }

    /**
     * The slot a divider released at [position] collapses, or null. A release
     * that would leave a pane less than half of [dragMinPx] puts that pane
     * away: 0 for the first slot, 1 for the second.
     */
    fun collapsedSlot(position: Float, axisLength: Int, dividerPx: Int, dragMinPx: Int): Int? {
        val available = axisLength - dividerPx
        if (available <= 0 || dragMinPx <= 0) return null
        val first = position - dividerPx / 2f
        val zone = dragMinPx / 2f
        return when {
            first < zone -> 0
            available - first < zone -> 1
            else -> null
        }
    }

    /** A released ratio close to equal sizes becomes exactly equal sizes. */
    fun snap(ratio: Double): Double =
        if (abs(ratio - 0.5) <= SNAP_DISTANCE + 1e-9) 0.5 else ratio

    /**
     * Whether ([x], [y]) is a divider touch target. Drags start anywhere on the
     * gap. Around the grip (a [gripZonePx] square on the divider's center),
     * they also start up to [gripReachPx] into either pane.
     */
    fun isDividerHit(
        rects: SplitRects,
        x: Float,
        y: Float,
        gripZonePx: Int,
        gripReachPx: Int,
    ): Boolean {
        val divider = rects.divider ?: return false
        if (divider.contains(x, y)) return true

        val centerX = (divider.left + divider.right) / 2f
        val centerY = (divider.top + divider.bottom) / 2f
        val half = gripZonePx / 2f
        return when (rects.arrangement) {
            PaneArrangement.SIDE_BY_SIDE ->
                abs(y - centerY) <= half &&
                    x >= divider.left - gripReachPx && x < divider.right + gripReachPx
            PaneArrangement.STACKED ->
                abs(x - centerX) <= half &&
                    y >= divider.top - gripReachPx && y < divider.bottom + gripReachPx
            PaneArrangement.SINGLE -> false
        }
    }

    /** Whether ([x], [y]) is within the grip zone, where a tap opens the controls. */
    fun isGripHit(rects: SplitRects, x: Float, y: Float, gripZonePx: Int): Boolean {
        val divider = rects.divider ?: return false
        val centerX = (divider.left + divider.right) / 2f
        val centerY = (divider.top + divider.bottom) / 2f
        val half = gripZonePx / 2f
        return abs(x - centerX) <= half.coerceAtLeast(divider.width / 2f) &&
            abs(y - centerY) <= half.coerceAtLeast(divider.height / 2f)
    }
}
