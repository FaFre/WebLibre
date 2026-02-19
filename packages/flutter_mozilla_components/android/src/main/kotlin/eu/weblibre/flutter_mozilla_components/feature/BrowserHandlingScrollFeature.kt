/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

/**
 * Feature that reports whether GeckoView is currently handling scroll input.
 *
 * Checks InputResultDetail while active and only emits on state changes.
 */
class BrowserHandlingScrollFeature(
    private val flutterEvents: GeckoViewportEvents,
) {
    private var running = false
    private var touchSessionActive = false
    private var lastValue: Boolean? = null
    private var touchListener: View.OnTouchListener? = null
    private var touchTargetView: View? = null

    fun start() {
        if (running) return
        running = true
        touchSessionActive = false
        lastValue = null
        attachTouchListenerIfPossible()
    }

    fun stop() {
        if (!running) return
        running = false
        touchSessionActive = false
        detachTouchListenerIfPossible()
        lastValue = null
    }

    private fun attachTouchListenerIfPossible() {
        val engineViewRoot = GlobalComponents.components?.mainBrowserEngineView?.asView()
        if (engineViewRoot == null) return

        if (touchListener != null) return

        val targetView = resolveTouchTargetView(engineViewRoot)

        touchListener = View.OnTouchListener { _, event ->
            if (!running) return@OnTouchListener false

            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    touchSessionActive = true
                    emitIfChanged()
                }

                MotionEvent.ACTION_MOVE -> {
                    if (touchSessionActive) {
                        emitIfChanged()
                    }
                }

                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> {
                    touchSessionActive = false
                }
            }

            // Never consume touch; GeckoView must keep handling it.
            false
        }

        targetView.setOnTouchListener(touchListener)
        touchTargetView = targetView
    }

    private fun detachTouchListenerIfPossible() {
        if (touchTargetView != null && touchListener != null) {
            touchTargetView?.setOnTouchListener(null)
        }
        touchListener = null
        touchTargetView = null
    }

    private fun resolveTouchTargetView(root: View): View {
        if (root !is ViewGroup) return root

        // GeckoEngineView wraps the actual NestedGeckoView as its first child.
        if (root.childCount > 0) {
            return root.getChildAt(0)
        }

        return root
    }

    private fun emitIfChanged() {
        val isHandling = try {
            val engineView = GlobalComponents.components?.mainBrowserEngineView
            if (engineView == null) {
                false
            } else {
                val detail = engineView.getInputResultDetail()
                detail.canScrollToTop() || detail.canScrollToBottom()
            }
        } catch (_: Throwable) {
            false
        }

        if (lastValue == isHandling) return
        lastValue = isHandling

        val sequence = EventSequence.next()
        runOnUiThread {
            flutterEvents.onBrowserHandlingScrollChanged(sequence, isHandling) { }
        }
    }
}
