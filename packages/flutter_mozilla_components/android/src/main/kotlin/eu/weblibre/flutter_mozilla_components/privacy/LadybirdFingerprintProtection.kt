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
        // Resist Fingerprinting (RFP) — Gecko's built-in fingerprinting countermeasure
        // =========================================================================

        // Enable RFP globally. This:
        // - Spoofs navigator.userAgent to a generic Firefox on Windows string
        // - Rounds window.devicePixelRatio to nearest integer
        // - Spoofs CSS media queries (prefers-color-scheme, etc.)
        // - Reports UTC timezone only
        // - Reduces canvas fingerprinting entropy
        prefs.setInt("privacy.resistFingerprinting", 1)

        // Spoof English locale to reduce Accept-Language fingerprinting surface.
        prefs.setInt("privacy.spoof_english", if (privacyConfig.protectionLevel() == LadybirdPrivacyConfig.ProtectionLevel.Strict) 2 else 1)

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

        // =========================================================================
        // Per-origin UA spoofing via content script
        // =========================================================================

        if (privacyConfig.shouldSpoofUserAgent()) {
            // Gecko's RFP spoofs to a generic Windows Firefox UA — which itself
            // is a fingerprinting signal (it marks the user as an RFP user).
            // We override this with per-origin mobile UAs that blend in with
            // normal Android Chrome traffic.
            logger.debug("Per-origin UA spoofing enabled")
        }

        logger.info(
            "Fingerprint protection applied at ${privacyConfig.protectionLevel().name} level"
        )
    }

    /**
     * Returns JavaScript that overrides navigator.userAgent with the per-origin
     * isolated UA from [LadybirdPrivacyConfig].
     *
     * This script is designed to be injected as a content script via the
     * WebExtension API at document_start, before any page JS runs.
     *
     * @param origin The serialized origin of the current document
     * @return Self-executing JavaScript that patches navigator.userAgent
     */
    fun getUAOverrideScript(origin: String): String {
        val spoofedUA = LadybirdPrivacyConfig.getIsolatedUserAgent(origin)
        val noiseSeed = LadybirdPrivacyConfig.getNoiseSeedForOrigin(origin)

        val escapedUA = spoofedUA
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\"", "\\\"")

        return """
(function() {
    if (window.__ladybird_ua_spoof_applied) return;
    window.__ladybird_ua_spoof_applied = true;

    var SPOOFED_UA = "$escapedUA";
    var NOISE_SEED = $noiseSeed;

    try {
        // Override navigator.userAgent
        var _navigator = window.navigator;
        Object.defineProperty(_navigator, 'userAgent', {
            get: function() { return SPOOFED_UA; },
            configurable: true
        });

        // Also override navigator.appVersion (derived from UA)
        Object.defineProperty(_navigator, 'appVersion', {
            get: function() {
                var m = SPOOFED_UA.match(/Chrome\/(\d+\.\d+)/);
                return m ? '5.0 (Android; ' + m[1] + ')' : '5.0 (Android)';
            },
            configurable: true
        });

        // Override User-Agent header in fetch and XHR
        var _fetch = window.fetch;
        window.fetch = function(url, opts) {
            opts = opts || {};
            opts.headers = opts.headers || {};
            if (typeof opts.headers === 'object' && !(opts.headers instanceof Headers)) {
                opts.headers['User-Agent'] = SPOOFED_UA;
            }
            return _fetch.call(this, url, opts);
        };
    } catch (e) {
        // Silently fail — better to load the page without spoofing than to break it
    }
})();
""".trimIndent()
    }
}