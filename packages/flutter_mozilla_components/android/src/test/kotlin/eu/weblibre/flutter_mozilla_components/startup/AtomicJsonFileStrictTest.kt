/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

import java.io.File
import java.nio.file.Files
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import org.json.JSONObject
import org.junit.Assume.assumeTrue

/**
 * Strict mode (5.6, F34): only a file confirmed absent reads as absent; one
 * whose existence cannot be established is corrupt, never "no record".
 */
class AtomicJsonFileStrictTest {
    private val root: File = Files.createTempDirectory("strict").toFile()

    @AfterTest
    fun tearDown() {
        root.walkTopDown().forEach { it.setReadable(true); it.setExecutable(true) }
        root.deleteRecursively()
    }

    @Test
    fun `a missing file is absent`() {
        assertEquals(AtomicJsonFile.Read.Absent, AtomicJsonFile(File(root, "r.json"), strict = true).read())
    }

    @Test
    fun `a file that cannot be stat'ed is corrupt in strict mode and absent otherwise`() {
        val folder = File(root, "locked").apply { mkdirs() }
        val file = File(folder, "r.json")
        AtomicJsonFile(file).write(JSONObject().put("a", 1))
        // Without search permission on the folder, stat of the file fails.
        folder.setExecutable(false)
        assumeTrue("running with permission checks", !file.exists() && folder.exists())

        assertIs<AtomicJsonFile.Read.Corrupt>(AtomicJsonFile(file, strict = true).read())
        assertEquals(AtomicJsonFile.Read.Absent, AtomicJsonFile(file).read())
    }

    @Test
    fun `a folder in the file's place is corrupt`() {
        val file = File(root, "r.json").apply { mkdirs() }

        assertIs<AtomicJsonFile.Read.Corrupt>(AtomicJsonFile(file, strict = true).read())
    }

    @Test
    fun `strict writes read back the same`() {
        val file = File(root, "r.json")
        val strict = AtomicJsonFile(file, syncDirectory = true, strict = true)

        strict.write(JSONObject().put("tabs", JSONObject()))

        val read = assertIs<AtomicJsonFile.Read.Present>(strict.read())
        assertEquals("{\"tabs\":{}}", read.json.toString())
    }
}
