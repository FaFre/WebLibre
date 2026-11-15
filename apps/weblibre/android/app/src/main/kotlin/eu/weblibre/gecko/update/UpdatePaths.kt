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

import android.content.Context
import java.io.File

/**
 * Every file the updater owns (plan section 6).
 *
 * State lives under `noBackupFilesDir`, which Android Auto Backup and device
 * transfer never copy (F7): a restored backup must never bring back an old
 * revision floor or a stale installer journal. Staged downloads live under
 * `cacheDir`, so clearing the cache loses a download and nothing else.
 *
 * Staged files are named by their digest and by nothing else. [partFile] and
 * [apkFile] are the only way to name one, and both refuse a digest that is not
 * 64 lower-case hex characters before any file is touched.
 */
class UpdatePaths(val stateDir: File, val stagingDir: File) {
    constructor(context: Context) : this(
        File(context.noBackupFilesDir, DIR_NAME),
        File(context.cacheDir, DIR_NAME),
    )

    val journalFile: File get() = File(stateDir, "installer_journal.json")

    fun partFile(sha256: String): File = File(stagingDir, "${requireDigest(sha256)}.part")

    fun apkFile(sha256: String): File = File(stagingDir, "${requireDigest(sha256)}.apk")

    fun ensureDirs() {
        stateDir.mkdirs()
        stagingDir.mkdirs()
    }

    companion object {
        const val DIR_NAME = "app_update"

        private val DIGEST = Regex("^[0-9a-f]{64}$")

        fun isDigest(value: String): Boolean = DIGEST.matches(value)

        fun requireDigest(value: String): String {
            if (!isDigest(value)) {
                throw IllegalArgumentException("Not a SHA-256 digest: ${value.take(80)}")
            }
            return value
        }
    }
}
