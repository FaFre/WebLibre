/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

object PwaConstants {
    const val PROFILES_DIR_NAME = "weblibre_profiles"
    const val PROFILE_DIR_PREFIX = "profile-"

    // Intent extras keys for PWA metadata
    const val EXTRA_PWA_PROFILE_UUID = "pwa_profile_uuid"
    const val EXTRA_PWA_CONTEXT_ID = "pwa_context_id"
    const val EXTRA_PWA_TOKEN = "pwa_token"
    const val EXTRA_PWA_INSTALL_START_URL = "pwa_install_start_url"
    const val EXTRA_SHORTCUT_TYPE = "shortcut_type"
    const val EXTRA_SHORTCUT_CONTAINER_MODE = "shortcut_container_mode"

    // Shortcut type values
    const val SHORTCUT_TYPE_BASIC = "basic"
    const val SHORTCUT_TYPE_PWA = "pwa"

    // Shortcut container mode values
    const val SHORTCUT_CONTAINER_MODE_SPECIFIC = "specific"
    const val SHORTCUT_CONTAINER_MODE_UNASSIGNED = "unassigned"

    // Profile and file paths
    const val CURRENT_PROFILE_FILE = "weblibre_profiles/current_profile"
    const val PROFILE_MAPPING_PREFS = "pwa_profile_mapping"
    const val PROFILE_MAPPING_TOKEN_PREFIX = "token_"

    // Component initialization timeouts
    const val COMPONENT_INIT_TIMEOUT_MS = 10000L
    const val COMPONENT_INIT_CHECK_INTERVAL_MS = 100L
}
