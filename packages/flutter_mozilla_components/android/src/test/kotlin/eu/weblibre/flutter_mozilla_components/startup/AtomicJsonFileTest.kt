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
package eu.weblibre.flutter_mozilla_components.startup

import java.io.File
import java.nio.file.Files
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertTrue
import org.json.JSONObject

class AtomicJsonFileTest {

    private lateinit var dir: File

    @BeforeTest
    fun setUp() {
        dir = Files.createTempDirectory("weblibre_atomic").toFile()
    }

    @AfterTest
    fun tearDown() {
        dir.deleteRecursively()
    }

    @Test
    fun anAbsentFileReadsAsAbsentRatherThanCorrupt() {
        val store = AtomicJsonFile(File(dir, "missing.json"))
        assertIs<AtomicJsonFile.Read.Absent>(store.read())
    }

    @Test
    fun writesLeaveNoTempFileBehind() {
        val file = File(dir, "record.json")
        AtomicJsonFile(file).write(JSONObject().put("a", 1))

        assertTrue(file.isFile)
        assertFalse(File(dir, "record.json.tmp").exists())
    }

    @Test
    fun aWrittenRecordReadsBackIdentically() {
        val file = File(dir, "record.json")
        AtomicJsonFile(file).write(JSONObject().put("a", 1).put("b", "two"))

        val read = AtomicJsonFile(file).read()
        assertIs<AtomicJsonFile.Read.Present>(read)
        assertEquals(1, read.json.getInt("a"))
        assertEquals("two", read.json.getString("b"))
    }

    @Test
    fun malformedAndEmptyContentAreCorruptNotAbsent() {
        val malformed = File(dir, "malformed.json").apply { writeText("{ nope") }
        assertIs<AtomicJsonFile.Read.Corrupt>(AtomicJsonFile(malformed).read())

        val empty = File(dir, "empty.json").apply { writeText("   ") }
        assertIs<AtomicJsonFile.Read.Corrupt>(AtomicJsonFile(empty).read())
    }

    @Test
    fun quarantinePreservesTheOriginalBytes() {
        val file = File(dir, "record.json").apply { writeText("{ nope") }

        val quarantined = AtomicJsonFile(file).quarantine()

        assertFalse(file.exists())
        assertEquals("{ nope", File(quarantined!!).readText())
    }

    @Test
    fun aWriteReplacesTheWholeFileRatherThanOverlayingIt() {
        val file = File(dir, "record.json")
        AtomicJsonFile(file).write(JSONObject().put("long", "x".repeat(200)))
        AtomicJsonFile(file).write(JSONObject().put("short", 1))

        val read = AtomicJsonFile(file).read()
        assertIs<AtomicJsonFile.Read.Present>(read)
        assertFalse(read.json.has("long"))
    }
}
