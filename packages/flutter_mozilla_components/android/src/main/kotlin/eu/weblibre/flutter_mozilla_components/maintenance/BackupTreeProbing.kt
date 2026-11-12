/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.maintenance

import android.content.Context
import android.provider.DocumentsContract
import android.system.ErrnoException
import android.system.OsConstants
import eu.weblibre.flutter_mozilla_components.SafTreeUris
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbeOutcome
import java.io.FileNotFoundException

/**
 * The decisions behind `GeckoProfileApi.probeBackupTree`, kept apart from the
 * content resolver calls so they can be tested.
 */
internal object BackupTreeProbing {
    /**
     * Whether a persisted read/write grant covers the folder [treeUri] names.
     *
     * Compared as tree URIs, not as strings: the app stores the picker's
     * document form (`…/tree/<id>/document/<id>`) while the grant is recorded
     * on the tree form (`…/tree/<id>`). Plain equality reported every folder
     * picked in the app as having no grant.
     */
    fun hasReadWriteGrant(context: Context, treeUri: String): Boolean {
        val wanted = SafTreeUris.normalizeTreeUri(treeUri)

        // Grants on single documents, which shared files leave behind, are
        // skipped before normalizing: they are not trees and would only throw.
        return context.contentResolver.persistedUriPermissions.any {
            it.isReadPermission &&
                it.isWritePermission &&
                DocumentsContract.isTreeUri(it.uri) &&
                SafTreeUris.normalizeTreeUri(it.uri.toString()) == wanted
        }
    }

    /**
     * Which way creating or opening a file in the folder failed.
     *
     * Only access failures blame the folder. Callers act on that answer — they
     * ask for the folder again, or forget it — so a full volume or a provider
     * that died must not be reported as one: the folder is fine, and telling
     * the user to choose it again sends them the wrong way.
     *
     * Exceptions that crossed the binder arrive rebuilt from their class and
     * message only (ExternalStorageProvider reports a failed create as
     * `IllegalStateException("Failed to touch …: java.io.IOException: No space
     * left on device")`), so the errno is matched in the message text as well
     * as on a local [ErrnoException].
     *
     * [folderInDoubt] says the error came from creating the file in a folder
     * the query did not show to be there. There, and only there, a
     * [FileNotFoundException] answers for the folder: every `DocumentsProvider`
     * reports a parent it does not have — a deleted folder, an unmounted volume
     * (`ExternalStorageProvider`'s "Missing file for …" and "No root for …") —
     * that way, and `DocumentsContract` rethrows it as itself. Querying the same
     * folder cannot say so: `DocumentsProvider` turns that exception into a null
     * cursor, which is also what a provider that crashed returns. Once the
     * query has returned the folder's row, the exception is the provider
     * failing some other way: it is the only checked exception a create can
     * declare. Elsewhere it is just as often `ContentResolver`'s "Dead content
     * provider". Both stay inconclusive.
     */
    fun classifyFailure(error: Throwable, folderInDoubt: Boolean = false): BackupTreeProbeOutcome {
        val chain = causes(error)

        if (chain.any { it.hasErrno(NO_SPACE_ERRNOS) || it.endsWithError(NO_SPACE_TEXT) }) {
            return BackupTreeProbeOutcome.NO_SPACE
        }
        if (chain.any {
                it is SecurityException ||
                    it.hasErrno(ACCESS_ERRNOS) ||
                    it.endsWithError(ACCESS_TEXT)
            }
        ) {
            return BackupTreeProbeOutcome.REFUSED
        }
        if (folderInDoubt && error is FileNotFoundException) {
            return BackupTreeProbeOutcome.MISSING
        }
        return BackupTreeProbeOutcome.INCONCLUSIVE
    }

    private fun causes(error: Throwable): List<Throwable> {
        val seen = mutableListOf<Throwable>()
        var current: Throwable? = error
        while (current != null && current !in seen && seen.size < MAX_CAUSES) {
            seen += current
            current = current.cause
        }
        return seen
    }

    private fun Throwable.hasErrno(errnos: Set<Int>): Boolean =
        this is ErrnoException && errno in errnos

    /**
     * Whether the message ends by naming one of [errors], as the platform
     * words them: `…: No space left on device`, or
     * `open failed: ENOSPC (No space left on device)`.
     *
     * Only the end counts, because everything before it can hold a path, and
     * a staging file's name holds the profile's name. A folder called EPERM
     * says nothing about access.
     */
    private fun Throwable.endsWithError(errors: List<String>): Boolean {
        val last = message?.trimEnd()?.substringAfterLast(": ") ?: return false
        return errors.any { last == it || last.startsWith("$it (") }
    }

    private const val MAX_CAUSES = 8

    private val NO_SPACE_ERRNOS = setOf(OsConstants.ENOSPC, OsConstants.EDQUOT)
    private val NO_SPACE_TEXT = listOf(
        "ENOSPC",
        "No space left on device",
        "EDQUOT",
        "Disk quota exceeded",
    )

    private val ACCESS_ERRNOS = setOf(OsConstants.EACCES, OsConstants.EPERM, OsConstants.EROFS)
    private val ACCESS_TEXT = listOf(
        "EACCES",
        "Permission denied",
        "EPERM",
        "Operation not permitted",
        "EROFS",
        "Read-only file system",
    )
}
