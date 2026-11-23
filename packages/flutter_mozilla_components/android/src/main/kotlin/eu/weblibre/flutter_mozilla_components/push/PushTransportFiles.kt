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
package eu.weblibre.flutter_mozilla_components.push

import eu.weblibre.flutter_mozilla_components.ProfileContext
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import java.io.File
import java.io.IOException
import java.nio.channels.FileChannel
import java.nio.file.StandardOpenOption
import org.json.JSONObject

/**
 * Where a profile tree keeps its UnifiedPush transport, and the two markers that
 * say what became of it.
 *
 * The transport is the connector's database (tokens, the distributor and the
 * Keystore-wrapped Web Push keys) and the queue of decrypted payloads that have
 * not reached Gecko yet. Both identify the profile they were made for, so neither
 * may move into another profile: a clone or a restore that kept them could
 * decrypt and deliver the source's messages.
 *
 * Every name here is duplicated in Dart's `push_transport_scrub.dart`, which
 * leaves them out of archives and strips them from a restored tree.
 */
internal object PushTransportFiles {
    /** The connector's own database (`DBStore.DB_NAME` in connector 3.3.5). */
    const val CONNECTOR_DATABASE = "unifiedpush-connector"

    /** The SQLite side files that hold part of the same database. */
    private val SQLITE_SUFFIXES = listOf("", "-journal", "-wal", "-shm")

    /** [PushMessageStore]'s queue, under `noBackupFilesDir`. */
    const val QUEUED_MESSAGES_DIR = "queued_push_messages"

    /**
     * Under `noBackupFilesDir`: the subscription rows still carry the endpoints
     * and keys of a transport this tree no longer has. Push's startup clears them
     * before Gecko, the settings or a registration can read them.
     */
    const val ENDPOINT_RESET_MARKER = "push_endpoint_reset"

    /**
     * Under `noBackupFilesDir`: recovery of a restore made by an older build could
     * not tell whether this tree is the original or an unscrubbed replacement, so
     * its transport is treated as one that may be shared ([PushTransportMigration]).
     */
    const val TRANSPORT_UNKNOWN_MARKER = "push_transport_unknown"

    fun connectorFiles(profileDir: File): List<File> {
        val databases = File(profileDir, ProfileContext.DATABASES_DIR_NAME)
        return SQLITE_SUFFIXES.map { File(databases, CONNECTOR_DATABASE + it) }
    }

    /** A file check only: the connector's schema is private and never read. */
    fun hasConnectorDatabase(profileDir: File): Boolean = connectorFiles(profileDir).first().exists()

    fun queuedMessagesDir(profileDir: File): File = File(noBackup(profileDir), QUEUED_MESSAGES_DIR)

    fun endpointResetMarker(profileDir: File): File = File(noBackup(profileDir), ENDPOINT_RESET_MARKER)

    fun transportUnknownMarker(profileDir: File): File = File(noBackup(profileDir), TRANSPORT_UNKNOWN_MARKER)

    /** [ProfileContext.getNoBackupFilesDir] is the profile folder's `no_backup`. */
    fun endpointResetMarker(context: ProfileContext): File =
        File(context.noBackupFilesDir, ENDPOINT_RESET_MARKER)

    /**
     * Removes [profileDir]'s transport locally, sending nothing: no UNREGISTER, so
     * a profile that shares the tokens and has not reset yet keeps them alive.
     *
     * The endpoint-reset marker is written first. A kill after it and before the
     * deletes leaves a tree that resets again; the other order could leave the
     * old endpoints in the subscription rows with nothing to say they are dead.
     * The deletes are synced before it returns, so the migration's `done`,
     * written after it, cannot outlive them in a power cut. Idempotent, and
     * throws when any step failed.
     */
    fun reset(profileDir: File) {
        writeEndpointResetMarker(profileDir)
        connectorFiles(profileDir).forEach(::deleteOrThrow)
        val queue = queuedMessagesDir(profileDir)
        if (queue.exists() && !queue.deleteRecursively()) {
            throw IOException("Could not delete ${queue.path}")
        }
        deleteOrThrow(transportUnknownMarker(profileDir))
        syncDirectory(File(profileDir, ProfileContext.DATABASES_DIR_NAME))
        syncDirectory(noBackup(profileDir))
    }

    fun writeEndpointResetMarker(profileDir: File) {
        AtomicJsonFile(endpointResetMarker(profileDir), syncDirectory = true, strict = true)
            .write(JSONObject().put("version", MARKER_VERSION))
    }

    private fun noBackup(profileDir: File) = File(profileDir, ProfileContext.NO_BACKUP_DIR_NAME)

    /** As [AtomicJsonFile] syncs a directory; throws when it cannot. */
    private fun syncDirectory(dir: File) {
        if (!dir.isDirectory) return
        FileChannel.open(dir.toPath(), StandardOpenOption.READ).use { it.force(true) }
    }

    private fun deleteOrThrow(file: File) {
        if (file.exists() && !file.delete()) throw IOException("Could not delete ${file.path}")
    }

    private const val MARKER_VERSION = 1
}
