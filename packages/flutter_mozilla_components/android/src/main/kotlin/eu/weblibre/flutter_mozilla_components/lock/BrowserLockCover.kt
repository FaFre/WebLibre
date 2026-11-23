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
import android.app.ActivityManager
import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.util.TypedValue
import android.view.Choreographer
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.annotation.MainThread
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.R
import java.lang.ref.WeakReference

/**
 * Keeps a locked profile's browser off the screen from the moment it leaves
 * until Dart has drawn its lock decision.
 *
 * The lock is Dart's (`ProfileAuthState`), and Dart can only show the lock
 * screen once it draws again. What the window and the system show before
 * that is the browser as it was left:
 *
 * - Android's task snapshot, the screenshot taken on leaving. It is the
 *   recents thumbnail, and the window that grows from the launcher icon on
 *   the way back, until the app's own window has drawn. While [arm]ed it is
 *   not a screenshot: `setRecentsScreenshotEnabled(false)` makes the system
 *   paint the task's background colour instead. Android 13 and later only;
 *   before that only `FLAG_SECURE` does it, which the screenshot protection
 *   setting already offers.
 * - The window's own first frames: Flutter's last image and the engine's
 *   surface come back with the window, before Dart has drawn anything. An
 *   opaque view on top of the decor covers both. The engine's `SurfaceView`
 *   sits under the window's views (see `EngineViewVisibility`), and the window
 *   redraws before Android shows it again, so the cover is in its first frame.
 *   Touches, keys and accessibility services do not get past it either.
 *
 * Both are painted in the app's background colour once Dart sends it
 * ([setColor]): the window's theme follows the system's day and night, not
 * the app's theme setting.
 *
 * Dart arms this while the profile is open and a lock applies on some return,
 * and [release]s the cover once its decision is on screen: the lock screen,
 * or the browser if the unlock still holds. Each departure has a number
 * ([currentDeparture]), and a release lifts only the cover of the departure
 * Dart decided for.
 *
 * Process-wide, like the browser's lock: a cover put up for one activity is
 * put back on a new one ([onStart]). A new Flutter engine disarms it as it
 * starts and lifts what an engine before it left behind
 * ([liftLeftoverCover]), since nothing of the profile is on its screen.
 * Called on the main thread only, by `MainActivity` and the Pigeon handlers.
 */
@MainThread
object BrowserLockCover {
    private const val TAG = "BrowserLockCover"

    /**
     * How long a release waits for Flutter before the cover shows a lock and
     * watches less often. Flutter takes a few frames; see [release].
     */
    private const val STALLED_AFTER_MS = 1000L
    private const val STALLED_POLL_MS = 250L

    /**
     * Frames the surface stays hidden at least. Steps run before the frame's
     * traversal, where a hidden surface view releases its surface, so the
     * first step after hiding can come before the release.
     */
    private const val HIDDEN_FRAMES = 2

    private const val OPAQUE = 0xFF000000.toInt()

    /** Material's secondary text greys, for the lock on a dark or a light cover. */
    private const val LOCK_ON_DARK = 0xB3FFFFFF.toInt()
    private const val LOCK_ON_LIGHT = 0x8A000000.toInt()

    private var armed = false

    /** Whether something this engine runs armed the cover since [disarmForNewEngine]. */
    private var armedSinceNewEngine = false
    private var covered = false
    private var activity: WeakReference<Activity>? = null

    /** Whether the browser window is between its start and its stop. */
    private var started = false

    /** Counts the browser window's departures; see [currentDeparture]. */
    private var departures = 0L

    /** A release waiting for a frame drawn since the decision; see [release]. */
    private class Attempt(val departure: Long, val since: Long) {
        /** Bumped when the attempt starts over; steps of an earlier round stop. */
        var round = 0
        var surfaceTaken = false
        var hiddenFrames = 0
        var waitingForFrame = false
    }

    private var attempt: Attempt? = null

    /** The app's background colour, opaque; null until Dart sends it ([setColor]). */
    private var color: Int? = null

    /** Tags the cover view, so the decor can tell it apart from its content. */
    private val coverTag = Any()

    /** Tags the lock a stalled cover shows. */
    private val lockTag = Any()

    private val systemRecentsScreenshot: (Activity, Boolean) -> Unit = { activity, enabled ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.setRecentsScreenshotEnabled(enabled)
        }
    }

    @VisibleForTesting
    internal var setRecentsScreenshotEnabled = systemRecentsScreenshot

    /**
     * The colour the system paints instead of a screenshot of the window
     * (Android 13 and later, where [arm] turns screenshots off). The activity
     * takes its task description's background from its theme as it is
     * created, so each new window needs it again. The theme's primary colour
     * goes along, since a description replaces the one the theme set.
     */
    private val systemTaskBackground: (Activity, Int) -> Unit = { activity, color ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val primary = themeColor(activity, android.R.attr.colorPrimary, 0)
            activity.setTaskDescription(
                ActivityManager.TaskDescription.Builder()
                    .setBackgroundColor(color)
                    .apply { if (Color.alpha(primary) == 0xFF) setPrimaryColor(primary) }
                    .build(),
            )
        }
    }

    @VisibleForTesting
    internal var setTaskBackground = systemTaskBackground

    @VisibleForTesting
    internal var surface: FlutterWindowSurface = FlutterViewSurface

    @VisibleForTesting
    internal var clock: () -> Long = SystemClock::uptimeMillis

    private val mainThread by lazy { Handler(Looper.getMainLooper()) }

    private val systemSchedule: (Long, () -> Unit) -> Unit = { delayMs, step ->
        if (delayMs == 0L) {
            Choreographer.getInstance().postFrameCallback { step() }
        } else {
            mainThread.postDelayed({ step() }, delayMs)
        }
    }

    /**
     * Runs a step on the next frame (no delay) or after a delay, on the main
     * thread's clocks rather than on a view: a recreated window's views
     * detach, and what is posted on them never runs. Tests drive it
     * themselves: Robolectric advances its clock whenever a frame is asked
     * for and runs it at once.
     */
    @VisibleForTesting
    internal var schedule = systemSchedule

    /** [activity] is the browser window now. */
    fun attach(activity: Activity) {
        this.activity = WeakReference(activity)
        setRecentsScreenshotEnabled(activity, !armed)
        color?.let { setTaskBackground(activity, it) }
        // A release under way starts over on the new window's Flutter view.
        attempt?.let { restart(it) }
    }

    /**
     * The app's background colour, which the cover and the system's stand-in
     * for a screenshot of the window are painted in from now on.
     */
    fun setColor(argb: Int) {
        val opaque = argb or OPAQUE
        if (opaque == color) return
        color = opaque

        val activity = activity?.get() ?: return
        setTaskBackground(activity, opaque)
        (activity.window.peekDecorView() as? ViewGroup)
            ?.findViewWithTag<View>(coverTag)
            ?.let { paint(it, opaque) }
    }

    /**
     * Whether [activity] keeps [event] from its views: while it is covered,
     * keys reach nothing behind the cover, as touches do not. System keys
     * (volume, media, Back) still do what they do.
     */
    fun consumesKey(activity: Activity, event: KeyEvent): Boolean = !event.isSystem && hasCover(activity)

    fun detach(activity: Activity) {
        if (this.activity?.get() === activity) {
            this.activity = null
            started = false
            surface.abandon()
        }
    }

    /**
     * Whether leaving covers the window, and keeps its content out of the
     * system's screenshot of it.
     *
     * Disarming leaves a cover that is already up: it stays until [release],
     * because a profile locked on leaving still has its browser behind the
     * cover until Dart draws the lock screen.
     */
    fun arm(armed: Boolean) {
        this.armed = armed
        if (armed) armedSinceNewEngine = true
        activity?.get()?.let { setRecentsScreenshotEnabled(it, !armed) }
    }

    /** The window is coming back: a cover put up on another activity applies here too. */
    fun onStart(activity: Activity) {
        if (activity !== this.activity?.get()) return

        started = true
        if (covered) {
            cover(activity)
        }
        if (attempt != null) step()
    }

    /**
     * The window goes out of sight: a departure, which no release asked for
     * before it may answer.
     *
     * Only the attached window's: an activity being replaced stops after its
     * successor has started. Called before the activity's own `onStop`, which
     * saves the Flutter view's visibility to put back on start: a surface
     * this took away is back by then.
     */
    fun onStop(activity: Activity) {
        if (activity !== this.activity?.get()) return

        attempt = null
        surface.abandon()
        started = false
        departures++
        if (!armed) return

        covered = true
        cover(activity)
    }

    /**
     * The departure the window is back from, or null while it is out of
     * sight.
     *
     * Dart asks before it decides, and passes the answer to [release]. A
     * decision made after the window came back holds for the cover of that
     * departure and for no later one: going out of sight again before the
     * release arrives makes it a release for an older departure, which
     * [release] ignores.
     */
    fun currentDeparture(): Long? = if (started) departures else null

    /**
     * Dart's decision for [departure] is made; lifts the cover once it is on
     * screen.
     *
     * Ignored while the window is out of sight, or when it has left again
     * since [departure]: that cover protects a newer departure, which a later
     * return decides for.
     *
     * Without [afterFreshFrame], the decision kept the browser open: what the
     * cover hides is the same open profile, and it goes at once.
     *
     * With it, the decision changed what the window shows (the profile
     * locked), and the cover stays until Flutter has drawn a frame since. Dart
     * asks only once no frame from before its decision can still be drawn
     * (`ProfileAuthState`). Here, in turn:
     *
     * 1. Flutter must show nothing it rendered before leaving
     *    ([FlutterWindowSurface.showsPreReturnImage]).
     * 2. Its surface is taken away and brought back new, and the cover goes
     *    when Flutter reports the first frame drawn on it. That is the only
     *    frame Flutter reports as drawn, and a frame it discarded, during a
     *    resize say, is never reported.
     *
     * Nothing but that report lifts the cover. One not in after
     * [STALLED_AFTER_MS] shows a lock on the cover, and the wait goes on.
     * Leaving and coming back starts the return over.
     */
    fun release(departure: Long, afterFreshFrame: Boolean) {
        if (!started || departure != departures) {
            Log.d(TAG, "Ignored a release for departure $departure (now $departures, started=$started)")
            return
        }
        val decor = currentDecor() ?: return

        if (!afterFreshFrame) {
            attempt = null
            surface.abandon()
            removeCover(decor)
            return
        }
        if (decor.findViewWithTag<View>(coverTag) == null) {
            covered = false
            return
        }
        // Already waiting on it.
        if (attempt?.departure == departure) return

        attempt = Attempt(departure, clock())
        step()
    }

    /**
     * A new Flutter engine is starting: nothing it shows comes from the
     * profile yet, and the cover is armed again only by its own unlock.
     */
    fun disarmForNewEngine() {
        arm(false)
        armedSinceNewEngine = false
    }

    /**
     * The new engine's first frame is on screen: lifts a cover an engine
     * before it left behind.
     *
     * Not one this engine put up: once it armed the cover, its own returns
     * release it.
     */
    fun liftLeftoverCover() {
        if (armedSinceNewEngine) return

        attempt = null
        surface.abandon()
        // Not pending on anything: no window should get this cover again,
        // whether or not one is attached now.
        covered = false
        currentDecor()?.let(::uncover)
    }

    /** One step of [release]'s wait, on the window attached now. */
    private fun step() {
        val attempt = attempt ?: return
        // Left again: that departure's cover waits for its own return.
        if (!started || attempt.departure != departures) return
        // No window right now: still covered, and the next one is too.
        val decor = currentDecor() ?: return
        if (decor.findViewWithTag<View>(coverTag) == null) {
            finish(decor)
            return
        }
        if (attempt.waitingForFrame) return

        when {
            surface.showsPreReturnImage(decor) -> Unit

            !attempt.surfaceTaken -> {
                if (!surface.takeAway(decor)) {
                    // No Flutter surface in this window to confirm a frame
                    // on. Dart has waited until no frame from before its
                    // decision is left to draw, and that has to do.
                    Log.w(TAG, "No Flutter surface view to confirm a fresh frame on; lifting the cover without one")
                    finish(decor)
                    return
                }
                attempt.surfaceTaken = true
            }

            attempt.hiddenFrames < HIDDEN_FRAMES || !surface.isGone() -> attempt.hiddenFrames++

            else -> {
                attempt.waitingForFrame = true
                val round = attempt.round
                surface.bringBack { if (attempt.round == round) onFreshFrame(attempt) }
                if (attempt.waitingForFrame) watchForStall(attempt)
                return
            }
        }
        waitAgain(attempt, decor)
    }

    private fun waitAgain(attempt: Attempt, decor: ViewGroup) {
        val round = attempt.round
        val next = { if (this.attempt === attempt && attempt.round == round) step() }
        if (clock() - attempt.since < STALLED_AFTER_MS) {
            schedule(0L, next)
            return
        }
        showStalledLock(decor)
        schedule(STALLED_POLL_MS, next)
    }

    /** Shows the lock if the drawn frame has not been reported by then. */
    private fun watchForStall(attempt: Attempt) {
        val round = attempt.round
        val remaining = (attempt.since + STALLED_AFTER_MS - clock()).coerceAtLeast(1L)
        schedule(remaining) {
            if (this.attempt === attempt && attempt.round == round && attempt.waitingForFrame) {
                currentDecor()?.let(::showStalledLock)
            }
        }
    }

    private fun onFreshFrame(attempt: Attempt) {
        if (this.attempt !== attempt) return
        attempt.waitingForFrame = false
        if (!started || attempt.departure != departures) return
        currentDecor()?.let(::finish)
    }

    /** A window replaced the one [attempt] was working on: starts it over there. */
    private fun restart(attempt: Attempt) {
        surface.abandon()
        attempt.round++
        attempt.surfaceTaken = false
        attempt.hiddenFrames = 0
        attempt.waitingForFrame = false
    }

    private fun finish(decor: ViewGroup) {
        attempt = null
        surface.abandon()
        removeCover(decor)
    }

    /**
     * Takes the cover off [decor], the current window's. Only now does the
     * window stop being covered: until then a replacement window gets a cover
     * of its own ([onStart]), even with the profile locked and disarmed, when
     * no stop would put one up again.
     */
    private fun removeCover(decor: ViewGroup) {
        uncover(decor)
        covered = false
    }

    /** Takes the cover view off [decor], and gives accessibility services the views under it back. */
    private fun uncover(decor: ViewGroup) {
        val cover = decor.findViewWithTag<CoverView>(coverTag) ?: return
        cover.underneath.uncover()
        decor.removeView(cover)
    }

    /**
     * The cover, with the views it sits on: a screen reader reads views
     * through a view on top of them, so they are hidden from it while
     * covered. Their focus stays, and with it the keyboard the lock screen
     * raises behind the cover; keys are kept out at dispatch ([consumesKey]).
     */
    private class CoverView(activity: Activity, val underneath: CoveredViews) : FrameLayout(activity)

    private fun showStalledLock(decor: ViewGroup) {
        val lock = decor.findViewWithTag<View>(coverTag)?.findViewWithTag<View>(lockTag) ?: return
        if (lock.visibility != View.VISIBLE) {
            lock.visibility = View.VISIBLE
            Log.w(TAG, "No frame drawn since the lock decision is reported yet; the window stays covered")
        }
    }

    private fun currentDecor(): ViewGroup? = activity?.get()?.window?.peekDecorView() as? ViewGroup

    private fun hasCover(activity: Activity): Boolean =
        (activity.window.peekDecorView() as? ViewGroup)?.findViewWithTag<View>(coverTag) != null

    @VisibleForTesting
    internal fun isCovered(activity: Activity): Boolean = hasCover(activity)

    @VisibleForTesting
    internal fun showsStalledLock(activity: Activity): Boolean =
        (activity.window.peekDecorView() as? ViewGroup)
            ?.findViewWithTag<View>(coverTag)
            ?.findViewWithTag<View>(lockTag)
            ?.visibility == View.VISIBLE

    private fun cover(activity: Activity) {
        val decor = activity.window.decorView as? ViewGroup ?: return
        if (decor.findViewWithTag<View>(coverTag) != null) return

        val size = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            48f,
            activity.resources.displayMetrics,
        ).toInt()
        val lock = ImageView(activity).apply {
            tag = lockTag
            setImageResource(R.drawable.weblibre_ic_lock)
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            visibility = View.GONE
        }
        val content = (0 until decor.childCount).map(decor::getChildAt).filterIsInstance<ViewGroup>()
        val cover = CoverView(activity, CoveredViews(content, blocksFocus = false)).apply {
            tag = coverTag
            // Taps on the stale browser underneath go nowhere, and neither do
            // a mouse's wheel or hover.
            isClickable = true
            setOnGenericMotionListener { _, _ -> true }
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            addView(lock, FrameLayout.LayoutParams(size, size, Gravity.CENTER))
        }
        // The colour the system paints the snapshot in, so the way back shows
        // one colour until the lock screen.
        paint(cover, color ?: themeColor(activity, android.R.attr.colorBackground, Color.BLACK))
        cover.underneath.cover()
        // Last, so it draws over the content and everything Flutter adds to it.
        decor.addView(
            cover,
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT),
        )
    }

    /** Paints [cover] in [background], and its lock in a grey that shows on it. */
    private fun paint(cover: View, background: Int) {
        cover.setBackgroundColor(background)
        val lockTint = if (Color.luminance(background) < 0.5f) LOCK_ON_DARK else LOCK_ON_LIGHT
        cover.findViewWithTag<ImageView>(lockTag)?.imageTintList = ColorStateList.valueOf(lockTint)
    }

    /** A colour of the window's theme, which follows the system's day and night. */
    private fun themeColor(activity: Activity, attr: Int, fallback: Int): Int {
        val value = TypedValue()
        if (!activity.theme.resolveAttribute(attr, value, true)) return fallback
        if (value.type in TypedValue.TYPE_FIRST_COLOR_INT..TypedValue.TYPE_LAST_COLOR_INT) return value.data
        if (value.resourceId != 0) {
            return runCatching { activity.getColorStateList(value.resourceId).defaultColor }.getOrDefault(fallback)
        }
        return fallback
    }

    @VisibleForTesting
    internal fun resetForTest() {
        armed = false
        armedSinceNewEngine = false
        covered = false
        activity = null
        started = false
        departures = 0L
        attempt = null
        color = null
        setRecentsScreenshotEnabled = systemRecentsScreenshot
        setTaskBackground = systemTaskBackground
        surface = FlutterViewSurface
        clock = SystemClock::uptimeMillis
        schedule = systemSchedule
    }
}
