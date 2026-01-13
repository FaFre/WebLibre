/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportApi
import mozilla.components.support.base.log.logger.Logger

/**
 * Implementation of GeckoViewportApi that controls GeckoView's viewport behavior
 * for dynamic toolbar and keyboard handling.
 *
 * This allows Flutter to control how GeckoView adjusts its internal viewport
 * without resizing the platform view itself, avoiding visual flickering.
 */
class GeckoViewportApiImpl : GeckoViewportApi {
    companion object {
        private const val TAG = "GeckoViewportApi"
    }

    private val logger = Logger(TAG)

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    // Store the current dynamic toolbar max height
    private var currentDynamicToolbarMaxHeight: Int = 0

    /**
     * Sets the maximum height that dynamic toolbars (top + bottom) can occupy.
     *
     * GeckoView will adjust its internal viewport calculations to account for
     * this space. The website will receive proper viewport dimensions through
     * standard web APIs (CSS viewport units, window.innerHeight).
     */
    override fun setDynamicToolbarMaxHeight(heightPx: Long) {
        val height = heightPx.toInt()
        currentDynamicToolbarMaxHeight = height

        val engineView = components.engineView
        if (engineView == null) {
            logger.warn("$TAG: setDynamicToolbarMaxHeight called but engineView is null")
            return
        }

        logger.debug("$TAG: setDynamicToolbarMaxHeight($height)")
        engineView.setDynamicToolbarMaxHeight(height)
    }

    /**
     * Sets the vertical clipping offset for the GeckoView content.
     *
     * Use this as the toolbar animates to clip content at the bottom.
     * Negative values clip from the bottom (for bottom toolbar sliding up).
     * Positive values clip from the top (for top toolbar sliding down).
     */
    override fun setVerticalClipping(clippingPx: Long) {
        val clipping = clippingPx.toInt()

        val engineView = components.engineView
        if (engineView == null) {
            logger.warn("$TAG: setVerticalClipping called but engineView is null")
            return
        }

        logger.debug("$TAG: setVerticalClipping($clipping)")
        engineView.setVerticalClipping(clipping)
    }

    /**
     * Applies any pending viewport settings that were set before engineView was available.
     *
     * Call this method after setting components.engineView to ensure that any
     * setDynamicToolbarMaxHeight calls made during startup are properly applied.
     */
    fun applyPendingSettings() {
        val engineView = components.engineView
        if (engineView == null) {
            logger.warn("$TAG: applyPendingSettings called but engineView is still null")
            return
        }

        if (currentDynamicToolbarMaxHeight > 0) {
            logger.debug("$TAG: Applying pending dynamicToolbarMaxHeight: $currentDynamicToolbarMaxHeight")
            engineView.setDynamicToolbarMaxHeight(currentDynamicToolbarMaxHeight)
        }
    }
}
