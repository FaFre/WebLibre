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
import android.content.pm.ShortcutManager
import android.os.Build
import androidx.core.content.getSystemService
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONObject
import java.io.File

/**
 * A profile's PWA launch tokens, and the pinned shortcuts that use them.
 *
 * The tokens live in one global preference file keyed
 * `token_<startUrl>::<profileUuid>[::<contextId>]`, so they belong to a profile
 * without being stored under it. They are what makes a launch *trusted*: without
 * them a restored profile's home-screen icons still exist but no longer
 * authenticate, and every one of them falls back to the ordinary candidate
 * profile.
 *
 * Pinned shortcuts themselves cannot be fully round-tripped, and the manifest
 * says so. `requestPinShortcut` requires user confirmation, so a shortcut the
 * user removed cannot be put back by a restore; one that still exists keeps
 * working because its token comes back with this participant. On delete they are
 * disabled rather than removed — `disableShortcuts` is the strongest action
 * available for a pinned shortcut — which leaves them visible but inert instead
 * of silently launching into a profile that no longer exists.
 */
class PwaShortcutParticipant(private val context: Context) : MaintenanceParticipantHandler {
    companion object {
        const val ID = "pwaShortcuts"
        const val VERSION = 1

        private const val SNAPSHOT_FILE = "pwa_tokens.json"
        private const val ROLLBACK_FILE = "pwa_tokens.rollback.json"

        /**
         * Whether [key] names a token belonging to [profileId].
         *
         * The profile is the second `::` segment. Matching on "contains the uuid"
         * would also match a *start URL* that happens to contain it.
         */
        fun belongsToProfile(key: String, profileId: String): Boolean {
            if (!key.startsWith(PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX)) return false

            val segments = key
                .removePrefix(PwaConstants.PROFILE_MAPPING_TOKEN_PREFIX)
                .split("::")

            return segments.size >= 2 && segments[1].equals(profileId, ignoreCase = true)
        }
    }

    private val logger = Logger("PwaShortcutParticipant")

    private fun mappings() = context.getSharedPreferences(
        PwaConstants.PROFILE_MAPPING_PREFS,
        Context.MODE_PRIVATE,
    )

    private fun capture(profileId: String): JSONObject {
        val tokens = JSONObject()
        for ((key, value) in mappings().all) {
            if (belongsToProfile(key, profileId) && value is String) {
                tokens.put(key, value)
            }
        }

        return JSONObject().apply {
            put("version", VERSION)
            put("tokens", tokens)
        }
    }

    override fun prepare(workDir: File, profileId: String, kind: String): Boolean {
        val snapshot = capture(profileId)
        val name = if (kind == "backup") SNAPSHOT_FILE else ROLLBACK_FILE
        AtomicJsonFile(File(workDir, name)).write(snapshot)
        return true
    }

    override fun apply(workDir: File, profileId: String, kind: String): Boolean = when (kind) {
        "restore" -> {
            val staged = readTokens(File(workDir, SNAPSHOT_FILE))
            if (staged == null) {
                logger.info("Archive carries no PWA tokens; leaving them as they are")
                true
            } else {
                writeTokens(profileId, staged)
            }
        }

        "delete" -> {
            // Both steps always run. Disabling is best effort and independent of
            // the token write, and a `&&` here would leave a shortcut still
            // launching *trusted* into a profile being deleted precisely when the
            // removal that should have stopped it failed. The write's result is
            // still what the participant reports, so the failure is not hidden.
            val removed = removeTokens(profileId)
            disablePinnedShortcuts(profileId)
            removed
        }

        else -> true
    }

    override fun verify(workDir: File, profileId: String, kind: String): Boolean = when (kind) {
        "delete" -> mappings().all.keys.none { belongsToProfile(it, profileId) }
        else -> true
    }

    override fun finalizeWork(workDir: File): Boolean {
        File(workDir, ROLLBACK_FILE).delete()
        return true
    }

    override fun rollback(workDir: File, profileId: String): Boolean {
        // Absent undo data is not a failure: recovery cannot know which
        // participants applied, so "nothing to put back" is an expected answer.
        // Corrupt undo data is — it exists and cannot be used — and stays a
        // refusal, so the operation is held rather than reported reconciled.
        val snapshot = when (val result = AtomicJsonFile(File(workDir, ROLLBACK_FILE)).read()) {
            is AtomicJsonFile.Read.Present -> result.json.optJSONObject("tokens") ?: JSONObject()
            AtomicJsonFile.Read.Absent -> return true
            is AtomicJsonFile.Read.Corrupt -> {
                logger.warn("PWA token rollback data is unreadable: ${result.reason}")
                return false
            }
        }

        if (!removeTokens(profileId)) return false
        if (!writeTokens(profileId, snapshot)) return false

        // Delete's `apply` disables this profile's pinned shortcuts, and putting
        // the tokens back does not undo that: a disabled shortcut stays greyed out
        // with "This profile was deleted" on it forever, and re-pinning by hand is
        // the only way back. Unconditional because this is the only code that ever
        // disables them, so re-enabling one that was never disabled is a no-op —
        // and rollback does not get told which operation it is undoing.
        enablePinnedShortcuts(profileId)
        return true
    }

    private fun readTokens(file: File): JSONObject? =
        when (val result = AtomicJsonFile(file).read()) {
            is AtomicJsonFile.Read.Present -> result.json.optJSONObject("tokens")
            else -> null
        }

    /**
     * Replaces this profile's launch tokens with [tokens], and reports whether the
     * change reached disk.
     *
     * Replace, not merge. A token is what makes a home-screen shortcut a
     * *trusted* launch, so merging left a PWA installed after the backup still
     * authenticating into a profile whose data has just been rolled back to a
     * point where that PWA did not exist. The preferences participant draws the
     * same line for the same reason.
     *
     * `commit()` rather than `apply()`, everywhere on this path. `apply()` returns
     * before the write lands, so the participant could report success, the journal
     * could advance past it, and a power loss could then leave the profile with
     * tokens the record says were already replaced. Every other durable step in
     * maintenance is written and flushed before it is claimed; this one holds
     * credentials for trusted launches and has no reason to be the exception. It
     * blocks, which on a maintenance screen with no browser behind it is free.
     */
    private fun writeTokens(profileId: String, tokens: JSONObject): Boolean {
        val prefs = mappings()
        val editor = prefs.edit()

        // One editor for the removal and the write, so a crash between them
        // cannot leave the profile with no tokens at all — which would silently
        // demote every one of its home-screen shortcuts to an untrusted launch.
        for (key in prefs.all.keys.filter { belongsToProfile(it, profileId) }) {
            editor.remove(key)
        }

        for (key in tokens.keys()) {
            // Only ever writes this profile's own keys, even if the staged file
            // claims others: an archive is not entitled to rewrite another
            // profile's launch tokens.
            if (!belongsToProfile(key, profileId)) continue
            tokens.optString(key).takeIf { it.isNotEmpty() }?.let { editor.putString(key, it) }
        }

        return editor.commit().also {
            if (!it) logger.error("Could not persist PWA tokens for $profileId")
        }
    }

    /** See [writeTokens] on why this commits rather than applies. */
    private fun removeTokens(profileId: String): Boolean {
        val prefs = mappings()
        val editor = prefs.edit()
        for (key in prefs.all.keys.filter { belongsToProfile(it, profileId) }) {
            editor.remove(key)
        }

        return editor.commit().also {
            if (!it) logger.error("Could not remove PWA tokens for $profileId")
        }
    }

    /**
     * Puts back the shortcuts [disablePinnedShortcuts] took away.
     *
     * Best effort, like its counterpart: a home-screen shortcut is outside this
     * app's storage and failing to reach it is not a reason to hold a rollback
     * that has already put the data back.
     */
    private fun enablePinnedShortcuts(profileId: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return

        val manager = context.getSystemService<ShortcutManager>() ?: return
        val ids = runCatching {
            manager.pinnedShortcuts
                .filter { shortcut ->
                    !shortcut.isEnabled &&
                        shortcut.intent
                            ?.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
                            ?.equals(profileId, ignoreCase = true) == true
                }
                .map { it.id }
        }.getOrElse { error ->
            logger.warn("Could not enumerate pinned shortcuts", error)
            return
        }

        if (ids.isEmpty()) return

        runCatching {
            manager.enableShortcuts(ids)
        }.onFailure { logger.warn("Could not re-enable pinned shortcuts", it) }
    }

    private fun disablePinnedShortcuts(profileId: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return

        val manager = context.getSystemService<ShortcutManager>() ?: return
        val ids = runCatching {
            manager.pinnedShortcuts
                .filter { shortcut ->
                    shortcut.intent
                        ?.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID)
                        ?.equals(profileId, ignoreCase = true) == true
                }
                .map { it.id }
        }.getOrElse { error ->
            logger.warn("Could not enumerate pinned shortcuts", error)
            return
        }

        if (ids.isEmpty()) return

        runCatching {
            manager.disableShortcuts(ids, "This profile was deleted")
        }.onFailure { logger.warn("Could not disable pinned shortcuts", it) }
    }
}
