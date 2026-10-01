/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.sync

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.browser.storage.sync.PlacesBookmarksStorage
import mozilla.components.concept.storage.BookmarkNode
import mozilla.components.concept.storage.BookmarkNodeType
import mozilla.components.support.base.log.logger.Logger

/**
 * Merges bookmarks imported from Google Chrome (via HTML export or Takeout API)
 * into WebLibre's PlacesBookmarksStorage.
 *
 * Design principles:
 * - Additive only: never deletes or overwrites existing bookmarks
 * - Deduplication by URL: skips entries whose URL already exists in the store
 * - Folder isolation: all imported bookmarks go under a "[Chrome Import]" root
 *   folder to keep them visually separated from Firefox-synced bookmarks
 * - Idempotent: running the same import twice produces no duplicates
 *
 * This runs on the Kotlin side to directly access PlacesBookmarksStorage
 * without cross-platform serialization overhead.
 */
class GoogleBookmarksMerger(
    private val bookmarksStorage: Lazy<PlacesBookmarksStorage>,
) {
    private val logger = Logger("GoogleBookmarksMerger")

    data class ImportedBookmark(
        val title: String,
        val url: String,
        val folderPath: String,
        val dateAdded: Long, // milliseconds since epoch
    )

    data class MergeResult(
        val added: Int,
        val skipped: Int,
        val errors: Int,
    )

    /**
     * Merge a list of imported bookmarks into the local store.
     *
     * @param bookmarks List of bookmarks parsed from Chrome HTML export
     * @return Merge statistics
     */
    suspend fun merge(bookmarks: List<ImportedBookmark>): MergeResult =
        withContext(Dispatchers.IO) {
            val storage = bookmarksStorage.value
            var added = 0
            var skipped = 0
            var errors = 0

            // Ensure the root import folder exists
            val rootFolderGuid = getOrCreateImportRootFolder(storage)

            // Build a set of existing URLs for O(1) deduplication
            val existingUrls = mutableSetOf<String>()
            try {
                val tree = storage.getTree(rootFolderGuid, recursive = true).getOrThrow()
                collectUrls(tree, existingUrls)
            } catch (e: Exception) {
                logger.warn("Failed to load existing bookmarks tree for dedup", e)
            }

            // Also check the entire bookmark tree for URLs outside our import folder
            try {
                val fullTree = storage.getTree("root________", recursive = true).getOrThrow()
                collectUrls(fullTree, existingUrls)
            } catch (e: Exception) {
                logger.warn("Failed to load full bookmarks tree for dedup", e)
            }

            // Cache of folder GUIDs by path to avoid repeated lookups/creates
            val folderCache = mutableMapOf<String, String>("/" to rootFolderGuid)

            for (bookmark in bookmarks) {
                try {
                    // Skip if URL already exists anywhere in the store
                    if (existingUrls.contains(bookmark.url)) {
                        skipped++
                        continue
                    }

                    // Resolve or create the target folder
                    val parentGuid = resolveFolder(
                        storage, rootFolderGuid, bookmark.folderPath, folderCache
                    )

                    // Add the bookmark
                    storage.addItem(
                        parentGuid = parentGuid,
                        url = bookmark.url,
                        title = bookmark.title,
                        position = null,
                    ).getOrThrow()

                    existingUrls.add(bookmark.url)
                    added++
                } catch (e: Exception) {
                    logger.warn("Failed to import bookmark: ${bookmark.url}", e)
                    errors++
                }
            }

            logger.info(
                "Google bookmarks merge complete: added=$added, skipped=$skipped, errors=$errors"
            )

            MergeResult(added = added, skipped = skipped, errors = errors)
        }

    /**
     * Get or create the "[Chrome Import]" root folder under the mobile bookmarks root.
     */
    private suspend fun getOrCreateImportRootFolder(
        storage: PlacesBookmarksStorage
    ): String {
        val mobileRoot = storage.getTree("mobile______", recursive = false).getOrThrow()
        val children = mobileRoot?.children ?: emptyList()

        // Look for existing import folder
        for (child in children) {
            if (child.type == BookmarkNodeType.FOLDER && child.title == "[Chrome Import]") {
                return child.guid
            }
        }

        // Create it
        return storage.addFolder(
            parentGuid = "mobile______",
            title = "[Chrome Import]",
            position = null,
        ).getOrThrow()
    }

    /**
     * Resolve a folder path like "/Bookmarks Bar/Tech/" to a GUID,
     * creating intermediate folders as needed.
     */
    private suspend fun resolveFolder(
        storage: PlacesBookmarksStorage,
        rootGuid: String,
        path: String,
        cache: MutableMap<String, String>,
    ): String {
        if (path == "/" || path.isEmpty()) return rootGuid

        // Check cache first
        cache[path]?.let { return it }

        // Parse path segments
        val segments = path.split("/").filter { it.isNotEmpty() }
        var currentGuid = rootGuid
        var currentPath = ""

        for (segment in segments) {
            currentPath += "/$segment"

            // Check cache for this intermediate path
            val cached = cache[currentPath]
            if (cached != null) {
                currentGuid = cached
                continue
            }

            // Look for existing child folder
            val tree = storage.getTree(currentGuid, recursive = false).getOrThrow()
            val existingFolder = tree?.children?.find {
                it.type == BookmarkNodeType.FOLDER && it.title == segment
            }

            currentGuid = if (existingFolder != null) {
                existingFolder.guid
            } else {
                // Create the folder
                storage.addFolder(
                    parentGuid = currentGuid,
                    title = segment,
                    position = null,
                ).getOrThrow()
            }

            cache[currentPath] = currentGuid
        }

        cache[path] = currentGuid
        return currentGuid
    }

    /**
     * Recursively collect all bookmark URLs from a tree node.
     */
    private fun collectUrls(node: BookmarkNode?, urls: MutableSet<String>) {
        if (node == null) return
        if (node.type == BookmarkNodeType.ITEM) {
            node.url?.let { urls.add(it) }
        }
        node.children?.forEach { collectUrls(it, urls) }
    }
}
