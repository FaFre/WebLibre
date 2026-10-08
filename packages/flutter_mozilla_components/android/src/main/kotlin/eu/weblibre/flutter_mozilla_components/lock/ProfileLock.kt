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
package eu.weblibre.flutter_mozilla_components.lock

import android.os.SystemClock
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import java.io.File
import org.json.JSONObject

/** Mirrors Dart's `ProfileLockMethod`. */
enum class ProfileLockMethod { NONE, DEVICE, PASSWORD }

/** Mirrors Dart's `AutoLockMode`. */
enum class AutoLockMode { BACKGROUND, TIMEOUT, STARTUP }

/**
 * A profile's lock, read from its `metadata.json` the way Dart's
 * `AuthSettings.fromJson` reads it.
 */
data class ProfileLockSettings(
    val method: ProfileLockMethod,
    val autoLockMode: AutoLockMode,
    val timeoutMs: Long,
) {
    val isLocked: Boolean
        get() = method != ProfileLockMethod.NONE

    companion object {
        private const val DEFAULT_TIMEOUT_MS = 5 * 60 * 1000L

        val UNLOCKED = ProfileLockSettings(
            ProfileLockMethod.NONE,
            AutoLockMode.BACKGROUND,
            DEFAULT_TIMEOUT_MS,
        )

        /**
         * What a profile whose metadata cannot be read is treated as.
         *
         * Locked, and with the password: only Dart can answer that, and Dart
         * reads the metadata again before it does. Treating it as open, or as
         * device-locked, would let a damaged file stand in for whatever lock
         * the profile really has.
         */
        val UNREADABLE = ProfileLockSettings(
            ProfileLockMethod.PASSWORD,
            AutoLockMode.BACKGROUND,
            0L,
        )

        /** Reads [profileId]'s lock from disk. */
        fun read(paths: StartupPaths, profileId: String): ProfileLockSettings {
            val file = File(paths.profileDir(profileId), StartupPaths.PROFILE_METADATA_FILE_NAME)
            return try {
                parse(JSONObject(file.readText()))
            } catch (_: Exception) {
                UNREADABLE
            }
        }

        /**
         * The `authSettings` object of a profile's metadata.
         *
         * A missing object is an unlocked profile, as in Dart. An unknown lock
         * method comes from a newer build and reads as the device lock, which
         * is Dart's `unknownEnumValue`.
         */
        fun parse(metadata: JSONObject): ProfileLockSettings {
            if (!metadata.has("authSettings") || metadata.isNull("authSettings")) {
                return UNLOCKED
            }
            val auth = metadata.optJSONObject("authSettings") ?: return UNREADABLE

            val method = when (val raw = auth.opt("lockMethod")) {
                null, JSONObject.NULL ->
                    // Every build before lock methods wrote only this boolean,
                    // and it always meant the device prompt.
                    if (auth.opt("authenticationRequired") == true) {
                        ProfileLockMethod.DEVICE
                    } else {
                        ProfileLockMethod.NONE
                    }

                "none" -> ProfileLockMethod.NONE
                "device" -> ProfileLockMethod.DEVICE
                "password" -> ProfileLockMethod.PASSWORD
                is String -> ProfileLockMethod.DEVICE
                else -> return UNREADABLE
            }

            val autoLockMode = when (auth.opt("autoLockMode")) {
                "timeout" -> AutoLockMode.TIMEOUT
                "startup" -> AutoLockMode.STARTUP
                // The strictest mode for anything this build does not know.
                else -> AutoLockMode.BACKGROUND
            }

            // Dart stores a `Duration` in microseconds.
            val timeoutMs = (auth.opt("timeout") as? Number)
                ?.let { it.toLong() / 1000L }
                ?: DEFAULT_TIMEOUT_MS

            return ProfileLockSettings(method, autoLockMode, timeoutMs)
        }
    }
}

/** A shared unlock as Dart sees it: see [ProfileUnlockRegistry.shared]. */
data class SharedUnlock(
    val mode: AutoLockMode,
    val timeoutMs: Long,
    val ageMs: Long,
)

/**
 * Which profiles are unlocked in this process, for Custom Tab and PWA windows.
 *
 * The browser keeps its own record in Dart (`LocalAuthenticationService`).
 * The two meet here, and only for the timeout and until-restart auto-lock
 * modes: the browser reports its unlocks in, and adopts the ones a window
 * made. A background-mode unlock is never shared. Switching between the
 * browser and a window counts as leaving, so the other side could not use it
 * anyway, and its eviction runs on a different lifecycle in each.
 *
 * Process-global and in memory on purpose: a killed process forgets every
 * unlock, which is what "until restart" means.
 */
object ProfileUnlockRegistry {
    private data class Unlock(
        val mode: AutoLockMode,
        val timeoutMs: Long,
        val unlockedAtMs: Long,
    )

    private val unlocks = HashMap<String, Unlock>()
    private var departures = 0

    /** Monotonic, so a changed wall clock neither ends nor extends a timeout. */
    @VisibleForTesting
    internal var clock: () -> Long = SystemClock::elapsedRealtime

    /** Records an unlock of [profileId] under [settings], made [ageMs] ago. */
    @Synchronized
    fun record(profileId: String, settings: ProfileLockSettings, ageMs: Long = 0L) {
        unlocks[profileId] = Unlock(
            settings.autoLockMode,
            settings.timeoutMs,
            clock() - ageMs,
        )
    }

    /** Records an unlock the browser made [ageMs] ago, see [record]. */
    @Synchronized
    fun recordShared(profileId: String, mode: AutoLockMode, timeoutMs: Long, ageMs: Long) {
        if (mode == AutoLockMode.BACKGROUND) {
            // Never shared; a report of one means the browser's unlock no
            // longer holds anywhere else.
            forgetShared(profileId)
            return
        }
        unlocks[profileId] = Unlock(mode, timeoutMs, clock() - ageMs.coerceAtLeast(0L))
    }

    /**
     * Drops the shared unlock of [profileId]: the browser locked again, or its
     * settings no longer let an unlock cross over.
     *
     * A window's own background-mode unlock stays. The browser never shared
     * it and cannot take it back; it ends when the person leaves the window.
     * Only reachable while both are on screen (split screen, freeform), since
     * otherwise the browser cannot be unlocking while a window is open.
     */
    @Synchronized
    fun forgetShared(profileId: String) {
        if (unlocks[profileId]?.mode != AutoLockMode.BACKGROUND) {
            unlocks.remove(profileId)
        }
    }

    /**
     * Whether [profileId], locked as [settings] says now, is open.
     *
     * An unlock recorded under another auto-lock mode does not count: the
     * settings changed since, and the new ones have not been satisfied. A
     * timeout counts from the stricter of the recorded and the current one.
     */
    @Synchronized
    fun isUnlocked(profileId: String, settings: ProfileLockSettings): Boolean {
        if (!settings.isLocked) return true

        val unlock = unlocks[profileId] ?: return false
        if (unlock.mode != settings.autoLockMode) return false

        return when (unlock.mode) {
            AutoLockMode.BACKGROUND, AutoLockMode.STARTUP -> true
            AutoLockMode.TIMEOUT ->
                clock() - unlock.unlockedAtMs < minOf(unlock.timeoutMs, settings.timeoutMs)
        }
    }

    /**
     * The unlock of [profileId] the browser may adopt, or null.
     *
     * Only timeout and until-restart unlocks, and only while they still hold.
     * The browser checks the result against its own settings again.
     */
    @Synchronized
    fun shared(profileId: String): SharedUnlock? {
        val unlock = unlocks[profileId] ?: return null
        val age = clock() - unlock.unlockedAtMs

        return when (unlock.mode) {
            AutoLockMode.BACKGROUND -> null
            AutoLockMode.STARTUP -> SharedUnlock(unlock.mode, unlock.timeoutMs, age)
            AutoLockMode.TIMEOUT ->
                if (age < unlock.timeoutMs) {
                    SharedUnlock(unlock.mode, unlock.timeoutMs, age)
                } else {
                    null
                }
        }
    }

    /**
     * Windows that lost the front and have not shown yet whether they left,
     * each with what it does once it has. See [windowPaused].
     */
    private val pendingDepartures = LinkedHashMap<Any, () -> Unit>()

    /**
     * [window] lost the front. Whether that was leaving is settled by what
     * comes next, and [onLeft] runs once it is.
     *
     * A pause alone is not leaving. A system permission dialog, the share
     * sheet, a passkey sheet or one of the app's own trampolines draws over
     * the window and goes away again, and the person was there throughout.
     * Leaving is the window going out of sight ([windowStopped]), or another
     * window taking the front ([windowResumed]). The second has to be settled
     * when that window resumes, which is before this one stops.
     */
    fun windowPaused(window: Any, onLeft: () -> Unit) {
        synchronized(this) { pendingDepartures[window] = onLeft }
    }

    /**
     * [window] is in front. Its own pause, if any, was not leaving. Every
     * other window still pending did leave: one window taking the front from
     * another is leaving. Call before [window] checks its lock, so it sees
     * that.
     */
    fun windowResumed(window: Any) {
        val left = synchronized(this) {
            pendingDepartures.remove(window)
            if (pendingDepartures.isEmpty()) return

            val left = pendingDepartures.values.toList()
            pendingDepartures.clear()
            evictOnLeave()
            left
        }
        left.forEach { it() }
    }

    /** [window] went out of sight: if its pause was still pending, it left. */
    fun windowStopped(window: Any) {
        val onLeft = synchronized(this) {
            pendingDepartures.remove(window)?.also { evictOnLeave() }
        } ?: return
        onLeft()
    }

    /**
     * A window left without a pause that could still turn out not to be
     * leaving, e.g. its picture-in-picture window was closed.
     */
    fun windowLeft(onLeft: () -> Unit) {
        evictOnLeave()
        onLeft()
    }

    /**
     * Leaving is settled: background-mode unlocks end.
     *
     * Also counted ([departureCount]), so a password check that was running
     * when the person left does not unlock behind their back.
     */
    @Synchronized
    internal fun evictOnLeave() {
        departures++
        unlocks.values.removeAll { it.mode == AutoLockMode.BACKGROUND }
    }

    /** How often a window has left; see [evictOnLeave]. */
    @Synchronized
    fun departureCount(): Int = departures

    @VisibleForTesting
    @Synchronized
    internal fun resetForTest() {
        unlocks.clear()
        pendingDepartures.clear()
        departures = 0
        clock = SystemClock::elapsedRealtime
    }
}
