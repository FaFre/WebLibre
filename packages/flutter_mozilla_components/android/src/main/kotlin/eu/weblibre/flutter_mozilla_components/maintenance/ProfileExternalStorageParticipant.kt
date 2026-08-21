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
import mozilla.components.support.base.log.logger.Logger
import java.io.File
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths

/**
 * The profile's trees on external storage.
 *
 * `ProfileContext` redirects `getExternalFilesDir` and `externalCacheDir` under
 * `<external>/weblibre_profiles/profile-<uuid>/`, so downloads and media a
 * profile owns live entirely outside its internal directory and no
 * directory-scoped backup or delete can see them.
 *
 * `files` travels; `cache` does not. External cache is regenerable for the same
 * reason the internal one is, and it is usually the larger of the two.
 */
class ProfileExternalStorageParticipant(private val context: Context) : MaintenanceParticipantHandler {
    companion object {
        const val ID = "externalStorage"
        const val VERSION = 1

        private const val STAGED_FILES = "external_files"
    }

    private val logger = Logger("ExternalStorageParticipant")

    private fun relativePath(profileId: String) =
        StartupPaths.relativeProfilePath(profileId.lowercase())

    /** The `files` tree, or null when external storage is unavailable. */
    private fun externalFiles(profileId: String): File? =
        externalTree(context.getExternalFilesDir(null), profileId, "files")

    private fun externalCache(profileId: String): File? =
        externalTree(context.externalCacheDir, profileId, "cache")

    /**
     * The profile's own subtree under an external root.
     *
     * `getExternalFilesDir`/`externalCacheDir` answer for the *app*, so the
     * profile's tree is one level up and back down — the same derivation
     * `ProfileContext` uses to create it.
     */
    private fun externalTree(appDir: File?, profileId: String, leaf: String): File? =
        appDir?.parentFile?.let { File(File(it, relativePath(profileId)), leaf) }

    override fun prepare(workDir: File, profileId: String, kind: String): Boolean {
        val source = externalFiles(profileId) ?: return true
        val staged = File(workDir, STAGED_FILES)

        return when (kind) {
            // Copied into the archive tree. Absent external storage is not a
            // failure: the profile simply never had any.
            "backup" -> {
                if (source.isDirectory) copyTree(source, staged) else true
            }

            // Rollback data for the two that mutate. Same file name as the
            // archived copy above and no conflict: this step is handed the undo
            // workspace, that one the archive tree. Same reasoning as backup —
            // nothing there means nothing to put back.
            else -> {
                if (source.isDirectory) copyTree(source, staged) else true
            }
        }
    }

    override fun apply(workDir: File, profileId: String, kind: String): Boolean {
        val target = externalFiles(profileId) ?: return true

        return when (kind) {
            "restore" -> {
                val staged = File(workDir, STAGED_FILES)
                if (!staged.isDirectory) {
                    // An archive from before this participant. Leaving the live
                    // tree alone beats deleting files the archive never carried.
                    logger.info("Archive carries no external storage; leaving it as it is")
                    true
                } else {
                    target.deleteRecursively()
                    copyTree(staged, target)
                }
            }

            "delete" -> {
                // Cache goes too — it is excluded from *backup* because it is
                // regenerable, not because it belongs to anyone else.
                externalCache(profileId)?.deleteRecursively()
                target.deleteRecursively()
                // The now-empty profile root is removed as well, so nothing
                // enumerating external storage still sees the profile.
                context.getExternalFilesDir(null)?.parentFile
                    ?.let { File(it, relativePath(profileId)) }
                    ?.deleteRecursively()
                true
            }

            else -> true
        }
    }

    override fun verify(workDir: File, profileId: String, kind: String): Boolean = when (kind) {
        "delete" -> externalFiles(profileId)?.exists() != true
        else -> true
    }

    override fun finalizeWork(workDir: File): Boolean {
        File(workDir, STAGED_FILES).deleteRecursively()
        return true
    }

    override fun rollback(workDir: File, profileId: String): Boolean {
        // Absent undo data is not a failure: recovery cannot know which
        // participants applied, so "nothing to put back" is an expected answer.
        // `false` stays reserved for a rollback that was attempted and failed.
        val staged = File(workDir, STAGED_FILES)
        if (!staged.isDirectory) return true

        val target = externalFiles(profileId) ?: return false
        target.deleteRecursively()
        return copyTree(staged, target)
    }

    private fun copyTree(source: File, target: File): Boolean = runCatching {
        target.parentFile?.mkdirs()
        source.copyRecursively(target, overwrite = true)
    }.getOrElse { error ->
        logger.error("Could not copy ${source.path} to ${target.path}", error)
        false
    }
}
