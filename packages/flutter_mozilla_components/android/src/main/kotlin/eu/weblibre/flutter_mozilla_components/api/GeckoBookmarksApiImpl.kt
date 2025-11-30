package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkInfo
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNode
import eu.weblibre.flutter_mozilla_components.pigeons.BookmarkNodeType
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBookmarksApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class GeckoBookmarksApiImpl() : GeckoBookmarksApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
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
                components.core.bookmarksStorage.addItem(parentGuid, url, title, position?.toUInt())
                    .fold(
                        { guid -> callback(Result.success(guid)) },
                        { e -> callback(Result.failure(e)) }
                    )
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
                components.core.bookmarksStorage.addFolder(parentGuid, title, position?.toUInt())
                    .fold(
                        { guid -> callback(Result.success(guid)) },
                        { e -> callback(Result.failure(e)) }
                    )
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
                components.core.bookmarksStorage.updateNode(guid, conceptInfo).fold(
                    { callback(Result.success(Unit)) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

    override fun deleteNode(
        guid: String,
        callback: (Result<Boolean>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.bookmarksStorage.deleteNode(guid).fold(
                    { deleted -> callback(Result.success(deleted)) },
                    { e -> callback(Result.failure(e)) }
                )
            }
        }
    }

}