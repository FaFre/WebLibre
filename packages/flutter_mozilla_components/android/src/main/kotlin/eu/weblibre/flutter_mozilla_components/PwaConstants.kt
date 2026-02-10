/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

object PwaConstants {
    // Intent extras keys for PWA metadata
    const val EXTRA_PWA_PROFILE_UUID = "pwa_profile_uuid"
    const val EXTRA_PWA_CONTEXT_ID = "pwa_context_id"

    // Profile and file paths
    const val CURRENT_PROFILE_FILE = "weblibre_profiles/current_profile"
    const val PROFILE_MAPPING_PREFS = "pwa_profile_mapping"

    // Component initialization timeouts
    const val COMPONENT_INIT_TIMEOUT_MS = 10000L
    const val COMPONENT_INIT_CHECK_INTERVAL_MS = 100L
}
