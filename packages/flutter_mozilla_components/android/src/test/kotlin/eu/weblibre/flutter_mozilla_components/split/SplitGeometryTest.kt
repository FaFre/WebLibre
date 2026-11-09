/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class SplitGeometryTest {
    private fun rects(
        arrangement: PaneArrangement,
        width: Int = 1000,
        height: Int = 600,
        ratio: Double = 0.5,
        divider: Int = 10,
        minWidth: Int = 200,
        minHeight: Int = 100,
    ) = SplitGeometry.rects(arrangement, width, height, ratio, divider, minWidth, minHeight)

    @Test
    fun sideBySideSplitsTheWidthAroundTheDivider() {
        val r = rects(PaneArrangement.SIDE_BY_SIDE, ratio = 0.5)
        assertEquals(PaneBounds(0, 0, 495, 600), r.first)
        assertEquals(PaneBounds(495, 0, 505, 600), r.divider)
        assertEquals(PaneBounds(505, 0, 1000, 600), r.second)
    }

    @Test
    fun stackedSplitsTheHeight() {
        val r = rects(PaneArrangement.STACKED, ratio = 0.25)
        assertEquals(PaneBounds(0, 0, 1000, 148), r.first)
        assertEquals(PaneBounds(0, 158, 1000, 600), r.second)
    }

    @Test
    fun ratiosAreClampedToTheMinimumPaneSize() {
        assertEquals(200, rects(PaneArrangement.SIDE_BY_SIDE, ratio = 0.01).first.width)
        assertEquals(200, rects(PaneArrangement.SIDE_BY_SIDE, ratio = 0.99).second!!.width)
    }

    @Test
    fun singleFillsTheLayout() {
        val r = rects(PaneArrangement.SINGLE)
        assertEquals(PaneBounds(0, 0, 1000, 600), r.first)
        assertNull(r.second)
        assertNull(r.divider)
    }

    @Test
    fun aSplitThatNoLongerFitsShowsTheFocusedPaneAlone() {
        // Stale geometry: Dart asked for side by side at a width that shrank.
        assertEquals(
            PaneArrangement.SINGLE,
            SplitGeometry.effectiveArrangement(PaneArrangement.SIDE_BY_SIDE, 409, 600, 10, 200, 100),
        )
        assertEquals(
            PaneArrangement.SIDE_BY_SIDE,
            SplitGeometry.effectiveArrangement(PaneArrangement.SIDE_BY_SIDE, 410, 600, 10, 200, 100),
        )
        // Never the other axis by itself, even where it would fit.
        assertEquals(
            PaneArrangement.SINGLE,
            SplitGeometry.effectiveArrangement(PaneArrangement.STACKED, 1000, 209, 10, 200, 100),
        )
    }

    @Test
    fun releaseNearEqualSizesSnaps() {
        assertEquals(0.5, SplitGeometry.snap(0.52))
        assertEquals(0.5, SplitGeometry.snap(0.47))
        assertEquals(0.6, SplitGeometry.snap(0.6))
    }

    @Test
    fun dragPositionMapsToAClampedRatio() {
        assertEquals(0.5, SplitGeometry.ratioForPosition(505f, 1010, 10, 200))
        assertEquals(200.0 / 1000, SplitGeometry.ratioForPosition(3f, 1010, 10, 200))
        assertEquals(800.0 / 1000, SplitGeometry.ratioForPosition(1009f, 1010, 10, 200))
    }

    @Test
    fun aReleaseWithinHalfTheDragMinimumOfAnEdgeCollapsesThatPane() {
        // 1010 long, a 10 divider: 1000 to share; a 200 minimum collapses
        // below 100.
        assertEquals(0, SplitGeometry.collapsedSlot(104f, 1010, 10, 200))
        assertEquals(null, SplitGeometry.collapsedSlot(106f, 1010, 10, 200))
        assertEquals(1, SplitGeometry.collapsedSlot(1006f - 100f, 1010, 10, 200))
        assertEquals(null, SplitGeometry.collapsedSlot(505f, 1010, 10, 200))
        assertEquals(null, SplitGeometry.collapsedSlot(3f, 10, 10, 200))
    }

    @Test
    fun dividerHitZoneReachesIntoThePanesOnlyAroundTheGrip() {
        val r = rects(PaneArrangement.SIDE_BY_SIDE)
        // On the gap anywhere.
        assertTrue(SplitGeometry.isDividerHit(r, 500f, 10f, 48, 20))
        // Next to the gap, at the grip's height.
        assertTrue(SplitGeometry.isDividerHit(r, 480f, 300f, 48, 20))
        // Next to the gap, far from the grip: that belongs to the page.
        assertFalse(SplitGeometry.isDividerHit(r, 480f, 10f, 48, 20))
        // Too far into the pane.
        assertFalse(SplitGeometry.isDividerHit(r, 470f, 300f, 48, 20))
        // Single presentation has no divider.
        assertFalse(SplitGeometry.isDividerHit(rects(PaneArrangement.SINGLE), 500f, 300f, 48, 20))
    }
}
