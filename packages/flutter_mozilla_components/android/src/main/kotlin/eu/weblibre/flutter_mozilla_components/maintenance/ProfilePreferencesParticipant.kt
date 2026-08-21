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
import android.content.SharedPreferences
import androidx.preference.PreferenceManager
import eu.weblibre.flutter_mozilla_components.ActiveProfile
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import mozilla.components.support.base.log.logger.Logger
import java.io.File

/**
 * Carries a profile's SharedPreferences through backup, restore, and delete.
 *
 * These do not live in the profile directory — they are files named
 * `<prefix>_<name>` in `shared_prefs/`, plus keys suffixed `.<prefix>` in the
 * app-wide default file — so a directory-scoped operation cannot see them at all.
 * Without this participant a restored profile comes back signed out with its sync
 * engines reset, and a deleted profile leaves its account state behind.
 *
 * Every step is idempotent, because recovery cannot know which of them already
 * ran: the record of a step can fail to reach disk after the step succeeded.
 */
class ProfilePreferencesParticipant(private val context: Context) : MaintenanceParticipantHandler {
    companion object {
        const val ID = "sharedPreferences"
        const val VERSION = 1

        private const val SNAPSHOT_FILE = "preferences.json"
        private const val ROLLBACK_FILE = "preferences.rollback.json"

        /**
         * The storage prefix for an *arbitrary* profile.
         *
         * Deliberately derived from the profile id rather than read from
         * [ActiveProfile.prefix]. Maintenance runs in a process that has
         * committed nothing — that is the point of it — so asking the process
         * which profile it is would always answer "none", and the participant
         * would refuse every step. The profile it must act on is the task's, and
         * only the task knows it.
         */
        fun prefixFor(profileId: String): String =
            "${PwaConstants.PROFILE_DIR_PREFIX}${profileId.lowercase()}"
    }

    private val logger = Logger("PreferencesParticipant")

    /**
     * Reads the live state into a snapshot.
     *
     * A profile with nothing stored is a valid, empty snapshot rather than an
     * error: not every profile has ever signed in.
     */
    fun capture(prefix: String): PreferenceSnapshot {
        val files = LinkedHashMap<String, Map<String, Any>>()

        for (name in ActiveProfile.FXA_SHARED_PREFERENCE_NAMES) {
            val store = context.getSharedPreferences("${prefix}_$name", Context.MODE_PRIVATE)
            val values = store.all.filterValuesNotNull()
            if (values.isNotEmpty()) files[name] = values
        }

        val suffix = ".$prefix"
        val defaultKeys = PreferenceManager.getDefaultSharedPreferences(context)
            .all
            .filterKeys { it.endsWith(suffix) }
            .mapKeys { (key, _) -> key.removeSuffix(suffix) }
            .filterValuesNotNull()

        return PreferenceSnapshot(files = files, defaultKeys = defaultKeys)
    }

    /** Writes [snapshot] into the live stores under [prefix], replacing what is there. */
    fun restore(prefix: String, snapshot: PreferenceSnapshot) {
        // Cleared first, not merged into. `capture` omits a file that was empty
        // when the archive was written, so iterating the snapshot alone leaves a
        // *live* file that the archive does not describe exactly as it is: back
        // up while signed out, sign in, restore, and the restored profile comes
        // back signed in with an account its databases know nothing about.
        //
        // The rollback path below has always done it this way; only the forward
        // path was merging.
        for (name in ActiveProfile.FXA_SHARED_PREFERENCE_NAMES) {
            if (snapshot.files.containsKey(name)) continue
            context.getSharedPreferences("${prefix}_$name", Context.MODE_PRIVATE)
                .edit()
                .clear()
                .commit()
        }

        for ((name, values) in snapshot.files) {
            val store = context.getSharedPreferences("${prefix}_$name", Context.MODE_PRIVATE)
            store.edit().clear().also { editor -> editor.putAll(values) }.commit()
        }

        // The default file is shared with every other profile, so it cannot be
        // cleared the way the per-profile files are — but this profile's own keys
        // still have to be *replaced* rather than merged into. A key set after the
        // archive was written must not survive a restore that deliberately
        // reinstates an older state, and `verify` would not notice: it only checks
        // that the snapshot's keys are present.
        val suffix = ".$prefix"
        val defaults = PreferenceManager.getDefaultSharedPreferences(context)
        val editor = defaults.edit()
        for (key in defaults.all.keys.filter { it.endsWith(suffix) }) {
            editor.remove(key)
        }
        for ((key, value) in snapshot.defaultKeys) {
            editor.putAny("$key$suffix", value)
        }
        editor.commit()
    }

    /** Removes every trace of [prefix]. Missing state reconciles as already done. */
    fun purge(prefix: String) {
        for (name in ActiveProfile.FXA_SHARED_PREFERENCE_NAMES) {
            context.getSharedPreferences("${prefix}_$name", Context.MODE_PRIVATE)
                .edit()
                .clear()
                .commit()
            deletePreferenceFile("${prefix}_$name")
        }

        val suffix = ".$prefix"
        val defaults = PreferenceManager.getDefaultSharedPreferences(context)
        val editor = defaults.edit()
        for (key in defaults.all.keys.filter { it.endsWith(suffix) }) {
            editor.remove(key)
        }
        editor.commit()
    }

    // --- participant protocol ---------------------------------------------------

    /** Captures the live state: as archive content, or as rollback data. */
    override fun prepare(workDir: File, profileId: String, kind: String): Boolean {
        val snapshot = capture(prefixFor(profileId)).toJson()

        if (kind == "backup") {
            // Written into the archive tree, so restoring this archive finds it.
            // A backup mutates nothing, so there is nothing to roll back.
            AtomicJsonFile(File(workDir, SNAPSHOT_FILE)).write(snapshot)
        } else {
            // Restore and delete replace or remove live state, so the only thing
            // that can undo them is what was there beforehand.
            AtomicJsonFile(File(workDir, ROLLBACK_FILE)).write(snapshot)
        }

        return true
    }

    override fun apply(workDir: File, profileId: String, kind: String): Boolean {
        val prefix = prefixFor(profileId)

        return when (kind) {
            "restore" -> {
                val staged = readSnapshot(File(workDir, SNAPSHOT_FILE))
                if (staged == null) {
                    // An archive with no preference snapshot predates this
                    // participant. Leaving the live state alone is right: the
                    // alternative is wiping an account the archive never carried.
                    logger.info("Archive carries no preferences; leaving them as they are")
                    true
                } else {
                    restore(prefix, staged)
                    true
                }
            }

            "delete" -> {
                purge(prefix)
                true
            }

            else -> true
        }
    }

    override fun verify(workDir: File, profileId: String, kind: String): Boolean {
        val prefix = prefixFor(profileId)

        return when (kind) {
            "restore" -> {
                val staged = readSnapshot(File(workDir, SNAPSHOT_FILE)) ?: return true
                val live = capture(prefix)
                staged.files.all { (name, values) ->
                    live.files[name]?.let { it.keys.containsAll(values.keys) } ?: values.isEmpty()
                } && live.defaultKeys.keys.containsAll(staged.defaultKeys.keys)
            }

            "delete" -> capture(prefix).isEmpty

            else -> true
        }
    }

    /** Drops rollback data. Never fails the operation. */
    override fun finalizeWork(workDir: File): Boolean {
        File(workDir, ROLLBACK_FILE).delete()
        return true
    }

    override fun rollback(workDir: File, profileId: String): Boolean {
        val prefix = prefixFor(profileId)
        val file = File(workDir, ROLLBACK_FILE)

        // Absent undo data is not a failure: recovery cannot know which
        // participants applied, so "nothing to put back" is an expected answer.
        // An unreadable file is different — it exists and cannot be used — and
        // stays a refusal.
        if (!file.isFile) return true

        val snapshot = readSnapshot(file) ?: return false

        purge(prefix)
        restore(prefix, snapshot)
        return true
    }

    private fun readSnapshot(file: File): PreferenceSnapshot? =
        // Kotlin's reader never quarantines, which is what a rollback file needs:
        // moving it aside on a bad read would destroy the only copy of the state
        // an aborted apply has to be undone with.
        when (val result = AtomicJsonFile(file).read()) {
            is AtomicJsonFile.Read.Present -> PreferenceSnapshot.fromJson(result.json)
            else -> null
        }

    private fun deletePreferenceFile(name: String) {
        // `clear()` empties the store but leaves the XML behind, which keeps the
        // profile visible to anything that enumerates shared_prefs.
        val file = File(File(context.applicationInfo.dataDir, "shared_prefs"), "$name.xml")
        if (file.exists() && !file.delete()) {
            logger.warn("Could not remove preference file ${file.name}")
        }
    }
}

private fun Map<String, Any?>.filterValuesNotNull(): Map<String, Any> {
    val result = LinkedHashMap<String, Any>()
    for ((key, value) in this) {
        if (value != null) result[key] = value
    }
    return result
}

private fun SharedPreferences.Editor.putAll(values: Map<String, Any>) {
    for ((key, value) in values) putAny(key, value)
}

private fun SharedPreferences.Editor.putAny(key: String, value: Any) {
    when (value) {
        is Boolean -> putBoolean(key, value)
        is Int -> putInt(key, value)
        is Long -> putLong(key, value)
        is Float -> putFloat(key, value)
        is String -> putString(key, value)
        is Set<*> -> putStringSet(key, value.filterIsInstance<String>().toSet())
        else -> Unit
    }
}
