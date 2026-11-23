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
package eu.weblibre.flutter_mozilla_components.push

import android.util.Log
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.MaintenanceScan
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import eu.weblibre.flutter_mozilla_components.startup.intOr
import eu.weblibre.flutter_mozilla_components.startup.stringOrEmpty
import java.io.IOException
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import org.json.JSONArray
import org.json.JSONObject

/**
 * The one-time, install-wide reset of push transports made before restores and
 * clones were isolated.
 *
 * An older build copied the connector database into every clone and restore, so
 * two profiles may hold the same tokens and keys. Either one could then decrypt
 * and deliver a message meant for the other. Without reading the connector's
 * private token table nothing proves which transports are shared: different
 * endpoint URLs, a missing ownership entry and the order profiles open in are no
 * evidence. So when more than one legacy transport exists, every surviving one is
 * reset locally (no UNREGISTER), and a sole one is kept. That keeps the old
 * limitation that a lone surviving clone may still hold a deleted source's
 * credentials, a case with no surviving provenance.
 *
 * ## Order
 *
 * - [captureEvidence] runs when the arbiter reserves maintenance, before anything
 *   can delete or replace a profile: a transport can sit under a restore
 *   workspace's `old/` tree, and a queued delete would otherwise hide the only
 *   evidence of a second one. Nothing is reset there, because recovery has not
 *   decided yet which trees survive.
 * - [finalize] runs only in a committed process, which is past maintenance. It
 *   writes the whole reset set in one atomic write, confirmed durable, before
 *   deleting anything,
 *   retries an unfinished reset with that same set rather than a fresh count, and
 *   records `done` only once every reset succeeded. A corrupt state is never done:
 *   it resets every transport it can find.
 * - [awaitOpen] is the shared check every connector access and queued-payload
 *   read waits for, the receiver and the worker included.
 */
internal object PushTransportMigration {
    private const val TAG = "PushTransportMigration"

    private val submitLock = Any()
    private val finalizeLock = Any()

    @Volatile
    private var done = false

    private var inFlight: Future<Boolean>? = null

    private val executor = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "PushTransportMigration").apply { isDaemon = true }
    }

    /**
     * Records the legacy transports that exist now, if nothing was recorded yet.
     *
     * File checks only, and only when maintenance is reserved, so an ordinary
     * start does no work here. Throws when the record cannot be made durable
     * (or the profiles cannot be listed): the arbiter then hands out no
     * maintenance lease, because a delete or a restore could remove the only
     * evidence of a second transport. An existing record, readable or not,
     * stands; [finalize] treats an unreadable one as "reset every transport".
     */
    fun captureEvidence(paths: StartupPaths, scan: MaintenanceScan) {
        val file = stateFile(paths)
        if (file.read() !is AtomicJsonFile.Read.Absent) {
            // Visible is not durable: the write that made it may have been
            // renamed into place and then failed its directory sync.
            file.confirmDurable()
            return
        }

        val legacy = profilesWithConnector(paths).toSortedSet()
        var unattributed = 0
        val targets = scan.journals.associate { it.taskId to it.targetProfileId.lowercase() }
        for (artifact in scan.artifacts) {
            if (!artifact.hasOld) continue
            if (!PushTransportFiles.hasConnectorDatabase(paths.restoreOldDir(artifact.taskId))) continue
            // The aside tree is the target as it was. Its id only says which
            // profile a later reset lands on; without one it still counts.
            val target = targets[artifact.taskId]?.takeIf(ProfileUuid::isCanonical)
            if (target != null) legacy += target else unattributed++
        }

        file.write(State.Evidence(legacy, unattributed).toJson())
        file.confirmDurable()
        Log.i(TAG, "Recorded ${legacy.size + unattributed} legacy push transports before maintenance")
    }

    /**
     * Whether connector access and queued-payload reads are safe in this process,
     * waiting up to [timeoutMillis] for the migration to finish.
     *
     * The migration runs on its own thread, so a receiver that waits here never
     * runs it on the broadcast path, and a slow one costs the caller only its
     * timeout. False until it is done, and always false before a commit.
     */
    fun awaitOpen(
        paths: StartupPaths,
        timeoutMillis: Long,
        committed: Boolean = StartupArbiter.committedProfileId() != null,
    ): Boolean {
        if (done) return true
        if (!committed) return false

        val future = synchronized(submitLock) {
            inFlight?.takeUnless { it.isDone }
                ?: executor.submit<Boolean> { finalize(paths) }.also { inFlight = it }
        }
        return try {
            future.get(timeoutMillis.coerceAtLeast(0), TimeUnit.MILLISECONDS)
        } catch (_: TimeoutException) {
            false
        } catch (_: ExecutionException) {
            false
        } catch (_: InterruptedException) {
            Thread.currentThread().interrupt()
            false
        }
    }

    /** Runs the migration in the caller's thread. Callers outside tests use [awaitOpen]. */
    internal fun finalize(paths: StartupPaths): Boolean = synchronized(finalizeLock) {
        if (done) return true

        try {
            val file = stateFile(paths)
            val state = State.read(file)
            if (state is State.Done) {
                // Opening push on a `done` a power cut could still take back
                // would run the resets again over transports made since.
                file.confirmDurable()
                done = true
                return true
            }

            val reset = (state as? State.Resetting)?.reset ?: decide(paths, state)
            if (state is State.Resetting) {
                // Found, not written now: its write may have failed its
                // directory sync, and a set lost after the first delete would
                // leave the rest looking like a sole transport.
                file.confirmDurable()
            } else if (reset.isNotEmpty()) {
                file.write(State.Resetting(reset).toJson())
                file.confirmDurable()
            }
            if (reset.isNotEmpty()) {
                Log.w(TAG, "Resetting the push transports of ${reset.size} profiles that may share credentials")
            }

            val ownership = PushOwnershipStore(paths)
            for (profileId in reset) {
                val profileDir = paths.profileDir(profileId)
                if (profileDir.isDirectory) PushTransportFiles.reset(profileDir)
                ownership.forgetProfile(profileId)
            }

            file.write(State.Done.toJson())
            file.confirmDurable()
            done = true
            true
        } catch (error: Exception) {
            Log.e(TAG, "Push transport migration failed; push stays closed until it succeeds", error)
            false
        }
    }

    private fun decide(paths: StartupPaths, state: State): Set<String> {
        val evidence = state as? State.Evidence
        val legacy = evidence?.legacy.orEmpty() + profilesWithConnector(paths)
        val unknown = profilesWithUnknownTransport(paths)
        val count = legacy.size + (evidence?.unattributed ?: 0)

        // An ambiguous old restore is a reason on its own, even when its
        // target looks like the only transport.
        val mayShare = state is State.Corrupt || unknown.isNotEmpty() || count >= 2
        return if (mayShare) (legacy + unknown).toSortedSet() else emptySet()
    }

    /** Throws when the folder exists but cannot be listed: that is not "no profiles". */
    private fun profileIds(paths: StartupPaths): List<String> {
        val dir = paths.profilesDir
        val entries = dir.listFiles()
            ?: if (dir.exists()) throw IOException("Cannot list ${dir.path}") else return emptyList()
        return entries
            .filter { it.isDirectory }
            .mapNotNull { ProfileUuid.fromDirName(it.name) }
    }

    private fun profilesWithConnector(paths: StartupPaths): Set<String> =
        profileIds(paths).filterTo(mutableSetOf()) {
            PushTransportFiles.hasConnectorDatabase(paths.profileDir(it))
        }

    private fun profilesWithUnknownTransport(paths: StartupPaths): Set<String> =
        profileIds(paths).filterTo(mutableSetOf()) {
            PushTransportFiles.transportUnknownMarker(paths.profileDir(it)).exists()
        }

    private fun stateFile(paths: StartupPaths) =
        AtomicJsonFile(paths.pushTransportMigrationFile, syncDirectory = true, strict = true)

    internal fun resetForTest() {
        synchronized(submitLock) { inFlight = null }
        done = false
    }

    private sealed interface State {
        fun toJson(): JSONObject = JSONObject().put(KEY_VERSION, VERSION)

        data object Absent : State

        data object Corrupt : State

        data class Evidence(val legacy: Set<String>, val unattributed: Int) : State {
            override fun toJson(): JSONObject = super.toJson()
                .put(KEY_PHASE, PHASE_EVIDENCE)
                .put(KEY_LEGACY, JSONArray(legacy.sorted()))
                .put(KEY_UNATTRIBUTED, unattributed)
        }

        data class Resetting(val reset: Set<String>) : State {
            override fun toJson(): JSONObject = super.toJson()
                .put(KEY_PHASE, PHASE_RESETTING)
                .put(KEY_RESET, JSONArray(reset.sorted()))
        }

        data object Done : State {
            override fun toJson(): JSONObject = super.toJson().put(KEY_PHASE, PHASE_DONE)
        }

        companion object {
            fun read(file: AtomicJsonFile): State = when (val read = file.read()) {
                AtomicJsonFile.Read.Absent -> Absent
                is AtomicJsonFile.Read.Corrupt -> Corrupt
                is AtomicJsonFile.Read.Present -> parse(read.json)
            }

            private fun parse(json: JSONObject): State = when (json.stringOrEmpty(KEY_PHASE)) {
                PHASE_DONE -> Done
                PHASE_RESETTING -> ids(json, KEY_RESET)?.let(::Resetting) ?: Corrupt
                PHASE_EVIDENCE -> ids(json, KEY_LEGACY)
                    ?.let { Evidence(it, json.intOr(KEY_UNATTRIBUTED, 0)) }
                    ?: Corrupt
                else -> Corrupt
            }

            /** Null when the list is missing: a reset set that cannot be read is not an empty one. */
            private fun ids(json: JSONObject, key: String): Set<String>? {
                val array = json.optJSONArray(key) ?: return null
                return (0 until array.length())
                    .map { array.optString(it).lowercase() }
                    .filterTo(mutableSetOf(), ProfileUuid::isCanonical)
            }
        }
    }

    private const val VERSION = 1
    private const val KEY_VERSION = "version"
    private const val KEY_PHASE = "phase"
    private const val KEY_LEGACY = "legacy"
    private const val KEY_UNATTRIBUTED = "unattributed"
    private const val KEY_RESET = "reset"
    private const val PHASE_EVIDENCE = "evidence"
    private const val PHASE_RESETTING = "resetting"
    private const val PHASE_DONE = "done"
}
