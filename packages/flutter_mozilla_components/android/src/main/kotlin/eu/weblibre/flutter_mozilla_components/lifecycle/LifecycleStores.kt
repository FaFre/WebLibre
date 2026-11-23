/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import android.content.Context
import eu.weblibre.flutter_mozilla_components.rootApplicationContext
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import java.io.File
import java.io.IOException
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONObject

/**
 * A JSON file beside `tab_lifecycle.json` in the committed profile's folder.
 * Swapped for memory in tests.
 */
internal interface JsonStore {
    /** The file, or null while no profile is committed. */
    fun read(): AtomicJsonFile.Read?

    /** Writes durably (strict stores) or best effort; throws when it failed. */
    fun write(json: JSONObject)

    /** Keeps a copy of a damaged file for inspection. Best effort. */
    fun keepDamagedCopy() {}
}

/** Where the lifecycle files live: the app's files root, set once per process. */
internal object LifecycleFiles {
    @Volatile
    private var filesDir: File? = null

    fun attach(context: Context) {
        if (filesDir == null) filesDir = context.rootApplicationContext.filesDir
    }

    fun store(name: String, strict: Boolean): JsonStore = object : JsonStore {
        private fun file(): File? {
            val root = filesDir ?: return null
            val folder = StartupArbiter.boundProfileFolder() ?: return null
            return File(File(root, folder), name)
        }

        private fun atomic(file: File) = AtomicJsonFile(file, syncDirectory = strict, strict = strict)

        override fun read(): AtomicJsonFile.Read? = file()?.let { atomic(it).read() }

        override fun write(json: JSONObject) {
            val file = file() ?: throw IOException("No profile is committed")
            atomic(file).write(json)
        }

        override fun keepDamagedCopy() {
            val file = file() ?: return
            runCatching {
                file.copyTo(File(file.parentFile, "${file.name}.corrupt.${System.currentTimeMillis()}"))
            }
        }
    }
}

/**
 * Push messages consumed unread for restricted contexts (5.8), counted per
 * context for the frozen placeholder's notice, and reset after Resume. Losing
 * the count costs only that notice, so its file is written best effort.
 */
object UndeliveredPushCounts {
    private val logger = Logger("UndeliveredPushCounts")
    private val lock = Any()
    internal var store: JsonStore = LifecycleFiles.store("undelivered_push.json", strict = false)
    private var counts: MutableMap<String, Int>? = null
    private val _changes = MutableStateFlow(0L)

    /**
     * Raised by every change of a count. A skipped message changes nothing in
     * the registry, so this is how the placeholder's line hears of it (5.8).
     */
    val changes: StateFlow<Long> = _changes.asStateFlow()

    private fun current(): MutableMap<String, Int> {
        counts?.let { return it }
        // No profile committed yet: nothing to read, and nothing cached.
        val read = store.read() ?: return mutableMapOf()
        val loaded = mutableMapOf<String, Int>()
        (read as? AtomicJsonFile.Read.Present)?.json?.let { json ->
            json.keys().forEach { key -> loaded[key] = json.optInt(key, 0) }
        }
        counts = loaded
        return loaded
    }

    fun countOf(contextId: String): Int = synchronized(lock) { current()[contextId] ?: 0 }

    fun increment(contextId: String) = synchronized(lock) {
        val counts = current()
        counts[contextId] = (counts[contextId] ?: 0) + 1
        persist(counts)
        _changes.value += 1
    }

    fun reset(contextIds: Collection<String>) = synchronized(lock) {
        val counts = current()
        if (contextIds.none { it in counts }) return
        contextIds.forEach { counts.remove(it) }
        persist(counts)
        _changes.value += 1
    }

    private fun persist(counts: Map<String, Int>) {
        runCatching { store.write(JSONObject(counts as Map<*, *>)) }
            .onFailure { logger.warn("Could not write the undelivered push counts", it) }
    }

    internal fun resetForTest(store: JsonStore) = synchronized(lock) {
        this.store = store
        counts = null
    }
}

/**
 * Subscription changes deferred while their context is restricted (D25, 5.8):
 * one entry per scope with its context, written before the change's entry point
 * returns. An entry is removed only after it was handed to Gecko, so delivery
 * is at least once. Independent of the registry's phases: Resume never deletes
 * it, it drains it.
 */
object PushOutbox {
    private val logger = Logger("PushOutbox")
    private val lock = Any()
    internal var store: JsonStore = LifecycleFiles.store("push_outbox.json", strict = true)
    private var entries: MutableMap<String, String>? = null

    /**
     * Whether the file may lack something [entries] has: the last write
     * failed. Kept in memory, a deferred change still drains in this process,
     * but it is durable only once a write succeeds.
     */
    private var unwritten = false

    private fun current(): MutableMap<String, String> {
        entries?.let { return it }
        val read = store.read() ?: return mutableMapOf()
        val loaded = mutableMapOf<String, String>()
        when (read) {
            is AtomicJsonFile.Read.Present -> read.json.optJSONObject(KEY_ENTRIES)?.let { json ->
                json.keys().forEach { scope -> loaded[scope] = json.optString(scope) }
            }
            // A lost change leaves a site with a stale subscription until it
            // checks; keep the damage for inspection (the next write replaces
            // the file) and start empty.
            is AtomicJsonFile.Read.Corrupt -> {
                logger.error("Push outbox unreadable (${read.reason}); deferred changes lost")
                store.keepDamagedCopy()
            }
            AtomicJsonFile.Read.Absent -> Unit
        }
        entries = loaded
        return loaded
    }

    /**
     * Defers [scope]'s change; returns whether it is written. One already
     * deferred is written again while an earlier write failed: storage may
     * be back.
     */
    fun defer(scope: String, contextId: String): Boolean = synchronized(lock) {
        val entries = current()
        if (entries[scope] == contextId && !unwritten) return true
        entries[scope] = contextId
        persist(entries)
    }

    /** The deferred scopes of [contextIds]. */
    fun scopesOf(contextIds: Collection<String>): List<String> = synchronized(lock) {
        current().filterValues { it in contextIds }.keys.sorted()
    }

    /** The deferred scopes whose context [isRestricted] no longer restricts. */
    fun deliverable(isRestricted: (String) -> Boolean): List<String> = synchronized(lock) {
        current().filterValues { !isRestricted(it) }.keys.sorted()
    }

    /** Forgets [scope] after it was handed to Gecko. */
    fun delivered(scope: String) = synchronized(lock) {
        val entries = current()
        if (entries.remove(scope) != null) persist(entries)
    }

    private fun persist(entries: Map<String, String>): Boolean = try {
        store.write(JSONObject().put(KEY_ENTRIES, JSONObject(entries as Map<*, *>)))
        unwritten = false
        true
    } catch (e: IOException) {
        logger.error("Could not write the push outbox", e)
        unwritten = true
        false
    }

    internal fun resetForTest(store: JsonStore) = synchronized(lock) {
        this.store = store
        entries = null
        unwritten = false
    }

    private const val KEY_ENTRIES = "entries"
}

/**
 * The context each download was started in (D24, 5.11), recorded when it is
 * added, independently of its tab: `contextId`, [DEFAULT] or [PRIVATE]. A
 * download without an entry (not resolvable, a failed write, or from before
 * this feature) is unknown, which the download gate treats conservatively.
 *
 * Kept in memory at once and written on [writer], off the main thread, where
 * the store dispatches: the file only matters to a later process, and an entry
 * lost before it was written leaves its download unknown there, which is safe.
 */
object DownloadContexts {
    private val logger = Logger("DownloadContexts")
    private val lock = Any()
    internal var store: JsonStore = LifecycleFiles.store("download_contexts.json", strict = true)
    private var entries: MutableMap<String, String>? = null

    /** Runs the writes, one at a time; direct in tests. */
    private var writer: Executor = Executors.newSingleThreadExecutor { runnable ->
        Thread(runnable, "DownloadContexts").apply { isDaemon = true }
    }

    /** Recorded since the last write started: unknown if that write fails. */
    private val unwritten = mutableSetOf<String>()

    /** Whether a write is queued that has not read the entries yet. */
    private var writeQueued = false

    private fun current(): MutableMap<String, String> {
        entries?.let { return it }
        val read = store.read() ?: return mutableMapOf()
        val loaded = mutableMapOf<String, String>()
        when (read) {
            is AtomicJsonFile.Read.Present -> read.json.keys().forEach { id -> loaded[id] = read.json.optString(id) }
            // Every download is unknown then, which the gate handles safely.
            is AtomicJsonFile.Read.Corrupt -> logger.error("Download contexts unreadable (${read.reason})")
            AtomicJsonFile.Read.Absent -> Unit
        }
        entries = loaded
        return loaded
    }

    /** Records [downloadId]'s context; a failed write makes it unknown. */
    fun record(downloadId: String, context: String) = synchronized(lock) {
        current()[downloadId] = context
        unwritten += downloadId
        persistLocked()
    }

    /** Queues a write of the entries as they are when it runs. */
    private fun persistLocked() {
        if (writeQueued) return
        writeQueued = true
        writer.execute(::writeLatest)
    }

    private fun writeLatest() {
        val (json, recorded) = synchronized(lock) {
            writeQueued = false
            val recorded = unwritten.toSet()
            unwritten.clear()
            JSONObject(current() as Map<*, *>) to recorded
        }
        try {
            store.write(json)
        } catch (e: IOException) {
            if (recorded.isEmpty()) {
                logger.warn("Could not forget removed downloads", e)
                return
            }
            logger.error("Could not record the context of downloads $recorded; treated as unknown", e)
            // Without an entry they are unknown in this process too.
            synchronized(lock) { entries?.keys?.removeAll(recorded) }
        }
    }

    /** The recorded context of [downloadId], or null when it is unknown. */
    fun contextOf(downloadId: String): String? = synchronized(lock) {
        current()[downloadId]
    }

    fun forget(downloadIds: Collection<String>) {
        synchronized(lock) {
            val entries = current()
            unwritten -= downloadIds.toSet()
            if (downloadIds.none { it in entries }) return
            downloadIds.forEach { entries.remove(it) }
            persistLocked()
        }
    }

    fun forgetAll() {
        synchronized(lock) {
            unwritten.clear()
            val entries = current()
            if (entries.isEmpty()) return
            entries.clear()
            persistLocked()
        }
    }

    internal fun resetForTest(store: JsonStore, writer: Executor = Executor(Runnable::run)) = synchronized(lock) {
        this.store = store
        this.writer = writer
        entries = null
        unwritten.clear()
        writeQueued = false
    }

    const val DEFAULT = "default"
    const val PRIVATE = "private"
}
