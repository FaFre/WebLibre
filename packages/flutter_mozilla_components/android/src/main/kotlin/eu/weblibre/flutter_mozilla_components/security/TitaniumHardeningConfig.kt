/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import mozilla.components.concept.engine.Engine

/**
 * Centralized security hardening configuration inspired by Titanium Browser's
 * Chromium patch architecture (jqssun/android-titanium-browser).
 *
 * Translates compile-time Chromium patches and args.gn flags into GeckoView
 * runtime preferences. Every setting here corresponds to a specific Titanium
 * patch.sh entry or args.gn flag — comments reference the original for traceability.
 *
 * Design principle: these are process-level defaults applied once at runtime
 * creation. User-facing settings in GeckoEngineSettingsApiImpl can override
 * non-locked prefs, but locked prefs remain enforced regardless of user choice,
 * mirroring Titanium's compile-time enforcement model.
 */
object TitaniumHardeningConfig {

    /**
     * Apply all hardening preferences to the GeckoRuntime.
     * Called once during runtime creation in EngineProvider.getOrCreateRuntime().
     */
    fun applyRuntimeHardening(engine: Engine) {
        val prefs = GeckoPrefs(engine)

        // =========================================================================
        // L3: Feature flags — mirrors Titanium args.gn compile-time feature toggles
        // =========================================================================

        // Disable telemetry/reporting (args.gn: enable_reporting = false)
        prefs.setBoolean("datareporting.healthreport.uploadEnabled", false)
        prefs.setBoolean("toolkit.telemetry.enabled", false)
        prefs.setString("toolkit.telemetry.server", "")
        prefs.setBoolean("browser.ping-centre.telemetry", false)
        prefs.setBoolean("beacon.enabled", false)

        // Disable VR/AR/XR (args.gn: enable_vr/arcore/openxr/cardboard = false)
        prefs.setBoolean("dom.vr.enabled", false)
        prefs.setBoolean("dom.webxr.enabled", false)
        prefs.setBoolean("dom.webxr.ar.enabled", false)

        // Disable remote debugging by default (attack surface reduction)
        // Can be re-enabled via about:config for development
        prefs.setBoolean("devtools.remote-debugging.enabled", false)

        // =========================================================================
        // L1: Security patches — mirrors Titanium patch.sh security section
        // =========================================================================

        // WebRTC IP leak protection (patch.sh: WebRTC IP Policy)
        // DEFAULT_PUBLIC_INTERFACE_ONLY prevents local/private IP exposure via ICE
        prefs.setInt("media.peerconnection.ice.default_address_only", 1)
        prefs.setBoolean("media.peerconnection.ice.no_host", true)

        // Disable mDNS ICE candidates (prevents LAN hostname leakage)
        prefs.setBoolean("media.peerconnection.ice.obfuscate_host_addresses", true)

        // Restrict navigator properties (patch.sh: feature overrides)
        prefs.setBoolean("dom.battery.enabled", false)
        prefs.setBoolean("dom.gamepad.enabled", false)
        prefs.setBoolean("dom.netinfo.enabled", false)

        // Disable speculative connections (reduces tracking surface)
        prefs.setInt("network.http.speculative-parallel-limit", 0)
        prefs.setBoolean("network.dns.disablePrefetch", true)
        prefs.setBoolean("browser.urlbar.speculativeConnect.enabled", false)

        // Harden TLS (mirrors Vanadium SSL hardening inherited by Titanium)
        prefs.setInt("security.tls.version.min", 3) // TLS 1.2 minimum
        prefs.setBoolean("security.ssl.require_safe_negotiation", true)
        prefs.setBoolean("security.ssl.treat_unsafe_negotiation_as_broken", true)

        // Disable potentially dangerous protocols
        prefs.setBoolean("network.jar.open-unsafe-types", false)
        prefs.setBoolean("javascript.options.asmjs", false)

        // =========================================================================
        // L1: Privacy/fingerprint patches — mirrors Titanium patch.sh privacy section
        // =========================================================================

        // Comprehensive RFP overrides — translates Titanium's Chromium-level
        // fingerprint resistance into GeckoView's fingerprintingProtectionOverrides
        prefs.setString(
            "privacy.fingerprintingProtection.overrides",
            "+CanvasRandomization,+WebGLRandomization,+EfficientCanvasRandomization," +
            "+NavigatorUserAgent,+NavigatorPlatform,+NavigatorAppVersion," +
            "+NavigatorHWConcurrency,+NavigatorHWConcurrencyTiered," +
            "+JSDateTimeUTC,+ReduceTimerPrecision,+FontVisibilityBaseSystem," +
            "+FontVisibilityRestrictGenerics,+RoundWindowSize,+WindowOuterSize," +
            "+ScreenRect,+ScreenAvailRect,+CSSDeviceSize,+CSSResolution," +
            "+MediaDevices,+AudioContext,+StreamVideoFacingMode," +
            "+PointerId,+MaxTouchPoints,+DeviceSensors,+FrameRate"
        )

        // Spoof screen dimensions to common values (reduce uniqueness)
        prefs.setInt("privacy.window.maxInnerWidth", 1920)
        prefs.setInt("privacy.window.maxInnerHeight", 1080)

        // Letterboxing (prevents window size fingerprinting)
        prefs.setBoolean("privacy.resistFingerprinting.letterboxing", true)
    }

    /**
     * Returns the set of prefs that should be locked (user cannot override).
     * Mirrors Titanium's compile-time enforcement where certain patches
     * cannot be disabled at runtime.
     */
    fun getLockedPrefs(): Set<String> = setOf(
        "datareporting.healthreport.uploadEnabled",
        "toolkit.telemetry.enabled",
        "dom.vr.enabled",
        "dom.webxr.enabled",
        "media.peerconnection.ice.default_address_only",
        "media.peerconnection.ice.no_host",
    )
}
