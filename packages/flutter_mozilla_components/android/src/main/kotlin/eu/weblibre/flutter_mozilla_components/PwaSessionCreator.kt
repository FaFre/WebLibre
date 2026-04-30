/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.state.CustomTabConfig
import mozilla.components.browser.state.state.ExternalAppType
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.concept.engine.EngineSession

object PwaSessionCreator {
    suspend fun create(url: String, contextId: String?): String {
        val components = GlobalComponents.components
            ?: throw IllegalStateException("Components not initialized")

        val manifest = withContext(Dispatchers.IO) {
            components.core.webAppManifestStorage.loadManifest(url)
        }

        return withContext(Dispatchers.Main) {
            val customTabConfig = CustomTabConfig(
                externalAppType = ExternalAppType.PROGRESSIVE_WEB_APP,
            )

            val tab = createCustomTab(
                url = url,
                contextId = contextId,
                config = customTabConfig,
                webAppManifest = manifest,
                source = SessionState.Source.Internal.CustomTab,
                private = false,
            )

            components.core.store.dispatch(
                CustomTabListAction.AddCustomTabAction(tab),
            )

            val loadUrlFlags = EngineSession.LoadUrlFlags.external()
            components.useCases.sessionUseCases.loadUrl(url, tab.id, loadUrlFlags)

            tab.id
        }
    }
}
