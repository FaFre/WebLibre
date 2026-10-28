/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * The tracker runs without a looper here: both scheduling seams are replaced so
 * the grace window is fired explicitly rather than waited out.
 */
class TextSelectionTrackerTest {
    private var scheduledDelayMs: Long? = null

    private lateinit var originalSchedule: (Long) -> Unit
    private lateinit var originalCancel: () -> Unit

    @BeforeTest
    fun setUp() {
        originalSchedule = TextSelectionTracker.scheduleGraceExpiry
        originalCancel = TextSelectionTracker.cancelGraceExpiry

        TextSelectionTracker.scheduleGraceExpiry = { delayMs ->
            scheduledDelayMs = delayMs
        }
        TextSelectionTracker.cancelGraceExpiry = {
            scheduledDelayMs = null
        }

        scheduledDelayMs = null
        TextSelectionTracker.reset()
    }

    @AfterTest
    fun tearDown() {
        TextSelectionTracker.reset()
        TextSelectionTracker.scheduleGraceExpiry = originalSchedule
        TextSelectionTracker.cancelGraceExpiry = originalCancel
    }

    @Test
    fun `selection is active while the action mode is up`() {
        assertFalse(TextSelectionTracker.isActive)

        TextSelectionTracker.onActionModeStarted()

        assertTrue(TextSelectionTracker.isActive)
    }

    @Test
    fun `selection outlives the action mode by the grace window`() {
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()

        // Gecko tears the toolbar down for the duration of a handle drag, so
        // the flag must not follow it down immediately: the next ACTION_DOWN
        // still belongs to the selection.
        assertTrue(TextSelectionTracker.isActive)
        assertEquals(TextSelectionTracker.GRACE_MS, scheduledDelayMs)

        TextSelectionTracker.expireGraceWindow()

        assertFalse(TextSelectionTracker.isActive)
    }

    @Test
    fun `a replacement action mode cancels the pending expiry`() {
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()
        TextSelectionTracker.onActionModeStarted()

        assertTrue(TextSelectionTracker.isActive)
        assertEquals(null, scheduledDelayMs)
    }

    @Test
    fun `overlapping action modes only expire once the last one finishes`() {
        // Selection toolbar replaced by the clipboard-permission mode: the two
        // starts are not balanced against their finishes in order.
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeStarted()

        TextSelectionTracker.onActionModeFinished()
        assertEquals(null, scheduledDelayMs, "expiry scheduled while a mode is still up")

        TextSelectionTracker.onActionModeFinished()
        assertEquals(TextSelectionTracker.GRACE_MS, scheduledDelayMs)

        TextSelectionTracker.expireGraceWindow()
        assertFalse(TextSelectionTracker.isActive)
    }

    @Test
    fun `unbalanced finishes do not drive the count negative`() {
        TextSelectionTracker.onActionModeFinished()
        TextSelectionTracker.onActionModeFinished()

        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()

        // Had the count underflowed, this finish would have left it above zero
        // and the flag stuck true — silently disabling gestures and auto-hide.
        assertEquals(TextSelectionTracker.GRACE_MS, scheduledDelayMs)
        TextSelectionTracker.expireGraceWindow()
        assertFalse(TextSelectionTracker.isActive)
    }

    @Test
    fun `a selection stream ending restarts the grace window`() {
        // A handle drag longer than the grace window: the mode finished on
        // press and its expiry already ran before the finger lifted.
        TextSelectionTracker.onActionModeStarted()
        assertTrue(TextSelectionTracker.onTouchStreamStarted())
        TextSelectionTracker.onActionModeFinished()
        TextSelectionTracker.expireGraceWindow()
        assertFalse(TextSelectionTracker.isActive)

        TextSelectionTracker.onSelectionStreamEnded()

        // Covers the gap until Gecko re-shows the mode after the release.
        assertTrue(TextSelectionTracker.isActive)
        assertEquals(TextSelectionTracker.GRACE_MS, scheduledDelayMs)

        TextSelectionTracker.expireGraceWindow()
        assertFalse(TextSelectionTracker.isActive)
    }

    @Test
    fun `a mode shown during the stream confirms it as a selection interaction`() {
        // A handle re-grabbed on the grace tail, with Gecko's re-show arriving
        // only after the press: the mode is up for part of the stream.
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()
        assertTrue(TextSelectionTracker.onTouchStreamStarted())
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()
        TextSelectionTracker.expireGraceWindow()

        TextSelectionTracker.onSelectionStreamEnded()

        assertTrue(TextSelectionTracker.isActive)
        assertEquals(TextSelectionTracker.GRACE_MS, scheduledDelayMs)
    }

    @Test
    fun `swipes latched on the grace tail alone do not renew it`() {
        // Selection dismissed: only the grace tail is left.
        TextSelectionTracker.onActionModeStarted()
        TextSelectionTracker.onActionModeFinished()

        // A swipe started inside the tail is latched, and outlasts it.
        assertTrue(TextSelectionTracker.onTouchStreamStarted())
        TextSelectionTracker.expireGraceWindow()
        scheduledDelayMs = null

        TextSelectionTracker.onSelectionStreamEnded()

        // Renewing here would let back-to-back swipes keep gestures and
        // auto-hide off indefinitely with no selection left.
        assertFalse(TextSelectionTracker.isActive)
        assertEquals(null, scheduledDelayMs)

        // The next swipe is an ordinary one.
        assertFalse(TextSelectionTracker.onTouchStreamStarted())
    }

    @Test
    fun `a selection stream ending leaves a live action mode alone`() {
        TextSelectionTracker.onActionModeStarted()
        assertTrue(TextSelectionTracker.onTouchStreamStarted())

        TextSelectionTracker.onSelectionStreamEnded()

        // No expiry may be pending while a mode is up, or it would clear the
        // flag under a selection that is still on screen.
        assertTrue(TextSelectionTracker.isActive)
        assertEquals(null, scheduledDelayMs)
    }

    @Test
    fun `reset clears a live selection without waiting for the grace window`() {
        TextSelectionTracker.onActionModeStarted()

        TextSelectionTracker.reset()

        assertFalse(TextSelectionTracker.isActive)
        assertEquals(null, scheduledDelayMs)

        // State is fully dropped, not merely hidden: a later stray finish must
        // not resurrect anything.
        TextSelectionTracker.onActionModeFinished()
        assertFalse(TextSelectionTracker.isActive)
    }
}
