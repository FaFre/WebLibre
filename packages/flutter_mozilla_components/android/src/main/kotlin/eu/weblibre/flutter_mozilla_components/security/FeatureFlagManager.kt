/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import mozilla.components.concept.engine.Engine

/**
 * Compile-time feature flag system mirroring Titanium Browser's args.gn architecture.
 *
 * In Titanium, features like VR, AR, remoting, and reporting are disabled at
 * build time via GN flags (e.g., enable_vr = false, enable_reporting = false).
 * Since we cannot recompile GeckoView, this manager provides equivalent enforcement
 * at runtime initialization by setting locked preferences that persist for the
 * lifetime of the process.
 *
 * Flags marked as [locked] cannot be overridden by user preferences or about:config,
 * mirroring Titanium's compile-time enforcement model where certain attack-surface-
 * reducing patches are permanent.
 *
 * Reference: jqssun/android-titanium-browser args.gn
 */
object FeatureFlagManager {

    data class FeatureFlag(
        val name: String,
        val enabled: Boolean,
        val locked: Boolean = false,
        val prefKey: String? = null,
        val description: String = "",
    )

    /**
     * Master feature table — mirrors Titanium's args.gn flags.
     *
     * Each entry maps to either:
     * - A GeckoView/Gecko preference key (prefKey != null)
     * - A conceptual feature with no direct pref equivalent (prefKey == null)
     *
     * Locked flags are applied once at runtime creation and cannot be changed.
     * Unlocked flags serve as defaults that user settings may override.
     */
    val FLAGS: List<FeatureFlag> = listOf(
        // === Disabled features (security/privacy hardening) ===
        // Mirrors: args.gn enable_vr = false
        FeatureFlag("vr", false, true, "dom.vr.enabled", "Virtual Reality support"),
        // Mirrors: args.gn enable_arcore = false
        FeatureFlag("arcore", false, true, "dom.webxr.ar.enabled", "ARCore integration"),
        // Mirrors: args.gn enable_openxr = false
        FeatureFlag("openxr", false, true, "dom.webxr.enabled", "OpenXR/WebXR support"),
        // Mirrors: args.gn enable_cardboard = false
        FeatureFlag("cardboard", false, true, "dom.vr.enabled", "Google Cardboard VR"),
        // Mirrors: args.gn enable_remoting = false
        FeatureFlag("remoting", false, true, "devtools.remote-debugging.enabled", "Remote debugging"),
        // Mirrors: args.gn enable_reporting = false
        FeatureFlag("reporting", false, true, "toolkit.telemetry.enabled", "Telemetry/reporting"),
        // Mirrors: args.gn build_contextual_search = false
        FeatureFlag("contextual_search", false, true, null, "Contextual search (no Gecko pref)"),
        // Disable asm.js to reduce JIT attack surface
        FeatureFlag("asmjs", false, true, "javascript.options.asmjs", "asm.js JIT compilation"),
        // Disable speculative connections to reduce tracking surface
        FeatureFlag("speculative_connect", false, true, "network.http.speculative-parallel-limit", "Speculative connections"),

        // === Enabled features (usability/compatibility) ===
        // Mirrors: args.gn enable_av1_decoder = true
        FeatureFlag("av1_decoder", true, false, "media.av1.enabled", "AV1 video codec"),
        // Mirrors: patch.sh ext:mv2 section — keep MV2 extension support
        FeatureFlag("extensions_mv2", true, false, "extensions.manifestV2.enabled", "Manifest V2 extensions"),
        // Mirrors: patch.sh desktop:menu — desktop UA in context menu
        FeatureFlag("desktop_mode_context_menu", true, false, null, "Desktop UA in context menu"),
        // Mirrors: patch.sh aboutConfigEnabled(true)
        FeatureFlag("about_config", true, true, null, "about:config access"),
    )

    /**
     * Apply all locked feature flags to the runtime.
     * Called during EngineProvider runtime creation, after TitaniumHardeningConfig.
     *
     * This is the GeckoView equivalent of Titanium's compile-time GN flag enforcement:
     * once set, these prefs define the security posture for the entire process lifetime.
     */
    fun applyLockedFlags(engine: Engine) {
        val prefs = GeckoPrefs(engine)
        for (flag in FLAGS.filter { it.locked && it.prefKey != null }) {
            when {
                flag.name == "speculative_connect" -> prefs.setInt(flag.prefKey, 0)
                else -> prefs.setBoolean(flag.prefKey, flag.enabled)
            }
        }
    }

    /**
     * Check if a feature is enabled by default.
     */
    fun isEnabled(name: String): Boolean =
        FLAGS.find { it.name == name }?.enabled ?: false

    /**
     * Check if a feature is locked (cannot be user-overridden).
     */
    fun isLocked(name: String): Boolean =
        FLAGS.find { it.name == name }?.locked ?: false

    /**
     * Get the preference key for a feature, if one exists.
     */
    fun getPrefKey(name: String): String? =
        FLAGS.find { it.name == name }?.prefKey
}
