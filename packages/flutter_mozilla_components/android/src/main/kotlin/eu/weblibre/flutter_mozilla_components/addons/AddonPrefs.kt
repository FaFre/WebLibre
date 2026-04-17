/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import android.content.SharedPreferences

object AddonPrefs {
    const val PREFS_NAME = "addon_prefs"
    const val PREF_AUTO_UPDATE_ENABLED = "addon_auto_update_enabled"
    // Legacy key name — kept to preserve previously pinned local-install preferences.
    const val PREF_AUTO_UPDATE_DISABLED_IDS = "pinned_local_addon_ids"
    const val PREF_LOCAL_FILE_ADDON_IDS = "local_file_addon_ids"
    const val PREF_MANUAL_UPDATE_ATTEMPT_PREFIX = "manual_addon_update_attempt."

    fun get(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
