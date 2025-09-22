/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// We need to do full suppressing as we have a import, that is deprecated.
// Follow-up https://github.com/mozilla-mobile/fenix/issues/25091

@file:Suppress("DEPRECATION")

package eu.weblibre.flutter_mozilla_components.intent

import android.content.Context
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.customtabs.CustomTabIntentProcessor
import mozilla.components.feature.pwa.ManifestStorage
import mozilla.components.feature.pwa.intent.WebAppIntentProcessor
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.tabs.CustomTabsUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.feature.webnotifications.WebNotificationIntentProcessor

/**
 * Component group for miscellaneous components.
 */
@Suppress("LongParameterList")
class IntentProcessors(
    private val context: Context,
    private val store: BrowserStore,
    private val sessionUseCases: SessionUseCases,
    private val tabsUseCases: TabsUseCases,
    private val customTabsUseCases: CustomTabsUseCases,
    private val manifestStorage: ManifestStorage,
    private val engine: Engine,
) {
//    val customTabIntentProcessor by lazy {
//        CustomTabIntentProcessor(customTabsUseCases.add, context.resources, isPrivate = false)
//    }
//
//    val privateCustomTabIntentProcessor by lazy {
//        CustomTabIntentProcessor(customTabsUseCases.add, context.resources, isPrivate = true)
//    }

    val externalAppIntentProcessors by lazy {
        listOf(
            WebAppIntentProcessor(store, customTabsUseCases.addWebApp, sessionUseCases.loadUrl, manifestStorage),
            WebLibreWebAppIntentProcessor(context, customTabsUseCases, manifestStorage),
        )
    }

    val webNotificationsIntentProcessor by lazy {
        WebNotificationIntentProcessor(engine)
    }
}
