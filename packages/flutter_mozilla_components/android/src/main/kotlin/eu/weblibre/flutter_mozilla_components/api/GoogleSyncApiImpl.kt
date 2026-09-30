/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GoogleSyncApi
import eu.weblibre.flutter_mozilla_components.pigeons.ImportedBookmarkData
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkMergeResult
import eu.weblibre.flutter_mozilla_components.sync.GoogleBookmarksMerger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Pigeon bridge implementation for Google bookmark/history import.
 *
 * Exposes the Kotlin-side GoogleBookmarksMerger to the Dart layer so
 * imported bookmarks can be written directly into PlacesBookmarksStorage
 * without cross-platform serialization overhead.
 */
class GoogleSyncApiImpl : GoogleSyncApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override suspend fun mergeImportedBookmarks(
        bookmarks: List<ImportedBookmarkData>
    ): BookmarkMergeResult = withContext(Dispatchers.IO) {
        val merger = GoogleBookmarksMerger(components.core.lazyBookmarksStorage)

        val converted = bookmarks.map {
            GoogleBookmarksMerger.ImportedBookmark(
                title = it.title,
                url = it.url,
                folderPath = it.folderPath,
                dateAdded = it.dateAddedMillis,
            )
        }

        val result = merger.merge(converted)

        BookmarkMergeResult(
            added = result.added.toLong(),
            skipped = result.skipped.toLong(),
            errors = result.errors.toLong(),
        )
    }
}
