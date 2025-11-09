/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.CookieManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.PrefManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.BrowserExtensionFeature
import eu.weblibre.flutter_mozilla_components.feature.MLEngineFeature
import eu.weblibre.flutter_mozilla_components.pigeons.BounceTrackingProtectionMode
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import mozilla.components.browser.engine.gecko.GeckoEngine
import mozilla.components.browser.engine.gecko.fetch.GeckoViewFetchClient
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.webcompat.WebCompatFeature
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.geckoview.ContentBlocking
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoRuntimeSettings

object EngineProvider {
    private var runtime: GeckoRuntime? = null

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    @Synchronized
    fun getOrCreateRuntime(context: Context): GeckoRuntime {
        if (runtime == null) {
            Logger.debug("Creating Runtime")
            val builder = GeckoRuntimeSettings.Builder()
            val contentBlocking = ContentBlocking.Settings.Builder();

            contentBlocking.bounceTrackingProtectionMode(when(components.contentBlocking.bounceTrackingProtectionMode) {
                BounceTrackingProtectionMode.ENABLED -> EngineSession.BounceTrackingProtectionMode.ENABLED.mode
                BounceTrackingProtectionMode.DISABLED -> EngineSession.BounceTrackingProtectionMode.DISABLED.mode
                BounceTrackingProtectionMode.ENABLED_STANDBY -> EngineSession.BounceTrackingProtectionMode.ENABLED_STANDBY.mode
                BounceTrackingProtectionMode.ENABLED_DRY_RUN -> EngineSession.BounceTrackingProtectionMode.ENABLED_DRY_RUN.mode
            })

            contentBlocking.queryParameterStrippingEnabled(when(components.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> false
            })

            contentBlocking.queryParameterStrippingPrivateBrowsingEnabled(when(components.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> true
            })

            contentBlocking.queryParameterStrippingAllowList(components.contentBlocking.queryParameterStrippingAllowList)
            contentBlocking.queryParameterStrippingStripList(components.contentBlocking.queryParameterStrippingStripList)

//            if (isCrashReportActive) {
//                builder.crashHandler(CrashHandlerService::class.java)
//            }

            // About config it's no longer enabled by default
            builder.aboutConfigEnabled(true)
            builder.extensionsProcessEnabled(true)
            builder.extensionsWebAPIEnabled(true)
            //builder.debugLogging(components.logLevel == Log.Priority.DEBUG)
            builder.consoleOutput(components.logLevel == Log.Priority.DEBUG)
            builder.contentBlocking(contentBlocking.build())
            builder.locales(arrayOf("en-US", "en")) // Will be overridden later

            runtime = GeckoRuntime.create(context, builder.build())
        }

        return runtime!!
    }

    fun createEngine(context: Context, defaultSettings: DefaultSettings, extensionEvents: BrowserExtensionEvents, stateEvents: GeckoStateEvents): Engine {
        Logger.debug("Creating Engine")
        val runtime = getOrCreateRuntime(context)

        return GeckoEngine(context, defaultSettings, runtime).also {
            WebCompatFeature.install(it)
            //CookieManagerFeature.install(it)
            PrefManagerFeature.install(it)
            ContainerProxyFeature.install(it, stateEvents)
            BrowserExtensionFeature.install(it, extensionEvents)
            MLEngineFeature.install(it)
        }
    }

    fun createClient(context: Context): Client {
        Logger.debug("Fetching Client")
        val runtime = getOrCreateRuntime(context)
        return GeckoViewFetchClient(context, runtime)
    }
}
