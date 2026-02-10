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
 * Toolbar height and vertical clipping target the main browser's EngineView specifically,
 * not the active/foreground EngineView. This prevents toolbar settings from leaking
 * to PWA/Custom Tab EngineViews.
 *
 * If the main browser EngineView is not yet available when setDynamicToolbarMaxHeight
 * is called, the value is stored and applied when the EngineView becomes available.
 */
class GeckoViewportApiImpl : GeckoViewportApi {
    companion object {
        private const val TAG = "GeckoViewportApi"
    }

    private val logger = Logger(TAG)

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private var pendingToolbarHeight: Int? = null

    /**
     * Sets the maximum height that dynamic toolbars (top + bottom) can occupy.
     *
     * Targets the main browser EngineView specifically. If the main browser
     * EngineView is not yet available, the height is stored and applied when
     * it becomes available via [applyPendingToolbarHeight].
     */
    override fun setDynamicToolbarMaxHeight(heightPx: Long) {
        val height = heightPx.toInt()

        val engineView = components.mainBrowserEngineView
        if (engineView == null) {
            logger.debug("$TAG: setDynamicToolbarMaxHeight($height) - mainBrowserEngineView not ready, storing as pending")
            pendingToolbarHeight = height
            return
        }

        pendingToolbarHeight = null
        logger.debug("$TAG: setDynamicToolbarMaxHeight($height)")
        engineView.setDynamicToolbarMaxHeight(height)
    }

    /**
     * Applies any pending toolbar height to the main browser EngineView.
     * Called when mainBrowserEngineView becomes available.
     */
    fun applyPendingToolbarHeight() {
        val pending = pendingToolbarHeight ?: return
        val engineView = components.mainBrowserEngineView ?: return
        pendingToolbarHeight = null
        logger.debug("$TAG: Applying pending toolbar height: $pending")
        engineView.setDynamicToolbarMaxHeight(pending)
    }

    /**
     * Sets the vertical clipping offset for the GeckoView content.
     *
     * Targets the main browser EngineView specifically.
     */
    override fun setVerticalClipping(clippingPx: Long) {
        val clipping = clippingPx.toInt()

        val engineView = components.mainBrowserEngineView
        if (engineView == null) {
            logger.warn("$TAG: setVerticalClipping called but mainBrowserEngineView is null")
            return
        }

        logger.debug("$TAG: setVerticalClipping($clipping)")
        engineView.setVerticalClipping(clipping)
    }
}
