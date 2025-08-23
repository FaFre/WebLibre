/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.ColorScheme
import eu.weblibre.flutter_mozilla_components.pigeons.CookieBannerHandlingMode
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.HttpsOnlyMode
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.WebContentIsolationStrategy
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.engine.mediaquery.PreferredColorScheme
import mozilla.components.feature.addons.logger
import mozilla.components.feature.session.SettingsUseCases
import mozilla.components.feature.session.TrackingProtectionUseCases

/**
 * Implementation of GeckoEngineSettingsApi that manages engine-specific settings
 */
class GeckoEngineSettingsApiImpl : GeckoEngineSettingsApi {
    companion object {
        private const val TAG = "GeckoEngineSettingsApi"
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun updateFingerprintingProtection(trackingProtectionPolicy: eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy) {
        when(trackingProtectionPolicy) {
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> {
                components.core.engineSettings.fingerprintingProtection = true
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> TODO()
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
        }
    }

    override fun setDefaultSettings(settings: GeckoEngineSettings) {
        if(settings.javascriptEnabled != null) {
            components.core.engineSettings.javascriptEnabled = settings.javascriptEnabled;
        }
        if(settings.trackingProtectionPolicy != null) {
            components.core.engineSettings.trackingProtectionPolicy = when(settings.trackingProtectionPolicy) {
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> TrackingProtectionPolicy.none()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> TrackingProtectionPolicy.recommended()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> TrackingProtectionPolicy.strict()
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> TODO()
            }

            updateFingerprintingProtection(settings.trackingProtectionPolicy)
        }
        if(settings.httpsOnlyMode != null) {
            components.core.engineSettings.httpsOnlyMode = when(settings.httpsOnlyMode) {
                HttpsOnlyMode.DISABLED -> Engine.HttpsOnlyMode.DISABLED
                HttpsOnlyMode.PRIVATE_ONLY -> Engine.HttpsOnlyMode.ENABLED_PRIVATE_ONLY
                HttpsOnlyMode.ENABLED -> Engine.HttpsOnlyMode.ENABLED
            }
        }
        if(settings.globalPrivacyControlEnabled != null) {
            components.core.engineSettings.globalPrivacyControlEnabled = settings.globalPrivacyControlEnabled;
        }
        if(settings.preferredColorScheme != null) {
            components.core.engineSettings.preferredColorScheme = when(settings.preferredColorScheme) {
                ColorScheme.SYSTEM -> PreferredColorScheme.System
                ColorScheme.LIGHT -> PreferredColorScheme.Light
                ColorScheme.DARK -> PreferredColorScheme.Dark
            }
        }
        if(settings.cookieBannerHandlingMode != null) {
            components.core.engineSettings.cookieBannerHandlingMode = when(settings.cookieBannerHandlingMode) {
                CookieBannerHandlingMode.DISABLED -> EngineSession.CookieBannerHandlingMode.DISABLED
                CookieBannerHandlingMode.REJECT_ALL -> EngineSession.CookieBannerHandlingMode.REJECT_ALL
                CookieBannerHandlingMode.REJECT_OR_ACCEPT_ALL -> EngineSession.CookieBannerHandlingMode.REJECT_OR_ACCEPT_ALL
            }
        }
        if(settings.cookieBannerHandlingModePrivateBrowsing != null) {
            components.core.engineSettings.cookieBannerHandlingModePrivateBrowsing = when(settings.cookieBannerHandlingModePrivateBrowsing) {
                CookieBannerHandlingMode.DISABLED -> EngineSession.CookieBannerHandlingMode.DISABLED
                CookieBannerHandlingMode.REJECT_ALL -> EngineSession.CookieBannerHandlingMode.REJECT_ALL
                CookieBannerHandlingMode.REJECT_OR_ACCEPT_ALL -> EngineSession.CookieBannerHandlingMode.REJECT_OR_ACCEPT_ALL
            }
        }
        if(settings.cookieBannerHandlingGlobalRules != null) {
            components.core.engineSettings.cookieBannerHandlingGlobalRules = settings.cookieBannerHandlingGlobalRules;
        }
        if(settings.cookieBannerHandlingGlobalRulesSubFrames != null) {
            components.core.engineSettings.cookieBannerHandlingGlobalRulesSubFrames = settings.cookieBannerHandlingGlobalRulesSubFrames;
        }
        if(settings.webContentIsolationStrategy != null) {
            components.core.engineSettings.webContentIsolationStrategy = when(settings.webContentIsolationStrategy) {
                WebContentIsolationStrategy.ISOLATE_NOTHING -> mozilla.components.concept.engine.fission.WebContentIsolationStrategy.ISOLATE_NOTHING
                WebContentIsolationStrategy.ISOLATE_EVERYTHING -> mozilla.components.concept.engine.fission.WebContentIsolationStrategy.ISOLATE_EVERYTHING
                WebContentIsolationStrategy.ISOLATE_HIGH_VALUE -> mozilla.components.concept.engine.fission.WebContentIsolationStrategy.ISOLATE_HIGH_VALUE
            }
        }
        if(settings.userAgent != null) {
            components.core.engineSettings.userAgentString = settings.userAgent;
        }
        if(settings.contentBlocking != null) {
            components.core.engineSettings.queryParameterStripping = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> false
            }
            components.core.engineSettings.queryParameterStrippingPrivateBrowsing = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> true
            }
            components.core.engineSettings.queryParameterStrippingAllowList = settings.contentBlocking.queryParameterStrippingAllowList
            components.core.engineSettings.queryParameterStrippingStripList = settings.contentBlocking.queryParameterStrippingStripList

            //TODO: Add bounce tracking protection when available
        }
    }

    override fun updateRuntimeSettings(settings: GeckoEngineSettings) {
        //First parse and set default values
        setDefaultSettings(settings);

        var reloadSession = false

        //Then copy default settings into runtime
        if(settings.javascriptEnabled != null) {
            components.core.engine.settings.javascriptEnabled = components.core.engineSettings.javascriptEnabled
            reloadSession = true
        }
        if(settings.trackingProtectionPolicy != null) {
            components.useCases.settingsUseCases.updateTrackingProtection(components.core.engineSettings.trackingProtectionPolicy!!)
            components.core.engine.settings.fingerprintingProtection = components.core.engineSettings.fingerprintingProtection
            components.core.engine.settings.fingerprintingProtectionPrivateBrowsing = components.core.engineSettings.fingerprintingProtectionPrivateBrowsing
            reloadSession = true
        }
        if(settings.httpsOnlyMode != null) {
            components.core.engine.settings.httpsOnlyMode = components.core.engineSettings.httpsOnlyMode
        }
        if(settings.globalPrivacyControlEnabled != null) {
            components.core.engine.settings.globalPrivacyControlEnabled = components.core.engineSettings.globalPrivacyControlEnabled
        }
        if(settings.preferredColorScheme != null) {
            components.core.engine.settings.preferredColorScheme = components.core.engineSettings.preferredColorScheme
            reloadSession = true
        }
        if(settings.cookieBannerHandlingMode != null) {
            components.core.engine.settings.cookieBannerHandlingMode = components.core.engineSettings.cookieBannerHandlingMode
            reloadSession = true
        }
        if(settings.cookieBannerHandlingModePrivateBrowsing != null) {
            components.core.engine.settings.cookieBannerHandlingModePrivateBrowsing = components.core.engineSettings.cookieBannerHandlingModePrivateBrowsing
            reloadSession = true
        }
        if(settings.cookieBannerHandlingGlobalRules != null) {
            components.core.engine.settings.cookieBannerHandlingGlobalRules = components.core.engineSettings.cookieBannerHandlingGlobalRules
        }
        if(settings.cookieBannerHandlingGlobalRulesSubFrames != null) {
            components.core.engine.settings.cookieBannerHandlingGlobalRulesSubFrames = components.core.engineSettings.cookieBannerHandlingGlobalRulesSubFrames
        }
        if(settings.webContentIsolationStrategy != null) {
            components.core.engine.settings.webContentIsolationStrategy = components.core.engineSettings.webContentIsolationStrategy
        }
        if(settings.userAgent != null) {
            components.core.engine.settings.userAgentString = components.core.engineSettings.userAgentString
            reloadSession = true
        }
        if(settings.contentBlocking != null) {
            components.core.engine.settings.queryParameterStripping = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> false
            }
            components.core.engine.settings.queryParameterStrippingPrivateBrowsing = when(settings.contentBlocking.queryParameterStripping) {
                QueryParameterStripping.ENABLED -> true
                QueryParameterStripping.DISABLED -> false
                QueryParameterStripping.PRIVATE_ONLY -> true
            }
            components.core.engine.settings.queryParameterStrippingAllowList = settings.contentBlocking.queryParameterStrippingAllowList
            components.core.engine.settings.queryParameterStrippingStripList = settings.contentBlocking.queryParameterStrippingStripList

            //TODO: Add bounce tracking protection when available

            reloadSession = true
        }

        if(reloadSession) {
            components.useCases.sessionUseCases.reload()
        }
    }
}
