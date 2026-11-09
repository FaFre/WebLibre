/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import mozilla.components.concept.engine.EngineView

/**
 * The main browser's engine views, replacing the single
 * `mainBrowserEngineView`. With split view there are up to two, and which one
 * a caller wants depends on the call: the focused page, a specific tab's page,
 * or all of them.
 *
 * Set by the browser fragment while its view exists, and only by it: Custom
 * Tabs and PWAs keep their own engine view.
 */
interface BrowserPanes {
    /** The engine view of the selected tab, which is always the focused pane. */
    val focusedEngineView: EngineView?

    /** Every engine view the main browser created, shown or not. */
    val allEngineViews: List<EngineView>

    /** Tabs whose page is on screen right now (one, or both of a pair). */
    val visibleTabIds: Set<String>

    /**
     * The tabs the browser presented last, kept while it is stopped (when
     * [visibleTabIds] is empty because the pages were released). What the
     * user comes back to.
     */
    val lastPresentedTabIds: Set<String>

    /** The engine view currently bound to [tabId], or null. */
    fun engineViewFor(tabId: String): EngineView?

    /** Whether a stroke at these screen coordinates belongs to the divider. */
    fun isDividerHitOnScreen(rawX: Float, rawY: Float): Boolean

    /** Applies the latest store and split state now, on the main thread. */
    fun reconcileNow()
}
