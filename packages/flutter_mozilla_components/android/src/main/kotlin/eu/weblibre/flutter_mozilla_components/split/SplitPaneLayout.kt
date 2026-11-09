/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.os.Bundle
import android.os.SystemClock
import android.util.AttributeSet
import android.util.TypedValue
import android.view.MotionEvent
import android.view.PointerIcon
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.view.KeyEvent
import android.view.accessibility.AccessibilityEvent
import androidx.core.view.AccessibilityDelegateCompat
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat.AccessibilityActionCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat.RangeInfoCompat
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.pigeons.SplitAxis
import kotlin.math.abs
import kotlin.math.roundToInt

/**
 * Lays out the split panes and draws the native split chrome: the divider,
 * its grip, the drag preview line and (through [PaneView]) the focus outline.
 * No Flutter overlay sits over the page.
 *
 * It lays out from its own size, so a keyboard or side-rail resize relayouts
 * without Dart. When the requested split no longer fits that size it shows the
 * focused pane alone ([SplitGeometry.effectiveArrangement]).
 *
 * Input:
 * - A pointer down in a pane reports [Listener.onPaneTouched] before the page
 *   sees it, which is what makes the touched page the selected tab. The event
 *   is not consumed.
 * - A stroke that starts on the divider belongs to the divider: drag to
 *   resize (applied on release), tap the grip for the controls, double-tap
 *   for equal sizes. A release near the edge, past the drag minimum, puts
 *   the squeezed pane away ([Listener.onDividerCollapsed]).
 *
 * Accessibility and keyboard: the divider is a separate, childless,
 * focusable view laid over the gap ([DividerHandle]), adjustable like a
 * seek bar and by the arrow keys. It is deliberately not a node provider on
 * this layout: a view group with a provider drops its real children from the
 * accessibility tree, which would hide both pages' own trees, in single view
 * too.
 */
class SplitPaneLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : ViewGroup(context, attrs) {

    interface Listener {
        fun onPaneTouched(pane: PaneView)
        fun onRatioCommitted(axis: SplitAxis, ratio: Double)

        /** The divider was released at the edge: show [kept] alone. */
        fun onDividerCollapsed(kept: PaneView)
        fun onHandleTapped()
    }

    /** What to show. [second] is null in single presentation. */
    data class Spec(
        val requested: PaneArrangement,
        val first: PaneView,
        val second: PaneView?,
        val focused: PaneView,
        val ratio: Double,
        val dividerDp: Double,
        val draggable: Boolean,
        /** The smallest panes the split is shown with at all. */
        val minWidthDp: Double,
        val minHeightDp: Double,
        /** How small the divider may make a pane; past it, the pane collapses. */
        val dragMinWidthDp: Double,
        val dragMinHeightDp: Double,
        val firstAccent: Int,
        val secondAccent: Int,
        val dividerColor: Int,
        val gripColor: Int,
        val dragPreviewColor: Int,
        val dividerDescription: String,
        val dividerOptionsAction: String,
        /** Identifies the pair, so a drag never outlives the pair it began on. */
        val pairId: String?,
    )

    var listener: Listener? = null

    private var spec: Spec? = null

    /** A ratio committed by a drag, shown until the next state from Dart. */
    private var committedRatio: Double? = null

    private var rects: SplitRects? = null

    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    private val doubleTapTimeout = ViewConfiguration.getDoubleTapTimeout().toLong()

    private val dividerPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val gripPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val previewPaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val gripRect = RectF()

    // Divider stroke in flight.
    private var dividerStream = false
    private var dividerDownX = 0f
    private var dividerDownY = 0f
    private var dragging = false
    private var dragPosition = 0f
    private var dragPairId: String? = null

    // Tap bookkeeping for double-tap on the grip.
    private var lastTapAt = 0L
    private val singleTap = Runnable { listener?.onHandleTapped() }

    private val handle = DividerHandle(context)
    private val focusPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
    }

    init {
        setWillNotDraw(false)
        addView(handle)
    }

    /** Applies a new presentation. Cheap when nothing changed. */
    fun apply(next: Spec) {
        val previous = spec
        if (next == previous) return
        if (previous?.pairId != next.pairId) {
            cancelDividerStream()
        }
        // A committed ratio stands until Dart answers about the ratio itself:
        // a new ratio (the echo, or another change that wins), other panes
        // (a swap mirrors the ratio) or another arrangement. Anything else
        // (focus, colors, labels) arriving first would snap the divider back.
        if (previous == null ||
            previous.pairId != next.pairId ||
            previous.ratio != next.ratio ||
            previous.requested != next.requested ||
            previous.first !== next.first ||
            previous.second !== next.second
        ) {
            committedRatio = null
        }
        spec = next
        handle.contentDescription = next.dividerDescription
        requestLayout()
        invalidate()
    }

    /** Cancels a divider stroke in flight; it commits nothing. */
    fun cancelDividerStream() {
        if (!dividerStream && !dragging) return
        dividerStream = false
        dragging = false
        dragPairId = null
        removeCallbacks(singleTap)
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        setMeasuredDimension(width, height)

        val current = spec
        if (current == null) {
            rects = null
            handle.visibility = View.GONE
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (child === handle) continue
                child.measure(
                    MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY),
                )
            }
            return
        }

        val dividerPx = dp(current.dividerDp)
        val minWidthPx = dp(current.minWidthDp)
        val minHeightPx = dp(current.minHeightDp)
        val requested = if (current.second == null) PaneArrangement.SINGLE else current.requested
        val effective = SplitGeometry.effectiveArrangement(
            requested,
            width,
            height,
            dividerPx,
            minWidthPx,
            minHeightPx,
        )
        val computed = SplitGeometry.rects(
            effective,
            width,
            height,
            committedRatio ?: current.ratio,
            dividerPx,
            dp(current.dragMinWidthDp),
            dp(current.dragMinHeightDp),
        )
        rects = computed

        val shown = shownPanes(current, effective)
        for (i in 0 until childCount) {
            val pane = getChildAt(i) as? PaneView ?: continue
            val bounds = shown[pane]
            if (bounds == null) {
                pane.setPaneShown(false)
                pane.setFocusOutline(null)
                continue
            }
            pane.setPaneShown(true)
            pane.setFocusOutline(
                when {
                    effective == PaneArrangement.SINGLE -> null
                    pane !== current.focused -> null
                    pane === current.first -> current.firstAccent
                    else -> current.secondAccent
                },
            )
            pane.measure(
                MeasureSpec.makeMeasureSpec(bounds.width, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(bounds.height, MeasureSpec.EXACTLY),
            )
        }
        val divider = computed.divider
        if (divider == null) {
            if (handle.hasFocus()) handle.clearFocus()
            handle.visibility = View.GONE
        } else {
            handle.visibility = View.VISIBLE
            handle.measure(
                MeasureSpec.makeMeasureSpec(divider.width, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(divider.height, MeasureSpec.EXACTLY),
            )
        }
        if (effective == PaneArrangement.SINGLE) {
            cancelDividerStream()
        }
    }

    private fun shownPanes(current: Spec, effective: PaneArrangement): Map<PaneView, PaneBounds> {
        val computed = rects ?: return emptyMap()
        return if (effective == PaneArrangement.SINGLE) {
            mapOf(current.focused to computed.first)
        } else {
            buildMap {
                put(current.first, computed.first)
                current.second?.let { second -> computed.second?.let { put(second, it) } }
            }
        }
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val current = spec
        if (current == null) {
            for (i in 0 until childCount) {
                val child = getChildAt(i)
                if (child === handle) continue
                child.layout(0, 0, r - l, b - t)
            }
            return
        }
        val effective = rects?.arrangement ?: return
        val shown = shownPanes(current, effective)
        shown.forEach { (pane, bounds) ->
            pane.layout(bounds.left, bounds.top, bounds.right, bounds.bottom)
        }
        rects?.divider?.let { handle.layout(it.left, it.top, it.right, it.bottom) }
    }

    override fun dispatchDraw(canvas: Canvas) {
        super.dispatchDraw(canvas)

        val current = spec ?: return
        val computed = rects ?: return
        val divider = computed.divider ?: return

        dividerPaint.color = current.dividerColor
        canvas.drawRect(
            divider.left.toFloat(),
            divider.top.toFloat(),
            divider.right.toFloat(),
            divider.bottom.toFloat(),
            dividerPaint,
        )

        if (current.draggable) {
            val centerX = (divider.left + divider.right) / 2f
            val centerY = (divider.top + divider.bottom) / 2f
            val thickness = dp(GRIP_THICKNESS_DP).toFloat()
            val length = dp(GRIP_LENGTH_DP).toFloat()
            if (computed.arrangement == PaneArrangement.SIDE_BY_SIDE) {
                gripRect.set(
                    centerX - thickness / 2,
                    centerY - length / 2,
                    centerX + thickness / 2,
                    centerY + length / 2,
                )
            } else {
                gripRect.set(
                    centerX - length / 2,
                    centerY - thickness / 2,
                    centerX + length / 2,
                    centerY + thickness / 2,
                )
            }
            gripPaint.color = current.gripColor
            canvas.drawRoundRect(gripRect, thickness / 2, thickness / 2, gripPaint)
        }

        if (handle.isFocused) {
            focusPaint.color = current.dragPreviewColor
            focusPaint.strokeWidth = dp(FOCUS_RING_DP).toFloat()
            val inset = focusPaint.strokeWidth / 2
            canvas.drawRect(
                divider.left + inset,
                divider.top + inset,
                divider.right - inset,
                divider.bottom - inset,
                focusPaint,
            )
        }

        if (dragging) {
            previewPaint.color = current.dragPreviewColor
            val half = dp(PREVIEW_DP) / 2f
            val position = clampedDragPosition(current, computed)
            if (computed.arrangement == PaneArrangement.SIDE_BY_SIDE) {
                canvas.drawRect(position - half, 0f, position + half, height.toFloat(), previewPaint)
            } else {
                canvas.drawRect(0f, position - half, width.toFloat(), position + half, previewPaint)
            }
        }
    }

    /** The axis length and the drag minimum along it, in pixels. */
    private fun dragAxis(current: Spec, sideBySide: Boolean): Pair<Int, Int> =
        if (sideBySide) {
            width to dp(current.dragMinWidthDp)
        } else {
            height to dp(current.dragMinHeightDp)
        }

    /**
     * The preview line position, kept where a release would put the divider:
     * at the edge while a release would collapse a pane.
     */
    private fun clampedDragPosition(current: Spec, computed: SplitRects): Float {
        val dividerPx = dp(current.dividerDp)
        val (axis, min) = dragAxis(current, computed.arrangement == PaneArrangement.SIDE_BY_SIDE)
        when (SplitGeometry.collapsedSlot(dragPosition, axis, dividerPx, min)) {
            0 -> return 0f
            1 -> return axis.toFloat()
        }
        val ratio = SplitGeometry.ratioForPosition(dragPosition, axis, dividerPx, min)
        return (ratio * (axis - dividerPx)).toFloat() + dividerPx / 2f
    }

    // Input --------------------------------------------------------------

    /**
     * Whether a stroke at screen coordinates ([rawX], [rawY]) would go to the
     * divider. The drawn-gesture recognizer asks this, so a divider drag never
     * also feeds a gesture.
     */
    fun isDividerHitOnScreen(rawX: Float, rawY: Float): Boolean {
        if (!isShown) return false
        val location = IntArray(2)
        getLocationOnScreen(location)
        return isDividerHit(rawX - location[0], rawY - location[1])
    }

    private fun isDividerHit(x: Float, y: Float): Boolean {
        val current = spec ?: return false
        val computed = rects ?: return false
        if (computed.divider == null) return false
        return SplitGeometry.isDividerHit(
            computed,
            x,
            y,
            gripZonePx = dp(GRIP_ZONE_DP),
            gripReachPx = if (current.draggable) dp(GRIP_REACH_DP) else 0,
        )
    }

    private fun paneAt(x: Float, y: Float): PaneView? {
        for (i in 0 until childCount) {
            val pane = getChildAt(i) as? PaneView ?: continue
            if (pane.visibility != View.VISIBLE) continue
            if (x >= pane.left && x < pane.right && y >= pane.top && y < pane.bottom) {
                return pane
            }
        }
        return null
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                if (isDividerHit(ev.x, ev.y)) {
                    dividerStream = true
                    dragging = false
                    dividerDownX = ev.x
                    dividerDownY = ev.y
                    dragPairId = spec?.pairId
                    parent?.requestDisallowInterceptTouchEvent(true)
                    return true
                }
                dividerStream = false
                paneAt(ev.x, ev.y)?.let { listener?.onPaneTouched(it) }
            }

            MotionEvent.ACTION_POINTER_DOWN -> if (!dividerStream) {
                val index = ev.actionIndex
                paneAt(ev.getX(index), ev.getY(index))?.let { listener?.onPaneTouched(it) }
            }
        }

        if (dividerStream) {
            onDividerEvent(ev)
            return true
        }
        return super.dispatchTouchEvent(ev)
    }

    private fun onDividerEvent(ev: MotionEvent) {
        val current = spec
        val computed = rects
        if (current == null || computed == null || current.pairId != dragPairId) {
            cancelDividerStream()
            return
        }
        val sideBySide = computed.arrangement == PaneArrangement.SIDE_BY_SIDE

        when (ev.actionMasked) {
            MotionEvent.ACTION_MOVE -> {
                if (!current.draggable) return
                val distance = if (sideBySide) ev.x - dividerDownX else ev.y - dividerDownY
                if (!dragging && abs(distance) > touchSlop) {
                    dragging = true
                    removeCallbacks(singleTap)
                }
                if (dragging) {
                    dragPosition = if (sideBySide) ev.x else ev.y
                    invalidate()
                }
            }

            MotionEvent.ACTION_UP -> {
                if (dragging) {
                    // The release decides, not the last move: the two can fall
                    // on opposite sides of the collapse threshold.
                    dragPosition = if (sideBySide) ev.x else ev.y
                    val dividerPx = dp(current.dividerDp)
                    val (axis, min) = dragAxis(current, sideBySide)
                    val kept = when (SplitGeometry.collapsedSlot(dragPosition, axis, dividerPx, min)) {
                        0 -> current.second
                        1 -> current.first
                        else -> null
                    }
                    if (kept != null) {
                        // No ratio: showing both again brings the last one back.
                        listener?.onDividerCollapsed(kept)
                    } else {
                        val ratio = SplitGeometry.snap(
                            SplitGeometry.ratioForPosition(dragPosition, axis, dividerPx, min),
                        )
                        commitRatio(if (sideBySide) SplitAxis.SIDE_BY_SIDE else SplitAxis.STACKED, ratio)
                    }
                } else if (SplitGeometry.isGripHit(computed, ev.x, ev.y, dp(GRIP_ZONE_DP))) {
                    onGripTap(sideBySide)
                }
                dividerStream = false
                dragging = false
                dragPairId = null
                invalidate()
            }

            MotionEvent.ACTION_CANCEL -> cancelDividerStream()
        }
    }

    private fun onGripTap(sideBySide: Boolean) {
        val now = SystemClock.uptimeMillis()
        if (now - lastTapAt <= doubleTapTimeout) {
            lastTapAt = 0L
            removeCallbacks(singleTap)
            if (spec?.draggable == true) {
                commitRatio(if (sideBySide) SplitAxis.SIDE_BY_SIDE else SplitAxis.STACKED, 0.5)
            }
        } else {
            lastTapAt = now
            postDelayed(singleTap, doubleTapTimeout)
        }
    }

    private fun commitRatio(axis: SplitAxis, ratio: Double) {
        committedRatio = ratio
        requestLayout()
        invalidate()
        listener?.onRatioCommitted(axis, ratio)
    }

    override fun onResolvePointerIcon(event: MotionEvent, pointerIndex: Int): PointerIcon? {
        val current = spec
        val computed = rects
        if (current != null && computed?.divider != null && current.draggable &&
            computed.divider.contains(event.getX(pointerIndex), event.getY(pointerIndex))
        ) {
            val type = if (computed.arrangement == PaneArrangement.SIDE_BY_SIDE) {
                PointerIcon.TYPE_HORIZONTAL_DOUBLE_ARROW
            } else {
                PointerIcon.TYPE_VERTICAL_DOUBLE_ARROW
            }
            return PointerIcon.getSystemIcon(context, type)
        }
        return super.onResolvePointerIcon(event, pointerIndex)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        cancelDividerStream()
    }

    private fun dp(value: Double): Int =
        TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            resources.displayMetrics,
        ).roundToInt()

    private fun dp(value: Float): Int = dp(value.toDouble())

    /** The axis the divider moves on in the current arrangement, if any. */
    private fun dividerAxis(): SplitAxis? = when (rects?.arrangement) {
        PaneArrangement.SIDE_BY_SIDE -> SplitAxis.SIDE_BY_SIDE
        PaneArrangement.STACKED -> SplitAxis.STACKED
        else -> null
    }

    private fun currentRatio(): Double? {
        val current = spec ?: return null
        return committedRatio ?: current.ratio
    }

    /**
     * Commits [ratio] (the first pane's share), clamped to the drag minimum.
     * The keyboard and accessibility path of a divider drag; it never
     * collapses a pane (the controls offer "Show only this page" for that).
     */
    private fun commitRatioClamped(ratio: Double): Boolean {
        val current = spec ?: return false
        if (!current.draggable) return false
        val axis = dividerAxis() ?: return false
        val dividerPx = dp(current.dividerDp)
        val (axisLength, min) = dragAxis(current, axis == SplitAxis.SIDE_BY_SIDE)
        val available = axisLength - dividerPx
        if (available <= 0) return false
        val position = (ratio * available).toFloat() + dividerPx / 2f
        commitRatio(axis, SplitGeometry.ratioForPosition(position, axisLength, dividerPx, min))
        return true
    }

    private fun stepRatio(delta: Double): Boolean {
        val ratio = currentRatio() ?: return false
        return commitRatioClamped(ratio + delta)
    }

    /**
     * The divider for accessibility services and the keyboard: one focusable,
     * childless view over the gap, announced as an adjustable control.
     *
     * - TalkBack: swipe up/down moves it by a tenth, "set progress" places it,
     *   and a custom action opens the split view controls. While it sits on a
     *   hinge only that action is offered.
     * - Keyboard: it takes part in focus traversal between the panes; the
     *   arrow keys along its axis move it by a tenth, Enter or Space opens the
     *   controls.
     *
     * Touch never reaches it: the layout keeps divider strokes for itself.
     */
    private inner class DividerHandle(context: Context) : View(context) {
        init {
            isFocusable = true
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
            visibility = View.GONE
            ViewCompat.setAccessibilityDelegate(this, Delegate())
        }

        override fun getAccessibilityClassName(): CharSequence = "android.widget.SeekBar"

        override fun onFocusChanged(gainFocus: Boolean, direction: Int, previouslyFocusedRect: Rect?) {
            super.onFocusChanged(gainFocus, direction, previouslyFocusedRect)
            this@SplitPaneLayout.invalidate()
        }

        override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
            val axis = dividerAxis() ?: return super.onKeyDown(keyCode, event)
            val sideBySide = axis == SplitAxis.SIDE_BY_SIDE
            val handled = when (keyCode) {
                KeyEvent.KEYCODE_DPAD_LEFT -> sideBySide && stepRatio(-A11Y_STEP)
                KeyEvent.KEYCODE_DPAD_RIGHT -> sideBySide && stepRatio(A11Y_STEP)
                KeyEvent.KEYCODE_DPAD_UP -> !sideBySide && stepRatio(-A11Y_STEP)
                KeyEvent.KEYCODE_DPAD_DOWN -> !sideBySide && stepRatio(A11Y_STEP)
                KeyEvent.KEYCODE_ENTER,
                KeyEvent.KEYCODE_NUMPAD_ENTER,
                KeyEvent.KEYCODE_DPAD_CENTER,
                KeyEvent.KEYCODE_SPACE -> {
                    listener?.onHandleTapped()
                    true
                }
                else -> false
            }
            // Arrows across the axis keep moving focus to the next view.
            return handled || super.onKeyDown(keyCode, event)
        }

        private inner class Delegate : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(
                host: View,
                info: AccessibilityNodeInfoCompat,
            ) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                val current = spec ?: return
                info.className = "android.widget.SeekBar"
                info.contentDescription = current.dividerDescription
                info.addAction(
                    AccessibilityActionCompat(
                        R.id.split_divider_options_action,
                        current.dividerOptionsAction,
                    ),
                )
                if (current.draggable) {
                    info.rangeInfo = RangeInfoCompat.obtain(
                        RangeInfoCompat.RANGE_TYPE_PERCENT,
                        0f,
                        100f,
                        ((currentRatio() ?: 0.5) * 100).toFloat(),
                    )
                    info.addAction(AccessibilityActionCompat.ACTION_SCROLL_FORWARD)
                    info.addAction(AccessibilityActionCompat.ACTION_SCROLL_BACKWARD)
                    info.addAction(AccessibilityActionCompat.ACTION_SET_PROGRESS)
                }
            }

            override fun performAccessibilityAction(host: View, action: Int, args: Bundle?): Boolean {
                val handled = when (action) {
                    R.id.split_divider_options_action -> {
                        listener?.onHandleTapped()
                        true
                    }
                    AccessibilityNodeInfoCompat.ACTION_SCROLL_FORWARD -> stepRatio(A11Y_STEP)
                    AccessibilityNodeInfoCompat.ACTION_SCROLL_BACKWARD -> stepRatio(-A11Y_STEP)
                    android.R.id.accessibilityActionSetProgress -> {
                        val progress = args?.getFloat(
                            AccessibilityNodeInfoCompat.ACTION_ARGUMENT_PROGRESS_VALUE,
                        )
                        progress != null && commitRatioClamped(progress / 100.0)
                    }
                    else -> return super.performAccessibilityAction(host, action, args)
                }
                if (handled) {
                    host.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_SELECTED)
                }
                return handled
            }
        }
    }

    companion object {
        private const val A11Y_STEP = 0.1
        private const val FOCUS_RING_DP = 2f
        private const val GRIP_THICKNESS_DP = 4f
        private const val GRIP_LENGTH_DP = 32f
        private const val GRIP_ZONE_DP = 48f
        private const val GRIP_REACH_DP = 20f
        private const val PREVIEW_DP = 2f
    }
}
