/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.view.MotionEvent
import eu.weblibre.flutter_mozilla_components.pigeons.GestureConfig
import kotlin.math.abs
import kotlin.math.min

/**
 * Pure, view-agnostic touch-gesture recognizer.
 *
 * Ported from the Simple Gesture add-on
 * (https://github.com/utubo/firefox-simple_gesture, MPL-2.0, Copyright 2017
 * utubo): the same stroke grammar is used so user configuration carries over.
 * A gesture is encoded as a canonical key built from three parts:
 *
 *  - an optional **start-position** prefix describing where the touch began
 *    (`L:`/`R:`/`T:`/`B:` for the four edges, `W:`/`E:` for the left/right
 *    half otherwise),
 *  - an optional **finger-count** prefix (`2:`, `3:` …; omitted for a single
 *    finger), and
 *  - the dash-joined sequence of dominant **directions** (`U`/`D`/`L`/`R`),
 *
 * e.g. `R:2:D-L` (two fingers, started at the right edge, moved down then
 * left) or simply `D-R`.
 *
 * Recognition is **observational**: callers feed every [MotionEvent] via [feed]
 * without consuming it, and [feed] returns the matched key on the terminating
 * `ACTION_UP` only when the assembled stroke matches an entry in
 * [GestureConfig.activeGestureKeys]. Pages therefore scroll and tap normally;
 * multi-stroke gestures simply fire their action on release.
 */
class GestureRecognizer {
    /**
     * Current configuration. Assigned by the owner (the browser container)
     * before each event so updates pushed from Dart take effect immediately.
     */
    var config: GestureConfig? = null

    /**
     * Invoked on the UI thread whenever a new direction arrow is appended to the
     * in-progress stroke, with the current partial canonical key (e.g. `R:D`).
     * The owner uses this both to restart the idle-timeout (matching the
     * reference add-on, which restarts only on a new arrow) and to drive the
     * live gesture-feedback overlay.
     */
    var onProgress: ((String) -> Unit)? = null

    private val arrows = ArrayList<Char>(MAX_ARROWS + 1)
    private var startPosition = ""
    private var fingers = ""
    private var fingersNum = 1
    private var lastX = 0f
    private var lastY = 0f
    private var lastArrow = ' '
    private var lastArrowTime = 0L
    private var strokeSize = 0f
    private var edgeWidth = 0f
    private var contentBottom = 0f
    private var aborted = false
    private var active = false

    /**
     * Feeds one motion event. Returns the recognized gesture key on the
     * terminating `ACTION_UP`, or null otherwise. Never consumes the event.
     *
     * [bottomInsetPx] is the height (physical px) of the dynamic bottom toolbar
     * currently overlaying the engine view. It is subtracted from the view
     * height so the bottom edge zone tracks the visible content edge rather than
     * the toolbar area (which never receives touches).
     */
    fun feed(
        event: MotionEvent,
        viewWidth: Int,
        viewHeight: Int,
        bottomInsetPx: Int,
    ): String? {
        val cfg = config
        if (cfg == null || !cfg.enabled || cfg.activeGestureKeys.isEmpty()) {
            active = false
            return null
        }

        return when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                onDown(event, cfg, viewWidth, viewHeight, bottomInsetPx)
                null
            }

            MotionEvent.ACTION_POINTER_DOWN,
            MotionEvent.ACTION_MOVE -> {
                onMove(event, cfg)
                null
            }

            MotionEvent.ACTION_UP -> onUp(cfg)

            MotionEvent.ACTION_CANCEL -> {
                reset()
                null
            }

            else -> null
        }
    }

    /** Discards any in-progress gesture (e.g. on idle timeout or back-gesture
     *  interception). */
    fun cancel() = reset()

    private fun onDown(
        event: MotionEvent,
        cfg: GestureConfig,
        w: Int,
        h: Int,
        bottomInsetPx: Int,
    ) {
        reset()
        val minSide = min(w, h).toFloat()
        if (minSide <= 0f) {
            aborted = true
            return
        }
        active = true
        // Scale the configured base stroke length to the screen, matching the
        // reference add-on's `strokeSize * min(w, h) / 320`.
        strokeSize = cfg.strokeSize * minSide / REFERENCE_SHORT_SIDE
        edgeWidth = minSide / EDGE_DIVISOR
        // The visible content ends above the dynamic bottom toolbar.
        contentBottom = (h - bottomInsetPx).toFloat()
        lastX = event.getX(0)
        lastY = event.getY(0)
        startPosition = computeStartPosition(lastX, lastY, w)
    }

    private fun onMove(event: MotionEvent, cfg: GestureConfig) {
        if (!active || aborted) return
        if (!setupFingers(event, cfg)) return
        if (arrows.size > MAX_ARROWS) return

        val x = event.getX(0)
        val y = event.getY(0)
        val dx = x - lastX
        val dy = y - lastY
        val absX = abs(dx)
        val absY = abs(dy)
        if (absX < strokeSize && absY < strokeSize) return

        lastX = x
        lastY = y
        val arrow = if (absX < absY) {
            if (dy < 0) 'U' else 'D'
        } else {
            if (dx < 0) 'L' else 'R'
        }
        // Collapse consecutive identical directions into a single stroke.
        if (arrow == lastArrow) return
        // Reject gestures whose direction changes come faster than the
        // configured minimum (e.g. an accidental fast scribble). The first
        // arrow has no predecessor, so it is never gated.
        val minInterval = cfg.minStrokeIntervalMs
        if (lastArrow != ' ' && minInterval > 0 &&
            event.eventTime - lastArrowTime < minInterval) {
            aborted = true
            return
        }
        lastArrow = arrow
        lastArrowTime = event.eventTime
        arrows.add(arrow)
        onProgress?.invoke(currentKey())
    }

    private fun onUp(cfg: GestureConfig): String? {
        val result = if (active && !aborted && arrows.isNotEmpty()) matchKey(cfg) else null
        reset()
        return result
    }

    private fun setupFingers(event: MotionEvent, cfg: GestureConfig): Boolean {
        val count = event.pointerCount
        if (count > cfg.maxFingers) {
            aborted = true
            return false
        }
        if (fingersNum < count) {
            fingersNum = count
            fingers = "$count:"
        }
        return true
    }

    /**
     * The current in-progress canonical key including the start-position and
     * finger prefixes, e.g. `R:2:D-L`. Used for live feedback, where the
     * consumer matches it against configured bindings to suggest completions.
     */
    private fun currentKey(): String = startPosition + fingers + arrows.joinToString("-")

    private fun matchKey(cfg: GestureConfig): String? {
        val input = fingers + arrows.joinToString("-")
        val withStart = startPosition + input
        return when {
            cfg.activeGestureKeys.contains(withStart) -> withStart
            cfg.activeGestureKeys.contains(input) -> input
            else -> null
        }
    }

    private fun computeStartPosition(x: Float, y: Float, w: Int): String {
        return when {
            x < edgeWidth -> "L:"
            x > w - edgeWidth -> "R:"
            y < edgeWidth -> "T:"
            y > contentBottom - edgeWidth -> "B:"
            x < w / 2f -> "W:"
            else -> "E:"
        }
    }

    private fun reset() {
        arrows.clear()
        startPosition = ""
        fingers = ""
        fingersNum = 1
        lastArrow = ' '
        lastArrowTime = 0L
        aborted = false
        active = false
    }

    companion object {
        /** Maximum number of direction strokes per gesture. */
        private const val MAX_ARROWS = 9

        /** Reference short-side length the base stroke size is calibrated for. */
        private const val REFERENCE_SHORT_SIDE = 320f

        /** Edge-zone width is `min(width, height) / EDGE_DIVISOR`. */
        private const val EDGE_DIVISOR = 10f
    }
}
