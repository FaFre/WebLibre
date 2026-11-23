/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.CookieManagerFeature
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycleRegistry
import eu.weblibre.flutter_mozilla_components.feature.BrowserExtensionFeature
import eu.weblibre.flutter_mozilla_components.feature.BuiltInExtensionInstalls
import eu.weblibre.flutter_mozilla_components.feature.MLEngineFeature
import eu.weblibre.flutter_mozilla_components.feature.ReadabilityExtractFeature
import eu.weblibre.flutter_mozilla_components.feature.ReaderViewAppearanceFeature
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureFeature
import eu.weblibre.flutter_mozilla_components.pigeons.BounceTrackingProtectionMode
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import mozilla.components.browser.engine.gecko.GeckoEngine
import mozilla.components.browser.engine.gecko.fetch.GeckoViewFetchClient
import mozilla.components.concept.engine.DefaultSettings
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.fetch.Client
import mozilla.components.feature.webcompat.WebCompatFeature
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.mozilla.geckoview.ContentBlocking
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.GeckoRuntimeSettings

/**
 * The runtime's lifetime, which is the process's lifetime.
 *
 * A nullable runtime cannot express the difference between "not created yet" and
 * "created and shut down", and those two must not behave alike: GeckoView keeps
 * its own static reference to the runtime it created, so `shutdown()` does not
 * return the process to a state where another runtime can be built. Re-creating
 * after a shutdown fails somewhere deep inside GeckoView instead of here, which
 * is far harder to attribute.
 */
sealed interface GeckoRuntimeState {
    data object NeverCreated : GeckoRuntimeState

    data class Live(val profileId: String, val runtime: GeckoRuntime) : GeckoRuntimeState

    data class Shutdown(val profileId: String) : GeckoRuntimeState
}

object EngineProvider {
    private const val LOG_TAG = "WebLibreFreeze"

    private var state: GeckoRuntimeState = GeckoRuntimeState.NeverCreated

    @Synchronized
    fun runtimeState(): GeckoRuntimeState = state

    private val components: Components
        get() = requireNotNull(GlobalComponents.components) { "Components not initialized" }

    /**
     * The runtime for the committed profile, created on first use.
     *
     * Every creation path funnels through here so the identity check cannot be
     * bypassed: the process profile is decided once by [StartupArbiter], and a
     * runtime built for any other profile would read a different Gecko data
     * directory than the rest of the process, permanently.
     */
    @Synchronized
    fun getOrCreateRuntime(context: Context): GeckoRuntime {
        val profileId = StartupArbiter.committedProfileId()
            ?: error("Refusing to create a GeckoRuntime before this process committed a profile")

        when (val current = state) {
            is GeckoRuntimeState.Live -> {
                if (current.profileId != profileId) {
                    error(
                        "GeckoRuntime is bound to ${current.profileId} but $profileId was " +
                            "requested; the process profile is immutable",
                    )
                }
                return current.runtime
            }

            is GeckoRuntimeState.Shutdown -> error(
                "GeckoRuntime was shut down for ${current.profileId}; this process cannot " +
                    "create another and must restart",
            )

            GeckoRuntimeState.NeverCreated -> Unit
        }

        return run {
            Logger.debug("Creating Runtime")
            val builder = GeckoRuntimeSettings.Builder()
            val contentBlocking = ContentBlocking.Settings.Builder();

            contentBlocking.bounceTrackingProtectionMode(
                when (components.contentBlocking.bounceTrackingProtectionMode) {
                    BounceTrackingProtectionMode.ENABLED -> EngineSession.BounceTrackingProtectionMode.ENABLED.mode
                    BounceTrackingProtectionMode.DISABLED -> EngineSession.BounceTrackingProtectionMode.DISABLED.mode
                    BounceTrackingProtectionMode.ENABLED_STANDBY -> EngineSession.BounceTrackingProtectionMode.ENABLED_STANDBY.mode
                    BounceTrackingProtectionMode.ENABLED_DRY_RUN -> EngineSession.BounceTrackingProtectionMode.ENABLED_DRY_RUN.mode
                }
            )

            contentBlocking.queryParameterStrippingEnabled(
                when (components.contentBlocking.queryParameterStripping) {
                    QueryParameterStripping.ENABLED -> true
                    QueryParameterStripping.DISABLED -> false
                    QueryParameterStripping.PRIVATE_ONLY -> false
                }
            )

            contentBlocking.queryParameterStrippingPrivateBrowsingEnabled(
                when (components.contentBlocking.queryParameterStripping) {
                    QueryParameterStripping.ENABLED -> true
                    QueryParameterStripping.DISABLED -> false
                    QueryParameterStripping.PRIVATE_ONLY -> true
                }
            )

            if (components.contentBlocking.queryParameterStrippingAllowList.isNotEmpty()) {
                contentBlocking.queryParameterStrippingAllowList(
                    components.contentBlocking.queryParameterStrippingAllowList,
                )
            }
            if (components.contentBlocking.queryParameterStrippingStripList.isNotEmpty()) {
                contentBlocking.queryParameterStrippingStripList(
                    components.contentBlocking.queryParameterStrippingStripList,
                )
            }

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

            // Apply builder-only settings from startup config
            GlobalComponents.startupSettings?.let { settings ->
                settings.fissionEnabled?.let { builder.fissionEnabled(it) }
                settings.isolatedProcessEnabled?.let { builder.isolatedProcessEnabled(it) }
                settings.appZygoteProcessEnabled?.let { builder.appZygoteProcessEnabled(it) }
                settings.extensionsWebAPIEnabled?.let { builder.extensionsWebAPIEnabled(it) }
                settings.displayDensityOverride?.let { builder.displayDensityOverride(it.toFloat()) }
                val screenWidth = settings.screenWidthOverride
                val screenHeight = settings.screenHeightOverride
                if (screenWidth != null && screenHeight != null && screenWidth > 0 && screenHeight > 0) {
                    builder.screenSizeOverride(screenWidth.toInt(), screenHeight.toInt())
                }
            }

            // E1: frozen containers are restricted from Gecko's first instruction,
            // on every path that creates the runtime (5.6). Derived from the one
            // durable record each time; Gecko never persists it.
            TabLifecycleRegistry.attach(context)
            val restricted = TabLifecycleRegistry.restrictedContexts()
            if (restricted.isNotEmpty()) {
                // Straight to logcat, under the tag the freeze checks read: AC's
                // Logger goes through Dart once a Flutter engine is attached,
                // and this is the line that shows E1 held on every kind of start.
                android.util.Log.i(LOG_TAG, "Restricting session contexts from startup: $restricted")
                builder.restrictedSessionContexts(restricted)
            }

            val created = GeckoRuntime.create(context, builder.build())
            state = GeckoRuntimeState.Live(profileId, created)
            created
        }
    }

    fun createEngine(
        context: Context,
        defaultSettings: DefaultSettings,
        extensionEvents: BrowserExtensionEvents,
        stateEvents: GeckoStateEvents
    ): Engine {
        Logger.debug("Creating Engine")
        val runtime = getOrCreateRuntime(context)

        return GeckoEngine(context, defaultSettings, runtime).also {
            // A5: a page of a restricted context opens no window, whichever
            // session it runs in (process-wide in AC).
            it.windowRequestGate = { openerContextId -> !TabLifecycleRegistry.isRestricted(openerContextId) }
            WebCompatFeature.install(it)
            //CookieManagerFeature.install(it)
            ContainerProxyFeature.install(it, stateEvents)
            BrowserExtensionFeature.install(it, extensionEvents)
            MLEngineFeature.install(it)

            //Install extensions early
            BuiltInExtensionInstalls.install(
                ReadabilityExtractFeature.READER_EXTRACT_EXTENSION_ID,
                BuiltInWebExtensionController(
                    ReadabilityExtractFeature.READER_EXTRACT_EXTENSION_ID,
                    ReadabilityExtractFeature.READER_EXTRACT_EXTENSION_URL,
                    ReadabilityExtractFeature.READER_EXTRACT_CONTENT_PORT,
                ),
                it,
            )

            SandboxCaptureFeature.install(it)

            // Installs Mozilla's reader view extension early and wires the
            // WebLibre "pure black" (AMOLED) appearance bridge into it.
            ReaderViewAppearanceFeature.install(
                it,
                PreferenceManager.getDefaultSharedPreferences(context),
            )
        }
    }

    fun createClient(context: Context): Client {
        Logger.debug("Fetching Client")
        val runtime = getOrCreateRuntime(context)
        return GeckoViewFetchClient(context, runtime)
    }

    /**
     * Shuts the runtime down and marks the process terminal for Gecko.
     *
     * The state does not go back to [GeckoRuntimeState.NeverCreated]. Recording
     * which profile it was is what lets a later creation attempt say why it is
     * refused instead of failing inside GeckoView.
     */
    @Synchronized
    fun shutdown() {
        val current = state
        if (current is GeckoRuntimeState.Live) {
            Logger.debug("Shutting down GeckoRuntime")
            current.runtime.shutdown()
            state = GeckoRuntimeState.Shutdown(current.profileId)
        }
    }
}
