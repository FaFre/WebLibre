/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.content.Context
import android.graphics.Bitmap
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import eu.weblibre.flutter_mozilla_components.pigeons.SplitAxis
import kotlin.test.assertEquals
import kotlin.test.assertSame
import kotlin.test.assertTrue
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

internal class InertEngineView(context: Context) : FrameLayout(context), EngineView {
    override fun render(session: EngineSession) = Unit
    override fun release() = Unit
    override val verticalScrollPosition: Flow<Float> = emptyFlow()
    override val verticalScrollDelta: Flow<Float> = emptyFlow()
    override fun captureThumbnail(onFinish: (Bitmap?) -> Unit) = onFinish(null)
    override fun setVerticalClipping(clippingHeight: Int) = Unit
    override fun setDynamicToolbarMaxHeight(height: Int) = Unit
    override fun setActivityContext(context: Context?) = Unit
    override fun addWindowInsetsListener(
        key: String,
        listener: androidx.core.view.OnApplyWindowInsetsListener?,
    ) = Unit
    override fun removeWindowInsetsListener(key: String) = Unit
    override var selectionActionDelegate: SelectionActionDelegate? = null
}

/**
 * The divider keeps a committed position until Dart sends a new ratio, and a
 * release at the edge collapses a pane instead of committing one.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class SplitPaneLayoutRatioTest {
    private lateinit var layout: SplitPaneLayout
    private lateinit var first: PaneView
    private lateinit var second: PaneView
    private val committed = mutableListOf<Double>()
    private val collapsedTo = mutableListOf<PaneView>()

    @Before
    fun setUp() {
        val context = RuntimeEnvironment.getApplication()
        layout = SplitPaneLayout(context)
        first = PaneView(context, InertEngineView(context))
        second = PaneView(context, InertEngineView(context))
        layout.listener = object : SplitPaneLayout.Listener {
            override fun onPaneTouched(pane: PaneView) = Unit
            override fun onRatioCommitted(axis: SplitAxis, ratio: Double) {
                committed += ratio
            }
            override fun onDividerCollapsed(kept: PaneView) {
                collapsedTo += kept
            }
            override fun onHandleTapped() = Unit
        }
    }

    private fun spec(
        ratio: Double = 0.5,
        focused: PaneView = first,
        firstPane: PaneView = first,
        secondPane: PaneView = second,
        pairId: String = "pair",
        dragMinDp: Double = 10.0,
    ) = SplitPaneLayout.Spec(
        requested = PaneArrangement.SIDE_BY_SIDE,
        first = firstPane,
        second = secondPane,
        focused = focused,
        ratio = ratio,
        dividerDp = 8.0,
        draggable = true,
        minWidthDp = 10.0,
        minHeightDp = 10.0,
        dragMinWidthDp = dragMinDp,
        dragMinHeightDp = dragMinDp,
        firstAccent = 0,
        secondAccent = 0,
        dividerColor = 0,
        gripColor = 0,
        dragPreviewColor = 0,
        dividerDescription = "Divider",
        dividerOptionsAction = "Options",
        pairId = pairId,
    )

    private fun applyAndLayOut(spec: SplitPaneLayout.Spec) {
        layout.apply(spec)
        layout.measure(
            View.MeasureSpec.makeMeasureSpec(1000, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(800, View.MeasureSpec.EXACTLY),
        )
        layout.layout(0, 0, 1000, 800)
    }

    private val handle: View get() = layout.getChildAt(0)

    /** The divider's position as accessibility reports it, in percent. */
    private fun shownPercent(): Float {
        val info = AccessibilityNodeInfoCompat.obtain()
        ViewCompat.onInitializeAccessibilityNodeInfo(handle, info)
        return info.rangeInfo!!.current
    }

    private fun commitStep() {
        ViewCompat.performAccessibilityAction(
            handle,
            AccessibilityNodeInfoCompat.ACTION_SCROLL_FORWARD,
            null,
        )
        assertEquals(1, committed.size)
    }

    @Test
    fun aFocusChangeBeforeTheEchoKeepsTheCommittedPosition() {
        applyAndLayOut(spec())
        commitStep()
        val position = shownPercent()

        applyAndLayOut(spec(focused = second))

        assertEquals(position, shownPercent())
    }

    @Test
    fun theEchoedRatioTakesOver() {
        applyAndLayOut(spec())
        commitStep()

        applyAndLayOut(spec(ratio = 0.3))

        assertEquals(30f, shownPercent(), 0.01f)
    }

    @Test
    fun aSwapDropsTheCommittedPosition() {
        applyAndLayOut(spec())
        commitStep()

        applyAndLayOut(spec(firstPane = second, secondPane = first))

        assertEquals(50f, shownPercent(), 0.01f)
    }

    /**
     * Drags the divider (at the center, ratio 0.5) to [x] and releases at
     * [releaseX], which a real stroke may report apart from its last move.
     */
    private fun dragDividerTo(x: Float, releaseX: Float = x) {
        val y = 400f
        fun send(action: Int, at: Float) {
            val event = MotionEvent.obtain(0L, 0L, action, at, y, 0)
            layout.dispatchTouchEvent(event)
            event.recycle()
        }
        send(MotionEvent.ACTION_DOWN, 500f)
        send(MotionEvent.ACTION_MOVE, x)
        send(MotionEvent.ACTION_UP, releaseX)
    }

    @Test
    fun aReleaseOutsideTheCollapseZoneAfterAMoveIntoItCommitsARatio() {
        applyAndLayOut(spec(dragMinDp = 120.0))

        dragDividerTo(5f, releaseX = 100f)

        assertTrue(collapsedTo.isEmpty())
        assertEquals(120.0 / 992, committed.single(), 1e-9)
    }

    @Test
    fun aReleaseInsideTheCollapseZoneAfterAMoveOutsideItCollapses() {
        applyAndLayOut(spec(dragMinDp = 120.0))

        dragDividerTo(100f, releaseX = 5f)

        assertEquals(listOf(second), collapsedTo)
        assertTrue(committed.isEmpty())
    }

    @Test
    fun aReleaseAtTheEdgeCollapsesThatPane() {
        applyAndLayOut(spec(dragMinDp = 120.0))

        dragDividerTo(5f)

        assertEquals(listOf(second), collapsedTo)
        assertTrue(committed.isEmpty())
    }

    @Test
    fun aReleaseAtTheOtherEdgeKeepsTheFirstPane() {
        applyAndLayOut(spec(dragMinDp = 120.0))

        dragDividerTo(995f)

        assertSame(first, collapsedTo.single())
        assertTrue(committed.isEmpty())
    }

    @Test
    fun aReleaseBeforeTheCollapseZoneStopsAtTheDragMinimum() {
        applyAndLayOut(spec(dragMinDp = 120.0))

        dragDividerTo(100f)

        assertTrue(collapsedTo.isEmpty())
        // 1000 wide, an 8 dp divider: 992 to share, at least 120 each.
        assertEquals(120.0 / 992, committed.single(), 1e-9)
    }
}
