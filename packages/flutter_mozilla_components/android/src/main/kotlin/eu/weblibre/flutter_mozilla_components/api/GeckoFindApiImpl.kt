/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoFindApi
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.EngineSession

class GeckoFindApiImpl : GeckoFindApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun sessionByTabId(tabId: String?) : EngineSession? {
        val loadSessionId = tabId
            ?: components.core.store.state.selectedTabId

        if (loadSessionId == null) {
            return null
        }

        val tab = components.core.store.state.findTabOrCustomTab(loadSessionId)
        return tab?.engineState?.engineSession
    }

    override fun findAll(tabId: String?, text: String) {
        val engineSession = sessionByTabId(tabId)
        engineSession?.findAll(text)
    }

    override fun findNext(tabId: String?, forward: Boolean) {
        val engineSession = sessionByTabId(tabId)
        engineSession?.findNext(forward)
    }

    override fun clearMatches(tabId: String?) {
        val loadSessionId = tabId
            ?: components.core.store.state.selectedTabId

        if (loadSessionId == null) {
            return
        }

        val engineSession = sessionByTabId(loadSessionId)
        engineSession?.clearFindMatches()
        components.core.store.dispatch(ContentAction.ClearFindResultsAction(loadSessionId))
    }
}