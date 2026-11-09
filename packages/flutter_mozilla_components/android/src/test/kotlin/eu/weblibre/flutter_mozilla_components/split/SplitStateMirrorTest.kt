/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewLabels
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

internal fun splitState(epoch: String, revision: Long, pair: eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState? = null) =
    SplitViewState(
        epoch = epoch,
        revision = revision,
        pair = pair,
        minPaneWidthDp = 280.0,
        minPaneHeightDp = 200.0,
        dragMinPaneWidthDp = 120.0,
        dragMinPaneHeightDp = 100.0,
        dividerColorArgb = 0,
        gripColorArgb = 0,
        dragPreviewColorArgb = 0,
        placeholderColorArgb = 0,
        onPlaceholderColorArgb = 0,
        labels = SplitViewLabels("divider", "options", "crashed", "reload"),
    )

class SplitStateMirrorTest {
    @Test
    fun aLowerOrEqualRevisionInTheSameEpochIsIgnored() {
        val mirror = SplitStateMirrorStore()
        assertTrue(mirror.accept(splitState("e1", 2)))
        assertFalse(mirror.accept(splitState("e1", 2)))
        assertFalse(mirror.accept(splitState("e1", 1)))
        assertEquals(2, mirror.state.value?.revision)
    }

    @Test
    fun aNewEpochTakesOverFromRevisionOne() {
        val mirror = SplitStateMirrorStore()
        mirror.accept(splitState("old", 40))
        assertTrue(mirror.accept(splitState("new", 1)))
        assertEquals("new", mirror.epoch)
    }

    @Test
    fun clearForgetsTheStateAndTellsListeners() {
        val mirror = SplitStateMirrorStore()
        var cleared = 0
        mirror.addClearListener { cleared++ }
        mirror.accept(splitState("e1", 1))
        mirror.clear()
        assertNull(mirror.state.value)
        assertNull(mirror.epoch)
        assertEquals(1, cleared)
        // After a clear any epoch is accepted again, even the old one.
        assertTrue(mirror.accept(splitState("e1", 1)))
    }
}
