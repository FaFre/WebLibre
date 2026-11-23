/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.lock

import android.app.Activity
import android.graphics.drawable.ColorDrawable
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The browser window of a locked profile, from leaving until Dart's lock
 * decision is on screen.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class BrowserLockCoverTest {
    /** Flutter's surface in the window, as the cover sees it. */
    private class FakeSurface : FlutterWindowSurface {
        var preReturnImage = false
        var hasFlutter = true

        /** Whether a surface taken away has been released yet. */
        var released = true
        var taken = false
        var broughtBack = false
        var abandoned = 0
        private var onDrawn: (() -> Unit)? = null

        override fun showsPreReturnImage(decor: ViewGroup) = preReturnImage

        override fun takeAway(decor: ViewGroup): Boolean {
            if (!hasFlutter) return false
            taken = true
            return true
        }

        override fun isGone() = released

        override fun bringBack(onDrawn: () -> Unit) {
            broughtBack = true
            this.onDrawn = onDrawn
        }

        override fun abandon() {
            abandoned++
            taken = false
            broughtBack = false
            onDrawn = null
        }

        /** Flutter reports the first frame drawn on the new surface. */
        fun draw() {
            onDrawn?.also { onDrawn = null }?.invoke()
        }
    }

    /** What the recents-screenshot switch was last set to, per activity. */
    private val recentsScreenshots = mutableMapOf<Activity, Boolean>()

    /** The task background colour last set, per activity. */
    private val taskBackgrounds = mutableMapOf<Activity, Int>()

    /** Steps waiting for a frame or a delay, run by [nextFrame] and [later]. */
    private val frameSteps = ArrayDeque<() -> Unit>()
    private val delayedSteps = ArrayDeque<() -> Unit>()

    private val surface = FakeSurface()
    private var now = 0L

    private fun browser(): Activity =
        Robolectric.buildActivity(Activity::class.java).setup().get().apply {
            setContentView(FrameLayout(this))
        }

    @Before
    fun setUp() {
        BrowserLockCover.resetForTest()
        BrowserLockCover.setRecentsScreenshotEnabled = { activity, enabled ->
            recentsScreenshots[activity] = enabled
        }
        BrowserLockCover.setTaskBackground = { activity, color ->
            taskBackgrounds[activity] = color
        }
        BrowserLockCover.surface = surface
        BrowserLockCover.clock = { now }
        BrowserLockCover.schedule = { delayMs, step ->
            if (delayMs == 0L) frameSteps.addLast(step) else delayedSteps.addLast(step)
        }
    }

    @After
    fun tearDown() {
        BrowserLockCover.resetForTest()
    }

    @Test
    fun anArmedWindowIsCoveredOnLeavingUntilReleased() {
        val activity = startedBrowser()
        BrowserLockCover.arm(true)

        BrowserLockCover.onStop(activity)

        // Drawn over the content, which is the decor's earlier child.
        val decor = activity.window.decorView as ViewGroup
        val cover = decor.getChildAt(decor.childCount - 1)
        assertTrue(BrowserLockCover.isCovered(activity))
        assertFalse(cover is ViewGroup && cover.findViewById<View>(android.R.id.content) != null)
        assertTrue(cover.isClickable, "taps must not reach the stale browser")
        assertEquals(ViewGroup.LayoutParams.MATCH_PARENT, cover.layoutParams.width)
        assertEquals(ViewGroup.LayoutParams.MATCH_PARENT, cover.layoutParams.height)
        assertFalse(BrowserLockCover.showsStalledLock(activity))

        val departure = comeBack(activity)
        assertTrue(BrowserLockCover.isCovered(activity), "coming back is not the decision")

        BrowserLockCover.release(departure, afterFreshFrame = false)
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aWindowNotArmedIsNotCovered() {
        val activity = startedBrowser()

        BrowserLockCover.onStop(activity)
        comeBack(activity)

        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aLockedReturnLiftsOnlyOnAFrameDrawnOnANewSurface() {
        val activity = coveredBrowser()

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)
        assertTrue(surface.taken)

        // Hidden for two frames at least, so its surface is released.
        nextFrame()
        nextFrame()
        assertFalse(surface.broughtBack)
        nextFrame()
        assertTrue(surface.broughtBack)

        repeat(10) { nextFrame() }
        assertTrue(BrowserLockCover.isCovered(activity), "frames counted are no frame drawn")

        surface.draw()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aSurfaceNotReleasedYetIsNotBroughtBack() {
        surface.released = false
        val activity = coveredBrowser()

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)
        repeat(5) { nextFrame() }
        assertFalse(surface.broughtBack)

        surface.released = true
        nextFrame()
        assertTrue(surface.broughtBack)
        surface.draw()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun theSurfaceWaitsWhileFlutterShowsAnImageFromBefore() {
        surface.preReturnImage = true
        val activity = coveredBrowser()

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)
        repeat(3) { nextFrame() }
        assertFalse(surface.taken, "its surface view is paused until the image goes")

        surface.preReturnImage = false
        completeFreshFrame()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aDecisionThatKeptTheProfileOpenDoesNotWait() {
        surface.preReturnImage = true
        val activity = coveredBrowser()

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = false)

        assertFalse(BrowserLockCover.isCovered(activity))
        assertFalse(surface.taken)
    }

    @Test
    fun anUnlockReplacesALockedReleaseThatIsWaiting() {
        // Unlocked from the lock screen while the cover waits for it: the
        // browser draws through Flutter's image view again, which a locked
        // release would wait out for good.
        surface.preReturnImage = true
        val activity = coveredBrowser()
        val departure = comeBack(activity)
        BrowserLockCover.release(departure, afterFreshFrame = true)
        repeat(5) { nextFrame() }
        assertTrue(BrowserLockCover.isCovered(activity))

        BrowserLockCover.release(departure, afterFreshFrame = false)
        assertFalse(BrowserLockCover.isCovered(activity))

        // Nothing of the locked wait runs on.
        surface.preReturnImage = false
        repeat(5) { nextFrame() }
        assertFalse(surface.taken)
    }

    @Test
    fun anUnlockReplacesALockedReleaseWaitingForItsFrame() {
        val activity = coveredBrowser()
        val departure = comeBack(activity)
        BrowserLockCover.release(departure, afterFreshFrame = true)
        repeat(3) { nextFrame() }
        assertTrue(surface.broughtBack)

        BrowserLockCover.release(departure, afterFreshFrame = false)
        assertFalse(BrowserLockCover.isCovered(activity))
        assertFalse(surface.broughtBack, "the surface is given back and no frame is waited for")
    }

    @Test
    fun aCoveredWindowIsHiddenFromAccessibilityAndKeys() {
        val activity = startedBrowser()
        val decor = activity.window.decorView as ViewGroup
        val content = decor.getChildAt(0)
        content.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
        val typed = KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_A)
        val volume = KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_VOLUME_UP)
        assertFalse(BrowserLockCover.consumesKey(activity, typed))

        BrowserLockCover.arm(true)
        BrowserLockCover.onStop(activity)
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS, content.importantForAccessibility)
        assertTrue(BrowserLockCover.consumesKey(activity, typed))
        assertFalse(BrowserLockCover.consumesKey(activity, volume), "system keys still work")

        // Leaving again while covered changes nothing to put back.
        comeBack(activity)
        BrowserLockCover.onStop(activity)

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = false)
        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_YES, content.importantForAccessibility)
        assertFalse(BrowserLockCover.consumesKey(activity, typed))
    }

    @Test
    fun aLeftoverCoverLiftedByANewEngineGivesAccessibilityBack() {
        val activity = coveredBrowser()
        val content = (activity.window.decorView as ViewGroup).getChildAt(0)
        comeBack(activity)

        BrowserLockCover.disarmForNewEngine()
        BrowserLockCover.liftLeftoverCover()

        assertEquals(View.IMPORTANT_FOR_ACCESSIBILITY_AUTO, content.importantForAccessibility)
    }

    @Test
    fun theCoverAndTheTaskTakeTheAppBackground() {
        val activity = startedBrowser()
        BrowserLockCover.setColor(0xFF101418.toInt())
        assertEquals(0xFF101418.toInt(), taskBackgrounds[activity])

        BrowserLockCover.arm(true)
        BrowserLockCover.onStop(activity)
        assertEquals(0xFF101418.toInt(), coverColor(activity))

        // Changed while covered, and opaque whatever Dart sent.
        BrowserLockCover.setColor(0x80FFFFFF.toInt())
        assertEquals(0xFFFFFFFF.toInt(), coverColor(activity))

        // A new window's theme resets the task's colour, so it is set again.
        val recreated = browser()
        BrowserLockCover.attach(recreated)
        assertEquals(0xFFFFFFFF.toInt(), taskBackgrounds[recreated])
    }

    @Test
    fun aWindowWithoutFlutterHasNothingToWaitFor() {
        surface.hasFlutter = false
        val activity = coveredBrowser()

        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)

        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aDrawnFrameThatNeverComesKeepsTheWindowCoveredAndShowsTheLock() {
        val activity = coveredBrowser()
        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)
        repeat(3) { nextFrame() }
        assertTrue(surface.broughtBack)

        now = 1000L
        later()
        assertTrue(BrowserLockCover.isCovered(activity))
        assertTrue(BrowserLockCover.showsStalledLock(activity))

        // However long it takes, time alone never lifts it.
        now = 60_000L
        later()
        repeat(10) { nextFrame() }
        assertTrue(BrowserLockCover.isCovered(activity))

        surface.draw()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun anImageViewThatStaysKeepsTheWindowCoveredAndShowsTheLock() {
        surface.preReturnImage = true
        val activity = coveredBrowser()
        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)

        now = 999L
        nextFrame()
        assertFalse(BrowserLockCover.showsStalledLock(activity))
        now = 1000L
        nextFrame()
        assertTrue(BrowserLockCover.showsStalledLock(activity))
        now = 60_000L
        later()
        assertTrue(BrowserLockCover.isCovered(activity))

        // Past the stall, the steps run on the slower watch.
        surface.preReturnImage = false
        repeat(4) { later() }
        assertTrue(surface.broughtBack)
        surface.draw()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun leavingWhileWaitingGivesTheSurfaceBackAndKeepsTheCover() {
        val activity = coveredBrowser()
        BrowserLockCover.release(comeBack(activity), afterFreshFrame = true)
        repeat(3) { nextFrame() }
        val abandonedBefore = surface.abandoned

        BrowserLockCover.onStop(activity)
        assertTrue(surface.abandoned > abandonedBefore, "the activity saves the Flutter view's state next")

        surface.draw()
        repeat(3) { nextFrame() }
        assertTrue(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aWindowRecreatedWhileAReleaseWaitsIsCoveredUntilItCompletes() {
        // Locked on leaving, so disarmed: no stop puts a cover up again.
        val old = coveredBrowser()
        BrowserLockCover.arm(false)
        BrowserLockCover.release(comeBack(old), afterFreshFrame = true)
        repeat(3) { nextFrame() }
        assertTrue(surface.broughtBack)

        val recreated = browser()
        BrowserLockCover.attach(recreated)
        BrowserLockCover.onStart(recreated)
        BrowserLockCover.onStop(old)
        assertTrue(BrowserLockCover.isCovered(recreated), "the release has not completed")

        // Started over on the new window: a frame reported for the old one
        // does not count.
        surface.draw()
        assertTrue(BrowserLockCover.isCovered(recreated))

        completeFreshFrame()
        assertFalse(BrowserLockCover.isCovered(recreated))

        // Done: the next window is not covered again.
        BrowserLockCover.onStop(recreated)
        comeBack(recreated)
        assertFalse(BrowserLockCover.isCovered(recreated))
    }

    @Test
    fun aNewWindowStartedWhileCoveredIsCoveredToo() {
        val old = coveredBrowser()

        val recreated = browser()
        BrowserLockCover.attach(recreated)
        val departure = comeBack(recreated)
        assertTrue(BrowserLockCover.isCovered(recreated))

        // The old window stopping after its successor started is no departure.
        BrowserLockCover.onStop(old)
        assertEquals(departure, BrowserLockCover.currentDeparture())

        BrowserLockCover.release(departure, afterFreshFrame = true)
        completeFreshFrame()
        assertFalse(BrowserLockCover.isCovered(recreated))
    }

    @Test
    fun disarmingKeepsACoverThatIsUpUntilRelease() {
        // The profile locked on leaving: the browser is still behind the
        // cover until Dart draws the lock screen.
        val activity = coveredBrowser()

        BrowserLockCover.arm(false)
        val departure = comeBack(activity)
        assertTrue(BrowserLockCover.isCovered(activity))

        BrowserLockCover.release(departure, afterFreshFrame = true)
        completeFreshFrame()
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun leavingTwiceAddsOneCover() {
        val activity = coveredBrowser()
        val decor = activity.window.decorView as ViewGroup
        val children = decor.childCount

        comeBack(activity)
        BrowserLockCover.onStop(activity)
        comeBack(activity)

        assertEquals(children, decor.childCount)
    }

    @Test
    fun recentsScreenshotsFollowTheArmingAndApplyToANewWindow() {
        val activity = startedBrowser()
        assertEquals(true, recentsScreenshots[activity])

        BrowserLockCover.arm(true)
        assertEquals(false, recentsScreenshots[activity])

        val recreated = browser()
        BrowserLockCover.attach(recreated)
        assertEquals(false, recentsScreenshots[recreated])

        BrowserLockCover.arm(false)
        assertEquals(true, recentsScreenshots[recreated])
    }

    @Test
    fun thereIsNoDepartureWhileTheWindowIsOutOfSight() {
        val activity = coveredBrowser()

        assertNull(BrowserLockCover.currentDeparture())
        comeBack(activity)
        assertEquals(1L, BrowserLockCover.currentDeparture())
    }

    @Test
    fun aReleaseArrivingAfterTheWindowLeftAgainKeepsTheNewerCover() {
        // A timeout-mode return approved just before leaving again: its
        // release must not uncover the departure after it.
        val activity = coveredBrowser()
        val approved = comeBack(activity)

        BrowserLockCover.onStop(activity)
        BrowserLockCover.release(approved, afterFreshFrame = false)
        assertTrue(BrowserLockCover.isCovered(activity))

        // Nor once the window is back: that return decides for itself.
        val newer = comeBack(activity)
        BrowserLockCover.release(approved, afterFreshFrame = false)
        assertTrue(BrowserLockCover.isCovered(activity))

        BrowserLockCover.release(newer, afterFreshFrame = false)
        assertFalse(BrowserLockCover.isCovered(activity))
    }

    @Test
    fun aNewEngineLiftsALeftoverCover() {
        val activity = coveredBrowser()
        comeBack(activity)

        BrowserLockCover.disarmForNewEngine()
        BrowserLockCover.liftLeftoverCover()

        assertFalse(BrowserLockCover.isCovered(activity))
        assertEquals(true, recentsScreenshots[activity])
        BrowserLockCover.onStop(activity)
        assertFalse(BrowserLockCover.isCovered(activity), "disarmed until the new engine arms it")
    }

    @Test
    fun aNewEngineLeavesTheCoverOfItsOwnArming() {
        val activity = startedBrowser()
        BrowserLockCover.disarmForNewEngine()

        // The new engine's profile was unlocked and left before the lift arrived.
        BrowserLockCover.arm(true)
        BrowserLockCover.onStop(activity)
        BrowserLockCover.liftLeftoverCover()

        assertTrue(BrowserLockCover.isCovered(activity))
    }

    private fun startedBrowser(): Activity = browser().also {
        BrowserLockCover.attach(it)
        BrowserLockCover.onStart(it)
    }

    private fun coveredBrowser(): Activity = startedBrowser().also {
        BrowserLockCover.arm(true)
        BrowserLockCover.onStop(it)
    }

    /** Starts [activity] again, and answers what Dart asks before deciding. */
    private fun comeBack(activity: Activity): Long {
        BrowserLockCover.onStart(activity)
        return BrowserLockCover.currentDeparture()!!
    }

    private fun coverColor(activity: Activity): Int {
        val decor = activity.window.decorView as ViewGroup
        return (decor.getChildAt(decor.childCount - 1).background as ColorDrawable).color
    }

    /** Runs frames until the surface is back, then reports a frame drawn on it. */
    private fun completeFreshFrame() {
        repeat(10) { if (!surface.broughtBack) nextFrame() }
        assertTrue(surface.broughtBack)
        surface.draw()
    }

    /** Runs what waited for this frame; what it asks for runs on the next. */
    private fun nextFrame() {
        repeat(frameSteps.size) { frameSteps.removeFirst()() }
    }

    /** Runs what waited for a delay. */
    private fun later() {
        repeat(delayedSteps.size) { delayedSteps.removeFirst()() }
    }
}
