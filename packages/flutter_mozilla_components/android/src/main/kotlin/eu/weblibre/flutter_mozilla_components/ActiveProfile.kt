/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import eu.weblibre.flutter_mozilla_components.startup.CommittedProfileWriter
import eu.weblibre.flutter_mozilla_components.startup.ExternalCommitResult
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import eu.weblibre.flutter_mozilla_components.sync.SyncStateCache
import java.io.File
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

/**
 * The process's profile identity.
 *
 * All arbitration lives in [StartupArbiter]; this object is the Android-facing
 * side of it — it owns the `current_profile` write and hands out the one
 * [ProfileContext] the committed process is allowed to use.
 *
 * Two rules are load-bearing:
 *
 * - **Committed identity is immutable and is never re-derived from disk.** The old
 *   implementation reinterpreted `current_profile` on every call, which let a
 *   worker bind Gecko to profile A while Dart opened profile B's databases.
 * - **Writing the profile for a *future* process does not rebind this one.**
 *   `current_profile` is next-start state; the live process keeps serving whatever
 *   it committed until it dies.
 */
object ActiveProfile {

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
        SyncStateCache.STORAGE_NAME,    // Last-known account profile + device constellation
    )

    /**
     * SharedPreferences prefix of the committed profile, or `null` before
     * commitment.
     *
     * Read-only on purpose. It used to be a mutable `var` that `ProfileContext.init`
     * assigned, so merely *constructing* a profile-scoped context silently
     * repointed every profile-sensitive preference file in the process.
     */
    val prefix: String?
        get() = StartupArbiter.boundProfileFolder()?.let { File(it).name }

    /** The committed profile's UUID, or `null` before commitment. */
    val committedProfileId: String?
        get() = StartupArbiter.committedProfileId()

    /**
     * Guards [cachedContext] only.
     *
     * Deliberately *not* the object monitor, and deliberately not the same lock as
     * [writeLock]. [StartupArbiter] calls [persistNextStartProfile] while holding its
     * own monitor, and [resolveContext] asks the arbiter for the committed folder —
     * one shared lock here would close that cycle into a deadlock. The arbiter is
     * always queried before either lock is taken.
     */
    private val contextLock = Any()

    /** Guards the `current_profile` write. Nothing under it calls the arbiter. */
    private val writeLock = Any()

    @Volatile
    private var cachedContext: ProfileContext? = null

    /**
     * The one [ProfileContext] this process may use, or `null` while the process is
     * unresolved, selecting, under maintenance, or restarting.
     *
     * A `null` here is never a reason to fall back to an unscoped context. It means
     * "not yet decided"; the caller must retry or refuse.
     */
    fun resolveContext(context: Context): ProfileContext? {
        val relativePath = StartupArbiter.boundProfileFolder() ?: return null

        return synchronized(contextLock) {
            cachedContext?.let { existing ->
                if (existing.relativePath == relativePath) return@synchronized existing
                // Cannot happen without a Committed -> Committed transition, which
                // the arbiter does not have. Fail loudly rather than serve two
                // profiles from one process.
                error("Process rebind detected: ${existing.relativePath} -> $relativePath")
            }

            ProfileContext(context.applicationContext, relativePath).also {
                cachedContext = it
            }
        }
    }

    /**
     * Resolves the committed context, committing the startup candidate first when
     * the process is still unresolved.
     *
     * This is the entry point for headless components — workers, exported services,
     * receivers — that may legitimately be the first thing to run in a process.
     * They may bind the *candidate*, never a profile of their own choosing.
     *
     * Returns `null` when the process refuses to bind right now (selection in
     * progress, maintenance, restarting, or no valid profile). Callers retry or
     * fail safely; they must not invent a profile.
     */
    fun resolveOrCommitContext(context: Context): ProfileContext? {
        return when (StartupArbiter.tryCommitExternal(requestedProfileId = null, trusted = false)) {
            is ExternalCommitResult.CommittedRequested,
            is ExternalCommitResult.AlreadyCommittedSame,
            is ExternalCommitResult.AlreadyCommittedDifferent,
            is ExternalCommitResult.AnsweredSelection,
            -> resolveContext(context)

            ExternalCommitResult.MaintenanceRefused,
            ExternalCommitResult.SelectionInProgress,
            ExternalCommitResult.Terminating,
            ExternalCommitResult.NoValidProfile,
            -> null
        }
    }

    /**
     * Persists the profile a *future* process should resolve.
     *
     * Deliberately does not touch [prefix] or [cachedContext]: this process keeps
     * serving the profile it committed until it dies. Leaving disk saying B while a
     * live process still serves A is the intended, temporary state of a switch —
     * the alternative, rebinding in place, is what corrupts profiles.
     */
    fun persistNextStartProfile(context: Context, profileId: String) {
        val normalizedId = profileId.lowercase()
        require(ProfileUuid.isCanonical(normalizedId)) { "Invalid profile id" }

        // `filesDir` rather than `applicationContext`: this can be reached from a
        // context captured in `Application.attachBaseContext`, where the Application
        // instance itself is not published yet.
        val paths = StartupPaths(context.filesDir)
        require(paths.profileDir(normalizedId).isDirectory) { "Profile does not exist" }

        synchronized(writeLock) {
            val profileFile = paths.currentProfileFile
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
        }
    }

    /** The [CommittedProfileWriter] the arbiter uses at commit time. */
    fun committedProfileWriter(context: Context): CommittedProfileWriter =
        CommittedProfileWriter { profileId -> persistNextStartProfile(context, profileId) }

    /**
     * Prevents profile switches from crossing active-profile background work.
     *
     * Lock order is `startup arbitration -> this lock -> UnifiedPush exclusivity`.
     * Kotlin's [Mutex] is not reentrant, so nothing under this lock may call back
     * into a path that takes it again.
     */
    internal suspend fun <T> withProfileLock(block: suspend () -> T): T =
        profileMutex.withLock { block() }

    /** Test seam. Never call from production code. */
    internal fun resetForTest() {
        synchronized(contextLock) { cachedContext = null }
    }

    private val profileMutex = Mutex()
}
