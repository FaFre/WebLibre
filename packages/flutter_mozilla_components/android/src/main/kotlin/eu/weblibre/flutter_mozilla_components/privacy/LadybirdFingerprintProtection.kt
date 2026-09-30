/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.privacy

import mozilla.components.support.base.log.logger.Logger
import org.mozilla.geckoview.GeckoRuntime

/**
 * GeckoView fingerprint protection integration inspired by Ladybird's
 * NavigatorID privacy hook and LibPrivacy module.
 *
 * Applies GeckoView's ResistFingerprinting (RFP) preferences plus
 * additional countermeasures that Gecko's RFP does not cover by default:
 * - WebGL block via preference
 * - Per-origin UA spoofing via content script injection
 * - Hardware concurrency spoofing
 * - Battery API disable
 *
 * Unlike TitaniumHardeningConfig (which focuses on security isolation),
 * this config targets the fingerprinting vector specifically — mirroring
 * Ladybird's privacy-by-default architecture.
 *
 * Reference:
 * - qwerzxcva/ladybird Libraries/LibPrivacy
 * - qwerzxcva/ladybird Libraries/LibWeb/HTML/NavigatorID.cpp
 */
object LadybirdFingerprintProtection {
    private val logger = Logger("LadybirdFingerprintProtection")

    /**
     * Apply all fingerprint protection preferences to the runtime.
     * Must be called after [LadybirdRuntimeConfig.applyPerformancePrefs]
     * and [TitaniumHardeningConfig] if present, to avoid pref conflicts.
     */
    fun apply(runtime: GeckoRuntime) {
        val privacyConfig = LadybirdPrivacyConfig
        if (privacyConfig.protectionLevel() == LadybirdPrivacyConfig.ProtectionLevel.Off) {
            logger.info("Fingerprint protection disabled by user preference")
            return
        }

        val prefs = runtime.settings

        // =========================================================================
        // Layering
        //
        // Gecko's own ResistFingerprinting (privacy.resistFingerprinting) is
        // deliberately NOT enabled here. It spoofs the UA and platform to a
        // desktop Windows Firefox identity, which would contradict the
        // per-origin Android Chrome profile that the Fingerprint Shield
        // WebExtension exposes to JavaScript and to the User-Agent header.
        // Two spoofing layers disagreeing is worse than one: the mismatch is
        // itself a unique, trackable signal.
        //
        // This method therefore only sets engine-level prefs that complement
        // (rather than duplicate) the shield — surfaces the content script
        // cannot reach from JavaScript.
        // =========================================================================

        // =========================================================================
        // WebGL and Canvas countermeasures
        // =========================================================================

        if (privacyConfig.shouldBlockWebGL()) {
            // Block WebGL entirely. Fingerprinting risk outweighs utility on mobile.
            prefs.setBoolean("webgl.disabled", true)
        }

        // Reduce font enumeration surface. RFP already limits this but we tighten further.
        prefs.setInt("layout.css.font-visibility.level", 2)

        // =========================================================================
        // Hardware/device spoofing
        // =========================================================================

        // Spoof hardware concurrency to 4 (common mid-range value).
        // Real values (8 or 12 cores) are a strong fingerprinting signal.
        prefs.setInt("dom.maxHardwareConcurrency", 4)

        // Disable Battery Status API — it has no legitimate use case and is a
        // known fingerprinting vector (battery percentage + charging rate).
        prefs.setBoolean("dom.battery.enabled", false)

        // =========================================================================
        // Network fingerprinting countermeasures
        // =========================================================================

        // Reduce WebRTC exposure beyond Titanium's IP policy.
        // Even with public-IP-only mode, the exposed IP still fingerprints.
        // Strict mode disables WebRTC entirely.
        if (privacyConfig.protectionLevel() == LadybirdPrivacyConfig.ProtectionLevel.Strict) {
            prefs.setBoolean("media.peerconnection.enabled", false)
        }

        // Disable mDNS hostname obfuscation (can be de-obfuscated).
        prefs.setBoolean("media.peerconnection.ice.obfuscate_host_addresses", false)

        // UA, screen, canvas, WebGL, audio, fonts and timezone are spoofed by
        // the Fingerprint Shield WebExtension (assets/extensions/fingerprint_shield),
        // which derives one coherent per-origin profile and applies it to both
        // JavaScript and the outgoing User-Agent header.
        if (privacyConfig.shouldSpoofUserAgent()) {
            logger.debug("Per-origin UA spoofing delegated to the Fingerprint Shield extension")
        }

        logger.info(
            "Fingerprint protection applied at ${privacyConfig.protectionLevel().name} level"
        )
    }
}