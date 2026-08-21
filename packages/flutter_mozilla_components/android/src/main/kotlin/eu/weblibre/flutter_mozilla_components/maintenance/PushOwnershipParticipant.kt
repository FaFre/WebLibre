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
package eu.weblibre.flutter_mozilla_components.maintenance

import android.content.Context
import eu.weblibre.flutter_mozilla_components.push.PushOwnershipStore
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Keeps the global push ownership map in step with a profile's data.
 *
 * The map is the only piece of a profile's push state that lives *outside* the
 * profile — the connector's own database is inside it, and therefore already
 * travels in the archive. What travels badly is the claim "this token belongs to
 * this profile": after a restore the profile's tokens came out of an archive, and
 * whether a distributor still honours them is not something this side can know.
 *
 * So restore and delete **purge** rather than rewrite. The map is a cache whose
 * only power is to make the receiver decline a broadcast, so a missing entry costs
 * one redundant wake-up while a wrong entry costs a message. Purging is the choice
 * that fails in the cheap direction.
 */
class PushOwnershipParticipant(private val context: Context) : MaintenanceParticipantHandler {
    companion object {
        const val ID = "pushOwnership"
        const val VERSION = 1

        private const val SNAPSHOT_FILE = "push_ownership.json"
        private const val ROLLBACK_FILE = "push_ownership.rollback.json"
    }

    private val logger = Logger("PushOwnershipParticipant")

    private val store: PushOwnershipStore
        get() = PushOwnershipStore(StartupPaths(context.applicationContext))

    /**
     * Captures the profile's entries, as archive content or as undo data.
     *
     * The backup snapshot is informational: a restore does not replay it, for the
     * reason above. It is written anyway so a support question about a profile's
     * push registrations can be answered from the archive alone.
     */
    override fun prepare(workDir: File, profileId: String, kind: String): Boolean {
        val entries = store.entriesForProfile(profileId)
        val name = if (kind == "backup") SNAPSHOT_FILE else ROLLBACK_FILE

        AtomicJsonFile(File(workDir, name)).write(
            JSONObject().apply {
                put("profileId", profileId.lowercase())
                put("entries", JSONArray().apply { entries.forEach { put(it.toJson()) } })
            },
        )
        return true
    }

    override fun apply(workDir: File, profileId: String, kind: String): Boolean =
        when (kind) {
            "restore", "delete" -> {
                store.forgetProfile(profileId)
                true
            }

            else -> true
        }

    override fun verify(workDir: File, profileId: String, kind: String): Boolean =
        when (kind) {
            "restore", "delete" -> store.entriesForProfile(profileId).isEmpty()
            else -> true
        }

    override fun finalizeWork(workDir: File): Boolean {
        File(workDir, ROLLBACK_FILE).delete()
        return true
    }

    /**
     * Restores the entries that were purged.
     *
     * Only reachable before the restore's commit barrier, where the profile's own
     * data is about to go back to what it was — which makes its old tokens the
     * right ones again.
     */
    override fun rollback(workDir: File, profileId: String): Boolean {
        // Absent undo data is not a failure: recovery cannot know which
        // participants applied, so "nothing to put back" is an expected answer.
        // Corrupt undo data is — it exists and cannot be used — and stays a
        // refusal, so the operation is held rather than reported reconciled.
        val json = when (val result = AtomicJsonFile(File(workDir, ROLLBACK_FILE)).read()) {
            is AtomicJsonFile.Read.Present -> result.json
            AtomicJsonFile.Read.Absent -> return true
            is AtomicJsonFile.Read.Corrupt -> {
                logger.warn("Push ownership rollback data is unreadable: ${result.reason}")
                return false
            }
        }

        val entries = json.optJSONArray("entries") ?: JSONArray()
        val restored = store
        for (index in 0 until entries.length()) {
            val entry = entries.optJSONObject(index) ?: continue
            val owner = eu.weblibre.flutter_mozilla_components.push.PushOwner
                .tryFromJson(entry) ?: continue
            runCatching {
                restored.record(owner.token, owner.profileId, owner.instance, owner.updatedAtMillis)
            }.onFailure { logger.warn("Could not restore a push ownership entry", it) }
        }

        return true
    }
}
