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

import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class StagingPathsTest {
    private val paths = UpdatePaths(File("/data/no_backup/app_update"), File("/data/cache/app_update"))
    private val digest = "a".repeat(64)

    @Test
    fun namesAreDerivedFromTheDigestOnly() {
        assertEquals(File("/data/cache/app_update/$digest.part"), paths.partFile(digest))
        assertEquals(File("/data/cache/app_update/$digest.apk"), paths.apkFile(digest))
    }

    @Test
    fun malformedDigestsAreRejectedBeforeAnyFileAccess() {
        for (bad in listOf(
            "",
            "A".repeat(64),
            "a".repeat(63),
            "a".repeat(65),
            "../../" + "a".repeat(58),
            "a".repeat(60) + ".apk",
        )) {
            assertThrows(IllegalArgumentException::class.java) { paths.partFile(bad) }
            assertThrows(IllegalArgumentException::class.java) { paths.apkFile(bad) }
        }
    }

    @Test
    fun everyUpdaterPathIsUnderNoBackupOrCache() {
        val noBackup = File("/data/no_backup")
        val cache = File("/data/cache")
        val real = UpdatePaths(File(noBackup, UpdatePaths.DIR_NAME), File(cache, UpdatePaths.DIR_NAME))
        assertTrue(real.journalFile.path.startsWith(noBackup.path))
        assertTrue(real.stateDir.path.startsWith(noBackup.path))
        assertTrue(real.partFile(digest).path.startsWith(cache.path))
        assertTrue(real.apkFile(digest).path.startsWith(cache.path))
    }
}
