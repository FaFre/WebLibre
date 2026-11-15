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
package eu.weblibre.gecko.update

import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.stringOrNull
import org.json.JSONObject
import java.io.File

/** Whether a session in this phase is history, not a reservation. */
val InstallerPhase.terminal: Boolean
    get() = when (this) {
        InstallerPhase.NONE, InstallerPhase.SUCCEEDED, InstallerPhase.FAILED, InstallerPhase.ABANDONED -> true
        InstallerPhase.SESSION_CREATED, InstallerPhase.COMMIT_REQUESTED,
        InstallerPhase.PENDING_USER_ACTION, InstallerPhase.ABANDON_REQUESTED -> false
    }

/** The session reached `commit()`, so an install that completes is ours. */
val InstallerPhase.reachedCommit: Boolean
    get() = this == InstallerPhase.COMMIT_REQUESTED ||
        this == InstallerPhase.PENDING_USER_ACTION ||
        this == InstallerPhase.SUCCEEDED

data class JournalState(
    val phase: InstallerPhase = InstallerPhase.NONE,
    val sessionId: Int? = null,
    val nonce: String? = null,
    val expected: ExpectedArtifact? = null,
    val failure: NativeFailure? = null,
    val lastMessage: String? = null,
    /** The previous session's outcome, kept after retiring it. */
    val lastOutcome: InstallerPhase? = null,
    val lastOutcomeFailure: NativeFailure? = null,
) {
    /**
     * History, not a reservation (7.5 step 7): the outcome moves to the
     * `last*` fields and the session fields are cleared.
     */
    fun retired(): JournalState = JournalState(
        lastOutcome = phase,
        lastOutcomeFailure = failure,
    )

    fun toJson(): JSONObject = JSONObject().apply {
        put("phase", phase.wire)
        sessionId?.let { put("sessionId", it) }
        nonce?.let { put("nonce", it) }
        expected?.let { put("expected", it.toJson()) }
        failure?.let { put("failure", it.wire) }
        lastMessage?.let { put("lastMessage", it) }
        lastOutcome?.let { put("lastOutcome", it.wire) }
        lastOutcomeFailure?.let { put("lastOutcomeFailure", it.wire) }
    }

    companion object {
        fun fromJson(json: JSONObject): JournalState {
            val phase = json.requireWire<InstallerPhase>("phase")
            return JournalState(
                phase = phase,
                sessionId = if (json.has("sessionId")) json.getInt("sessionId") else null,
                nonce = json.stringOrNull("nonce"),
                expected = json.optJSONObject("expected")?.let(::expectedFromJson),
                failure = json.optWire("failure"),
                lastMessage = json.stringOrNull("lastMessage"),
                lastOutcome = json.optWire("lastOutcome"),
                lastOutcomeFailure = json.optWire("lastOutcomeFailure"),
            )
        }
    }
}

fun ExpectedArtifact.toJson(): JSONObject = JSONObject().apply {
    put("sha256", sha256)
    put("byteLength", byteLength)
    put("versionCode", versionCode)
    put("logicalReleaseSequence", logicalReleaseSequence)
    put("distribution", distribution.wire)
    put("track", track.wire)
    put("renderer", renderer.wire)
    put("abi", abi)
    put("authorizedUntilEpochMs", authorizedUntilEpochMs)
}

fun expectedFromJson(json: JSONObject): ExpectedArtifact = ExpectedArtifact(
    sha256 = UpdatePaths.requireDigest(json.getString("sha256")),
    byteLength = json.getLong("byteLength"),
    versionCode = json.getLong("versionCode"),
    logicalReleaseSequence = json.getLong("logicalReleaseSequence"),
    distribution = json.requireWire("distribution"),
    track = json.requireWire("track"),
    renderer = json.requireWire("renderer"),
    abi = json.getString("abi"),
    authorizedUntilEpochMs = json.getLong("authorizedUntilEpochMs"),
)

/** A value this build doesn't know makes the journal unreadable, never absent. */
private inline fun <reified E : Enum<E>> JSONObject.optWire(key: String): E? =
    if (has(key)) requireWire<E>(key) else null

sealed class JournalRead {
    object Absent : JournalRead()
    data class Present(val state: JournalState) : JournalRead()

    /** Unreadable is never absence: it proves nothing either way (7.6). */
    data class Corrupt(val reason: String) : JournalRead()
}

/**
 * `installer_journal.json` (plan 6, 7.5). Kotlin's alone: the installer's
 * status broadcast can arrive in a process with no Flutter engine. Dart reads
 * it through the bridge and never writes it.
 *
 * Written ahead of each step, with `fsync(file)`, rename, `fsync(directory)`,
 * so a recorded phase survives a power cut once the write returned.
 */
class InstallerJournal(file: File) {
    private val store = AtomicJsonFile(file, syncDirectory = true)
    private val lock = Any()

    fun read(): JournalRead = synchronized(lock) {
        when (val read = store.read()) {
            AtomicJsonFile.Read.Absent -> JournalRead.Absent
            is AtomicJsonFile.Read.Corrupt -> JournalRead.Corrupt(read.reason)
            is AtomicJsonFile.Read.Present -> try {
                JournalRead.Present(JournalState.fromJson(read.json))
            } catch (e: Exception) {
                JournalRead.Corrupt(e.toString())
            }
        }
    }

    /** The state, or null when the journal is absent or unreadable. */
    fun state(): JournalState? = (read() as? JournalRead.Present)?.state

    fun write(state: JournalState) = synchronized(lock) { store.write(state.toJson()) }
}
