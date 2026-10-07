/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Intent
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.state.CustomTabConfig
import mozilla.components.browser.state.state.ExternalAppType
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.concept.engine.EngineSession

object PwaSessionCreator {
    /**
     * The desktop mode a PWA launch asks for, or null when its shortcut predates
     * [PwaConstants.EXTRA_PWA_DESKTOP_MODE].
     */
    fun desktopModeOf(intent: Intent?): Boolean? {
        if (intent?.hasExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE) != true) return null
        return intent.getBooleanExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE, false)
    }

    /**
     * Creates the PWA's session in [desktopMode], falling back to the
     * browser-wide default when the shortcut does not say.
     *
     * It has to be set here: the engine session is created from the tab's own
     * `desktopMode` (`CreateEngineSessionMiddleware`), and `createCustomTab`
     * defaults that to false, so a PWA would otherwise always open mobile.
     */
    suspend fun create(url: String, contextId: String?, desktopMode: Boolean?): String {
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
                desktopMode = desktopMode ?: components.core.store.state.desktopMode,
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
