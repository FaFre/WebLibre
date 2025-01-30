package eu.lensai.flutter_mozilla_components.api

import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.ColorScheme
import eu.lensai.flutter_mozilla_components.pigeons.CookieBannerHandlingMode
import eu.lensai.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.lensai.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.lensai.flutter_mozilla_components.pigeons.HttpsOnlyMode
import eu.lensai.flutter_mozilla_components.pigeons.WebContentIsolationStrategy
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

    override fun setDefaultSettings(settings: GeckoEngineSettings) {
        if(settings.javascriptEnabled != null) {
            components.core.engineSettings.javascriptEnabled = settings.javascriptEnabled;
        }
        if(settings.trackingProtectionPolicy != null) {
            components.core.engineSettings.trackingProtectionPolicy = when(settings.trackingProtectionPolicy) {
                eu.lensai.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> TrackingProtectionPolicy.none()
                eu.lensai.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> TrackingProtectionPolicy.recommended()
                eu.lensai.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> TrackingProtectionPolicy.strict()
                eu.lensai.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> TODO()
            }
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
    }

    override fun updateRuntimeSettings(settings: GeckoEngineSettings) {
        //First parse and set default values
        setDefaultSettings(settings);

        //Then copy default settings into runtime
        if(settings.javascriptEnabled != null) {
            components.core.engine.settings.javascriptEnabled = components.core.engineSettings.javascriptEnabled
        }
        if(settings.trackingProtectionPolicy != null) {
            components.useCases.settingsUseCases.updateTrackingProtection(components.core.engineSettings.trackingProtectionPolicy!!)
            components.useCases.sessionUseCases.reload()
        }
        if(settings.httpsOnlyMode != null) {
            components.core.engineSettings.httpsOnlyMode = components.core.engineSettings.httpsOnlyMode
        }
        if(settings.globalPrivacyControlEnabled != null) {
            components.core.engineSettings.globalPrivacyControlEnabled = components.core.engineSettings.globalPrivacyControlEnabled
        }
        if(settings.preferredColorScheme != null) {
            components.core.engineSettings.preferredColorScheme = components.core.engineSettings.preferredColorScheme
        }
        if(settings.cookieBannerHandlingMode != null) {
            components.core.engineSettings.cookieBannerHandlingMode = components.core.engineSettings.cookieBannerHandlingMode
        }
        if(settings.cookieBannerHandlingModePrivateBrowsing != null) {
            components.core.engineSettings.cookieBannerHandlingModePrivateBrowsing = components.core.engineSettings.cookieBannerHandlingModePrivateBrowsing
        }
        if(settings.cookieBannerHandlingGlobalRules != null) {
            components.core.engineSettings.cookieBannerHandlingGlobalRules = components.core.engineSettings.cookieBannerHandlingGlobalRules
        }
        if(settings.cookieBannerHandlingGlobalRulesSubFrames != null) {
            components.core.engineSettings.cookieBannerHandlingGlobalRulesSubFrames = components.core.engineSettings.cookieBannerHandlingGlobalRulesSubFrames
        }
        if(settings.webContentIsolationStrategy != null) {
            components.core.engineSettings.webContentIsolationStrategy = components.core.engineSettings.webContentIsolationStrategy
        }
    }
}
