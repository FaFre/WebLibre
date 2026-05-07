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
 * Feature that filters browser touch input and reports whether GeckoView is handling scroll input.
 *
 * Checks InputResultDetail while scroll detection is enabled and only emits on state changes.
 */
class BrowserHandlingScrollFeature(
    private val flutterEvents: GeckoViewportEvents,
) {
    private var running = false
    private var scrollDetectionEnabled = false
    private var touchSessionActive = false
    private var lastValue: Boolean? = null
    private var touchListener: View.OnTouchListener? = null
    private var touchTargetView: View? = null
    private var multiTouchSequenceActive = false
    private var suppressUntilAllPointersUp = false
    private var syntheticCancelDispatched = false

    fun start(scrollDetectionEnabled: Boolean) {
        if (running) {
            setScrollDetectionEnabled(scrollDetectionEnabled)
            return
        }

        running = true
        this.scrollDetectionEnabled = scrollDetectionEnabled
        touchSessionActive = false
        lastValue = null
        resetPinchGuard()
        attachTouchListenerIfPossible()
    }

    fun setScrollDetectionEnabled(enabled: Boolean) {
        if (scrollDetectionEnabled == enabled) return

        scrollDetectionEnabled = enabled
        if (!enabled) {
            touchSessionActive = false
            emitIfChanged(false)
        }
    }

    fun stop() {
        if (!running) return
        running = false
        scrollDetectionEnabled = false
        touchSessionActive = false
        resetPinchGuard()
        emitIfChanged(false)
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

            val consumeEvent = handlePinchGesture(targetView, event)
            updateScrollDetection(event)

            consumeEvent
        }

        targetView.setOnTouchListener(touchListener)
        touchTargetView = targetView
    }

    private fun updateScrollDetection(event: MotionEvent) {
        if (!scrollDetectionEnabled) return

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                touchSessionActive = true
                emitCurrentStateIfChanged()
            }

            MotionEvent.ACTION_POINTER_DOWN -> {
                touchSessionActive = false
                emitIfChanged(false)
            }

            MotionEvent.ACTION_MOVE -> {
                if (touchSessionActive) {
                    emitCurrentStateIfChanged()
                }
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                touchSessionActive = false
                emitIfChanged(false)
            }
        }
    }

    private fun handlePinchGesture(targetView: View, event: MotionEvent): Boolean {
        if (suppressUntilAllPointersUp) {
            when (event.actionMasked) {
                MotionEvent.ACTION_MOVE -> {
                    dispatchSyntheticCancelIfNeeded(targetView, event)
                    return true
                }

                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> {
                    val consumeEvent = syntheticCancelDispatched
                    if (!syntheticCancelDispatched && event.actionMasked == MotionEvent.ACTION_UP) {
                        dispatchSyntheticCancelIfNeeded(targetView, event)
                        resetPinchGuard()
                        return true
                    }

                    resetPinchGuard()
                    return consumeEvent
                }
            }
        }

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> resetPinchGuard()
            MotionEvent.ACTION_POINTER_DOWN -> multiTouchSequenceActive = true
            MotionEvent.ACTION_POINTER_UP -> {
                if (multiTouchSequenceActive) {
                    suppressUntilAllPointersUp = true
                    // Prevent APZ from treating the remaining finger as a pan/fling after pinch end.
                    postSyntheticCancelIfNeeded(targetView, event)
                }
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> resetPinchGuard()
        }

        // Do not consume normal touch; GeckoView must keep handling it.
        return false
    }

    private fun postSyntheticCancelIfNeeded(targetView: View, event: MotionEvent) {
        val cancelEvent = MotionEvent.obtain(event)
        targetView.post {
            if (running && suppressUntilAllPointersUp && !syntheticCancelDispatched) {
                dispatchSyntheticCancel(targetView, cancelEvent)
            } else {
                cancelEvent.recycle()
            }
        }
    }

    private fun dispatchSyntheticCancelIfNeeded(targetView: View, event: MotionEvent) {
        if (syntheticCancelDispatched) return

        val cancelEvent = MotionEvent.obtain(event)
        dispatchSyntheticCancel(targetView, cancelEvent)
    }

    private fun dispatchSyntheticCancel(targetView: View, cancelEvent: MotionEvent) {
        cancelEvent.action = MotionEvent.ACTION_CANCEL
        targetView.onTouchEvent(cancelEvent)
        cancelEvent.recycle()
        syntheticCancelDispatched = true
    }

    private fun resetPinchGuard() {
        multiTouchSequenceActive = false
        suppressUntilAllPointersUp = false
        syntheticCancelDispatched = false
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

    private fun emitCurrentStateIfChanged() {
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

        emitIfChanged(isHandling)
    }

    private fun emitIfChanged(isHandling: Boolean) {
        if (lastValue == isHandling) return
        lastValue = isHandling

        val sequence = EventSequence.next()
        runOnUiThread {
            flutterEvents.onBrowserHandlingScrollChanged(sequence, isHandling) { }
        }
    }
}
