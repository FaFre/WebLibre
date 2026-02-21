/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.components

import android.content.Context
import android.content.Intent
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.net.toUri
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.activities.AuthIntentReceiverActivity
import eu.weblibre.flutter_mozilla_components.ext.getPreferenceKey
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.accounts.FirefoxAccountsAuthFeature
import mozilla.components.feature.accounts.FxaCapability
import mozilla.components.feature.accounts.FxaWebChannelFeature
import mozilla.components.feature.app.links.AppLinksInterceptor
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.service.fxa.ServerConfig
import mozilla.components.service.fxa.manager.FxaAccountManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * Component group which encapsulates foreground-friendly services.
 */
class Services(
    private val context: Context,
    private val store: BrowserStore,
    private val tabsUseCases: TabsUseCases,
    accountManager: FxaAccountManager,
    private val engine: Engine,
    private val serverConfig: ServerConfig,
) {
    private val prefs = PreferenceManager.getDefaultSharedPreferences(context)

    val accountsAuthFeature by lazy {
        FirefoxAccountsAuthFeature(accountManager, FxaServer.REDIRECT_URL) { _, authUrl ->
            CoroutineScope(Dispatchers.Main).launch {
                val intent = CustomTabsIntent.Builder()
                    .setInstantAppsEnabled(false)
                    .build()
                    .intent
                    .setData(authUrl.toUri())
                    .setClassName(context, AuthIntentReceiverActivity::class.java.name)
                    .setPackage(context.packageName)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
            }
        }
    }

    val fxaWebChannelFeature by lazy {
        FxaWebChannelFeature(
            customTabSessionId = null,
            runtime = engine,
            store = store,
            accountManager = accountManager,
            serverConfig = serverConfig,
            fxaCapabilities = setOf(FxaCapability.CHOOSE_WHAT_TO_SYNC),
        )
    }

    val appLinksInterceptor by lazy {
        AppLinksInterceptor(
            context = context,
            launchInApp = { GlobalComponents.shouldOpenLinksInApp() },
            store = store,
        )
    }
}
