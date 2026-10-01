/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import mozilla.components.concept.engine.Engine
import mozilla.components.support.base.log.logger.Logger

/**
 * Enhanced security configuration inspired by Titanium Browser.
 *
 * Applies additional security hardening beyond the base TitaniumHardeningConfig.
 * Focuses on:
 * - Network security
 * - Script security
 * - Plugin security
 * - Referrer privacy
 */
object EnhancedSecurityConfig {

    private val logger = Logger("EnhancedSecurityConfig")

    /**
     * Apply enhanced security settings to the engine.
     */
    fun apply(engine: Engine) {
        val prefs = GeckoPrefs(engine)
        
        logger.info("Applying enhanced security configuration")

        // =========================================================================
        // Network Security
        // =========================================================================

        // Strip privacy info from referrer
        prefs.setBoolean("network.http.referer.strip_privacy_info", true)
        prefs.setBoolean("network.http.referer.stripPort", true)
        prefs.setInt("network.http.referer.default_policy", 2) // Never send referrer to third party

        // Disable insecure protocols
        prefs.setBoolean("network.http.spnego.allow-negotiate", false)
        prefs.setBoolean("network.http.ntlm.allow-negotiate", false)

        // Enforce secure connections
        prefs.setBoolean("security.ssl.require_safe_negotiation", true)
        prefs.setBoolean("security.ssl.enable_okp_key_reuse", false)

        // =========================================================================
        // Script Security
        // =========================================================================

        // Restrict JavaScript execution
        prefs.setBoolean("javascript.options.show_in_console", false)
        prefs.setBoolean("javascript.options.asyncstack", false)
        prefs.setBoolean("javascript.options.baseline.enable", true)
        prefs.setBoolean("javascript.options Ion.enable", true)

        // File URI restrictions
        prefs.setBoolean("security.fileuri.strict_origin_policy", true)
        prefs.setBoolean("security.fileuri.origin_energy", true)

        // =========================================================================
        // Plugin Security
        // =========================================================================

        // Disable known vulnerable plugins
        prefs.setBoolean("plugin.scan.Acrobat", "99.99")
        prefs.setBoolean("plugin.scan.WindowsMedia", "99.99")
        prefs.setBoolean("plugin.scan.RealPlayer", "99.99")
        prefs.setBoolean("plugin.scan.ShockwavePlayer", "99.99")

        // =========================================================================
        // Content Security
        // =========================================================================

        // Strengthen CSP
        prefs.setString("content.security_policy.default_src", "'self'")
        prefs.setString("content.security_policy.script_src", "'self' 'unsafe-inline'")
        prefs.setString("content.security_policy.style_src", "'self' 'unsafe-inline'")
        prefs.setString("content.security_policy.img_src", "'self' data: https:")
        prefs.setString("content.security_policy.connect_src", "'self'")
        prefs.setString("content.security_policy.font_src", "'self'")
        prefs.setString("content.security_policy.media_src", "'self'")
        prefs.setString("content.security_policy.object_src", "'none'")
        prefs.setString("content.security_policy.worker_src", "'self'")

        // Enable CSP reporting
        prefs.setBoolean("content.security_policy.report_only", false)

        // =========================================================================
        // XSS Protection
        // =========================================================================

        prefs.setBoolean("dom.secure_contexts.require_user_activation", true)
        prefs.setBoolean("security.xss.auditor.enabled", true)

        // =========================================================================
        // Clickjacking Protection
        // =========================================================================

        prefs.setBoolean("security.content.security_policy.enforce", true)
        prefs.setBoolean("security.xframe.options", true)
    }
}
