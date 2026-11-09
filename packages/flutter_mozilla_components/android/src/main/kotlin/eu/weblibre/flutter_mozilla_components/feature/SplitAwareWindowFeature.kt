/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.window.WindowRequest
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.ktx.kotlinx.coroutines.flow.filterChanged

/**
 * AC 159.0's `WindowFeature` for the main browser, aware of split view.
 *
 * AC's feature watches every tab, not just the selected one, and opens each
 * `window.open` with `selectTab = true`. With two pages on screen that would
 * let the unfocused page take focus without the user touching it. This copy
 * differs in one place: a popup from a page that is on screen but not focused
 * opens in the background. Everything else, popups from the focused page or
 * from a background tab included, behaves exactly as before.
 *
 * Derived from android-components `WindowFeature` (MPL-2.0).
 *
 * @param visibleTabIds The tabs on screen right now.
 */
class SplitAwareWindowFeature(
    private val store: BrowserStore,
    private val tabsUseCases: TabsUseCases,
    private val visibleTabIds: () -> Set<String>,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
) : LifecycleAwareFeature {

    private var scope: CoroutineScope? = null

    override fun start() {
        scope = store.flowScoped(dispatcher = mainDispatcher) { flow ->
            flow
                .mapNotNull { state -> state.tabs }
                .filterChanged { it.content.windowRequest }
                .collect { tab ->
                    val windowRequest = tab.content.windowRequest
                    when (windowRequest?.type) {
                        WindowRequest.Type.CLOSE ->
                            consumeWindowRequest(tab.id) {
                                store.state.tabs
                                    .find { it.engineState.engineSession === windowRequest.prepare() }
                                    ?.let { tabsUseCases.removeTab(it.id) }
                            }
                        WindowRequest.Type.OPEN ->
                            consumeWindowRequest(tab.id) {
                                tabsUseCases.addTab(
                                    selectTab = shouldSelectPopupOf(tab.id),
                                    parentId = tab.id,
                                    engineSession = windowRequest.prepare(),
                                    private = tab.content.private,
                                    contextId = tab.contextId,
                                )
                                windowRequest.start()
                            }
                        else -> Unit
                    }
                }
        }
    }

    internal fun shouldSelectPopupOf(openerId: String): Boolean =
        openerId == store.state.selectedTabId || openerId !in visibleTabIds()

    private fun consumeWindowRequest(tabId: String, consume: () -> Unit) {
        consume()
        store.dispatch(ContentAction.ConsumeWindowRequestAction(tabId))
    }

    override fun stop() {
        scope?.cancel()
    }
}
