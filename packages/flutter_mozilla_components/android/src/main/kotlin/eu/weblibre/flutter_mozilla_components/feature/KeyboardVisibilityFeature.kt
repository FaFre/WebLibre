/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Build
import android.view.View
import android.view.ViewTreeObserver
import androidx.core.view.OnApplyWindowInsetsListener
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsAnimationCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsCompat.Type.ime
import androidx.core.view.WindowInsetsCompat.Type.navigationBars
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

/**
 * Feature that detects keyboard visibility changes and reports them to Flutter.
 *
 * Uses WindowInsets API with animation-bounds-based height calculation on Android 11+ (API 30+),
 * with fallback to ViewTreeObserver.OnGlobalLayoutListener for older versions.
 *
 * The animation-bounds approach works around known
 * Android bugs where live insets during animation don't reflect the full keyboard height
 * (including suggestion bar/toolbar).
 */
class KeyboardVisibilityFeature(
    private val flutterEvents: GeckoViewportEvents
) : WindowInsetsAnimationCompat.Callback(DISPATCH_MODE_CONTINUE_ON_SUBTREE),
    OnApplyWindowInsetsListener {

    companion object {
        private const val TAG = "KeyboardVisibilityFeature"
    }

    private val logger = Logger(TAG)

    private var rootView: View? = null
    private var lastKeyboardHeight: Int = 0
    private var lastKeyboardVisible: Boolean = false

    // State tracking for animation-bounds-based keyboard height
    private var areKeyboardInsetsDeferred = false
    private var isKeyboardShowingUp = false
    private var keyboardAnimationInProgress = false
    private var keyboardHeight = 0 // full target height from animation bounds

    // For legacy keyboard detection (pre-API 30)
    private var globalLayoutListener: ViewTreeObserver.OnGlobalLayoutListener? = null

    /**
     * Start observing keyboard visibility changes on the given root view.
     */
    fun start(view: View) {
        rootView = view

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            ViewCompat.setWindowInsetsAnimationCallback(view, this)
            ViewCompat.setOnApplyWindowInsetsListener(view, this)
        } else {
            setupLegacyKeyboardDetection(view)
        }

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
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                ViewCompat.setWindowInsetsAnimationCallback(view, null)
                ViewCompat.setOnApplyWindowInsetsListener(view, null)
            }
        }

        globalLayoutListener = null
        rootView = null

        logger.debug("$TAG: Stopped keyboard visibility detection")
    }

    // --- WindowInsetsAnimationCompat.Callback implementation (API 30+) ---

    override fun onPrepare(animation: WindowInsetsAnimationCompat) {
        if (animation.typeMask and ime() != 0) {
            areKeyboardInsetsDeferred = true
        }
    }

    override fun onStart(
        animation: WindowInsetsAnimationCompat,
        bounds: WindowInsetsAnimationCompat.BoundsCompat,
    ): WindowInsetsAnimationCompat.BoundsCompat {
        if (animation.typeMask and ime() != 0) {
            keyboardAnimationInProgress = true

            // Workaround for https://issuetracker.google.com/issues/361027506
            // Compute the keyboard height based on the animation bounds, not live insets.
            // This correctly includes suggestion bar / toolbar height.
            keyboardHeight = bounds.upperBound.bottom - bounds.lowerBound.bottom

            // Workaround for https://issuetracker.google.com/issues/369223558
            // We expect the keyboard to have a bigger height than the OS navigation bar.
            if (keyboardHeight <= getNavbarHeight()) {
                keyboardHeight = 0
            }

            notifyKeyboardChange(
                calculateKeyboardHeight(keyboardHeight, getNavbarHeight()),
                isKeyboardShowingUp,
                isAnimating = true,
            )
        }

        return super.onStart(animation, bounds)
    }

    override fun onProgress(
        insets: WindowInsetsCompat,
        runningAnimations: MutableList<WindowInsetsAnimationCompat>,
    ): WindowInsetsCompat {
        if (!keyboardAnimationInProgress) return insets

        runningAnimations.firstOrNull { it.typeMask and ime() != 0 }?.let { imeAnimation ->
            // Ensure the fraction grows when keyboard is showing and shrinks when hiding
            val fraction = when (isKeyboardShowingUp) {
                true -> imeAnimation.interpolatedFraction
                false -> 1 - imeAnimation.interpolatedFraction
            }

            val currentHeight = calculateKeyboardHeight(
                (keyboardHeight * fraction).toInt(),
                getNavbarHeight(),
            )

            if (currentHeight != lastKeyboardHeight) {
                notifyKeyboardChange(currentHeight, currentHeight > 0, isAnimating = true)
            }
        }

        return insets
    }

    override fun onEnd(animation: WindowInsetsAnimationCompat) {
        keyboardAnimationInProgress = false

        if (areKeyboardInsetsDeferred && (animation.typeMask and ime()) != 0) {
            areKeyboardInsetsDeferred = false

            // Re-dispatch insets now that animation is complete.
            // This triggers onApplyWindowInsets with the final state.
            rootView?.let { view ->
                ViewCompat.getRootWindowInsets(view)?.let { insets ->
                    ViewCompat.dispatchApplyWindowInsets(view, insets)
                }
            }
        }
    }

    // --- OnApplyWindowInsetsListener implementation (API 30+) ---

    override fun onApplyWindowInsets(
        view: View,
        insets: WindowInsetsCompat,
    ): WindowInsetsCompat {
        isKeyboardShowingUp = insets.isVisible(ime())

        if (!areKeyboardInsetsDeferred) {
            val height = calculateKeyboardHeight(
                insets.getInsets(ime()).bottom,
                getNavbarHeight(),
            )
            notifyKeyboardChange(height, isKeyboardShowingUp, isAnimating = false)
        }

        return insets
    }

    // --- Legacy keyboard detection (pre-API 30) ---

    /**
     * Legacy keyboard detection using ViewTreeObserver (pre-API 30).
     */
    private fun setupLegacyKeyboardDetection(view: View) {
        globalLayoutListener = ViewTreeObserver.OnGlobalLayoutListener {
            val insets = ViewCompat.getRootWindowInsets(view) ?: return@OnGlobalLayoutListener

            val imeInsets = insets.getInsets(ime())
            val navInsets = insets.getInsets(navigationBars())

            val keyboardHeight = (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)
            val isVisible = keyboardHeight > 0

            if (keyboardHeight != lastKeyboardHeight || isVisible != lastKeyboardVisible) {
                notifyKeyboardChange(keyboardHeight, isVisible, isAnimating = false)
            }
        }

        view.viewTreeObserver.addOnGlobalLayoutListener(globalLayoutListener)
    }

    // --- Helper methods ---

    private fun getNavbarHeight(): Int =
        rootView?.let {
            ViewCompat.getRootWindowInsets(it)
                ?.getInsets(navigationBars())?.bottom
        } ?: 0

    private fun calculateKeyboardHeight(rawHeight: Int, navbarHeight: Int): Int =
        (rawHeight - navbarHeight).coerceAtLeast(0)

    /**
     * Notify Flutter about keyboard visibility change.
     */
    private fun notifyKeyboardChange(heightPx: Int, isVisible: Boolean, isAnimating: Boolean) {
        lastKeyboardHeight = heightPx
        lastKeyboardVisible = isVisible

        val sequence = EventSequence.next()

        logger.debug("$TAG: Keyboard change - height=$heightPx, visible=$isVisible, animating=$isAnimating")

        runOnUiThread {
            flutterEvents.onKeyboardVisibilityChanged(
                sequence,
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

            val imeVisible = insets.isVisible(ime())
            val imeInsets = insets.getInsets(ime())
            val navInsets = insets.getInsets(navigationBars())

            val keyboardHeight = if (imeVisible) {
                (imeInsets.bottom - navInsets.bottom).coerceAtLeast(0)
            } else {
                0
            }

            notifyKeyboardChange(keyboardHeight, imeVisible, isAnimating = false)
        }
    }
}
