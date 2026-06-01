/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import mozilla.components.concept.storage.BookmarkInfo
import mozilla.components.concept.storage.BookmarkNode
import mozilla.components.concept.storage.BookmarkNodeType
import mozilla.components.concept.storage.BookmarksStorage
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.gecko.EventDispatcher
import org.mozilla.gecko.util.BundleEventListener
import org.mozilla.gecko.util.EventCallback
import org.mozilla.gecko.util.GeckoBundle

/**
 * Bridges the WebExtension `browser.bookmarks` API (implemented in Gecko's
 * mobile/shared/components/extensions/ext-bookmarks.js) onto the application's
 * application-services Places store (`components.core.bookmarksStorage`).
 *
 * GeckoView builds disable Gecko's own Places (MOZ_GECKOVIEW_HISTORY instead of
 * MOZ_PLACES), so the JS API has no in-process bookmark store to talk to.
 * Instead, ext-bookmarks.js sends `GeckoView:Bookmarks:*` request events over
 * the global EventDispatcher; this listener answers them from the shared store
 * that also backs the app's own bookmark UI (and FxA Sync), so extensions such
 * as floccus operate on exactly the bookmarks the user sees.
 *
 * Wire format mirrors the android-components [BookmarkNode] shape (guid /
 * parentGuid / position / type as "item"|"folder"|"separator"); ext-bookmarks.js
 * maps it to/from the WebExtension BookmarkTreeNode shape.
 */
object GeckoBookmarksExtensionBridge : BundleEventListener {
    private val logger = Logger("GeckoBookmarksExtensionBridge")

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    // application-services Places root guids. Keep in sync with ext-bookmarks.js.
    private const val ROOT_GUID = "root________"
    private const val UNFILED_GUID = "unfiled_____"

    private const val TYPE_ITEM = "item"
    private const val TYPE_FOLDER = "folder"
    private const val TYPE_SEPARATOR = "separator"

    private const val REQUEST_GET = "GeckoView:Bookmarks:Get"
    private const val REQUEST_GET_TREE = "GeckoView:Bookmarks:GetTree"
    private const val REQUEST_GET_CHILDREN = "GeckoView:Bookmarks:GetChildren"
    private const val REQUEST_SEARCH = "GeckoView:Bookmarks:Search"
    private const val REQUEST_CREATE = "GeckoView:Bookmarks:Create"
    private const val REQUEST_MOVE = "GeckoView:Bookmarks:Move"
    private const val REQUEST_UPDATE = "GeckoView:Bookmarks:Update"
    private const val REQUEST_REMOVE = "GeckoView:Bookmarks:Remove"

    private const val EVENT_ON_CREATED = "GeckoView:Bookmarks:OnCreated"
    private const val EVENT_ON_REMOVED = "GeckoView:Bookmarks:OnRemoved"
    private const val EVENT_ON_CHANGED = "GeckoView:Bookmarks:OnChanged"
    private const val EVENT_ON_MOVED = "GeckoView:Bookmarks:OnMoved"

    private const val DEFAULT_SEARCH_LIMIT = 100

    private val REQUEST_EVENTS = arrayOf(
        REQUEST_GET,
        REQUEST_GET_TREE,
        REQUEST_GET_CHILDREN,
        REQUEST_SEARCH,
        REQUEST_CREATE,
        REQUEST_MOVE,
        REQUEST_UPDATE,
        REQUEST_REMOVE,
    )

    @Volatile
    private var registered = false

    /** Registers the request listener with the global EventDispatcher. Idempotent. */
    @Synchronized
    fun register() {
        if (registered) {
            return
        }
        EventDispatcher.getInstance().registerUiThreadListener(this, *REQUEST_EVENTS)
        registered = true
    }

    private val storage: BookmarksStorage?
        get() = GlobalComponents.components?.core?.bookmarksStorage

    override fun handleMessage(
        event: String,
        message: GeckoBundle,
        callback: EventCallback?,
    ) {
        if (callback == null) {
            return
        }

        val store = storage
        if (store == null) {
            callback.sendError("Bookmarks storage is not available")
            return
        }

        scope.launch {
            try {
                when (event) {
                    REQUEST_GET -> handleGet(store, message, callback)
                    REQUEST_GET_TREE -> handleGetTree(store, message, callback)
                    REQUEST_GET_CHILDREN -> handleGetChildren(store, message, callback)
                    REQUEST_SEARCH -> handleSearch(store, message, callback)
                    REQUEST_CREATE -> handleCreate(store, message, callback)
                    REQUEST_MOVE -> handleMove(store, message, callback)
                    REQUEST_UPDATE -> handleUpdate(store, message, callback)
                    REQUEST_REMOVE -> handleRemove(store, message, callback)
                    else -> callback.sendError("Unknown bookmarks request: $event")
                }
            } catch (e: Exception) {
                logger.error("Bookmarks request failed: $event", e)
                callback.sendError(e.message ?: "Bookmarks operation failed")
            }
        }
    }

    // region request handlers

    private suspend fun handleGet(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guids = message.getStringArray("guids") ?: emptyArray()
        val nodes = ArrayList<GeckoBundle>(guids.size)
        for (guid in guids) {
            val node = fetchNode(store, guid, recursive = false)
            if (node == null) {
                callback.sendError("Bookmark not found: $guid")
                return
            }
            nodes.add(nodeToBundle(node, includeChildren = false))
        }
        callback.sendSuccess(nodes.toTypedArray())
    }

    private suspend fun handleGetTree(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guid = message.getString("guid") ?: ROOT_GUID
        val recursive = message.getBoolean("recursive", true)
        val node = store.getTree(guid, recursive).getOrNull()
        if (node == null) {
            callback.sendError("Bookmark not found: $guid")
            return
        }
        callback.sendSuccess(nodeToBundle(node, includeChildren = recursive))
    }

    private suspend fun handleGetChildren(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guid = message.getString("guid")
        if (guid == null) {
            callback.sendError("Missing bookmark id")
            return
        }
        val node = store.getTree(guid, recursive = false).getOrNull()
        if (node == null) {
            callback.sendError("Bookmark not found: $guid")
            return
        }
        val children = node.children
            ?.map { nodeToBundle(it, includeChildren = false) }
            ?.toTypedArray()
            ?: emptyArray()
        callback.sendSuccess(children)
    }

    private suspend fun handleSearch(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val url = message.getString("url")
        val results = if (url != null) {
            // Desktop bookmarks.search({url}) matches the URL exactly.
            store.getBookmarksWithUrl(url).getOrDefault(emptyList())
        } else {
            val query = message.getString("query") ?: message.getString("title") ?: ""
            val limit = message.getInt("limit", DEFAULT_SEARCH_LIMIT).coerceAtLeast(1)
            store.searchBookmarks(query, limit).getOrDefault(emptyList())
        }
        val nodes = results.map { nodeToBundle(it, includeChildren = false) }.toTypedArray()
        callback.sendSuccess(nodes)
    }

    private suspend fun handleCreate(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val parentGuid = message.getString("parentGuid") ?: UNFILED_GUID
        val position = optionalPosition(message, "index")
        val title = message.getString("title") ?: ""
        val url = message.getString("url")
        val type = message.getString("type") ?: TYPE_ITEM

        val newGuid = when (type) {
            TYPE_FOLDER -> store.addFolder(parentGuid, title, position)
            TYPE_SEPARATOR -> store.addSeparator(parentGuid, position)
            else -> store.addItem(parentGuid, url ?: "", title, position)
        }.getOrThrow()

        val node = store.getBookmark(newGuid).getOrNull()
        if (node == null) {
            callback.sendError("Failed to read created bookmark")
            return
        }
        emitCreated(node)
        callback.sendSuccess(nodeToBundle(node, includeChildren = false))
    }

    private suspend fun handleMove(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guid = message.getString("guid")
        if (guid == null) {
            callback.sendError("Missing bookmark id")
            return
        }
        val parentGuid = message.getString("parentGuid")
        var position = optionalPosition(message, "index")
        if (position == null && parentGuid != null) {
            // Desktop move() uses DEFAULT_INDEX (append to the end of the new
            // parent). a-s keeps the current position when position is null, so
            // resolve an explicit append index from the target parent's size.
            position = (store.getTree(parentGuid, recursive = false)
                .getOrNull()?.children?.size ?: 0).toUInt()
        }

        store.updateNode(
            guid,
            BookmarkInfo(parentGuid = parentGuid, position = position, title = null, url = null),
        ).getOrThrow()

        val node = store.getBookmark(guid).getOrNull()
        if (node == null) {
            callback.sendError("Bookmark not found: $guid")
            return
        }
        emitMoved(node)
        callback.sendSuccess(nodeToBundle(node, includeChildren = false))
    }

    private suspend fun handleUpdate(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guid = message.getString("guid")
        if (guid == null) {
            callback.sendError("Missing bookmark id")
            return
        }
        val title = message.getString("title")
        val url = message.getString("url")

        store.updateNode(
            guid,
            BookmarkInfo(parentGuid = null, position = null, title = title, url = url),
        ).getOrThrow()

        val node = store.getBookmark(guid).getOrNull()
        if (node == null) {
            callback.sendError("Bookmark not found: $guid")
            return
        }
        emitChanged(node)
        callback.sendSuccess(nodeToBundle(node, includeChildren = false))
    }

    private suspend fun handleRemove(
        store: BookmarksStorage,
        message: GeckoBundle,
        callback: EventCallback,
    ) {
        val guid = message.getString("guid")
        if (guid == null) {
            callback.sendError("Missing bookmark id")
            return
        }
        val tree = message.getBoolean("tree", true)
        // Capture the node before deletion so listeners get its parent/index.
        val node = store.getBookmark(guid).getOrNull()
        if (!tree && node != null && node.type == BookmarkNodeType.FOLDER) {
            // Match desktop bookmarks.remove(): refuse non-empty folders
            // (preventRemovalOfNonEmptyFolders). removeTree() passes tree=true.
            val children = store.getTree(guid, recursive = false).getOrNull()?.children
            if (!children.isNullOrEmpty()) {
                callback.sendError("Cannot remove a non-empty folder")
                return
            }
        }
        store.deleteNode(guid).getOrThrow()
        if (node != null) {
            emitRemoved(node)
        }
        callback.sendSuccess(true)
    }

    // endregion

    /**
     * Fetches a node, falling back to a children-stripped single-level tree when
     * [BookmarksStorage.getBookmark] returns null for a folder root.
     */
    private suspend fun fetchNode(
        store: BookmarksStorage,
        guid: String,
        recursive: Boolean,
    ): BookmarkNode? {
        store.getBookmark(guid).getOrNull()?.let { return it }
        return store.getTree(guid, recursive).getOrNull()?.let {
            if (recursive) it else it.copy(children = null)
        }
    }

    private fun optionalPosition(message: GeckoBundle, key: String): UInt? {
        val raw = message.getInt(key, -1)
        return if (raw < 0) null else raw.toUInt()
    }

    // region change-event emission (UI edits -> extensions)

    /** Notify extension listeners that a bookmark was created. */
    fun emitCreated(node: BookmarkNode) {
        dispatch(EVENT_ON_CREATED, nodeToBundle(node, includeChildren = false))
    }

    /** Notify extension listeners that a bookmark's title and/or url changed. */
    fun emitChanged(node: BookmarkNode) {
        val bundle = GeckoBundle()
        bundle.putString("guid", node.guid)
        node.title?.let { bundle.putString("title", it) }
        node.url?.let { bundle.putString("url", it) }
        dispatch(EVENT_ON_CHANGED, bundle)
    }

    /** Notify extension listeners that a bookmark moved to a new parent/index. */
    fun emitMoved(node: BookmarkNode) {
        val bundle = GeckoBundle()
        bundle.putString("guid", node.guid)
        node.parentGuid?.let { bundle.putString("parentId", it) }
        node.position?.let { bundle.putInt("index", it.toInt()) }
        dispatch(EVENT_ON_MOVED, bundle)
    }

    /** Notify extension listeners that a bookmark was removed. */
    fun emitRemoved(node: BookmarkNode) {
        val bundle = GeckoBundle()
        bundle.putString("guid", node.guid)
        node.parentGuid?.let { bundle.putString("parentId", it) }
        node.position?.let { bundle.putInt("index", it.toInt()) }
        bundle.putBundle("node", nodeToBundle(node, includeChildren = false))
        dispatch(EVENT_ON_REMOVED, bundle)
    }

    private fun dispatch(event: String, bundle: GeckoBundle) {
        if (!registered) {
            return
        }
        try {
            EventDispatcher.getInstance().dispatch(event, bundle)
        } catch (e: Exception) {
            logger.warn("Failed to dispatch $event", e)
        }
    }

    // endregion

    // region serialization

    private fun typeName(type: BookmarkNodeType): String = when (type) {
        BookmarkNodeType.ITEM -> TYPE_ITEM
        BookmarkNodeType.FOLDER -> TYPE_FOLDER
        BookmarkNodeType.SEPARATOR -> TYPE_SEPARATOR
    }

    private fun nodeToBundle(node: BookmarkNode, includeChildren: Boolean): GeckoBundle {
        val bundle = GeckoBundle()
        bundle.putString("guid", node.guid)
        bundle.putString("type", typeName(node.type))
        node.parentGuid?.let { bundle.putString("parentGuid", it) }
        node.position?.let { bundle.putInt("position", it.toInt()) }
        node.title?.let { bundle.putString("title", it) }
        node.url?.let { bundle.putString("url", it) }
        bundle.putLong("dateAdded", node.dateAdded)
        bundle.putLong("lastModified", node.lastModified)
        if (includeChildren) {
            node.children?.let { children ->
                bundle.putBundleArray(
                    "children",
                    children.map { nodeToBundle(it, includeChildren = true) }.toTypedArray(),
                )
            }
        }
        return bundle
    }

    // endregion
}
