/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.content.Context
import eu.weblibre.flutter_mozilla_components.split.BrowserPanes
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.map
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.ktx.android.content.isOSOnLowMemory
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged

/**
 * Captures a thumbnail of the selected tab once it finished loading, from the
 * pane that actually shows it.
 *
 * Replaces AC's `BrowserThumbnails` in the main browser. That one captures the
 * single engine view it was built with and stores the bitmap under whatever
 * tab is selected when the capture returns. With two panes the view it holds
 * can show one tab while the other is selected, which would store one page's
 * pixels as the other's thumbnail. This captures the selected tab's own view
 * and stores the bitmap under the id it was taken for.
 */
class PaneThumbnailsFeature(
    private val context: Context,
    private val panes: () -> BrowserPanes?,
    private val store: BrowserStore,
    private val dispatcher: CoroutineDispatcher = Dispatchers.Main,
) : LifecycleAwareFeature {
    private var scope: CoroutineScope? = null

    override fun start() {
        scope = store.flowScoped(dispatcher = dispatcher) { flow ->
            flow.map { it.selectedTab }
                .ifAnyChanged {
                    arrayOf(it?.content?.loading, it?.content?.firstContentfulPaint)
                }
                .collect { tab ->
                    if (tab != null && !tab.content.loading && tab.content.firstContentfulPaint) {
                        requestScreenshot(tab.id)
                    }
                }
        }
    }

    private fun requestScreenshot(tabId: String) {
        if (context.isOSOnLowMemory()) return
        val engineView = panes()?.engineViewFor(tabId) ?: return
        // A local reference, so the callback does not keep this feature (and
        // through it the context) alive past the view.
        val store = this.store
        engineView.captureThumbnail { bitmap ->
            if (bitmap != null) {
                store.dispatch(ContentAction.UpdateThumbnailAction(tabId, bitmap))
            }
        }
    }

    override fun stop() {
        scope?.cancel()
    }
}
