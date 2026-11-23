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
 * Subscription changes Gecko has not been told about yet, one entry per scope.
 *
 * Two things put a scope here, and one entry can carry both:
 *
 * - a deferral (D25, 5.8): the change arrived while its context was restricted,
 *   so it waits under that context until Resume drains it. Written before the
 *   change's entry point returns;
 * - a write-ahead version: the endpoint and keys a NEW_ENDPOINT or an
 *   invalidation is about to write into the subscription row, recorded before
 *   the write. Without it, a process death after the row write and before the
 *   delayed notification left the new endpoint stored and Gecko uninformed, and
 *   the next renewal found nothing to report.
 *
 * An entry goes only when Gecko was handed the version it stands for
 * ([handedOff]): a drain that finds the row at another version, or a subscribe
 * answer carrying an older one, leaves it. A removed subscription takes its
 * entry along ([removed]). Delivery is at least once, never exactly once.
 * Independent of the registry's phases: Resume never deletes it, it drains it.
 */
object PushOutbox {
    private val logger = Logger("PushOutbox")
    private val lock = Any()
    internal var store: JsonStore = LifecycleFiles.store("push_outbox.json", strict = true)

    /** Deferred scopes and the context they wait under. */
    private var entries: MutableMap<String, String>? = null

    /** Scopes with a write-ahead version, and that version. */
    private var versions: MutableMap<String, String> = mutableMapOf()

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
        val loadedVersions = mutableMapOf<String, String>()
        when (read) {
            is AtomicJsonFile.Read.Present -> {
                read.json.optJSONObject(KEY_ENTRIES)?.let { json ->
                    json.keys().forEach { scope -> loaded[scope] = json.optString(scope) }
                }
                read.json.optJSONObject(KEY_VERSIONS)?.let { json ->
                    json.keys().forEach { scope -> loadedVersions[scope] = json.optString(scope) }
                }
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
        versions = loadedVersions
        return loaded
    }

    /**
     * Defers [scope]'s change; returns whether it is written. One already
     * deferred is written again while an earlier write failed: storage may
     * be back. A write-ahead version of the scope stays with it.
     */
    fun defer(scope: String, contextId: String): Boolean = synchronized(lock) {
        val entries = current()
        if (entries[scope] == contextId && !unwritten) return true
        entries[scope] = contextId
        persist(entries)
    }

    /**
     * Records that [scope]'s row is about to change to [version]; returns
     * whether it is written. Called before the write, so that a death after it
     * still reaches Gecko at the next start.
     */
    fun record(scope: String, version: String): Boolean = synchronized(lock) {
        val entries = current()
        if (versions[scope] == version && !unwritten) return true
        versions[scope] = version
        persist(entries)
    }

    /** The version [scope]'s pending change stands for, or null for none or a deferral alone. */
    fun pendingVersion(scope: String): String? = synchronized(lock) {
        current()
        versions[scope]
    }

    /** The deferred scopes of [contextIds]. */
    fun scopesOf(contextIds: Collection<String>): List<String> = synchronized(lock) {
        current().filterValues { it in contextIds }.keys.sorted()
    }

    /**
     * The scopes whose change may go to Gecko now: deferred ones whose context
     * [isRestricted] no longer restricts, and write-ahead ones never deferred.
     */
    fun deliverable(isRestricted: (String) -> Boolean): List<String> = synchronized(lock) {
        val entries = current()
        val deferred = entries.filterValues { !isRestricted(it) }.keys
        (deferred + versions.keys.filterNot { it in entries }).sorted()
    }

    /**
     * Gecko was told about [scope] at [version]. Forgets the entry unless it
     * waits for another version: a newer change still on its way, or one whose
     * row write has not happened.
     */
    fun handedOff(scope: String, version: String) = synchronized(lock) {
        val entries = current()
        val pending = versions[scope]
        if (pending != null && pending != version) return@synchronized
        val deferred = entries.remove(scope) != null
        if (versions.remove(scope) != null || deferred) persist(entries)
    }

    /** [scope]'s subscription is gone, and with it anything left to tell Gecko. */
    fun removed(scope: String) = synchronized(lock) {
        val entries = current()
        val deferred = entries.remove(scope) != null
        if (versions.remove(scope) != null || deferred) persist(entries)
    }

    private fun persist(entries: Map<String, String>): Boolean = try {
        store.write(
            JSONObject()
                .put(KEY_ENTRIES, JSONObject(entries as Map<*, *>))
                .put(KEY_VERSIONS, JSONObject(versions as Map<*, *>)),
        )
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
        versions = mutableMapOf()
        unwritten = false
    }

    private const val KEY_ENTRIES = "entries"
    private const val KEY_VERSIONS = "versions"
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
