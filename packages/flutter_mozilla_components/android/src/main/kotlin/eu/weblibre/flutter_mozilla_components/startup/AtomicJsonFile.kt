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
import java.io.IOException
import java.nio.channels.FileChannel
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.LinkOption
import java.nio.file.StandardOpenOption
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
 * over the target. Readers therefore never observe a torn file. With
 * [syncDirectory], the directory is fsynced after the rename as well, so a write
 * that returned survives a power cut (the app updater's installer journal).
 *
 * [strict] is for records whose loss is not safe to assume (the tab lifecycle
 * registry): a file whose existence cannot be established reads as [Read.Corrupt]
 * rather than [Read.Absent], and with [syncDirectory] a directory that cannot be
 * synced makes [write] throw instead of returning as if the rename were durable:
 * an [IOException] with the old content still in place when the directory cannot
 * be opened, an [UnconfirmedWriteException] when the rename happened but its sync
 * failed. The on-disk layout is the same either way.
 *
 * Public for the app module, which has no copy of its own.
 */
class AtomicJsonFile(
    private val file: File,
    private val syncDirectory: Boolean = false,
    private val strict: Boolean = false,
) {

    /**
     * [write] replaced the file, but the directory sync that makes the rename
     * durable failed (strict only): every reader sees the new content from now
     * on, yet a power cut may still bring back the old one.
     */
    class UnconfirmedWriteException(message: String, cause: Throwable) : IOException(message, cause)

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
        if (strict) {
            strictPresence()?.let { return it }
        } else if (!file.isFile) {
            return Read.Absent
        }

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

    /**
     * [Read.Absent] only when the file is confirmed not to exist; [Read.Corrupt]
     * when that cannot be established (`stat` failed, which `isFile` reports as
     * "not a file") or the path is not a regular file; null when it is one.
     */
    private fun strictPresence(): Read? {
        val path = file.toPath()
        if (Files.notExists(path, LinkOption.NOFOLLOW_LINKS)) return Read.Absent
        if (!Files.exists(path, LinkOption.NOFOLLOW_LINKS)) return Read.Corrupt("cannot stat")
        if (!Files.isRegularFile(path, LinkOption.NOFOLLOW_LINKS)) return Read.Corrupt("not a regular file")
        return null
    }

    fun write(json: JSONObject) {
        file.parentFile?.mkdirs()

        val temp = File(file.parentFile, "${file.name}.tmp")
        FileOutputStream(temp).use { stream ->
            stream.write(json.toString().toByteArray(StandardCharsets.UTF_8))
            stream.flush()
            stream.fd.sync()
        }

        // Opened before the rename, so a strict caller whose directory cannot
        // be synced learns it while the old content is still in place. Best
        // effort unless strict: not every file system lets a directory be opened.
        val directory = if (syncDirectory) {
            runCatching {
                FileChannel.open(file.absoluteFile.parentFile!!.toPath(), StandardOpenOption.READ)
            }.getOrElse { error ->
                if (strict) {
                    temp.delete()
                    throw IOException("Could not open the directory of ${file.path}", error)
                }
                null
            }
        } else {
            null
        }
        directory.use { channel ->
            if (!temp.renameTo(file)) {
                temp.delete()
                throw IOException("Could not replace ${file.path}")
            }
            val sync = channel?.let { runCatching { it.force(true) } }
            // A strict caller has to know the rename may not be durable.
            sync?.exceptionOrNull()?.let { error ->
                if (strict) throw UnconfirmedWriteException("Could not sync the directory of ${file.path}", error)
            }
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
