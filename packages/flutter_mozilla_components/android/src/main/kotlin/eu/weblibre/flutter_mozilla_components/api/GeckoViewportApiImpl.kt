/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportApi
import mozilla.components.concept.engine.EngineView

/**
 * Implementation of GeckoViewportApi that controls GeckoView's viewport behavior
 * for dynamic toolbar and keyboard handling.
 *
 * Toolbar height and vertical clipping target the main browser's EngineViews specifically
 * (every split pane), not the active/foreground EngineView. This prevents toolbar settings
 * from leaking to PWA/Custom Tab EngineViews.
 *
 * If no main browser EngineView is available yet when setDynamicToolbarMaxHeight
 * is called, the value is stored and applied when one becomes available. A pane
 * created later gets the current values through [applyToNewEngineView].
 */
class GeckoViewportApiImpl : GeckoViewportApi {
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
        GlobalComponents.dynamicToolbarMaxHeightPx = height
        GlobalComponents.notifyBottomViewportInsetChanged()

        val engineViews = components.browserPanes?.allEngineViews.orEmpty()
        if (engineViews.isEmpty()) {
            pendingToolbarHeight = height
            return
        }

        pendingToolbarHeight = null
        engineViews.forEach { it.setDynamicToolbarMaxHeight(height) }
    }

    /**
     * Applies any pending toolbar height to the main browser EngineView.
     * Called when the main browser's panes become available.
     */
    fun applyPendingToolbarHeight() {
        val pending = pendingToolbarHeight ?: return
        val engineViews = components.browserPanes?.allEngineViews.orEmpty()
        if (engineViews.isEmpty()) return
        pendingToolbarHeight = null
        engineViews.forEach { it.setDynamicToolbarMaxHeight(pending) }
    }

    /** Gives a split pane created after the fact the values its sibling has. */
    fun applyToNewEngineView(engineView: EngineView) {
        engineView.setDynamicToolbarMaxHeight(
            pendingToolbarHeight ?: GlobalComponents.dynamicToolbarMaxHeightPx,
        )
        engineView.setVerticalClipping(GlobalComponents.verticalClippingPx)
    }

    /**
     * Sets the vertical clipping offset for the GeckoView content.
     *
     * Targets the main browser EngineView specifically.
     */
    override fun setVerticalClipping(clippingPx: Long) {
        val clipping = clippingPx.toInt()
        GlobalComponents.verticalClippingPx = clipping
        GlobalComponents.notifyBottomViewportInsetChanged()

        components.browserPanes?.allEngineViews?.forEach { it.setVerticalClipping(clipping) }
    }
}
