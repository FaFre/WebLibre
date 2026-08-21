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
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets
import org.json.JSONObject

/**
 * Kotlin counterpart of Dart's `AtomicJsonFile`.
 *
 * Deliberately implemented on plain `java.io` rather than `android.util.AtomicFile`,
 * for two reasons: the on-disk layout has to match byte for byte what Dart writes
 * (AtomicFile keeps a `.bak` sibling and a different recovery rule), and the JVM
 * unit tests that prove Dart/Kotlin parity cannot call into the android.jar stub.
 *
 * Writes land in a same-directory temp file, are flushed and fsynced, then renamed
 * over the target. Readers therefore never observe a torn file.
 */
internal class AtomicJsonFile(private val file: File) {

    sealed interface Read {
        /** File does not exist; the caller substitutes its defaults. */
        object Absent : Read

        data class Present(val json: JSONObject) : Read

        /**
         * Present but unusable. Never conflated with [Absent]: for anything safety
         * relevant, "unreadable" has to keep the process cautious.
         */
        data class Corrupt(val reason: String) : Read
    }

    fun read(): Read {
        if (!file.isFile) return Read.Absent

        val contents = try {
            file.readText(StandardCharsets.UTF_8)
        } catch (error: Throwable) {
            return Read.Corrupt("unreadable: ${error.message}")
        }

        if (contents.isBlank()) return Read.Corrupt("empty")

        return try {
            Read.Present(JSONObject(contents))
        } catch (error: Throwable) {
            Read.Corrupt("malformed json: ${error.message}")
        }
    }

    fun write(json: JSONObject) {
        file.parentFile?.mkdirs()

        val temp = File(file.parentFile, "${file.name}.tmp")
        FileOutputStream(temp).use { stream ->
            stream.write(json.toString().toByteArray(StandardCharsets.UTF_8))
            stream.flush()
            stream.fd.sync()
        }

        if (!temp.renameTo(file)) {
            temp.delete()
            throw java.io.IOException("Could not replace ${file.path}")
        }
    }

    fun delete(): Boolean = !file.exists() || file.delete()

    /**
     * Moves a damaged file aside so it can still be inspected, and returns the new
     * path or `null` when even that failed.
     */
    fun quarantine(): String? {
        val target = File(file.parentFile, "${file.name}.corrupt.${System.currentTimeMillis()}")
        return if (file.renameTo(target)) target.path else null
    }
}
