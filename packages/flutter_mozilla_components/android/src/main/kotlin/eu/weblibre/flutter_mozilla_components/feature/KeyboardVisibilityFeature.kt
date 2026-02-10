/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Build
import android.view.View
import android.view.ViewTreeObserver
import android.view.WindowInsets
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

/**
 * Feature that detects keyboard visibility changes and reports them to Flutter.
 *
 * Uses WindowInsets API for accurate keyboard detection on Android 11+ (API 30+),
 * with fallback to ViewTreeObserver.OnGlobalLayoutListener for older versions.
 */
class KeyboardVisibilityFeature(
    private val flutterEvents: GeckoViewportEvents
) {
    companion object {
        private const val TAG = "KeyboardVisibilityFeature"
    }

    private val logger = Logger(TAG)

    private var rootView: View? = null
    private var lastKeyboardHeight: Int = 0
    private var lastKeyboardVisible: Boolean = false
    private var isAnimating: Boolean = false

    // For legacy keyboard detection (pre-API 30)
    private var globalLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

    // For modern keyboard animation tracking (API 30+)
    private var insetsAnimationCallback: WindowInsetsAnimationCompat.Callback? = null

    /**
     * Start observing keyboard visibility changes on the given root view.
     */
    fun start(view: View) {
        rootView = view

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            setupModernKeyboardDetection(view)
        } else {
            setupLegacyKeyboardDetection(view)
        }

        // Also set up WindowInsets listener for immediate state
        setupInsetsListener(view)

        logger.debug("$TAG: Started keyboard visibility detection")
    }

    /**
     * Stop observing keyboard visibility changes.
     */
    fun stop() {
        rootView?.let { view ->
            globalLayoutListener?.let {
                view.viewTreeObserver.removeOnGlobalLayoutListener(it)
            }
            insetsAnimationCallback?.let {
                ViewCompat.setWindowInsetsAnimationCallback(view, null)
            }
        }

        globalLayoutListener = null
        insetsAnimationCallback = null
        rootView = null

        logger.debug("$TAG: Stopped keyboard visibility detection")
    }

    /**
     * Modern keyboard detection using WindowInsetsAnimation (API 30+).
     * This provides smooth animation callbacks during keyboard show/hide.
     */
    private fun setupModernKeyboardDetection(view: View) {
        insetsAnimationCallback = object : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_STOP) {
            override fun onPrepare(animation: WindowInsetsAnimationCompat) {
                super.onPrepare(animation)
                if (animation.typeMask and WindowInsetsCompat.Type.ime() != 0) {
                    isAnimating = true
                }
            }

            override fun onProgress(
                insets: WindowInsetsCompat,
                runningAnimations: MutableList<WindowInsetsAnimationCompat>
            ): WindowInsetsCompat {
                // Find IME animation
                val imeAnimation = runningAnimations.find {
                    it.typeMask and WindowInsetsCompat.Type.ime() != 0
                }

                if (imeAnimation != null) {
                    val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
                    val navInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars())

                    // Keyboard height is IME height minus navigation bar (which is included)
                    val keyboardHeight = (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)

                    // During animation, report height changes
                    if (keyboardHeight != lastKeyboardHeight) {
                        notifyKeyboardChange(keyboardHeight, keyboardHeight > 0, isAnimating = true)
                    }
                }

                return insets
            }

            override fun onEnd(animation: WindowInsetsAnimationCompat) {
                super.onEnd(animation)
                if (animation.typeMask and WindowInsetsCompat.Type.ime() != 0) {
                    isAnimating = false
                    // Send final state
                    notifyKeyboardChange(lastKeyboardHeight, lastKeyboardVisible, isAnimating = false)
                }
            }
        }

        ViewCompat.setWindowInsetsAnimationCallback(view, insetsAnimationCallback)
    }

    /**
     * Legacy keyboard detection using ViewTreeObserver (pre-API 30).
     */
    private fun setupLegacyKeyboardDetection(view: View) {
        globalLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            val insets = ViewCompat.getRootWindowInsets(view) ?: return@OnGlobalLayoutListener

            val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
            val navInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars())

            val keyboardHeight = (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)
            val isVisible = keyboardHeight > 0

            if (keyboardHeight != lastKeyboardHeight || isVisible != lastKeyboardVisible) {
                notifyKeyboardChange(keyboardHeight, isVisible, isAnimating = false)
            }
        }

        view.viewTreeObserver.addOnGlobalLayoutListener(globalLayoutListener)
    }

    /**
     * Set up WindowInsets listener for immediate keyboard state.
     */
    private fun setupInsetsListener(view: View) {
        ViewCompat.setOnApplyWindowInsetsListener(view) { _, insets ->
            val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
            val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
            val navInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars())

            val keyboardHeight = if (imeVisible) {
                (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)
            } else {
                0
            }

            // Only notify if not currently animating (animation callbacks handle that)
            if (!isAnimating && (keyboardHeight != lastKeyboardHeight || imeVisible != lastKeyboardVisible)) {
                notifyKeyboardChange(keyboardHeight, imeVisible, isAnimating = false)
            }

            insets
        }
    }

    /**
     * Notify Flutter about keyboard visibility change.
     */
    private fun notifyKeyboardChange(heightPx: Int, isVisible: Boolean, isAnimating: Boolean) {
        lastKeyboardHeight = heightPx
        lastKeyboardVisible = isVisible

        val timestamp = EventSequence.next()

        logger.debug("$TAG: Keyboard change - height=$heightPx, visible=$isVisible, animating=$isAnimating")

        runOnUiThread {
            flutterEvents.onKeyboardVisibilityChanged(
                timestamp,
                heightPx.toLong(),
                isVisible,
                isAnimating
            ) { /* callback - ignore result */ }
        }
    }

    /**
     * Manually trigger a keyboard state check.
     * Useful after configuration changes or when resuming.
     */
    fun checkKeyboardState() {
        rootView?.let { view ->
            val insets = ViewCompat.getRootWindowInsets(view) ?: return

            val imeVisible = insets.isVisible(WindowInsetsCompat.Type.ime())
            val imeInsets = insets.getInsets(WindowInsetsCompat.Type.ime())
            val navInsets = insets.getInsets(WindowInsetsCompat.Type.navigationBars())

            val keyboardHeight = if (imeVisible) {
                (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)
            } else {
                0
            }

            notifyKeyboardChange(keyboardHeight, imeVisible, isAnimating = false)
        }
    }
}
