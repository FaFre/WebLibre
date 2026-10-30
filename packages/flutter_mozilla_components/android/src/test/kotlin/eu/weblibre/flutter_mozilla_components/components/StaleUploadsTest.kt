/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import java.io.File
import java.nio.file.Files
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Test

/**
 * Uploads an earlier process left in `cacheDir/uploads`. Startup moves them
 * aside before any session exists and deletes them later, so a file chosen in
 * between must survive the delete.
 */
class StaleUploadsTest {
    private val cacheDir = Files.createTempDirectory("weblibre_stale_uploads").toFile()
    private val uploads = File(cacheDir, "uploads")

    @After
    fun tearDown() {
        cacheDir.deleteRecursively()
    }

    private fun upload(name: String) =
        File(uploads, name).apply {
            parentFile?.mkdirs()
            writeText(name)
        }

    @Test
    fun `a file chosen after detaching survives the delete`() {
        val stale = upload("stale.txt")

        StaleUploads.detach(cacheDir)
        val chosen = upload("chosen.txt")
        StaleUploads.deleteDetached(cacheDir)

        assertFalse(stale.exists())
        assertTrue(chosen.exists())
    }

    @Test
    fun `a delete that never finished does not keep uploads in place`() {
        File(cacheDir, "uploads_to_be_deleted/older.txt").apply {
            parentFile?.mkdirs()
            writeText("older")
        }
        upload("stale.txt")

        StaleUploads.detach(cacheDir)
        assertFalse(uploads.exists())

        StaleUploads.deleteDetached(cacheDir)
        assertEquals(emptyList(), cacheDir.list()?.toList())
    }
}
