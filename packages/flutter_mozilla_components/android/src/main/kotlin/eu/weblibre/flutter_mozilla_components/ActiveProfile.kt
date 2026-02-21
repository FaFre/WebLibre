/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components

import android.content.Context
import java.io.File

object ActiveProfile {
    @Volatile
    var prefix: String? = null

    /** SharedPreference names used by mozilla-components FxA/sync that need profile isolation */
    val FXA_SHARED_PREFERENCE_NAMES = setOf(
        "fxaAppState",                  // FxA account state (SharedPrefAccountStorage)
        "fxaStatePrefAC",               // Sentinel flag for SecureAbove22 account state presence
        "fxaStateAC_kp_pre_m",          // SecureAbove22 encrypted account state (API < 23 fallback)
        "fxaStateAC_kp_post_m",         // SecureAbove22 encrypted account state (API >= 23)
        "fxa_abnormalities",            // Tracks FxA account abnormalities
        "mozac_feature_accounts_push",  // Push subscription scope + verification state
        "SyncAuthInfoCache",            // Cached sync auth tokens
        "FxaDeviceSettingsCache",       // Cached device settings (ID, name, type)
        "syncEngines",                  // Per-engine enabled/disabled state
        "syncPrefs",                    // Last-synced timestamp + persisted sync state
    )

    /**
     * Resolve the active profile prefix from disk.
     * Called in Application.onCreate() to handle cold-start WorkManager scenarios.
     */
    fun resolveFromDisk(context: Context) {
        val profileFile = File(context.filesDir, PwaConstants.CURRENT_PROFILE_FILE)
        if (!profileFile.exists()) return
        val uuid = profileFile.readText().trim().ifEmpty { return }
        val relativePath = "${PwaConstants.PROFILES_DIR_NAME}/${PwaConstants.PROFILE_DIR_PREFIX}$uuid"
        prefix = File(relativePath).name
    }
}
