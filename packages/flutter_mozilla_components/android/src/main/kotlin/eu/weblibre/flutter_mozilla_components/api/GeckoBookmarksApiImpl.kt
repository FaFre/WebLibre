package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.GeckoBookmarksExtensionBridge
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkImportNode
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkInfo
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkInsertTreeResult
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNode
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNodeType
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.storage.BookmarkInfo as MozillaBookmarkInfo
import mozilla.components.concept.storage.bookmarks.InsertableBookmarkTreeNode
import mozilla.components.concept.storage.bookmarks.InsertableBookmarkTreeRoot

class GeckoBookmarksApiImpl() : GeckoBookmarksApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

        /**
         * Name of the short-lived folder that loose top-level nodes pass through
         * during an import. Only visible if an import is interrupted partway.
         */
        private const val SCRATCH_FOLDER_TITLE = "Importing bookmarks…"
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    fun mozilla.components.concept.storage.BookmarkNode.toPigeonBookmarkNode(): BookmarkNode {
        return BookmarkNode(
            type = when (this.type) {
                mozilla.components.concept.storage.BookmarkNodeType.ITEM -> BookmarkNodeType.ITEM
                mozilla.components.concept.storage.BookmarkNodeType.FOLDER -> BookmarkNodeType.FOLDER
                mozilla.components.concept.storage.BookmarkNodeType.SEPARATOR -> BookmarkNodeType.SEPARATOR
            },
            guid = this.guid,
            parentGuid = this.parentGuid,
            position = this.position?.toLong(),
            title = this.title,
            url = this.url,
            dateAdded = this.dateAdded,
            lastModified = this.lastModified,
            children = this.children?.map { it.toPigeonBookmarkNode() }
        )
    }

    fun BookmarkNode.toConceptStorageBookmarkNode(): mozilla.components.concept.storage.BookmarkNode {
        return mozilla.components.concept.storage.BookmarkNode(
            type = when (this.type) {
                BookmarkNodeType.ITEM -> mozilla.components.concept.storage.BookmarkNodeType.ITEM
                BookmarkNodeType.FOLDER -> mozilla.components.concept.storage.BookmarkNodeType.FOLDER
                BookmarkNodeType.SEPARATOR -> mozilla.components.concept.storage.BookmarkNodeType.SEPARATOR
            },
            guid = this.guid,
            parentGuid = this.parentGuid,
            position = this.position?.toUInt(),
            title = this.title,
            url = this.url,
            dateAdded = this.dateAdded,
            lastModified = this.lastModified,
            children = this.children?.map { it.toConceptStorageBookmarkNode() }
        )
    }


    override fun getTree(
        guid: String,
        recursive: Boolean,
        callback: (Result<BookmarkNode?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val node = components.core.bookmarksStorage.getTree(guid, recursive)
                node.fold(
                    { node ->
                        callback(Result.success(node?.toPigeonBookmarkNode()))
                    },
                    { e -> callback(Result.failure(e)) })
            }
        }

    }

    override fun getBookmark(
        guid: String,
        callback: (Result<BookmarkNode?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getBookmark(guid).fold(
                    { node -> callback(Result.success(node?.toPigeonBookmarkNode())) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun getBookmarksWithUrl(
        url: String,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getBookmarksWithUrl(url).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun getRecentBookmarks(
        limit: Long,
        maxAge: Long?,
        currentTime: Long,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.getRecentBookmarks(
                    limit = limit.toInt(),
                    maxAge = maxAge,
                    currentTime = currentTime
                ).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun searchBookmarks(
        query: String,
        limit: Long,
        callback: (Result<List<BookmarkNode>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.searchBookmarks(query, limit.toInt()).fold(
                    { nodes -> callback(Result.success(nodes.map { it.toPigeonBookmarkNode() })) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun addItem(
        parentGuid: String,
        url: String,
        title: String,
        position: Long?,
        callback: (Result<String>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val result =
                    components.core.bookmarksStorage.addItem(parentGuid, url, title, position?.toUInt())
                result.fold(
                    { guid -> callback(Result.success(guid)) },
                    { e -> callback(Result.failure(e)) }
                )
                emitCreated(result.getOrNull())
            }
        }
    }

    override fun addFolder(
        parentGuid: String,
        title: String,
        position: Long?,
        callback: (Result<String>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val result =
                    components.core.bookmarksStorage.addFolder(parentGuid, title, position?.toUInt())
                result.fold(
                    { guid -> callback(Result.success(guid)) },
                    { e -> callback(Result.failure(e)) }
                )
                emitCreated(result.getOrNull())
            }
        }
    }

    override fun updateNode(
        guid: String,
        info: BookmarkInfo,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val conceptInfo = mozilla.components.concept.storage.BookmarkInfo(
                    parentGuid = info.parentGuid,
                    position = info.position?.toUInt(),
                    title = info.title,
                    url = info.url
                )
                val oldNode = components.core.bookmarksStorage.getBookmark(guid).getOrNull()
                val result = components.core.bookmarksStorage.updateNode(guid, conceptInfo)
                result.fold(
                    { callback(Result.success(Unit)) },
                    { e -> callback(Result.failure(e)) }
                )
                if (result.isSuccess) {
                    components.core.bookmarksStorage.getBookmark(guid).getOrNull()?.let { node ->
                        if (info.title != null || info.url != null) {
                            GeckoBookmarksExtensionBridge.emitChanged(node, oldNode)
                        }
                        if (info.parentGuid != null || info.position != null) {
                            GeckoBookmarksExtensionBridge.emitMoved(node, oldNode)
                        }
                    }
                }
            }
        }
    }

    override fun deleteNode(
        guid: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val node = components.core.bookmarksStorage.getBookmark(guid).getOrNull()
                components.core.bookmarksStorage.deleteNode(guid).fold(
                    { deleted ->
                        callback(Result.success(deleted))
                        if (deleted && node != null) {
                            GeckoBookmarksExtensionBridge.emitRemoved(node)
                        }
                    },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun insertTree(
        parentGuid: String,
        children: List<BookmarkImportNode>,
        callback: (Result<BookmarkInsertTreeResult>) -> Unit
    ) {
        coroutineScope.launch {
            // Imports can carry tens of thousands of nodes, so the whole batch runs
            // off the main thread. Only the callback returns to it, because Pigeon
            // replies must be delivered on the platform thread.
            val result = withContext(Dispatchers.IO) {
                runCatching { insertImportNodes(parentGuid, children) }
            }
            callback(result)
        }
    }

    /**
     * Appends [nodes] underneath [parentGuid], handing every top-level folder to
     * storage as a single tree insertion.
     *
     * `insertTree` is the only storage call that carries timestamps, and it can
     * only create a *folder*. Loose top-level items and separators would
     * therefore lose their `ADD_DATE` if inserted with `addItem`/`addSeparator`,
     * which have no timestamp parameters — so they are staged inside a scratch
     * folder and reparented instead. See [stageLooseNodes].
     *
     * A failing top-level node is counted and skipped rather than aborting the
     * whole import, matching the per-node importer this replaced. Deliberately
     * does not emit `bookmarks.onCreated`: one event per imported node would
     * flood every installed WebExtension.
     */
    private suspend fun insertImportNodes(
        parentGuid: String,
        nodes: List<BookmarkImportNode>
    ): BookmarkInsertTreeResult {
        val storage = components.core.bookmarksStorage
        var insertedItemCount = 0L
        var failedNodeCount = 0L

        val staged = stageLooseNodes(parentGuid, nodes)

        for (node in nodes) {
            // Every branch appends (position = null). Walking the nodes in order
            // therefore reproduces the file's order, and merging into a folder
            // that already has children leaves those in place.
            val outcome: Result<Long> = when (node.type) {
                BookmarkNodeType.FOLDER -> {
                    val folder = node.toInsertableFolder(position = null)
                    storage.insertTree(InsertableBookmarkTreeRoot(parentGuid, folder))
                        .map { folder.itemCount() }
                }

                // Already written by stageLooseNodes; only the move is left.
                else -> staged.reparent(node, parentGuid)
            }

            outcome.fold(
                { count -> insertedItemCount += count },
                { failedNodeCount += 1 }
            )
        }

        staged.discardScratchFolder()

        return BookmarkInsertTreeResult(insertedItemCount, failedNodeCount)
    }

    override fun countBookmarksInTrees(
        guids: List<String>,
        callback: (Result<Long>) -> Unit
    ) {
        coroutineScope.launch {
            val result = withContext(Dispatchers.IO) {
                runCatching {
                    components.core.bookmarksStorage.countBookmarksInTrees(guids).toLong()
                }
            }
            callback(result)
        }
    }

    /**
     * Loose top-level nodes written into a scratch folder, waiting to be moved
     * to their real parent.
     *
     * The scratch folder is created under the import destination and holds the
     * loose nodes in file order; [reparent] hands them out one at a time as the
     * caller walks the top level, and [discardScratchFolder] removes the folder
     * once it has been emptied.
     */
    private inner class StagedLooseNodes(
        private val scratchGuid: String?,
        /** The loose nodes that made it into the scratch folder, in order. */
        private val staged: List<BookmarkImportNode>,
        /** Guid assigned to each entry of [staged], by index. */
        private val guids: List<String>,
        private val failure: Throwable?
    ) {
        private var next = 0

        /**
         * Moves the next staged node under [parentGuid].
         *
         * Reparenting preserves `dateAdded`, which is what bookmark ordering and
         * "recently added" depend on. It does refresh `lastModified` — the pair
         * cannot both survive, because the only storage call that accepts
         * timestamps creates a folder.
         */
        suspend fun reparent(node: BookmarkImportNode, parentGuid: String): Result<Long> {
            failure?.let { return Result.failure(it) }

            // Nodes dropped while converting (an item with no usable url) were
            // never staged, so the cursor must not advance past them.
            if (staged.getOrNull(next) !== node) {
                return Result.failure(
                    IllegalArgumentException("Unusable bookmark node of type ${node.type}")
                )
            }

            val guid = guids.getOrNull(next)
                ?: return Result.failure(
                    IllegalStateException("Storage did not report a guid for ${node.type}")
                )
            next++

            // A null field means "leave unchanged"; appending (null position)
            // keeps the file's order as the caller walks the top level.
            val move = MozillaBookmarkInfo(
                parentGuid = parentGuid,
                position = null,
                title = null,
                url = null
            )

            return components.core.bookmarksStorage
                .updateNode(guid, move)
                .map { if (node.type == BookmarkNodeType.ITEM) 1L else 0L }
        }

        /**
         * Deletes the scratch folder, but only once it is empty.
         *
         * Deleting cascades to children, so anything that failed to move is left
         * behind in a visible folder rather than being silently destroyed.
         */
        suspend fun discardScratchFolder() {
            val guid = scratchGuid ?: return
            val storage = components.core.bookmarksStorage

            val remaining = storage.getTree(guid, false).getOrNull()?.children
            if (remaining.isNullOrEmpty()) {
                storage.deleteNode(guid)
            }
        }
    }

    /**
     * Writes every loose top-level node of [nodes] into a scratch folder under
     * [parentGuid] in a single tree insertion, so their timestamps survive.
     *
     * Returns an empty staging area when the import has no loose top-level
     * nodes, which is the common case for Firefox exports and costs nothing.
     */
    private suspend fun stageLooseNodes(
        parentGuid: String,
        nodes: List<BookmarkImportNode>
    ): StagedLooseNodes {
        val empty = StagedLooseNodes(null, emptyList(), emptyList(), null)

        val staged = ArrayList<BookmarkImportNode>()
        val insertable = ArrayList<InsertableBookmarkTreeNode>()
        for (node in nodes) {
            if (node.type == BookmarkNodeType.FOLDER) continue
            val converted = node.toInsertableNode(insertable.size.toUInt()) ?: continue
            insertable.add(converted)
            staged.add(node)
        }

        if (staged.isEmpty()) return empty

        val scratch = InsertableBookmarkTreeNode.Folder(
            title = SCRATCH_FOLDER_TITLE,
            dateAddedTimestamp = 0L,
            lastModifiedTimestamp = 0L,
            position = null,
            children = insertable
        )

        val storage = components.core.bookmarksStorage

        return storage.insertTree(InsertableBookmarkTreeRoot(parentGuid, scratch)).fold(
            { scratchGuid ->
                // Read the assigned guids back in position order, which is the
                // order the nodes were handed to insertTree.
                val children = storage.getTree(scratchGuid, false).getOrNull()?.children
                StagedLooseNodes(
                    scratchGuid = scratchGuid,
                    staged = staged,
                    guids = children.orEmpty().map { it.guid },
                    failure = null
                )
            },
            { error -> StagedLooseNodes(null, staged, emptyList(), error) }
        )
    }

    private fun BookmarkImportNode.toInsertableFolder(position: UInt?) =
        InsertableBookmarkTreeNode.Folder(
            title = this.title,
            dateAddedTimestamp = this.dateAdded,
            lastModifiedTimestamp = this.lastModified,
            position = position,
            children = this.children.toInsertableNodes()
        )

    /**
     * Converts children to their insertable form, dropping unusable nodes and
     * assigning positions from the surviving order so no gaps are left behind.
     */
    private fun List<BookmarkImportNode>.toInsertableNodes(): List<InsertableBookmarkTreeNode> {
        val converted = ArrayList<InsertableBookmarkTreeNode>(this.size)
        for (node in this) {
            converted.add(node.toInsertableNode(converted.size.toUInt()) ?: continue)
        }
        return converted
    }

    private fun BookmarkImportNode.toInsertableNode(position: UInt): InsertableBookmarkTreeNode? =
        when (this.type) {
            BookmarkNodeType.FOLDER -> this.toInsertableFolder(position)

            BookmarkNodeType.ITEM -> this.url?.takeIf { it.isNotEmpty() }?.let { url ->
                InsertableBookmarkTreeNode.Item(
                    title = this.title,
                    url = url,
                    dateAddedTimestamp = this.dateAdded,
                    lastModifiedTimestamp = this.lastModified,
                    position = position
                )
            }

            BookmarkNodeType.SEPARATOR -> InsertableBookmarkTreeNode.Separator(
                dateAddedTimestamp = this.dateAdded,
                lastModifiedTimestamp = this.lastModified,
                position = position
            )
        }

    /** Number of bookmark items in this subtree, excluding folders and separators. */
    private fun InsertableBookmarkTreeNode.itemCount(): Long = when (this) {
        is InsertableBookmarkTreeNode.Item -> 1L
        is InsertableBookmarkTreeNode.Folder -> this.children.sumOf { it.itemCount() }
        is InsertableBookmarkTreeNode.Separator -> 0L
    }

    /**
     * Notifies extension `bookmarks.onCreated` listeners about a node created
     * through the app UI, so extensions (e.g. floccus) observe app-side edits to
     * the shared store.
     */
    private suspend fun emitCreated(guid: String?) {
        if (guid == null) {
            return
        }
        components.core.bookmarksStorage.getBookmark(guid).getOrNull()?.let {
            GeckoBookmarksExtensionBridge.emitCreated(it)
        }
    }

}
