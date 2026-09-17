/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import android.content.Intent
import androidx.core.net.toUri
import androidx.documentfile.provider.DocumentFile
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * The rule that decides where a download is written.
 *
 * Worth its own test because the failure it guards against is silent and total:
 * Mozilla's writer throws on a SAF directory it has lost the grant for rather
 * than falling back, so handing out a dead folder fails every download until the
 * user notices and re-picks.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class DownloadLocationPreferenceTest {
    private val context: Context = RuntimeEnvironment.getApplication()

    private val treeUri = "content://com.android.externalstorage.documents/tree/primary%3ABooks"

    private fun grant(uri: String) {
        context.contentResolver.takePersistableUriPermission(
            uri.toUri(),
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )
    }

    @Test
    fun `nothing configured means the public downloads folder`() {
        assertEquals(
            DownloadLocationPreference.defaultLocation(),
            DownloadLocationPreference.resolve(context, null),
        )
    }

    @Test
    fun `a granted folder is used`() {
        grant(treeUri)

        assertEquals(treeUri, DownloadLocationPreference.resolve(context, treeUri))
    }

    @Test
    fun `a folder the grant was lost for falls back to the default`() {
        // Never granted — the same state a user revoking access in the system
        // settings, or an unmounted card, leaves behind.
        assertEquals(
            DownloadLocationPreference.defaultLocation(),
            DownloadLocationPreference.resolve(context, treeUri),
        )
    }

    @Test
    fun `a grant for another folder does not carry over`() {
        grant("content://com.android.externalstorage.documents/tree/primary%3AMusic")

        assertEquals(
            DownloadLocationPreference.defaultLocation(),
            DownloadLocationPreference.resolve(context, treeUri),
        )
    }

    @Test
    fun `the picker's document form of a folder resolves to its tree URI`() {
        // What the app actually stores: `saf_util` returns
        // DocumentFile.fromTreeUri(...).uri, while the grant is on the tree URI
        // the system returned. Asserted through the real androidx call rather
        // than a hand-written string, because this equivalence is the whole
        // reason the normalization exists.
        val picked = DocumentFile.fromTreeUri(context, treeUri.toUri())!!.uri.toString()
        assertNotEquals(treeUri, picked, "the picker hands back the document form")

        grant(treeUri)

        assertEquals(treeUri, DownloadLocationPreference.resolve(context, picked))
    }

    @Test
    fun `a document form with no grant still falls back`() {
        val picked = DocumentFile.fromTreeUri(context, treeUri.toUri())!!.uri.toString()

        assertEquals(
            DownloadLocationPreference.defaultLocation(),
            DownloadLocationPreference.resolve(context, picked),
        )
    }

    @Test
    fun `a plain path is taken at face value`() {
        // Not a SAF URI, so there is no grant to lose: this is what every call
        // site used before the preference existed.
        val path = "/storage/emulated/0/Download"

        assertEquals(path, DownloadLocationPreference.resolve(context, path))
    }
}
