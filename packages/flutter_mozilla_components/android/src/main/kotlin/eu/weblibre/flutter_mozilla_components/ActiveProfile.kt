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
import android.util.AtomicFile
import java.io.File
import java.io.FileNotFoundException
import java.util.UUID
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

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
    fun resolveFromDisk(context: Context): ProfileContext? = resolveContext(context)

    /** Resolve the active profile without constructing browser components. */
    @Synchronized
    fun resolveContext(context: Context): ProfileContext? {
        val profileFile = File(context.filesDir, PwaConstants.CURRENT_PROFILE_FILE)
        val uuid = try {
            AtomicFile(profileFile).openRead().bufferedReader().use { it.readText() }.trim()
        } catch (_: FileNotFoundException) {
            return null
        }.ifEmpty { return null }
        val relativePath = "${PwaConstants.PROFILES_DIR_NAME}/${PwaConstants.PROFILE_DIR_PREFIX}$uuid"
        if (!File(context.filesDir, relativePath).isDirectory) return null
        prefix = File(relativePath).name
        return ProfileContext(context.applicationContext, relativePath)
    }

    /** Atomically select the profile used by the next browser process. */
    @Synchronized
    fun switchTo(context: Context, profileId: String) {
        val normalizedId = UUID.fromString(profileId).toString()
        require(normalizedId == profileId.lowercase()) { "Invalid profile id" }

        val relativePath =
            "${PwaConstants.PROFILES_DIR_NAME}/${PwaConstants.PROFILE_DIR_PREFIX}$normalizedId"
        require(File(context.filesDir, relativePath).isDirectory) { "Profile does not exist" }

        val profileFile = File(context.filesDir, PwaConstants.CURRENT_PROFILE_FILE)
        profileFile.parentFile?.mkdirs()
        val atomicFile = AtomicFile(profileFile)
        val output = atomicFile.startWrite()
        try {
            output.write(normalizedId.toByteArray(Charsets.UTF_8))
            atomicFile.finishWrite(output)
        } catch (error: Throwable) {
            atomicFile.failWrite(output)
            throw error
        }
        prefix = File(relativePath).name
    }

    /** Prevent profile switches from crossing active-profile background work. */
    internal suspend fun <T> withProfileLock(block: suspend () -> T): T =
        profileMutex.withLock { block() }

    private val profileMutex = Mutex()
}
