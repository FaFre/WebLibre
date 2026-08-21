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

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import mozilla.components.support.base.log.logger.Logger
import java.io.File

/**
 * Largest shared file the broker will copy.
 *
 * There has to be a limit, and this is where the honesty is: staging happens on
 * the main thread before the activity returns, because the grant that makes the
 * bytes readable dies with the process and a restart is exactly the case being
 * served. A 2 GB video would freeze the UI and fill the data partition, so past
 * this size the broker declines the launch instead of promising a replay it
 * should not attempt.
 */
const val STARTUP_INTENT_MAX_PAYLOAD_BYTES = 32L * 1024 * 1024

/** Extras that carry a shared stream. */
private const val EXTRA_STREAM = "android.intent.extra.STREAM"

/**
 * A shared file cannot survive a restart on its URI alone.
 *
 * A `content://` URI from a share sheet is backed by a grant scoped to the
 * receiving activity. After the process dies — which is the whole point of the
 * restart flow — the URI resolves to nothing, and an entry replaying it would
 * hand the user a share of a file that no longer exists.
 *
 * So the bytes are copied into the entry's payload directory before the launch is
 * queued, and the entry points at the copy. A persistable grant is preferred when
 * the sender offered one, because it costs no disk; most share sheets do not
 * offer one.
 *
 * When neither works the launch is **declined** rather than queued with a URI
 * that will not resolve. §7.1 is explicit about that: block rather than promise a
 * replay you cannot deliver.
 */
object StartupIntentPayloads {
    private val logger = Logger("StartupIntentPayloads")

    /** Whether [descriptor] references anything that needs staging. */
    fun needsStaging(descriptor: StartupIntentDescriptor): Boolean =
        isContentUri(descriptor.dataUri) ||
            isContentUri(descriptor.extras[EXTRA_STREAM] as? String)

    /**
     * Copies referenced content into [entryId]'s payload directory.
     *
     * Returns a descriptor whose URIs point at the copies, or null when the
     * content could not be staged — too large, unreadable, or gone already.
     */
    fun stage(
        context: Context,
        paths: StartupPaths,
        entryId: String,
        descriptor: StartupIntentDescriptor,
        intent: Intent? = null,
    ): StartupIntentDescriptor? {
        if (!needsStaging(descriptor)) return descriptor

        val payloadDir = paths.startupIntentPayloadDir(entryId)
        if (!payloadDir.exists() && !payloadDir.mkdirs()) {
            logger.warn("Could not create a payload directory for $entryId")
            return null
        }

        val staged = runCatching {
            var staged = descriptor

            descriptor.dataUri?.let { uri ->
                if (isContentUri(uri)) {
                    val local = persistOrCopy(context, payloadDir, "data", uri, intent)
                        ?: return@runCatching null
                    staged = staged.copy(dataUri = local)
                }
            }

            (descriptor.extras[EXTRA_STREAM] as? String)?.let { uri ->
                if (isContentUri(uri)) {
                    val local = persistOrCopy(context, payloadDir, "stream", uri, intent)
                        ?: return@runCatching null
                    staged = staged.copy(
                        extras = staged.extras + (EXTRA_STREAM to local),
                    )
                }
            }

            staged
        }.getOrElse { error ->
            logger.error("Could not stage a shared file; declining the launch", error)
            null
        }

        if (staged == null) {
            // A declined launch has to leave nothing behind, and a refusal is not
            // only an exception: `copy` returns null *after* writing part of the
            // file, because the size limit is enforced while copying. No queue entry
            // will ever name this directory, so nothing could find it again — not
            // even the payload sweep, which keys off live entries.
            payloadDir.deleteRecursively()
            return null
        }

        return staged
    }

    /** Removes an entry's staged bytes. */
    fun discard(paths: StartupPaths, entryId: String) {
        runCatching { paths.startupIntentPayloadDir(entryId).deleteRecursively() }
    }

    /** Removes payload directories no queue entry refers to any more. */
    fun prune(paths: StartupPaths, liveEntryIds: Set<String>) {
        val root = paths.startupIntentPayloadsDir
        val children = root.listFiles() ?: return

        for (child in children) {
            if (child.name !in liveEntryIds) {
                runCatching { child.deleteRecursively() }
            }
        }
    }

    private fun isContentUri(value: String?): Boolean =
        value != null && value.startsWith("${ContentResolver.SCHEME_CONTENT}:")

    /**
     * Takes a persistable grant if one was offered, otherwise copies the bytes.
     *
     * The grant is tried first because it costs nothing and keeps the original
     * URI meaningful. It only works when the sender set
     * `FLAG_GRANT_PERSISTABLE_URI_PERMISSION`, which most share sheets do not.
     */
    private fun persistOrCopy(
        context: Context,
        payloadDir: File,
        name: String,
        uri: String,
        intent: Intent?,
    ): String? {
        val parsed = Uri.parse(uri)

        if (intent != null && takePersistableGrant(context, parsed, intent)) {
            return uri
        }

        return copy(context, payloadDir, name, parsed)
    }

    private fun takePersistableGrant(
        context: Context,
        uri: Uri,
        intent: Intent,
    ): Boolean {
        val persistable = intent.flags and Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        if (persistable == 0) return false

        return runCatching {
            context.contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
            true
        }.getOrElse { error ->
            logger.info("Sender offered a persistable grant that could not be taken", error)
            false
        }
    }

    private fun copy(
        context: Context,
        payloadDir: File,
        name: String,
        uri: Uri,
    ): String? {
        val target = File(payloadDir, name)

        context.contentResolver.openInputStream(uri).use { input ->
            if (input == null) {
                logger.warn("Shared file could not be opened; declining the launch")
                return null
            }

            var copied = 0L
            target.outputStream().use { output ->
                val buffer = ByteArray(64 * 1024)
                while (true) {
                    val read = input.read(buffer)
                    if (read <= 0) break

                    copied += read
                    if (copied > STARTUP_INTENT_MAX_PAYLOAD_BYTES) {
                        // Checked while copying rather than from the reported
                        // size: a content provider is free to report nothing, or
                        // to report a size it then exceeds.
                        logger.warn("Shared file exceeds the staging limit; declining the launch")
                        return null
                    }

                    output.write(buffer, 0, read)
                }
                output.flush()
                output.fd.sync()
            }
        }

        return Uri.fromFile(target).toString()
    }
}
