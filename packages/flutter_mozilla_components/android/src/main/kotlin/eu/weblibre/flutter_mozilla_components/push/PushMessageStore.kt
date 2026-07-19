/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.system.Os
import android.system.OsConstants
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File
import java.io.FileDescriptor
import java.io.FileNotFoundException
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID

data class StoredPushMessage(
    val id: String,
    val scope: String,
    val payload: ByteArray,
)

internal class CorruptPushMessageException(
    message: String,
    cause: Throwable? = null,
) : IOException(message, cause)

/** Profile-scoped, crash-safe queue storage for decrypted push payloads. */
class PushMessageStore internal constructor(
    private val directory: File,
) {
    constructor(context: Context) : this(File(context.noBackupFilesDir, DIRECTORY_NAME))

    @Synchronized
    fun persist(scope: String, payload: ByteArray, id: String = UUID.randomUUID().toString()): StoredPushMessage {
        require(id.matches(SAFE_ID)) { "Invalid push message id" }
        require(payload.size <= MAX_PAYLOAD_BYTES) { "Push payload is too large" }
        directory.mkdirs()
        if (isCompleted(id)) return StoredPushMessage(id, scope, payload.copyOf())

        val target = file(id)
        val temporary = File(directory, ".$id.tmp")
        try {
            FileOutputStream(temporary).use { output ->
                DataOutputStream(output).use { data ->
                    data.writeInt(FORMAT_VERSION)
                    data.writeUTF(scope)
                    data.writeInt(payload.size)
                    data.write(payload)
                    data.flush()
                    output.fd.sync()
                }
            }
            check(temporary.renameTo(target)) { "Unable to persist push message" }
            syncDirectory()
        } finally {
            temporary.delete()
        }
        return StoredPushMessage(id, scope, payload.copyOf())
    }

    @Synchronized
    fun get(id: String): StoredPushMessage? {
        val source = file(id)
        if (!source.isFile) return null
        if (isCompleted(id)) return null

        try {
            DataInputStream(FileInputStream(source)).use { data ->
                if (data.readInt() != FORMAT_VERSION) {
                    throw CorruptPushMessageException("Unsupported push message format")
                }
                val scope = data.readUTF()
                val size = data.readInt()
                if (size < 0 || size > MAX_PAYLOAD_BYTES) {
                    throw CorruptPushMessageException("Invalid push payload size")
                }
                val payload = ByteArray(size)
                data.readFully(payload)
                return StoredPushMessage(id, scope, payload)
            }
        } catch (error: CorruptPushMessageException) {
            throw error
        } catch (error: FileNotFoundException) {
            if (!source.exists()) return null
            throw CorruptPushMessageException("Unable to open push message", error)
        } catch (error: IOException) {
            throw CorruptPushMessageException("Unable to read push message", error)
        }
    }

    @Synchronized
    fun ids(): List<String> {
        if (!directory.isDirectory) return emptyList()
        val files = directory.listFiles().orEmpty()
        files.filter {
            it.isFile &&
                it.extension == COMPLETED_EXTENSION &&
                it.nameWithoutExtension.matches(SAFE_ID)
        }.forEach { isCompleted(it.nameWithoutExtension) }

        return files
            .filter {
                it.isFile &&
                    it.extension == FILE_EXTENSION &&
                    it.nameWithoutExtension.matches(SAFE_ID)
            }
            .filterNot {
                val id = it.nameWithoutExtension
                isCompleted(id)
            }
            .map { it.nameWithoutExtension }
    }

    @Synchronized
    fun complete(id: String): Boolean {
        val source = file(id)
        val completed = completedFile(id)
        if (!source.exists()) {
            return true
        }

        if (!completed.isFile) {
            directory.mkdirs()
            val temporary = File(directory, ".$id.$COMPLETED_EXTENSION.tmp")
            try {
                FileOutputStream(temporary).use { output ->
                    output.write(COMPLETED_MARKER)
                    output.flush()
                    output.fd.sync()
                }
                if (!temporary.renameTo(completed)) return false
                syncDirectory()
            } finally {
                temporary.delete()
            }
        }

        source.delete()
        return true
    }

    private fun file(id: String): File {
        require(id.matches(SAFE_ID)) { "Invalid push message id" }
        return File(directory, "$id.$FILE_EXTENSION")
    }

    private fun completedFile(id: String): File {
        require(id.matches(SAFE_ID)) { "Invalid push message id" }
        return File(directory, "$id.$COMPLETED_EXTENSION")
    }

    private fun isCompleted(id: String): Boolean {
        val completed = completedFile(id)
        if (!completed.isFile) return false

        val source = file(id)
        if (source.exists()) source.delete()
        if (source.exists()) return true

        val expired = System.currentTimeMillis() - completed.lastModified() >= COMPLETED_TTL_MS
        if (expired && completed.delete()) return false
        return completed.exists()
    }

    private fun syncDirectory() {
        var descriptor: FileDescriptor? = null
        try {
            descriptor = Os.open(directory.path, OsConstants.O_RDONLY, 0)
            Os.fsync(descriptor)
        } catch (_: Exception) {
            // File fsync remains the fallback on platforms that cannot fsync directories.
        } finally {
            descriptor?.let { runCatching { Os.close(it) } }
        }
    }

    companion object {
        private const val DIRECTORY_NAME = "queued_push_messages"
        private const val FILE_EXTENSION = "push"
        private const val COMPLETED_EXTENSION = "delivered"
        private const val COMPLETED_MARKER = 1
        private const val COMPLETED_TTL_MS = 7 * 24 * 60 * 60 * 1000L
        private const val FORMAT_VERSION = 1
        private const val MAX_PAYLOAD_BYTES = 16 * 1024 * 1024
        private val SAFE_ID = Regex("[A-Za-z0-9_-]+")
    }
}
