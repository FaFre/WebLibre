/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import android.content.Intent
import android.net.Uri
import mozilla.components.support.base.log.logger.Logger

/**
 * Titanium-inspired URI scheme security guard.
 *
 * Mirrors Titanium's LaunchIntentDispatcherHooks.java patches (patch.sh lines 22-24)
 * that reject non-network URLs from external callers. This is the GeckoView equivalent
 * of Chromium's compile-time scheme validation.
 *
 * Defense-in-depth: works alongside ExternalCallerInfo's intent-level guard
 * AND AppRequestInterceptor's navigation-level guard.
 *
 * Reference: jqssun/android-titanium-browser patch.sh lines 22-24
 */
object SchemeGuardFeature {
    private val logger = Logger("SchemeGuard")

    // Whitelist of schemes allowed from external intents
    // Mirrors Titanium's URLUtil.isNetworkUrl() check plus safe custom schemes
    private val ALLOWED_EXTERNAL_SCHEMES = setOf(
        "http", "https",
        "weblibre",           // Internal browser scheme
        "moz-extension",      // Extension pages
        "about",              // Internal pages (filtered further below)
    )

    // Dangerous about: pages that should never be opened externally
    private val BLOCKED_ABOUT_PAGES = setOf(
        "about:config",
        "about:debugging",
        "about:profiles",
        "about:support",
    )

    /**
     * Validate an incoming intent's URI against the scheme whitelist.
     * Returns true if safe, false if dangerous (and strips the data URI).
     */
    fun validateAndSanitizeExternalIntent(intent: Intent): Boolean {
        val uri = intent.data ?: return true
        val scheme = uri.scheme?.lowercase() ?: return true

        if (scheme !in ALLOWED_EXTERNAL_SCHEMES) {
            logger.warn("Blocked external intent with scheme '$scheme': $uri")
            intent.data = null
            return false
        }

        // Additional about: page filtering
        if (scheme == "about") {
            val page = uri.toString().lowercase()
            if (page in BLOCKED_ABOUT_PAGES) {
                logger.warn("Blocked external access to restricted page: $uri")
                intent.data = null
                return false
            }
        }

        return true
    }
}
