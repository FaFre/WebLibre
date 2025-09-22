/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.app.links.AppLinksUseCases
import mozilla.components.feature.downloads.DownloadsUseCases
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.session.SettingsUseCases
import mozilla.components.feature.session.TrackingProtectionUseCases
import mozilla.components.feature.tabs.CustomTabsUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.feature.pwa.WebAppShortcutManager
import mozilla.components.feature.pwa.WebAppUseCases

/**
 * Component group for all use cases. Use cases are provided by feature
 * modules and can be triggered by UI interactions.
 */
class UseCases(
    private val context: Context,
    private val engine: Engine,
    private val store: BrowserStore,
    private val shortcutManager: WebAppShortcutManager,
) {
    /**
     * Use cases that provide engine interactions for a given browser session.
     */
    val sessionUseCases by lazy { SessionUseCases(store) }

    /**
     * Use cases that provide tab management.
     */
    val tabsUseCases: TabsUseCases by lazy { TabsUseCases(store) }

    /**
     * Use cases that provide settings management.
     */
    val settingsUseCases by lazy { SettingsUseCases(engine, store) }

    /**
     * Use cases related to the downloads feature.
     */
    val downloadsUseCases: DownloadsUseCases by lazy { DownloadsUseCases(store) }

    /**
     * Use cases related to Custom Tabs.
     */
    val customTabsUseCases: CustomTabsUseCases by lazy { CustomTabsUseCases(store, sessionUseCases.loadUrl) }

    val appLinksUseCases by lazy { AppLinksUseCases(context) }

    val webAppUseCases by lazy {
        WebAppUseCases(context, store, shortcutManager)
    }

    //val trackingProtectionUseCases by lazy { TrackingProtectionUseCases(store, engine) }
}
