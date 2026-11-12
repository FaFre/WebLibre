/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.maintenance

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.system.ErrnoException
import android.system.Os
import android.system.OsConstants
import android.util.Log
import eu.weblibre.flutter_mozilla_components.SafTreeUris
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbe
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbeOutcome
import eu.weblibre.flutter_mozilla_components.pigeons.TreePublication
import eu.weblibre.flutter_mozilla_components.pigeons.TreePublicationFault
import java.io.FileDescriptor
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

/**
 * Creates files in a SAF tree through [DocumentsContract] directly.
 *
 * AndroidX's `DocumentFile.createFile` — and `saf_stream`, which is built on
 * it — catches the provider's exception and returns null, so a refused folder,
 * a full volume and a deleted folder all arrived as the same bare "File
 * creation failed" (issue #698). Here every call keeps the provider's own
 * exception and sorts it with [BackupTreeProbing.classifyFailure].
 *
 * Blocking: call it off the main thread.
 *
 * [freeBytes] measures the room left behind a descriptor the provider handed
 * out, and [fsync] pushes what was written to it to storage. Both injectable
 * because the platform's `fstatvfs` and `fsync` are not there under
 * Robolectric, and a sync that fails is what a test needs to cause.
 */
internal class SafTreeWriter(
    private val context: Context,
    private val freeBytes: (FileDescriptor) -> Long? = ::measureFreeBytes,
    private val fsync: (FileDescriptor) -> Unit = Os::fsync,
) {
    private val resolver: ContentResolver
        get() = context.contentResolver

    /**
     * Creates a hidden file in [treeUri], writes a block to it, syncs it and
     * deletes it again.
     *
     * Real bytes, not an empty file: on a full volume an empty file usually
     * still gets created, because it only needs a free inode, and the probe
     * would then call writable a folder no backup fits in.
     */
    fun probe(treeUri: String): BackupTreeProbe {
        val folder = when (val located = locate(treeUri)) {
            is Located.Stopped -> return located.probe
            is Located.Found -> located
        }

        // Hidden and unique, so it never lands on a user's file and never
        // shows up in a file manager during the moment it exists.
        val document = try {
            DocumentsContract.createDocument(
                resolver,
                folder.uri,
                PROBE_MIME_TYPE,
                "$PROBE_PREFIX${UUID.randomUUID()}",
            )
        } catch (error: Exception) {
            return failedProbe(error, folder.name, folderInDoubt = !folder.isConfirmed)
        } ?: return BackupTreeProbe(
            // Below API 26 `createDocument` logs the provider's exception and
            // returns null instead of throwing it, so there is nothing to tell
            // a refusal from a full disk by.
            outcome = BackupTreeProbeOutcome.INCONCLUSIVE,
            folderName = folder.name,
            errorMessage = "The provider created no document",
        )

        return try {
            write(document, requiredBytes = null) { out ->
                out.write(PROBE_BYTES)
                PROBE_BYTES.size.toLong()
            }
            BackupTreeProbe(outcome = BackupTreeProbeOutcome.WRITABLE, folderName = folder.name)
        } catch (error: Exception) {
            failedProbe(error, folder.name)
        } finally {
            // Harmless if it stays — small and hidden — but worth explaining.
            delete(document, "test file")
        }
    }

    /**
     * The display name of the folder [treeUri] names, or null when the provider
     * gives none. Blocks on the provider, so never on the main thread.
     */
    fun folderName(treeUri: String): String? =
        SafTreeUris.folderDocumentUri(Uri.parse(treeUri))?.let(::displayNameOf)

    /**
     * Copies [sourceLength] bytes from [source] into [treeUri] as [fileName].
     *
     * Written as [stagingName] first, checked against the size the provider
     * reports, and only then renamed: until the rename nothing in the folder
     * claims to be finished. Every failure past the create removes the staging
     * file, so a write that died half way — a full volume, a revoked grant —
     * does not leave hundreds of megabytes behind on the very storage that ran
     * out.
     *
     * A source that cannot be read is reported as
     * [TreePublicationFault.SOURCE_UNREADABLE] and never classified: its
     * errors are the app's own storage talking, and an EACCES there must not
     * read as the folder refusing access.
     */
    fun publish(
        source: () -> InputStream,
        sourceLength: Long,
        treeUri: String,
        fileName: String,
        stagingName: String,
        mimeType: String,
    ): TreePublication {
        val folder = when (val located = locate(treeUri)) {
            is Located.Stopped -> return TreePublication(
                outcome = located.probe.outcome,
                errorClass = located.probe.errorClass,
                errorMessage = located.probe.errorMessage,
            )
            is Located.Found -> located
        }

        // Opened before anything is created in the folder, so a source that is
        // gone leaves nothing behind there.
        val input = try {
            source()
        } catch (error: Exception) {
            return unreadableSource(error)
        }

        return input.use {
            publishFrom(it, sourceLength, folder, treeUri, fileName, stagingName, mimeType)
        }
    }

    private fun publishFrom(
        input: InputStream,
        sourceLength: Long,
        folder: Located.Found,
        treeUri: String,
        fileName: String,
        stagingName: String,
        mimeType: String,
    ): TreePublication {
        val staging = try {
            DocumentsContract.createDocument(resolver, folder.uri, mimeType, stagingName)
        } catch (error: Exception) {
            return failedPublication(error, treeUri, folderInDoubt = !folder.isConfirmed)
        } ?: return TreePublication(
            outcome = BackupTreeProbeOutcome.INCONCLUSIVE,
            errorMessage = "The provider created no document",
        )

        try {
            val written = write(staging, requiredBytes = sourceLength) { out ->
                copy(input, out)
            }

            // A stream that closed without an error only says the bytes left
            // this process. The size the provider reports is its own word on
            // what arrived. A provider that reports none is taken at the
            // stream's word.
            val held = sizeOf(staging)
            if (written != sourceLength || (held != null && held != written)) {
                delete(staging, "incomplete file")
                val message = "Wrote $written of $sourceLength bytes, and the destination holds " +
                    (held?.toString() ?: "an unknown number")
                Log.w(TAG, "Publishing into $treeUri: $message")
                return TreePublication(
                    outcome = BackupTreeProbeOutcome.INCONCLUSIVE,
                    fault = TreePublicationFault.TRUNCATED,
                    errorMessage = message,
                )
            }

            // Null only below API 26, where the provider's exception is logged
            // instead of thrown.
            val published = DocumentsContract.renameDocument(resolver, staging, fileName)
                ?: throw IOException("The provider did not rename $staging")

            return TreePublication(
                outcome = BackupTreeProbeOutcome.WRITABLE,
                uri = published.toString(),
                name = displayNameOf(published) ?: fileName,
            )
        } catch (error: Exception) {
            delete(staging, "incomplete file")
            return when (error) {
                is SourceReadFailure -> unreadableSource(error.cause ?: error)
                is InsufficientRoom -> {
                    Log.w(TAG, "Publishing into $treeUri: ${error.message}")
                    TreePublication(
                        outcome = BackupTreeProbeOutcome.NO_SPACE,
                        requiredBytes = error.requiredBytes,
                        availableBytes = error.availableBytes,
                        errorMessage = error.message,
                    )
                }
                else -> failedPublication(error, treeUri)
            }
        }
    }

    /**
     * Copies [input] into [out] and returns the bytes copied.
     *
     * By hand rather than with `copyTo`, so a failed read can be told from a
     * failed write: only the write is the folder's.
     */
    private fun copy(input: InputStream, out: OutputStream): Long {
        val buffer = ByteArray(COPY_BUFFER_BYTES)
        var copied = 0L
        while (true) {
            val read = try {
                input.read(buffer)
            } catch (error: IOException) {
                throw SourceReadFailure(error)
            }
            if (read < 0) return copied
            out.write(buffer, 0, read)
            copied += read
        }
    }

    /** Reading the local source failed. Says nothing about the folder. */
    private class SourceReadFailure(cause: IOException) : IOException(cause)

    /**
     * The volume shows it lacks the room the file needs. ENOSPC underneath,
     * so anything that classifies it sees a full volume.
     */
    private class InsufficientRoom(val requiredBytes: Long, val availableBytes: Long) :
        IOException(
            "$requiredBytes bytes do not fit in the $availableBytes bytes free",
            ErrnoException("fstatvfs", OsConstants.ENOSPC),
        )

    private sealed interface Located {
        /** [isConfirmed]: the provider returned a row that says it is a folder. */
        class Found(val uri: Uri, val name: String?, val isConfirmed: Boolean = false) : Located

        class Stopped(val probe: BackupTreeProbe) : Located
    }

    /**
     * The folder [treeUri] names, as far as asking about it can tell.
     *
     * Only a row that says the folder has become something else settles
     * anything. No cursor at all does not: `DocumentsProvider.query` turns the
     * `FileNotFoundException` of a folder it does not have into a null cursor,
     * and `ContentResolver` returns the same null for a provider that crashed
     * or could not be reached. An empty cursor does not either: a provider
     * whose folder is offline or not yet synced can return one for a folder
     * that is fine. Calling either missing made a failed export forget a good
     * folder; calling them inconclusive meant a deleted folder or a removed SD
     * card was never reported as gone. So both are left to the create that
     * follows, where a provider does report a missing folder as such.
     *
     * A query that throws for a reason nobody recognises is no answer either,
     * and the write does not need it. Only a stated reason, such as a denied
     * permission, stops here.
     *
     * Columns are looked up by name: a provider may answer with its own
     * projection rather than the one asked for.
     */
    private fun locate(treeUri: String): Located {
        if (!BackupTreeProbing.hasReadWriteGrant(context, treeUri)) {
            return Located.Stopped(BackupTreeProbe(outcome = BackupTreeProbeOutcome.NO_GRANT))
        }

        // The folder a write through androidx would land in, so the check
        // tests the same place the backup is written to.
        val folder = SafTreeUris.folderDocumentUri(Uri.parse(treeUri))
            ?: return Located.Stopped(BackupTreeProbe(outcome = BackupTreeProbeOutcome.MISSING))

        val cursor = try {
            query(
                folder,
                arrayOf(
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                ),
            )
        } catch (error: FileNotFoundException) {
            // Only a provider outside `DocumentsProvider` lets this through.
            // The same non-answer as a null cursor.
            null
        } catch (error: Exception) {
            val failed = failedProbe(error, folderName = null)
            if (failed.outcome != BackupTreeProbeOutcome.INCONCLUSIVE) {
                return Located.Stopped(failed)
            }
            null
        } ?: return Located.Found(folder, name = null)

        val row = cursor.use {
            if (it.moveToFirst()) {
                it.stringAt(DocumentsContract.Document.COLUMN_MIME_TYPE) to
                    it.stringAt(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
            } else {
                null
            }
        }

        val (mimeType, folderName) = row ?: return Located.Found(folder, name = null)

        // A provider that leaves the type out has not said the folder is
        // anything else.
        if (mimeType != null && mimeType != DocumentsContract.Document.MIME_TYPE_DIR) {
            return Located.Stopped(
                BackupTreeProbe(outcome = BackupTreeProbeOutcome.MISSING, folderName = folderName),
            )
        }
        return Located.Found(
            folder,
            folderName,
            isConfirmed = mimeType == DocumentsContract.Document.MIME_TYPE_DIR,
        )
    }

    /**
     * Opens [document], hands the stream to [body] and makes what it wrote
     * durable before closing. Returns what [body] returns: the bytes written.
     *
     * With [requiredBytes], a volume that visibly lacks that much room fails
     * before anything is copied, instead of being filled to the last byte
     * first.
     */
    private fun write(document: Uri, requiredBytes: Long?, body: (OutputStream) -> Long): Long {
        val stream = resolver.openOutputStream(document, "w")
            ?: throw FileNotFoundException("The provider returned no stream for $document")

        return stream.use { out ->
            // `ContentResolver` hands out a FileOutputStream over the
            // provider's descriptor. Anything else is written blind.
            val descriptor = (out as? FileOutputStream)?.fd

            // A lower bound: the file also takes the rest of its last block and
            // some metadata. A volume within that much of fitting passes here,
            // and the copy then fails with ENOSPC, which reports it as full —
            // only without the numbers.
            if (requiredBytes != null && descriptor != null) {
                val available = freeBytes(descriptor)
                if (available != null && available < requiredBytes) {
                    throw InsufficientRoom(requiredBytes, available)
                }
            }

            val written = body(out)
            out.flush()
            descriptor?.let(::sync)
            written
        }
    }

    /**
     * Pushes the written bytes to storage, so a failed writeback reports itself
     * here, while the staging file can still be thrown away, and not after the
     * stream is closed, when its error is lost.
     *
     * Through `Os.fsync`, not `FileDescriptor.sync()`: that one throws a bare
     * `SyncFailedException("sync failed")` with no errno and no cause, so a
     * volume that ran out of room or quota only at writeback, or an SD card
     * failing with EIO, looked the same as a descriptor that cannot be synced
     * at all, and was let through as a finished backup.
     *
     * Only that last case is let through: a pipe or a socket, what a cloud
     * provider usually hands out, answers EINVAL (or ENOSYS where sync is not
     * implemented), which says nothing about whether the bytes arrive. Every
     * other failure fails the write, classified by its errno like any other.
     */
    private fun sync(descriptor: FileDescriptor) {
        try {
            fsync(descriptor)
        } catch (error: ErrnoException) {
            if (error.errno !in UNSYNCABLE_ERRNOS) throw error
        }
    }

    private fun sizeOf(document: Uri): Long? =
        queryColumn(document, DocumentsContract.Document.COLUMN_SIZE) { cursor, index ->
            cursor.getLong(index)
        }

    private fun displayNameOf(document: Uri): String? =
        queryColumn(document, DocumentsContract.Document.COLUMN_DISPLAY_NAME) { cursor, index ->
            cursor.getString(index)
        }

    /**
     * One column of [document]'s row, or null when the provider gives none.
     * Found by name, like every column here.
     */
    private fun <T> queryColumn(
        document: Uri,
        column: String,
        read: (Cursor, Int) -> T?,
    ): T? = try {
        query(document, arrayOf(column))?.use {
            val index = it.getColumnIndex(column)
            if (index >= 0 && it.moveToFirst() && !it.isNull(index)) read(it, index) else null
        }
    } catch (error: Exception) {
        Log.w(TAG, "Could not read $column of $document", error)
        null
    }

    /**
     * [document]'s row, asked the way `ContentResolver` itself asks from API 26
     * on: with a Bundle. `DocumentsProvider` implements only that form, and
     * throws for the older one wherever a caller reaches it directly.
     */
    private fun query(document: Uri, columns: Array<String>): Cursor? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            resolver.query(document, columns, null as Bundle?, null)
        } else {
            resolver.query(document, columns, null, null, null)
        }

    private fun delete(document: Uri, what: String) {
        try {
            DocumentsContract.deleteDocument(resolver, document)
        } catch (error: Exception) {
            Log.w(TAG, "Could not remove the $what $document", error)
        }
    }

    private fun failedProbe(
        error: Throwable,
        folderName: String?,
        folderInDoubt: Boolean = false,
    ): BackupTreeProbe {
        val outcome = BackupTreeProbing.classifyFailure(error, folderInDoubt)
        Log.w(TAG, "The backup folder failed its write check: $outcome", error)
        return BackupTreeProbe(
            outcome = outcome,
            folderName = folderName,
            errorClass = error.javaClass.name,
            errorMessage = error.message,
        )
    }

    private fun failedPublication(
        error: Throwable,
        treeUri: String,
        folderInDoubt: Boolean = false,
    ): TreePublication {
        val outcome = BackupTreeProbing.classifyFailure(error, folderInDoubt)
        Log.w(TAG, "Publishing into $treeUri failed: $outcome", error)
        return TreePublication(
            outcome = outcome,
            errorClass = error.javaClass.name,
            errorMessage = error.message,
        )
    }

    private fun unreadableSource(error: Throwable): TreePublication {
        Log.w(TAG, "Could not read the file to publish", error)
        return TreePublication(
            outcome = BackupTreeProbeOutcome.INCONCLUSIVE,
            fault = TreePublicationFault.SOURCE_UNREADABLE,
            errorClass = error.javaClass.name,
            errorMessage = error.message,
        )
    }

    /** The value of [column] in the current row, or null when it has none. */
    private fun Cursor.stringAt(column: String): String? {
        val index = getColumnIndex(column)
        return if (index < 0 || isNull(index)) null else getString(index)
    }

    private companion object {
        const val TAG = "SafTreeWriter"

        const val PROBE_MIME_TYPE = "application/octet-stream"
        const val PROBE_PREFIX = ".weblibre-write-check-"

        /** One filesystem block, so the write has to allocate one. */
        val PROBE_BYTES = ByteArray(4096)

        const val COPY_BUFFER_BYTES = 256 * 1024

        /** What `fsync` answers for a descriptor that cannot be synced at all. */
        val UNSYNCABLE_ERRNOS = setOf(OsConstants.EINVAL, OsConstants.ENOSYS)
    }
}

/**
 * Bytes free on the filesystem behind [descriptor], or null when that would
 * say nothing about where the bytes go.
 *
 * Only a regular file counts: a pipe reports zero free bytes whatever the
 * provider at its other end has room for.
 */
internal fun measureFreeBytes(descriptor: FileDescriptor): Long? = try {
    if (!OsConstants.S_ISREG(Os.fstat(descriptor).st_mode)) {
        null
    } else {
        Os.fstatvfs(descriptor)
            .takeIf { it.f_blocks > 0 }
            ?.let { it.f_bavail * it.f_frsize }
    }
} catch (error: ErrnoException) {
    null
}
