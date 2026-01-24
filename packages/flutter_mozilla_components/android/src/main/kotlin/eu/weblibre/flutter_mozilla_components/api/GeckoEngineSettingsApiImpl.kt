/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import androidx.core.content.edit
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode
import eu.weblibre.flutter_mozilla_components.pigeons.ColorScheme
import eu.weblibre.flutter_mozilla_components.pigeons.CookieBannerHandlingMode
import eu.weblibre.flutter_mozilla_components.pigeons.CustomCookiePolicy
import eu.weblibre.flutter_mozilla_components.pigeons.DohSettingsMode
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettingsApi
import eu.weblibre.flutter_mozilla_components.pigeons.HttpsOnlyMode
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingScope
import eu.weblibre.flutter_mozilla_components.pigeons.WebContentIsolationStrategy
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.TrackingCategory
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.CookiePolicy
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

    /**
     * Updates fingerprinting protection settings based on the tracking protection policy.
     * For CUSTOM mode, uses the settings from GeckoEngineSettings to determine the behavior.
     */
    private fun updateFingerprintingProtection(
        trackingProtectionPolicy: eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy,
        settings: GeckoEngineSettings? = null
    ) {
        when(trackingProtectionPolicy) {
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.STRICT -> {
                components.core.engineSettings.fingerprintingProtection = true
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.RECOMMENDED -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> {
                // Handle suspected fingerprinters (separate from FINGERPRINTING category)
                if (settings?.blockSuspectedFingerprinters == true) {
                    when (settings.suspectedFingerprintersScope) {
                        TrackingScope.ALL -> {
                            components.core.engineSettings.fingerprintingProtection = true
                            components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
                        }
                        TrackingScope.PRIVATE_ONLY, null -> {
                            components.core.engineSettings.fingerprintingProtection = false
                            components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = true
                        }
                    }
                } else {
                    components.core.engineSettings.fingerprintingProtection = false
                    components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = false
                }
            }
            eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.NONE -> {
                components.core.engineSettings.fingerprintingProtection = false
                components.core.engineSettings.fingerprintingProtectionPrivateBrowsing = false
            }
        }
    }

    /**
     * Creates a custom tracking protection policy based on user settings.
     * Matches Fenix's implementation where AD, ANALYTICS, SOCIAL, and MOZILLA_SOCIAL
     * are always blocked, while other categories are configurable.
     */
    private fun createCustomTrackingProtectionPolicy(settings: GeckoEngineSettings): TrackingProtectionPolicy {
        // Always include these categories (not user-configurable, matches Fenix)
        val categories = mutableListOf(
            TrackingCategory.AD,
            TrackingCategory.ANALYTICS,
            TrackingCategory.SOCIAL,
            TrackingCategory.MOZILLA_SOCIAL,
        )

        // Add configurable categories
        if (settings.blockTrackingContent == true) {
            categories.add(TrackingCategory.SCRIPTS_AND_SUB_RESOURCES)
        }

        if (settings.blockFingerprinters == true) {
            categories.add(TrackingCategory.FINGERPRINTING)
        }

        if (settings.blockCryptominers == true) {
            categories.add(TrackingCategory.CRYPTOMINING)
        }

        // Determine cookie policy
        val cookiePolicy = if (settings.blockCookies != true) {
            CookiePolicy.ACCEPT_ALL
        } else {
            when (settings.customCookiePolicy) {
                CustomCookiePolicy.TOTAL_PROTECTION -> CookiePolicy.ACCEPT_FIRST_PARTY_AND_ISOLATE_OTHERS
                CustomCookiePolicy.CROSS_SITE_TRACKERS -> CookiePolicy.ACCEPT_NON_TRACKERS
                CustomCookiePolicy.UNVISITED -> CookiePolicy.ACCEPT_VISITED
                CustomCookiePolicy.THIRD_PARTY -> CookiePolicy.ACCEPT_ONLY_FIRST_PARTY
                CustomCookiePolicy.ALL_COOKIES -> CookiePolicy.ACCEPT_NONE
                null -> CookiePolicy.ACCEPT_FIRST_PARTY_AND_ISOLATE_OTHERS // default
            }
        }

        // Build policy
        val policy = TrackingProtectionPolicy.select(
            trackingCategories = categories.toTypedArray(),
            cookiePolicy = cookiePolicy,
            cookiePurging = settings.blockRedirectTrackers ?: true,
            strictSocialTrackingProtection = settings.blockTrackingContent ?: true,
            allowListBaselineTrackingProtection = settings.allowListBaseline ?: true,
            allowListConvenienceTrackingProtection = settings.allowListConvenience ?: false,
        )

        // Apply scope for tracking content
        return if (settings.trackingContentScope == TrackingScope.PRIVATE_ONLY) {
            policy.forPrivateSessionsOnly()
        } else {
            policy
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
                eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionPolicy.CUSTOM -> createCustomTrackingProtectionPolicy(settings)
            }

            updateFingerprintingProtection(settings.trackingProtectionPolicy, settings)
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
        if(settings.enterpriseRootsEnabled != null) {
            components.core.engineSettings.enterpriseRootsEnabled = settings.enterpriseRootsEnabled;
        }
        if(settings.dohSettings != null) {
            components.core.engineSettings.dohSettingsMode = when(settings.dohSettings.dohSettingsMode) {
                DohSettingsMode.GECKO_DEFAULT -> Engine.DohSettingsMode.DEFAULT
                DohSettingsMode.INCREASED -> Engine.DohSettingsMode.INCREASED
                DohSettingsMode.MAX -> Engine.DohSettingsMode.MAX
                DohSettingsMode.OFF -> Engine.DohSettingsMode.OFF
            }
            components.core.engineSettings.dohProviderUrl = settings.dohSettings.dohProviderUrl
            components.core.engineSettings.dohDefaultProviderUrl = settings.dohSettings.dohDefaultProviderUrl
            components.core.engineSettings.dohExceptionsList = settings.dohSettings.dohExceptionsList
        }
        if(settings.fingerprintingProtectionOverrides != null) {
            components.core.engineSettings.fingerprintingProtectionOverrides = settings.fingerprintingProtectionOverrides
        }
        if(settings.locales != null) {
//            components.core.engineSettings.automaticLanguageAdjustment = false
            components.core.runtime.settings.locales = settings.locales.toTypedArray()
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
            components.core.engine.settings.queryParameterStripping = components.core.engineSettings.queryParameterStripping
            components.core.engine.settings.queryParameterStrippingPrivateBrowsing = components.core.engineSettings.queryParameterStrippingPrivateBrowsing
            components.core.engine.settings.queryParameterStrippingAllowList = components.core.engineSettings.queryParameterStrippingAllowList
            components.core.engine.settings.queryParameterStrippingStripList = components.core.engineSettings.queryParameterStrippingStripList
            reloadSession = true
        }
        if(settings.enterpriseRootsEnabled != null) {
            components.core.engine.settings.enterpriseRootsEnabled = components.core.engineSettings.enterpriseRootsEnabled
            reloadSession = true
        }
        if(settings.dohSettings != null) {
            components.core.engine.settings.dohSettingsMode = components.core.engineSettings.dohSettingsMode
            components.core.engine.settings.dohProviderUrl = components.core.engineSettings.dohProviderUrl
            components.core.engine.settings.dohDefaultProviderUrl = components.core.engineSettings.dohDefaultProviderUrl
            components.core.engine.settings.dohExceptionsList = components.core.engineSettings.dohExceptionsList
        }
        if(settings.fingerprintingProtectionOverrides != null) {
            components.core.engine.settings.fingerprintingProtectionOverrides = components.core.engineSettings.fingerprintingProtectionOverrides
        }

        if(reloadSession) {
            components.useCases.sessionUseCases.reload()
        }
    }

    override fun setPullToRefreshEnabled(enabled: Boolean) {
        GlobalComponents.pullToRefreshEnabled = enabled
    }

    override fun setAppLinksMode(mode: AppLinksMode) {
        val context = components.profileApplicationContext
        val prefKey = context.getString(R.string.pref_key_open_links_in_apps)
        val modeValue = when (mode) {
            AppLinksMode.ALWAYS -> context.getString(R.string.pref_key_open_links_in_apps_always)
            AppLinksMode.ASK -> context.getString(R.string.pref_key_open_links_in_apps_ask)
            AppLinksMode.NEVER -> context.getString(R.string.pref_key_open_links_in_apps_never)
        }

        PreferenceManager.getDefaultSharedPreferences(context).edit {
            putString(prefKey, modeValue)
        }
    }

    override fun getAppLinksMode(): AppLinksMode {
        val context = components.profileApplicationContext
        val prefKey = context.getString(R.string.pref_key_open_links_in_apps)
        val defaultValue = context.getString(R.string.pref_key_open_links_in_apps_ask)
        val modeValue = PreferenceManager.getDefaultSharedPreferences(context)
            .getString(prefKey, defaultValue) ?: defaultValue

        return when (modeValue) {
            context.getString(R.string.pref_key_open_links_in_apps_always) -> AppLinksMode.ALWAYS
            context.getString(R.string.pref_key_open_links_in_apps_ask) -> AppLinksMode.ASK
            context.getString(R.string.pref_key_open_links_in_apps_never) -> AppLinksMode.NEVER
            else -> AppLinksMode.ASK
        }
    }
}
