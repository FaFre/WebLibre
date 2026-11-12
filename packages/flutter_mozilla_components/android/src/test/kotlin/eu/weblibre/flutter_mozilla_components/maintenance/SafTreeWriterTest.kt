/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.maintenance

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.ProviderInfo
import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract.Document
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import android.system.ErrnoException
import android.system.OsConstants
import androidx.core.net.toUri
import androidx.documentfile.provider.DocumentFile
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbe
import eu.weblibre.flutter_mozilla_components.pigeons.BackupTreeProbeOutcome
import eu.weblibre.flutter_mozilla_components.pigeons.TreePublication
import eu.weblibre.flutter_mozilla_components.pigeons.TreePublicationFault
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import java.io.InputStream
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * The write check and the publication, end to end, against a real
 * [DocumentsProvider].
 *
 * Real, not a plain ContentProvider dressed up as one, because the framework
 * class is what decides how a missing folder looks from outside: its `query`
 * swallows the provider's `FileNotFoundException` and returns no cursor, and
 * its `call` wraps the same exception so that `createDocument` rethrows it.
 * A fake that answers queries itself tests a path real providers never take.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class SafTreeWriterTest {
    private val context: Context = RuntimeEnvironment.getApplication()

    private val treeUri = "content://$AUTHORITY/tree/vol%3ABackups"

    /** The form the app stores: `saf_util` returns DocumentFile.fromTreeUri(...).uri. */
    private val storedUri: String
        get() = DocumentFile.fromTreeUri(context, treeUri.toUri())!!.uri.toString()

    private lateinit var provider: FakeTreeProvider
    private lateinit var source: File

    /** What the free-space check sees; null means it cannot tell. */
    private var freeBytes: Long? = null

    /** What `fsync` fails with; null lets it succeed. */
    private var syncError: ErrnoException? = null
    private var syncs = 0

    private val writer
        get() = SafTreeWriter(
            context,
            freeBytes = { freeBytes },
            fsync = {
                syncs++
                syncError?.let { throw it }
            },
        )

    @Before
    fun setUp() {
        provider = Robolectric.buildContentProvider(FakeTreeProvider::class.java)
            .create(
                ProviderInfo().apply {
                    authority = AUTHORITY
                    exported = true
                    grantUriPermissions = true
                    readPermission = Manifest.permission.MANAGE_DOCUMENTS
                    writePermission = Manifest.permission.MANAGE_DOCUMENTS
                },
            )
            .get()
        provider.storage = File(context.cacheDir, "tree-${System.nanoTime()}").apply { mkdirs() }

        context.contentResolver.takePersistableUriPermission(
            treeUri.toUri(),
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )

        source = File(context.cacheDir, "archive-${System.nanoTime()}").apply {
            writeBytes(ByteArray(100_000) { it.toByte() })
        }
    }

    private fun probe() = writer.probe(storedUri)

    /** The outcome, with the provider's error in the message when it fails. */
    private fun assertOutcome(expected: BackupTreeProbeOutcome, actual: BackupTreeProbe) =
        assertEquals(expected, actual.outcome, "${actual.errorClass}: ${actual.errorMessage}")

    private fun assertOutcome(expected: BackupTreeProbeOutcome, actual: TreePublication) =
        assertEquals(expected, actual.outcome, "${actual.errorClass}: ${actual.errorMessage}")

    private fun publish(open: () -> InputStream = { source.inputStream() }) = writer.publish(
        source = open,
        sourceLength = source.length(),
        treeUri = storedUri,
        fileName = "backup.weblibre",
        stagingName = "backup.weblibre.partial",
        mimeType = "application/octet-stream",
    )

    // -- The write check ---------------------------------------------------

    @Test
    fun `a folder that takes the test file is writable, and the file is removed`() {
        val result = probe()

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, result)
        assertEquals("Backups", result.folderName)
        assertEquals(1, provider.created.size)
        assertEquals(provider.created, provider.deleted)
    }

    @Test
    fun `the test file holds real bytes, so a full volume has to answer`() {
        probe()

        assertTrue(
            provider.lengthsAtDelete.single() > 0,
            "an empty file is created even on a full volume",
        )
    }

    @Test
    fun `a volume that refuses the test file's bytes is no space`() {
        assumeTrue(File("/dev/full").exists())
        provider.volumeFull = true

        assertOutcome(BackupTreeProbeOutcome.NO_SPACE, probe())
        assertEquals(provider.created, provider.deleted)
    }

    @Test
    fun `a deleted folder is missing, although the provider returns no cursor for it`() {
        provider.folder = FolderState.GONE

        assertOutcome(BackupTreeProbeOutcome.MISSING, probe())
        assertTrue(provider.created.isEmpty())
    }

    @Test
    fun `no cursor alone is no verdict - a folder that still takes files is writable`() {
        // A provider that could not answer the query, but whose folder is
        // fine. Calling that missing made a failed export forget the folder.
        provider.folder = FolderState.UNANSWERED

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, probe())
    }

    @Test
    fun `an empty cursor alone is no verdict - a folder that still takes files is writable`() {
        // A provider whose folder is offline or not yet synced can answer an
        // empty cursor for a folder that is fine. Calling that missing made
        // settings export forget it.
        provider.folder = FolderState.NO_ROW

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, probe())
    }

    @Test
    fun `an empty cursor is missing once the create says so`() {
        provider.folder = FolderState.NO_ROW
        provider.createError = FileNotFoundException("Missing file for $FOLDER_ID")

        assertOutcome(BackupTreeProbeOutcome.MISSING, probe())
    }

    @Test
    fun `a create that says not found does not lose a folder the query returned`() {
        // A cloud provider that is offline can fail a create this way: it is
        // the only checked exception `createDocument` can declare.
        provider.createError = FileNotFoundException("Upload service unavailable")

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, probe())
        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, publish())
    }

    @Test
    fun `a query that fails for no stated reason does not stop the write`() {
        provider.queryError = IllegalStateException("Query not supported")

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, probe())
        assertOutcome(BackupTreeProbeOutcome.WRITABLE, publish())
        assertEquals(listOf("backup.weblibre"), provider.names())
    }

    @Test
    fun `a query that is denied stops before anything is created`() {
        provider.queryError = SecurityException("Permission Denial: reading FakeTreeProvider")

        assertOutcome(BackupTreeProbeOutcome.REFUSED, probe())
        assertOutcome(BackupTreeProbeOutcome.REFUSED, publish())
        assertTrue(provider.created.isEmpty())
    }

    @Test
    fun `the folder's name is the provider's`() {
        assertEquals("Backups", writer.folderName(storedUri))
    }

    @Test
    fun `a provider that does not answer gives no folder name`() {
        provider.folder = FolderState.UNANSWERED

        assertNull(writer.folderName(storedUri))
    }

    @Test
    fun `a provider answering with its own columns is read by name`() {
        // Document id first, as a provider that ignores the projection lists
        // it. Read by position, the id looked like a mime type that is not a
        // folder, and every size looked wrong.
        provider.ownProjection = true

        val checked = probe()
        assertOutcome(BackupTreeProbeOutcome.WRITABLE, checked)
        assertEquals("Backups", checked.folderName)

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, publish())
        assertEquals(listOf("backup.weblibre"), provider.names())
    }

    @Test
    fun `a folder that turned into a file is missing`() {
        provider.folder = FolderState.FILE

        assertOutcome(BackupTreeProbeOutcome.MISSING, probe())
    }

    @Test
    fun `a full volume is no space`() {
        provider.createError = IllegalStateException(
            "Failed to touch /storage/vol/Backups/x: java.io.IOException: No space left on device",
        )

        assertOutcome(BackupTreeProbeOutcome.NO_SPACE, probe())
    }

    @Test
    fun `a refused create is a refusal`() {
        provider.createError = SecurityException("Permission Denial: writing FakeTreeProvider")

        assertOutcome(BackupTreeProbeOutcome.REFUSED, probe())
    }

    @Test
    fun `a provider failing for no stated reason is inconclusive`() {
        provider.createError = IllegalStateException("Failed to touch x")

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, probe())
    }

    @Test
    fun `a volume that runs out only at the sync is no space, and the test file is removed`() {
        // Delayed allocation, a quota, a FUSE writeback: the write itself
        // lands in the page cache, and only the sync finds no room.
        syncError = ErrnoException("fsync", OsConstants.ENOSPC)

        assertOutcome(BackupTreeProbeOutcome.NO_SPACE, probe())
        assertEquals(provider.created, provider.deleted)
    }

    @Test
    fun `a write the provider cannot open still removes the test file`() {
        provider.openError = FileNotFoundException("no stream")

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, probe())
        assertEquals(provider.created, provider.deleted)
    }

    @Test
    fun `without a grant nothing is asked of the provider`() {
        context.contentResolver.releasePersistableUriPermission(
            treeUri.toUri(),
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )

        assertOutcome(BackupTreeProbeOutcome.NO_GRANT, probe())
        assertEquals(0, provider.queries)
    }

    // -- Publishing ---------------------------------------------------------

    @Test
    fun `a published file holds every byte under its final name, and no partial is left`() {
        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, result)
        assertEquals("backup.weblibre", result.name)
        assertEquals(listOf("backup.weblibre"), provider.names())
        assertEquals(source.readBytes().toList(), provider.bytesOf("backup.weblibre")?.toList())
        assertEquals(1, syncs, "the bytes are synced before the file takes its name")
    }

    @Test
    fun `a sync that fails fails the publication, and nothing takes the final name`() {
        // A failing SD card: the bytes reached the page cache, the size the
        // provider reports matches, and only the sync knows they never
        // reached storage.
        syncError = ErrnoException("fsync", OsConstants.EIO)

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, result)
        assertNull(result.fault)
        assertNull(result.uri)
        assertTrue(provider.names().isEmpty(), "left behind: ${provider.names()}")
    }

    @Test
    fun `room or quota that runs out only at the sync is no space`() {
        for (errno in listOf(OsConstants.ENOSPC, OsConstants.EDQUOT)) {
            syncError = ErrnoException("fsync", errno)

            assertOutcome(BackupTreeProbeOutcome.NO_SPACE, publish())
            assertTrue(provider.names().isEmpty(), "left behind: ${provider.names()}")
        }
    }

    @Test
    fun `a descriptor that cannot be synced at all is not a failure`() {
        // A pipe or a socket, what a cloud provider usually hands out.
        for (errno in listOf(OsConstants.EINVAL, OsConstants.ENOSYS)) {
            provider.reset()
            syncError = ErrnoException("fsync", errno)

            assertOutcome(BackupTreeProbeOutcome.WRITABLE, publish())
        }
    }

    @Test
    fun `a source that cannot be opened is the source, not the folder`() {
        // EACCES from the app's own storage must not read as the folder
        // refusing access, which would make the caller forget a good folder.
        val result = publish(open = {
            throw FileNotFoundException("${source.path}: open failed: EACCES (Permission denied)")
        })

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, result)
        assertEquals(TreePublicationFault.SOURCE_UNREADABLE, result.fault)
        assertTrue(provider.created.isEmpty(), "nothing is created for a source that is not there")
    }

    @Test
    fun `a source that fails mid-copy is the source, and the partial is removed`() {
        val result = publish(open = {
            object : InputStream() {
                private var served = 0

                override fun read(): Int = throw UnsupportedOperationException()

                override fun read(b: ByteArray, off: Int, len: Int): Int {
                    if (served > 0) throw IOException("read failed: EPERM (Operation not permitted)")
                    served = len.coerceAtMost(1000)
                    return served
                }
            }
        })

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, result)
        assertEquals(TreePublicationFault.SOURCE_UNREADABLE, result.fault)
        assertTrue(provider.names().isEmpty(), "left behind: ${provider.names()}")
    }

    @Test
    fun `a full volume during the copy is no space, and the partial is removed`() {
        assumeTrue(File("/dev/full").exists())
        provider.volumeFull = true

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.NO_SPACE, result)
        assertTrue(provider.names().isEmpty(), "left behind: ${provider.names()}")
    }

    @Test
    fun `a volume visibly too small stops before anything is copied`() {
        freeBytes = source.length() - 1

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.NO_SPACE, result)
        // The numbers, so the user is told how much is missing rather than
        // that a volume with room left is full.
        assertEquals(source.length(), result.requiredBytes)
        assertEquals(source.length() - 1, result.availableBytes)
        assertEquals(listOf(0L), provider.lengthsAtDelete)
        assertTrue(provider.names().isEmpty())
    }

    @Test
    fun `free space that cannot be measured does not stop the copy`() {
        freeBytes = null

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, publish())
    }

    @Test
    fun `a provider holding fewer bytes than were written is truncated, and nothing is left`() {
        provider.reportedSize = { it - 1 }

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, result)
        assertEquals(TreePublicationFault.TRUNCATED, result.fault)
        assertTrue(provider.names().isEmpty())
    }

    @Test
    fun `a provider that reports no size is taken at the stream's word`() {
        provider.reportedSize = { null }

        assertOutcome(BackupTreeProbeOutcome.WRITABLE, publish())
    }

    @Test
    fun `publishing into a deleted folder is missing`() {
        provider.folder = FolderState.GONE

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.MISSING, result)
        assertNull(result.fault)
        assertNull(result.uri)
    }

    @Test
    fun `a failed rename leaves no partial behind`() {
        provider.renameError = IllegalStateException("Failed to rename")

        val result = publish()

        assertOutcome(BackupTreeProbeOutcome.INCONCLUSIVE, result)
        assertTrue(provider.names().isEmpty())
    }

    @Test
    fun `the name the provider chose is the one reported`() {
        provider.renameTo = { "$it (1)" }

        assertEquals("backup.weblibre (1)", publish().name)
    }

    enum class FolderState { DIRECTORY, FILE, NO_ROW, UNANSWERED, GONE }

    /** A DocumentsProvider over one folder, `vol:Backups`, backed by files. */
    class FakeTreeProvider : DocumentsProvider() {
        var folder = FolderState.DIRECTORY
        var queryError: Exception? = null
        var createError: Exception? = null
        var openError: Exception? = null
        var renameError: Exception? = null
        var renameTo: (String) -> String = { it }
        var reportedSize: (Long) -> Long? = { it }

        /** Answers every query with its own columns, document id first. */
        var ownProjection = false

        /** Every write fails with ENOSPC. */
        var volumeFull = false

        var queries = 0
        lateinit var storage: File

        /** How much each document held when it was deleted. */
        val lengthsAtDelete = mutableListOf<Long>()

        val created = mutableListOf<String>()
        val deleted = mutableListOf<String>()

        private val documents = mutableMapOf<String, File>()

        fun names(): List<String> = documents.keys.map { it.substringAfterLast('/') }

        fun reset() {
            documents.clear()
            created.clear()
            deleted.clear()
            lengthsAtDelete.clear()
        }

        fun bytesOf(name: String): ByteArray? =
            documents.entries.firstOrNull { it.key.endsWith("/$name") }?.value?.readBytes()

        override fun onCreate() = true

        override fun queryRoots(projection: Array<out String>?): Cursor =
            MatrixCursor(projection ?: arrayOf(Root.COLUMN_ROOT_ID))

        override fun queryChildDocuments(
            parentDocumentId: String,
            projection: Array<out String>?,
            sortOrder: String?,
        ): Cursor = MatrixCursor(projection ?: arrayOf(Document.COLUMN_DOCUMENT_ID))

        override fun isChildDocument(parentDocumentId: String, documentId: String) =
            documentId.startsWith("$parentDocumentId/")

        override fun queryDocument(documentId: String, projection: Array<out String>?): Cursor {
            queries++
            val columns = if (ownProjection || projection == null) {
                arrayOf(
                    Document.COLUMN_DOCUMENT_ID,
                    Document.COLUMN_FLAGS,
                    Document.COLUMN_SIZE,
                    Document.COLUMN_DISPLAY_NAME,
                    Document.COLUMN_MIME_TYPE,
                )
            } else {
                projection
            }

            if (documentId == FOLDER_ID) {
                queryError?.let { throw it }
                return when (folder) {
                    FolderState.DIRECTORY -> row(columns, Document.MIME_TYPE_DIR, "Backups", null)
                    FolderState.FILE -> row(columns, "application/octet-stream", "Backups", 0)
                    FolderState.NO_ROW -> MatrixCursor(columns)
                    // What ExternalStorageProvider throws for a folder that is
                    // gone; DocumentsProvider.query turns it into no cursor.
                    FolderState.UNANSWERED,
                    FolderState.GONE,
                    -> throw FileNotFoundException("Missing file for $documentId")
                }
            }

            val file = documents[documentId] ?: throw FileNotFoundException("Missing file for $documentId")
            return row(
                columns,
                "application/octet-stream",
                documentId.substringAfterLast('/'),
                reportedSize(file.length()),
            )
        }

        override fun createDocument(parentDocumentId: String, mimeType: String, displayName: String): String {
            createError?.let { throw it }
            if (folder == FolderState.GONE) {
                throw FileNotFoundException("Missing file for $parentDocumentId")
            }
            val id = "$parentDocumentId/$displayName"
            documents[id] = File(storage, "doc-${documents.size}-${System.nanoTime()}").apply { createNewFile() }
            created += id
            return id
        }

        override fun openDocument(documentId: String, mode: String, signal: CancellationSignal?): ParcelFileDescriptor {
            openError?.let { throw it }
            val file = documents[documentId] ?: throw FileNotFoundException("Missing file for $documentId")
            // A descriptor whose writes fail the way a full volume's do: with
            // ENOSPC, from write() itself.
            if (volumeFull) {
                return ParcelFileDescriptor.open(File("/dev/full"), ParcelFileDescriptor.MODE_WRITE_ONLY)
            }
            return ParcelFileDescriptor.open(file, ParcelFileDescriptor.parseMode(mode))
        }

        override fun deleteDocument(documentId: String) {
            deleted += documentId
            documents.remove(documentId)?.let {
                lengthsAtDelete += it.length()
                it.delete()
            }
        }

        override fun renameDocument(documentId: String, displayName: String): String {
            renameError?.let { throw it }
            val id = "${documentId.substringBeforeLast('/')}/${renameTo(displayName)}"
            documents[id] = documents.remove(documentId)
                ?: throw FileNotFoundException("Missing file for $documentId")
            return id
        }

        private fun row(columns: Array<out String>, mimeType: String, name: String, size: Long?) =
            MatrixCursor(columns).apply {
                addRow(
                    columns.map {
                        when (it) {
                            Document.COLUMN_MIME_TYPE -> mimeType
                            Document.COLUMN_DISPLAY_NAME -> name
                            Document.COLUMN_SIZE -> size
                            Document.COLUMN_DOCUMENT_ID -> name
                            Document.COLUMN_FLAGS -> 0
                            else -> null
                        }
                    },
                )
            }
    }

    private companion object {
        const val AUTHORITY = "eu.weblibre.test.backuptree"
        const val FOLDER_ID = "vol:Backups"
    }
}
