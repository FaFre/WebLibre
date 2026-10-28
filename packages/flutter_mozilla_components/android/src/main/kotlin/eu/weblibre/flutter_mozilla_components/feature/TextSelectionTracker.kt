/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Handler
import android.os.Looper
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence

/**
 * Tracks whether a text selection is currently on screen, so the touch-driven
 * chrome (configurable gestures, toolbar auto-hide) can ignore a touch stream
 * that is really a selection-handle drag.
 *
 * Why the action mode and not the engine: Gecko draws selection handles in the
 * compositor rather than as Android views, so dragging one produces an ordinary
 * `DOWN → MOVE… → UP` stream indistinguishable from a swipe. The obvious engine
 * signal is useless here — `EngineView.canClearSelection()` reads
 * `BasicSelectionActionDelegate.mSelection`, which Gecko *nulls* for the
 * duration of a handle drag (`onHideAction(HIDE_REASON_ACTIVE_SELECTION)` →
 * `mActionMode.finish()` → `onDestroyActionMode`). It is false exactly when we
 * need it to be true.
 *
 * What survives that is the action mode's *start*: Gecko's hide request arrives
 * asynchronously, well after the synchronous view-tree dispatch of the
 * `ACTION_DOWN` that grabbed the handle. Consumers therefore latch [isActive]
 * on touch-down and hold that decision for the rest of the stream — see
 * `BackGestureFilterFrameLayout` (through [onTouchStreamStarted]) and, on the
 * Dart side, `BrowserView`.
 *
 * Fed from the host activity's `onActionModeStarted`/`onActionModeFinished`
 * (see `MainActivity`), which is where the framework reports every action mode
 * started on the window — including the one `BasicSelectionActionDelegate`
 * starts via `Activity.startActionMode`.
 *
 * See https://github.com/FaFre/WebLibre/issues/578.
 */
object TextSelectionTracker {
    /**
     * How long [isActive] stays true after the last action mode finishes, or
     * after a confirmed selection interaction ends (see [onSelectionStreamEnded]).
     *
     * Between two consecutive handle drags the action mode is torn down and
     * then re-requested by Gecko over IPC. Without this window a quick re-grab
     * lands in the gap, reads the flag as false, and is treated as a swipe
     * again — the very bug this tracker exists to fix.
     */
    @VisibleForTesting
    internal const val GRACE_MS = 400L

    /**
     * Created lazily so unit tests can replace the scheduling seams below
     * before any Android framework class is touched.
     */
    private val handler by lazy { Handler(Looper.getMainLooper()) }

    private val clearRunnable = Runnable { setActive(false) }

    /** Posts the end of the grace window, replacing any pending post. */
    @VisibleForTesting
    internal var scheduleGraceExpiry: (Long) -> Unit = { delayMs ->
        handler.removeCallbacks(clearRunnable)
        handler.postDelayed(clearRunnable, delayMs)
    }

    /** Cancels a pending grace expiry. */
    @VisibleForTesting
    internal var cancelGraceExpiry: () -> Unit = {
        handler.removeCallbacks(clearRunnable)
    }

    /**
     * Number of action modes currently started on the window. A count rather
     * than a boolean because the engine can replace one mode with another
     * (selection → clipboard permission) without the two being balanced in
     * order.
     */
    private var activeModes = 0

    /**
     * Whether an action mode has been up at any point during the touch stream
     * in flight, i.e. whether it is a confirmed selection interaction rather
     * than one latched on the [GRACE_MS] tail alone. See
     * [onSelectionStreamEnded].
     */
    private var modeLiveInStream = false

    /**
     * Whether a text selection is on screen, including the [GRACE_MS] tail.
     * Read from the UI thread by the touch pipeline; volatile because it is
     * also read from `dispatchTouchEvent` on views that may be driven by a
     * different looper in tests.
     */
    @Volatile
    var isActive: Boolean = false
        private set

    /** Reports an action mode started on the host activity's window. */
    fun onActionModeStarted() {
        activeModes++
        modeLiveInStream = true
        cancelGraceExpiry()
        setActive(true)
    }

    /** Reports an action mode finished on the host activity's window. */
    fun onActionModeFinished() {
        activeModes = (activeModes - 1).coerceAtLeast(0)
        if (activeModes > 0) {
            return
        }
        scheduleGraceExpiry(GRACE_MS)
    }

    /**
     * Reports the start of a touch stream on the page (`ACTION_DOWN`) and
     * returns whether it belongs to the selection, which the caller latches
     * for the rest of the stream.
     */
    fun onTouchStreamStarted(): Boolean {
        modeLiveInStream = activeModes > 0
        return isActive
    }

    /**
     * Reports that a touch stream latched as a selection interaction has
     * ended, restarting the grace window from the moment the finger lifted.
     *
     * Gecko finishes the action mode when a handle is pressed, so the grace
     * window armed by [onActionModeFinished] runs out during any drag longer
     * than [GRACE_MS]. The mode only comes back after the release, over IPC; a
     * handle re-grabbed in that gap would otherwise read the flag as false.
     *
     * Only a stream an action mode was up for renews the window. A stream
     * latched on the grace tail alone — a swipe started right after a selection
     * was dismissed — must not, or back-to-back swipes would keep renewing it
     * with no selection left, keeping gestures and auto-hide off indefinitely.
     * No-op while a mode is up, since [isActive] is then already true without
     * an expiry pending.
     */
    fun onSelectionStreamEnded() {
        if (activeModes > 0 || !modeLiveInStream) {
            return
        }
        setActive(true)
        scheduleGraceExpiry(GRACE_MS)
    }

    /**
     * Drops all selection state immediately.
     *
     * A stuck-true flag is the only way this feature can break something: it
     * would silently kill gestures and toolbar auto-hide until the next action
     * mode completed a full cycle. An action mode destroyed without its finish
     * callback reaching us (activity torn down mid-selection) would do exactly
     * that, so the host resets when its activity is destroyed.
     */
    fun reset() {
        activeModes = 0
        modeLiveInStream = false
        cancelGraceExpiry()
        setActive(false)
    }

    /** Runs a pending grace expiry now, instead of waiting out [GRACE_MS]. */
    @VisibleForTesting
    internal fun expireGraceWindow() = clearRunnable.run()

    private fun setActive(value: Boolean) {
        if (isActive == value) {
            return
        }
        isActive = value
        GlobalComponents.gestureEvents
            ?.onTextSelectionActiveChange(EventSequence.next(), value) { }
    }
}
