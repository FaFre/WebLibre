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
import kotlinx.coroutines.flow.distinctUntilChangedBy
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.window.WindowRequest
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature

/**
 * Handles popup/window requests inside a standalone PWA session.
 */
class PwaWindowFeature(
    private val store: BrowserStore,
    private val loadUrlUseCase: SessionUseCases.DefaultLoadUrlUseCase,
    private val sessionId: String,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
) : LifecycleAwareFeature {

    private var scope: CoroutineScope? = null

    override fun start() {
        scope = store.flowScoped(dispatcher = mainDispatcher) { flow ->
            flow.mapNotNull { state -> state.findCustomTab(sessionId) }
                .distinctUntilChangedBy { it.content.windowRequest }
                .collect { state ->
                    val windowRequest = state.content.windowRequest
                    if (windowRequest?.type == WindowRequest.Type.OPEN) {
                        if (windowRequest.url.isNotBlank()) {
                            loadUrlUseCase(
                                windowRequest.url,
                                sessionId,
                                EngineSession.LoadUrlFlags.external(),
                            )
                        }

                        store.dispatch(ContentAction.ConsumeWindowRequestAction(sessionId))
                    }
                }
        }
    }

    override fun stop() {
        scope?.cancel()
        scope = null
    }
}
