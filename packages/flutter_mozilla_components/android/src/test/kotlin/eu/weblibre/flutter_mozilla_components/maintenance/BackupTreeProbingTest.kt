/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.maintenance

import android.content.Context
import android.content.Intent
import android.os.DeadObjectException
import android.provider.DocumentsContract
import android.system.ErrnoException
import android.system.OsConstants
import androidx.core.net.toUri
import androidx.documentfile.provider.DocumentFile
import eu.weblibre.flutter_mozilla_components.SafTreeUris
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbeOutcome
import java.io.FileNotFoundException
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * The decisions behind the backup folder write check (issue #698).
 *
 * The grant test is the one that matters most: a check that cannot find the
 * grant for a folder the user just picked refuses every backup, and nothing
 * on a device makes that look like anything but a broken folder.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class BackupTreeProbingTest {
    private val context: Context = RuntimeEnvironment.getApplication()

    private val authority = "com.android.externalstorage.documents"
    private val treeUri = "content://$authority/tree/1A2B-3C4D%3ABackups"

    /** What the app stores: `saf_util` returns DocumentFile.fromTreeUri(...).uri. */
    private val pickedUri: String
        get() = DocumentFile.fromTreeUri(context, treeUri.toUri())!!.uri.toString()

    private fun grant(uri: String, write: Boolean = true) {
        context.contentResolver.takePersistableUriPermission(
            uri.toUri(),
            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                (if (write) Intent.FLAG_GRANT_WRITE_URI_PERMISSION else 0),
        )
    }

    @Test
    fun `the picker's document form of a folder finds the grant on its tree`() {
        assertNotEquals(treeUri, pickedUri, "the picker hands back the document form")

        grant(treeUri)

        assertTrue(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `the tree form finds its own grant`() {
        grant(treeUri)

        assertTrue(BackupTreeProbing.hasReadWriteGrant(context, treeUri))
    }

    @Test
    fun `no grant is no grant in either form`() {
        assertFalse(BackupTreeProbing.hasReadWriteGrant(context, treeUri))
        assertFalse(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `grants on single documents next to it do not get in the way`() {
        // What a shared file leaves on record. saf_util's own check threw on
        // the first grant that is not a tree, so settings export reopened the
        // picker on every export while the app held one.
        grant("content://com.example.files/document/shared.json", write = false)
        grant("content://com.example.files/document/other.json")
        grant(treeUri)

        assertTrue(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `a grant on another folder does not carry over`() {
        grant("content://$authority/tree/1A2B-3C4D%3AOther")

        assertFalse(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `the same document id on another provider does not carry over`() {
        grant("content://com.example.cloud/tree/1A2B-3C4D%3ABackups")

        assertFalse(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `a read-only grant is not enough to back up into`() {
        grant(treeUri, write = false)

        assertFalse(BackupTreeProbing.hasReadWriteGrant(context, pickedUri))
    }

    @Test
    fun `new files go into the folder the stored uri names`() {
        val root = DocumentsContract.buildDocumentUriUsingTree(treeUri.toUri(), "1A2B-3C4D:Backups")

        assertEquals(root, SafTreeUris.folderDocumentUri(treeUri.toUri()))
        assertEquals(root, SafTreeUris.folderDocumentUri(pickedUri.toUri()))

        val subfolder = DocumentsContract.buildDocumentUriUsingTree(
            treeUri.toUri(),
            "1A2B-3C4D:Backups/WebLibre",
        )
        assertEquals(subfolder, SafTreeUris.folderDocumentUri(subfolder))
    }

    @Test
    fun `a uri that is not a tree has no folder`() {
        assertEquals(null, SafTreeUris.folderDocumentUri("content://$authority/document/x".toUri()))
    }

    @Test
    fun `a full volume is no space, not a refusal`() {
        // As ExternalStorageProvider reports it across the binder: only the
        // class and the message survive.
        assertEquals(
            BackupTreeProbeOutcome.NO_SPACE,
            BackupTreeProbing.classifyFailure(
                IllegalStateException(
                    "Failed to touch /storage/1A2B-3C4D/Backups/.weblibre-write-check: " +
                        "java.io.IOException: No space left on device",
                ),
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.NO_SPACE,
            BackupTreeProbing.classifyFailure(
                IOException("write failed", ErrnoException("write", OsConstants.ENOSPC)),
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.NO_SPACE,
            BackupTreeProbing.classifyFailure(ErrnoException("open", OsConstants.EDQUOT)),
        )
    }

    @Test
    fun `lost access is a refusal`() {
        assertEquals(
            BackupTreeProbeOutcome.REFUSED,
            BackupTreeProbing.classifyFailure(
                SecurityException("Permission Denial: writing ExternalStorageProvider uri"),
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.REFUSED,
            BackupTreeProbing.classifyFailure(
                IllegalStateException(
                    "Failed to touch /storage/1A2B-3C4D/Backups/x: " +
                        "java.io.IOException: Permission denied",
                ),
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.REFUSED,
            BackupTreeProbing.classifyFailure(
                IOException("open failed", ErrnoException("open", OsConstants.EROFS)),
            ),
        )
    }

    @Test
    fun `an error's name inside a path or file name blames nothing`() {
        listOf(
            "Failed to touch /storage/vol/EPERM/backup_x.partial",
            "Failed to touch /storage/vol/Backups/backup_EDQUOT_1.partial",
            "/storage/vol/Permission denied/x: some other failure",
            "open failed on /storage/vol/ENOSPC: EIO (I/O error)",
        ).forEach { message ->
            assertEquals(
                BackupTreeProbeOutcome.INCONCLUSIVE,
                BackupTreeProbing.classifyFailure(IllegalStateException(message)),
                message,
            )
        }
    }

    @Test
    fun `a provider that died or an unknown error blames nothing`() {
        assertEquals(
            BackupTreeProbeOutcome.INCONCLUSIVE,
            BackupTreeProbing.classifyFailure(DeadObjectException()),
        )
        assertEquals(
            BackupTreeProbeOutcome.INCONCLUSIVE,
            BackupTreeProbing.classifyFailure(IllegalStateException("Failed to touch x")),
        )
        assertEquals(
            BackupTreeProbeOutcome.INCONCLUSIVE,
            BackupTreeProbing.classifyFailure(FileNotFoundException("no stream")),
        )
    }

    @Test
    fun `a create refused as not found means the folder is gone`() {
        // As ExternalStorageProvider reports a deleted folder and an unmounted
        // volume; DocumentsContract.createDocument rethrows it as itself.
        assertEquals(
            BackupTreeProbeOutcome.MISSING,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("Missing file for 1A2B-3C4D:Backups"),
                folderInDoubt = true,
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.MISSING,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("No root for 1A2B-3C4D"),
                folderInDoubt = true,
            ),
        )
    }

    @Test
    fun `a create refused as not found blames nothing once the folder was seen`() {
        assertEquals(
            BackupTreeProbeOutcome.INCONCLUSIVE,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("Upload service unavailable"),
                folderInDoubt = false,
            ),
        )
    }

    @Test
    fun `not found anywhere but the create blames nothing`() {
        // ContentResolver's "Dead content provider" is a FileNotFoundException
        // too.
        assertEquals(
            BackupTreeProbeOutcome.INCONCLUSIVE,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("Dead content provider: content://x"),
            ),
        )
    }

    @Test
    fun `a create that names its cause is not taken for a missing folder`() {
        assertEquals(
            BackupTreeProbeOutcome.NO_SPACE,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("open failed: ENOSPC (No space left on device)"),
                folderInDoubt = true,
            ),
        )
        assertEquals(
            BackupTreeProbeOutcome.REFUSED,
            BackupTreeProbing.classifyFailure(
                FileNotFoundException("open failed: EACCES (Permission denied)"),
                folderInDoubt = true,
            ),
        )
    }

    @Test
    fun `space wins over access when both appear in the chain`() {
        // Retrying after freeing space is harmless; forgetting a folder that
        // was only full is not.
        assertEquals(
            BackupTreeProbeOutcome.NO_SPACE,
            BackupTreeProbing.classifyFailure(
                SecurityException("denied", IOException("No space left on device")),
            ),
        )
    }
}
