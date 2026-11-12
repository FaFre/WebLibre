/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.net.Uri
import android.provider.DocumentsContract
import androidx.core.net.toUri

/**
 * The two URI forms a SAF folder is known by, and how to get from one to the
 * other.
 *
 * The grant the picker took is recorded against the tree URI the system
 * returned (`…/tree/<id>`). But the picker WebLibre uses hands back
 * `DocumentFile.fromTreeUri(...).uri`, the *document* form of the same folder
 * (`…/tree/<id>/document/<id>`), and that is what the app stores. Comparing the
 * stored form against the grant list by plain equality finds nothing, so
 * anything that asks "is there still a grant for this folder" has to normalize
 * first.
 */
internal object SafTreeUris {
    /**
     * The tree URI [location] is granted under, or [location] unchanged when it
     * is not a SAF tree URI at all.
     *
     * The authority is kept, so the same document id on two providers never
     * matches.
     */
    fun normalizeTreeUri(location: String): String {
        if (!location.startsWith("content://")) {
            return location
        }

        val uri = try {
            location.toUri()
        } catch (e: IllegalArgumentException) {
            return location
        }

        val authority = uri.authority ?: return location

        return try {
            DocumentsContract.buildTreeDocumentUri(
                authority,
                DocumentsContract.getTreeDocumentId(uri),
            ).toString()
        } catch (e: IllegalArgumentException) {
            // Not a tree URI at all; nothing to normalize towards.
            location
        }
    }

    /**
     * The document URI of the folder [location] names, which is where new files
     * go.
     *
     * The same folder `DocumentFile.fromTreeUri` resolves to, so a check made
     * here tests the folder a write through androidx would land in: the tree's
     * root for the tree form, the named document for the document form.
     *
     * Null when [location] is not a tree URI.
     */
    fun folderDocumentUri(location: Uri): Uri? = try {
        val treeId = DocumentsContract.getTreeDocumentId(location)
        val segments = location.pathSegments
        val documentId = if (segments.size >= 4 && segments[2] == "document") {
            DocumentsContract.getDocumentId(location)
        } else {
            treeId
        }
        DocumentsContract.buildDocumentUriUsingTree(location, documentId)
    } catch (e: IllegalArgumentException) {
        null
    }
}
