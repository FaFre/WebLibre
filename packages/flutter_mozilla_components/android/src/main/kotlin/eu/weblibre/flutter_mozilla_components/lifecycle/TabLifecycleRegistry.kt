/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import android.content.Context
import eu.weblibre.flutter_mozilla_components.pigeons.EngineEnforcement
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleOperationState
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.booleanOr
import eu.weblibre.flutter_mozilla_components.startup.longOrNull
import eu.weblibre.flutter_mozilla_components.startup.stringOrNull
import java.io.IOException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONObject
import org.mozilla.geckoview.StorageController

/** Why a tab is held asleep (D26: separate from any restriction of its context). */
enum class SleepHoldKind { MANUAL, AUTOMATIC }

/**
 * A held tab as the panes see it. [tearingDown] is set by the sleep operation
 * right before it releases the session: until then a held tab that still has a
 * session keeps showing it, so a sleep that is refused never blanks the page.
 */
data class HeldTab(val kind: SleepHoldKind, val tearingDown: Boolean = false)

/**
 * The restricted phases a context can be stored in (5.4–5.6). Every stored
 * phase is enforced: a context without a record is unrestricted.
 */
enum class ContextPhase(internal val json: String) {
    FREEZING("freezing"),
    FROZEN("frozen"),
    FAILED("failed"),
    RESUMING("resuming"),
    DELETION_PENDING("deletionPending"),
    RELEASING("releasing"),
    ORPHANED("orphaned"),
    ;

    companion object {
        internal fun ofJson(value: String?): ContextPhase? = values().firstOrNull { it.json == value }
    }
}

/**
 * One restricted context. [previousPhase] only with [ContextPhase.DELETION_PENDING],
 * [wakeTabId] only with [ContextPhase.RESUMING]. [recovered]: frozen by the
 * reconstruction after a damaged registry, not by the user.
 */
data class ContextRecord(
    val ownerId: String?,
    val phase: ContextPhase,
    val previousPhase: ContextPhase? = null,
    val wakeTabId: String? = null,
    val recovered: Boolean = false,
)

/**
 * What the process knows about a restricted context beyond its record, none of
 * it written: the generation that owns it (3.2), what the engine last
 * acknowledged (D33), why the last operation stopped, and what runs now.
 */
data class ContextStatus(
    val generation: Long,
    val enforcement: EngineEnforcement,
    val failure: LifecycleFailure? = null,
    /** What a container operation is doing to the context right now; never `SLEEPING`. */
    val operation: LifecycleOperationState = LifecycleOperationState.IDLE,
)

/** A restricted context as the snapshot reports it. */
data class RestrictedContext(val contextId: String, val record: ContextRecord, val status: ContextStatus)

/** The registry's contexts at one [revision]; [recovery] per D23. */
data class ContextSnapshot(
    val recovery: Boolean,
    val revision: Long,
    val contexts: List<RestrictedContext>,
)

/**
 * The one durable record of tab sleep and container freeze (D8 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
 *
 * - **Tab holds.** A held tab gets no engine session until it is woken
 *   (`TabLifecycleGuardMiddleware` drops the creation action, and AC's creation
 *   gate refuses a creation that was already accepted). Only manual holds of
 *   normal tabs are written (D11): an automatic hold is policy the next start
 *   re-derives, and a private tab does not outlive the process. Their writes
 *   are lenient: a failed one keeps the hold for this process.
 * - **Context records.** Every restricted context with its phase. Gecko's
 *   restriction is derived from them at every runtime creation (E1) and changed
 *   live by the freeze operations; nothing else persists it. Their writes are
 *   strict: a failed one stops the step that needed it (`notPersisted`).
 * - **Recovery mode** (D23). A record found damaged is never taken as empty:
 *   the registry enters recovery, in which every non-default context is
 *   restricted (`"*"`), and writes that before anything else proceeds. Only the
 *   reconstruction ([installReconstruction], [endWildcard]) ends it.
 *
 * One predicate decides restriction everywhere ([isRestricted]): recovery, or
 * a record for the context. The engine at start, the push pre-check, the
 * creation, window and download gates and the snapshot all use it, so no list
 * of phases has to be kept in step.
 *
 * Process-wide and profile-scoped, like
 * [eu.weblibre.flutter_mozilla_components.tabs.TabCloseProtection]: a
 * components rebuild replaces `Core` without tearing it down, so a `Core`
 * member would briefly exist twice, and the holds have to apply to the session
 * restore, which runs before anything could push them again. Loaded on first
 * use by whichever comes first (the runtime's creation, the push worker, `Core`,
 * a snapshot).
 *
 * Every hold and every context change carries a generation (3.2): an operation
 * that started under one completes only while that is still the newest, so a
 * wake, a Resume or another operation in the meantime wins.
 *
 * The file is `tab_lifecycle.json` in the profile folder, read and written in
 * strict mode (F34):
 * `{"version":1,"mode":"normal","tabs":{"<id>":{"hold":"manual"}},
 * "contexts":{"<id>":{"phase":"frozen","owner":"<container>"}}}`.
 */
object TabLifecycleRegistry {
    private val logger = Logger("TabLifecycleRegistry")

    /**
     * A tab's hold. [persistent] holds are written once their sleep completed,
     * and from then on are [committed] (on disk): a sleep still running, or
     * refused, is never written, whatever else writes the file meanwhile.
     */
    private data class Hold(
        val kind: SleepHoldKind,
        val persistent: Boolean,
        val tearingDown: Boolean = false,
        val committed: Boolean = false,
    )

    /** Everything read from and written to the file. Guarded by [lock]. */
    private class Loaded(
        val holds: MutableMap<String, Hold>,
        var contexts: Map<String, ContextRecord>,
        /** The file says recovery (or could not be read). */
        var recoveryOnDisk: Boolean,
        /** The engine restricts `"*"`: from the init-time setting until an acknowledged lift. */
        var wildcard: Boolean,
        var recoverySince: Long?,
    ) {
        /** Recovery (D23), on disk or still in the engine: every context is restricted. */
        val inRecovery: Boolean get() = wildcard || recoveryOnDisk

        /**
         * The context records of the last write confirmed durable, or of the
         * file as it was read: what a power loss now could not undo. A write
         * can replace the file without its folder being synced.
         */
        var durableContexts: Map<String, ContextRecord> = contexts

        /**
         * Data deletions asked for with a container's deletion (D29), by
         * context, with the container: storage without a record, written
         * before the container's row is deleted. They restrict nothing;
         * once the row is gone they become `releasing` records.
         */
        var dataDeletions: Map<String, String> = emptyMap()

        /** [dataDeletions] as of the last write confirmed durable, or as read. */
        var durableDataDeletions: Map<String, String> = emptyMap()
    }

    private val lock = Any()

    @Volatile
    private var storage: JsonStore? = null

    /** Null until the record could be read; guarded by [lock]. */
    private var loaded: Loaded? = null
    private val generations = mutableMapOf<String, Long>()
    private val contextStatus = mutableMapOf<String, ContextStatus>()
    private var lastGeneration = 0L
    private var revision = 0L

    /**
     * Owners whose deletion began in this process ([beginDeletion]) and was
     * not cancelled: their records and data deletions are that deletion's,
     * which the start's owner reconciliation leaves alone. Guarded by [lock].
     */
    private val deletingOwners = mutableSetOf<String>()

    /** Tabs a freeze is tearing down right now; their panes let go of the page. */
    private val freezeTeardowns = mutableSetOf<String>()

    /**
     * Whether a hold change is waiting for [persistPendingHolds]: no write of
     * the record carried it yet. Guarded by [lock].
     */
    private var holdsUnwritten = false

    private val _heldTabs = MutableStateFlow<Map<String, HeldTab>>(emptyMap())

    /** Every held tab and why, for presenting and reporting. */
    val heldTabs: StateFlow<Map<String, HeldTab>> = _heldTabs.asStateFlow()

    private val _revisions = MutableStateFlow(0L)

    /** The context revision; changes with every context change in this process. */
    val revisions: StateFlow<Long> = _revisions.asStateFlow()

    /**
     * Gives the registry the context it persists through. Called wherever a
     * process can start enforcing; later calls do nothing.
     */
    fun attach(context: Context) {
        LifecycleFiles.attach(context)
        if (storage != null) return
        synchronized(lock) {
            if (storage == null) storage = LifecycleFiles.store(FILE_NAME, strict = true)
        }
    }

    /**
     * Holds placed before the record could be read (no profile committed yet),
     * kept in memory and laid over the record once it is. Guarded by [lock].
     */
    private var unloaded: MutableMap<String, Hold>? = null

    /** The state in force, read on first use; null while no profile is committed. Call with [lock] held. */
    private fun loadedOrNull(): Loaded? {
        loaded?.let { return it }
        val read = storage?.read() ?: return null
        val state = when (read) {
            AtomicJsonFile.Read.Absent -> Loaded(mutableMapOf(), emptyMap(), false, false, null)
            is AtomicJsonFile.Read.Present -> parse(read.json) ?: enterRecovery("unreadable records")
            is AtomicJsonFile.Read.Corrupt -> enterRecovery(read.reason)
        }
        unloaded?.let { early ->
            state.holds.putAll(early)
            unloaded = null
        }
        loaded = state
        // The init-time restriction (E1) is what the engine enforces from here.
        state.contexts.keys.forEach { contextId ->
            contextStatus[contextId] = ContextStatus(nextGeneration(contextKey(contextId)), EngineEnforcement.ENFORCED)
        }
        settleAfterRestart(state)
        publish(state.holds)
        bumpRevision()
        return state
    }

    /**
     * A freeze the process did not live to finish: nothing of its contexts runs
     * after a restart, and the init-time restriction keeps it that way, so it is
     * frozen now (5.6). `resuming` stays: a restart is not a deliberate Resume.
     */
    private fun settleAfterRestart(state: Loaded) {
        val settled = state.contexts.mapValues { (_, record) ->
            when (record.phase) {
                ContextPhase.FREEZING, ContextPhase.FAILED -> record.copy(phase = ContextPhase.FROZEN)
                else -> record
            }
        }
        if (settled == state.contexts) return
        state.contexts = settled
        runCatching { storage?.write(toJson(state)) }
            .onFailure { logger.warn("Could not write the frozen phase after a restart; the next start settles it again", it) }
    }

    /**
     * Null when the record cannot be understood; the caller enters recovery.
     * Fails closed on anything this version did not write: another format
     * version, and a field of the wrong type, which `optJSONObject` and the
     * like would read as absent, so that `"contexts": []` would restrict
     * nothing. The one other shape accepted is the hold-only record of the
     * first tab sleep builds, which wrote neither `mode` nor `contexts`: it
     * holds no restriction to lose.
     */
    private fun parse(json: JSONObject): Loaded? {
        if (json.opt(KEY_VERSION) != FORMAT_VERSION) return null
        if (!json.isAbsentOr<JSONObject>(KEY_TABS) || !json.isAbsentOr<Number>(KEY_SINCE)) return null
        val holdsOnly = !json.has(KEY_MODE) && !json.has(KEY_CONTEXTS)
        val entries = if (holdsOnly) JSONObject() else json.opt(KEY_CONTEXTS) as? JSONObject ?: return null
        val recovery = when (if (holdsOnly) MODE_NORMAL else json.opt(KEY_MODE)) {
            MODE_NORMAL -> false
            MODE_RECOVERY -> true
            else -> return null
        }

        val holds = mutableMapOf<String, Hold>()
        json.optJSONObject(KEY_TABS)?.let { tabs ->
            tabs.keys().forEach { tabId ->
                val kind = tabs.optJSONObject(tabId)?.stringOrNull(KEY_HOLD)
                if (kind == HOLD_MANUAL) holds[tabId] = Hold(SleepHoldKind.MANUAL, persistent = true, committed = true)
            }
        }
        val contexts = mutableMapOf<String, ContextRecord>()
        entries.keys().forEach { contextId ->
            val entry = entries.opt(contextId) as? JSONObject ?: return null
            val phase = ContextPhase.ofJson(entry.opt(KEY_PHASE) as? String) ?: return null
            val previous = if (entry.has(KEY_PREVIOUS)) {
                ContextPhase.ofJson(entry.opt(KEY_PREVIOUS) as? String) ?: return null
            } else {
                null
            }
            if (!entry.isAbsentOr<String>(KEY_OWNER) ||
                !entry.isAbsentOr<String>(KEY_WAKE_TAB) ||
                !entry.isAbsentOr<Boolean>(KEY_RECOVERED)
            ) {
                return null
            }
            contexts[contextId] = ContextRecord(
                ownerId = entry.stringOrNull(KEY_OWNER),
                phase = phase,
                previousPhase = previous,
                wakeTabId = entry.stringOrNull(KEY_WAKE_TAB),
                recovered = entry.booleanOr(KEY_RECOVERED, false),
            )
        }
        if (!json.isAbsentOr<JSONObject>(KEY_DATA_DELETIONS)) return null
        val dataDeletions = mutableMapOf<String, String>()
        json.optJSONObject(KEY_DATA_DELETIONS)?.let { entries ->
            entries.keys().forEach { contextId ->
                dataDeletions[contextId] = entries.opt(contextId) as? String ?: return null
            }
        }
        return Loaded(holds, contexts, recovery, wildcard = recovery, recoverySince = json.longOrNull(KEY_SINCE))
            .also {
                it.dataDeletions = dataDeletions
                it.durableDataDeletions = dataDeletions
            }
    }

    /** Whether [name] is absent or holds a [T] (an explicit `null` does not). */
    private inline fun <reified T> JSONObject.isAbsentOr(name: String): Boolean = !has(name) || opt(name) is T

    /**
     * D23, step 1: a damaged record restricts every context. The damage is
     * copied aside, then the recovery record is written over it, before any
     * runtime exists. If that write fails the file stays damaged, so the next
     * start comes back here: still fail closed. Sleep holds are lost, which only
     * costs a reload of an unloaded tab (F20).
     */
    private fun enterRecovery(reason: String): Loaded {
        logger.error("Tab lifecycle record unreadable ($reason); every container stays frozen until reconstructed")
        storage?.keepDamagedCopy()
        val state = Loaded(mutableMapOf(), emptyMap(), recoveryOnDisk = true, wildcard = true, recoverySince = System.currentTimeMillis())
        runCatching { storage?.write(toJson(state)) }
            .onFailure { logger.error("Could not write the recovery record; the next start enters recovery again", it) }
        return state
    }

    /** The state in force, read on first use. Call with [lock] held. */
    private fun holdsNow(): MutableMap<String, Hold> =
        loadedOrNull()?.holds ?: unloaded ?: mutableMapOf<String, Hold>().also { unloaded = it }

    private fun publish(holds: Map<String, Hold>) {
        _heldTabs.value = holds.mapValues { HeldTab(it.value.kind, it.value.tearingDown) }
    }

    private fun bumpRevision() {
        revision += 1
        _revisions.value = revision
    }

    private fun nextGeneration(key: String): Long {
        lastGeneration += 1
        generations[key] = lastGeneration
        return lastGeneration
    }

    // --- Tab holds -------------------------------------------------------

    /** Whether [tabId] is held asleep. */
    fun isHeld(tabId: String): Boolean = synchronized(lock) { tabId in holdsNow() }

    /**
     * Whether a session may be created for [tabId] in [contextId]: the tab is
     * not held asleep and its context is not restricted. The one check of the
     * guard middleware (B1) and AC's session creation gate (B2).
     */
    fun maySessionBeCreated(tabId: String, contextId: String?): Boolean =
        !isHeld(tabId) && !isRestricted(contextId)

    /** Why [tabId] is held, or null. */
    fun holdOf(tabId: String): SleepHoldKind? = synchronized(lock) { holdsNow()[tabId]?.kind }

    /** The newest generation of [tabId], 0 when it never had one. */
    fun generation(tabId: String): Long = synchronized(lock) { generations[tabId] ?: 0L }

    /**
     * Holds [tabId] at once, in memory, and returns the generation that owns the
     * hold. The hold is written only by [completeSleep]; one already written
     * stays on disk meanwhile.
     */
    fun beginSleep(tabId: String, kind: SleepHoldKind, private: Boolean): Long =
        synchronized(lock) { beginSleepLocked(tabId, kind, private) }

    /**
     * [beginSleep] with an automatic hold, unless [tabId] is held already
     * (asleep, or a sleep running on it): null then, and nothing changes. In
     * one step, so a manual sleep that came between the scheduler's pick and
     * this call keeps its hold: replaced, the automatic sleep would then
     * refuse the unloaded tab and release the hold, from disk too.
     */
    fun beginAutomaticSleep(tabId: String, private: Boolean): Long? =
        synchronized(lock) {
            if (holdsNow()[tabId] != null) return null
            beginSleepLocked(tabId, SleepHoldKind.AUTOMATIC, private)
        }

    private fun beginSleepLocked(tabId: String, kind: SleepHoldKind, private: Boolean): Long {
        val holds = holdsNow()
        val gen = nextGeneration(tabId)
        holds[tabId] = Hold(
            kind,
            persistent = kind == SleepHoldKind.MANUAL && !private,
            committed = holds[tabId]?.committed == true,
        )
        publish(holds)
        return gen
    }

    /**
     * Drops the hold [gen] installed, when [gen] still owns it. Returns whether
     * it did; a newer wake or sleep owns the tab otherwise. A hold on disk
     * (one the sleep replaced) is removed there too.
     */
    fun releaseSleep(tabId: String, gen: Long): Boolean = synchronized(lock) {
        if (generations[tabId] != gen) return false
        val holds = holdsNow()
        val removed = holds.remove(tabId) ?: return false
        nextGeneration(tabId)
        publish(holds)
        if (removed.committed) persistHoldsLocked()
        true
    }

    /**
     * Marks the hold [gen] owns as tearing the session down, so the panes let go
     * of the page. Returns false when a newer operation owns the tab.
     */
    fun markTearingDown(tabId: String, gen: Long): Boolean = synchronized(lock) {
        if (generations[tabId] != gen) return false
        val holds = holdsNow()
        val hold = holds[tabId] ?: return false
        if (!hold.tearingDown) {
            holds[tabId] = hold.copy(tearingDown = true)
            publish(holds)
        }
        true
    }

    /**
     * Commits the sleep [gen] started: the teardown is over, so the hold is an
     * ordinary sleeping tab again (one that shows its placeholder on screen
     * until the user wakes it, D10), and it is written when it persists. Returns false when a newer operation owns
     * the tab, in which case nothing changes. A failed write is logged and the
     * hold stays in force for this process; the next start then only lacks a
     * hold on an unloaded tab.
     *
     * Without [persist], the write is left to [persistPendingHolds], so that a
     * batch of sleeps rewrites and syncs the record once rather than once per
     * tab; any other write of the record meanwhile carries the hold too.
     */
    fun completeSleep(tabId: String, gen: Long, persist: Boolean = true): Boolean = synchronized(lock) {
        if (generations[tabId] != gen) return false
        val holds = holdsNow()
        val hold = holds[tabId] ?: return false
        holds[tabId] = hold.copy(tearingDown = false, committed = hold.persistent)
        if (hold.tearingDown) publish(holds)
        // Also when it replaced a hold on disk that it does not keep.
        if (hold.persistent || hold.committed) {
            if (persist) persistHoldsLocked() else holdsUnwritten = true
        }
        true
    }

    /**
     * Writes the holds that [completeSleep] left unwritten, if no other write
     * of the record carried them since. Lenient, like every hold write.
     */
    fun persistPendingHolds() = synchronized(lock) {
        if (holdsUnwritten) persistHoldsLocked()
    }

    /**
     * Clears [tabId]'s hold and makes every operation still running on it stale.
     * Returns whether there was a hold.
     */
    fun wake(tabId: String): Boolean = synchronized(lock) {
        val holds = holdsNow()
        nextGeneration(tabId)
        val removed = holds.remove(tabId) ?: return false
        publish(holds)
        if (removed.committed) persistHoldsLocked()
        true
    }

    /**
     * Forgets [tabIds] entirely: they were closed. Not written at once: this
     * runs on the main thread inside the store's dispatch, and a hold left on
     * disk for a closed tab is harmless. The next write of the record drops
     * it, and so does the next start's [retainOnly].
     */
    fun forget(tabIds: Collection<String>) {
        if (tabIds.isEmpty()) return
        synchronized(lock) {
            val holds = holdsNow()
            var removed = false
            tabIds.forEach { tabId ->
                generations.remove(tabId)
                freezeTeardowns.remove(tabId)
                if (holds.remove(tabId) != null) removed = true
            }
            if (removed) publish(holds)
        }
    }

    /**
     * Keeps only the holds of [liveTabIds]. For the end of the session restore,
     * when the store holds every tab the session had.
     */
    fun retainOnly(liveTabIds: Set<String>) {
        synchronized(lock) {
            val stale = holdsNow().keys - liveTabIds
            if (stale.isNotEmpty()) forget(stale)
        }
    }

    /** Holds are lenient: a failed write is logged and the hold stays in force. */
    private fun persistHoldsLocked() {
        val state = loadedOrNull()
        if (state == null) {
            logger.error("Could not write the tab lifecycle record: no profile is committed")
            return
        }
        writeState(state)
    }

    // --- Contexts --------------------------------------------------------

    /**
     * The one restriction predicate (5.6): recovery, or a record for
     * [contextId]. The default context (null) is never restricted.
     */
    fun isRestricted(contextId: String?): Boolean {
        if (contextId == null) return false
        return synchronized(lock) {
            val state = loadedOrNull() ?: return false
            state.inRecovery || contextId in state.contexts
        }
    }

    /**
     * Those of [contextIds] that [isRestricted] says are restricted, read under
     * one lock. Never null, the default context.
     */
    fun restrictedAmong(contextIds: Collection<String?>): Set<String?> = synchronized(lock) {
        val state = loadedOrNull() ?: return emptySet()
        contextIds.filterTo(mutableSetOf()) { it != null && (state.inRecovery || it in state.contexts) }
    }

    /** Whether any context is restricted (the download gate's unknown rule, 5.11). */
    fun anyRestricted(): Boolean = synchronized(lock) {
        val state = loadedOrNull() ?: return false
        state.inRecovery || state.contexts.isNotEmpty()
    }

    /** Whether the registry is in recovery (D23), on disk or still in the engine. */
    fun inRecovery(): Boolean = synchronized(lock) { loadedOrNull()?.inRecovery == true }

    /**
     * What the runtime restricts from its first instruction (E1): `"*"` in
     * recovery, otherwise every context with a record.
     */
    fun restrictedContexts(): List<String> = synchronized(lock) {
        val state = loadedOrNull() ?: run {
            // Never expected (the runtime needs a committed profile), and never
            // taken as "nothing is frozen".
            logger.error("Tab lifecycle record not readable at runtime creation; restricting every context")
            return listOf(ALL_CONTEXTS)
        }
        if (state.recoveryOnDisk) listOf(ALL_CONTEXTS) else state.contexts.keys.sorted()
    }

    /** The context's record, or null when it is unrestricted. */
    fun recordOf(contextId: String): ContextRecord? = synchronized(lock) { loadedOrNull()?.contexts?.get(contextId) }

    /** The context's status, or null when it has no record. */
    fun statusOf(contextId: String): ContextStatus? = synchronized(lock) {
        val state = loadedOrNull() ?: return null
        if (contextId !in state.contexts) null else contextStatus[contextId]
    }

    /** Every context with a record of [ownerId]. */
    fun contextsOf(ownerId: String): List<String> = synchronized(lock) {
        loadedOrNull()?.contexts?.filterValues { it.ownerId == ownerId }?.keys?.sorted().orEmpty()
    }

    /**
     * [ownerId]'s phase ([ownerPhaseOf]). Null when no record holds it: it
     * has none, or only ones that wait for their data to be deleted.
     */
    fun ownerPhase(ownerId: String): ContextPhase? = synchronized(lock) {
        ownerPhaseOf(
            loadedOrNull()?.contexts?.values?.filter { it.ownerId == ownerId }?.map { it.phase }.orEmpty(),
        )
    }

    /**
     * The phase of an owner whose contexts are in [phases]: they normally share
     * one; when they do not (a Resume confirmed for some), the one that needs
     * attention first. Null when none of them holds the owner ([holdsOwner]).
     */
    fun ownerPhaseOf(phases: Collection<ContextPhase>): ContextPhase? =
        OWNER_PHASE_ORDER.firstOrNull { it in phases }

    /**
     * Whether a record in [phase] holds its owner: frozen, being frozen,
     * resumed or deleted, or a freeze or Resume did not finish. A `releasing`
     * one only waits for its data to be deleted (an isolation group whose
     * release did not finish keeps it for a container that is not frozen),
     * and an `orphaned` one has no owner.
     */
    fun holdsOwner(phase: ContextPhase): Boolean = phase in OWNER_PHASE_ORDER

    /** Which phase an owner reports when its contexts differ. */
    private val OWNER_PHASE_ORDER = listOf(
        ContextPhase.FREEZING,
        ContextPhase.RESUMING,
        ContextPhase.FAILED,
        ContextPhase.DELETION_PENDING,
        ContextPhase.FROZEN,
    )

    /** Every record and its status, at one revision. */
    fun snapshot(): ContextSnapshot = synchronized(lock) {
        val state = loadedOrNull()
            ?: return ContextSnapshot(recovery = false, revision = revision, contexts = emptyList())
        ContextSnapshot(
            recovery = state.inRecovery,
            revision = revision,
            contexts = state.contexts.entries.sortedBy { it.key }.map { (contextId, record) ->
                RestrictedContext(contextId, record, contextStatus[contextId] ?: ContextStatus(0, EngineEnforcement.ENFORCED))
            },
        )
    }

    /**
     * Whether the record can be read: a profile is committed. Until then
     * [snapshot] reports nothing restricted, which is not known.
     */
    fun isReadable(): Boolean = synchronized(lock) { loadedOrNull() != null }

    /** The current revision. */
    fun revision(): Long = synchronized(lock) {
        loadedOrNull()
        revision
    }

    /**
     * Whether a write confirmed durable records every one of [contextIds], so
     * that no power loss could bring one back unrestricted. Not when the
     * write that recorded them replaced the file without its folder being
     * synced, and nothing confirmed since ([writeOrRevert] counts that one as
     * written when it cannot put the old file back).
     */
    fun isDurablyRecorded(contextIds: Collection<String>): Boolean = synchronized(lock) {
        val durable = loadedOrNull()?.durableContexts ?: return false
        contextIds.all { it in durable }
    }

    /** Whether [gen] still owns every one of [contextIds]. */
    fun owns(contextIds: Collection<String>, gen: Long): Boolean = synchronized(lock) {
        contextIds.all { generations[contextKey(it)] == gen }
    }

    /**
     * Applies [change] to the context records, and [deletions] to the data
     * deletions, and writes them. With [keepOnFailure] a failed write leaves
     * the change in memory (it is the safer state), otherwise the previous
     * records stay; with [durable] also when the write could not be
     * confirmed. Returns whether the write succeeded; nothing is written
     * while no profile is committed.
     */
    private inline fun mutateContexts(
        keepOnFailure: Boolean,
        durable: Boolean = false,
        deletions: (MutableMap<String, String>) -> Unit = {},
        change: (MutableMap<String, ContextRecord>) -> Unit,
    ): Boolean {
        val state = loadedOrNull() ?: return false
        val before = state.contexts
        val beforeDeletions = state.dataDeletions
        val next = before.toMutableMap().also(change)
        val nextDeletions = beforeDeletions.toMutableMap().also(deletions)
        if (next == before && nextDeletions == beforeDeletions) return true
        val apply = {
            state.contexts = next
            state.dataDeletions = nextDeletions
        }
        val restore = {
            state.contexts = before
            state.dataDeletions = beforeDeletions
        }
        apply()
        val outcome = if (keepOnFailure) writeState(state) else writeOrRevert(state, apply, restore, durable)
        val written = outcome == Written.YES
        if (!written && !keepOnFailure) restore()
        if (written || keepOnFailure) {
            next.keys.forEach { contextStatus.putIfAbsent(it, ContextStatus(0, EngineEnforcement.LIFTED)) }
            (before.keys - next.keys).forEach { contextStatus.remove(it) }
            bumpRevision()
        }
        return written
    }

    /** How a write of the record ended. */
    private enum class Written {
        YES,

        /** Not written: the file shows what it showed before. */
        NO,

        /** The file shows the new state, not confirmed durable. */
        UNCONFIRMED,
    }

    /**
     * Writes [state], which [apply] just changed. Readers see the change
     * already, and a write that counts as failed must have changed nothing: an
     * unconfirmed one has [restore] write the previous state back. When even
     * that cannot replace the file, the change is what it shows, so it is
     * applied again and counts as written, though not as durable
     * ([isDurablyRecorded]), unless [durable] asks for a confirmed write.
     */
    private inline fun writeOrRevert(
        state: Loaded,
        apply: () -> Unit,
        restore: () -> Unit,
        durable: Boolean = false,
    ): Written {
        val outcome = writeState(state)
        if (outcome != Written.UNCONFIRMED) return outcome
        restore()
        if (writeState(state) != Written.NO) return Written.UNCONFIRMED
        // With [durable] the change counts as failed anyway, kept out of
        // memory: what it allowed (a row delete) must not happen on a file a
        // power loss can undo. The unsynced file keeps showing it, which a
        // restart reconciles as a step that did not finish.
        if (durable) return Written.UNCONFIRMED
        apply()
        return Written.YES
    }

    private fun writeState(state: Loaded): Written = try {
        val target = storage ?: throw IOException("Tab lifecycle record has no storage attached")
        target.write(toJson(state))
        holdsUnwritten = false
        state.durableContexts = state.contexts
        state.durableDataDeletions = state.dataDeletions
        Written.YES
    } catch (e: AtomicJsonFile.UnconfirmedWriteException) {
        logger.error("The tab lifecycle record was replaced, but not confirmed durable", e)
        // The file shows the holds either way: a revert puts back only the
        // context records.
        holdsUnwritten = false
        Written.UNCONFIRMED
    } catch (e: IOException) {
        logger.error("Could not write the tab lifecycle record", e)
        Written.NO
    }

    private fun contextKey(contextId: String) = "ctx:$contextId"

    /** A new generation that owns [contextIds] from now on. Call with [lock] held. */
    private fun claimGeneration(contextIds: Collection<String>): Long {
        lastGeneration += 1
        contextIds.forEach { generations[contextKey(it)] = lastGeneration }
        return lastGeneration
    }

    /** Those of [contextIds] that [gen] still owns. Call with [lock] held. */
    private fun ownedBy(contextIds: Collection<String>, gen: Long): List<String> =
        contextIds.filter { generations[contextKey(it)] == gen }

    private fun updateStatus(contextIds: Collection<String>, update: (ContextStatus) -> ContextStatus) {
        var changed = false
        contextIds.forEach { contextId ->
            val current = contextStatus[contextId] ?: return@forEach
            val next = update(current)
            if (next != current) {
                contextStatus[contextId] = next
                changed = true
            }
        }
        if (changed) bumpRevision()
    }

    /**
     * Barrier 2: `freezing` written for each of [contextIds], owned by a new
     * generation, which it returns. Null when the write failed; nothing changed
     * then (`notPersisted`). A context already restricted keeps its engine state.
     */
    fun beginFreeze(ownerId: String, contextIds: Collection<String>): Long? = synchronized(lock) {
        val state = loadedOrNull() ?: return null
        val previous = contextIds.associateWith { state.contexts[it] }
        val written = mutateContexts(keepOnFailure = false) { records ->
            contextIds.forEach { records[it] = ContextRecord(ownerId, ContextPhase.FREEZING) }
        }
        if (!written) return null
        val gen = claimGeneration(contextIds)
        contextIds.forEach { contextId ->
            val enforcement = if (previous[contextId] != null) {
                contextStatus[contextId]?.enforcement ?: EngineEnforcement.ENFORCED
            } else {
                EngineEnforcement.LIFTED
            }
            contextStatus[contextId] = ContextStatus(gen, enforcement, operation = LifecycleOperationState.FREEZING)
        }
        bumpRevision()
        gen
    }

    /**
     * A freeze refused before it restricted anything new: the records [gen]
     * wrote are removed again, except that a context in [restore] (restricted
     * before this freeze, a Retry) gets that record back and stays restricted.
     * A failed write keeps them as `failed` in memory (the next start freezes
     * them, which is safe); returns whether it was written.
     */
    fun abandonFreeze(
        contextIds: Collection<String>,
        gen: Long,
        failure: LifecycleFailure,
        restore: Map<String, ContextRecord> = emptyMap(),
    ): Boolean = synchronized(lock) {
        val owned = ownedBy(contextIds, gen)
        if (owned.isEmpty()) return true
        val written = mutateContexts(keepOnFailure = false) { records ->
            owned.forEach { id ->
                val before = restore[id]
                if (before == null) records.remove(id) else records[id] = before.copy(phase = settledAfterRefusal(before.phase))
            }
        }
        if (!written) {
            mutateContexts(keepOnFailure = true) { records ->
                owned.forEach { id -> records[id]?.let { records[id] = it.copy(phase = ContextPhase.FAILED) } }
            }
            updateStatus(owned) { it.copy(failure = LifecycleFailure.NOT_PERSISTED, operation = LifecycleOperationState.IDLE) }
            return false
        }
        val kept = owned.filter { it in restore }
        (owned - kept.toSet()).forEach { generations.remove(contextKey(it)) }
        updateStatus(kept) { it.copy(failure = failure, operation = LifecycleOperationState.IDLE) }
        logger.debug("Freeze of $owned abandoned: $failure")
        true
    }

    /** A phase put back after a refused Retry; nobody runs a freeze or Resume for it any more. */
    private fun settledAfterRefusal(phase: ContextPhase): ContextPhase = when (phase) {
        ContextPhase.FREEZING -> ContextPhase.FAILED
        else -> phase
    }

    /**
     * Writes [phase] for those of [contextIds] that [gen] still owns, and
     * records [failure]. A failed write keeps the phase in memory: callers only
     * move to phases at least as restrictive as the stored one. Returns whether
     * it was written; false also when [gen] owns none of them.
     */
    fun setPhase(
        contextIds: Collection<String>,
        gen: Long,
        phase: ContextPhase,
        failure: LifecycleFailure? = null,
        operation: LifecycleOperationState = LifecycleOperationState.IDLE,
    ): Boolean = synchronized(lock) {
        val owned = ownedBy(contextIds, gen)
        if (owned.isEmpty()) return false
        val written = mutateContexts(keepOnFailure = true) { records ->
            owned.forEach { id -> records[id]?.let { records[id] = it.copy(phase = phase, previousPhase = null, wakeTabId = null) } }
        }
        updateStatus(owned) {
            it.copy(failure = if (written) failure else failure ?: LifecycleFailure.NOT_PERSISTED, operation = operation)
        }
        written
    }

    /** Records what the engine acknowledged for [contextIds] (D33). */
    fun setEnforcement(contextIds: Collection<String>, enforcement: EngineEnforcement) = synchronized(lock) {
        loadedOrNull()
        updateStatus(contextIds) { it.copy(enforcement = enforcement) }
    }

    /** Records why the operation [gen] owns stopped, without a phase change. */
    fun setFailure(contextIds: Collection<String>, gen: Long, failure: LifecycleFailure?, operation: LifecycleOperationState = LifecycleOperationState.IDLE) =
        synchronized(lock) {
            loadedOrNull()
            updateStatus(ownedBy(contextIds, gen)) {
                it.copy(failure = failure, operation = operation)
            }
        }

    /**
     * Resume, step 2: `resuming` written for [contextIds] under a new
     * generation, which supersedes any running freeze. Null when the write
     * failed; nothing changed then.
     */
    fun beginResume(contextIds: Collection<String>, wakeTabId: String?): Long? = synchronized(lock) {
        val state = loadedOrNull() ?: return null
        val present = contextIds.filter { it in state.contexts }
        if (present.isEmpty()) return null
        val written = mutateContexts(keepOnFailure = false) { records ->
            present.forEach { id ->
                records[id] = records.getValue(id).copy(phase = ContextPhase.RESUMING, previousPhase = null, wakeTabId = wakeTabId)
            }
        }
        if (!written) {
            updateStatus(present) { it.copy(failure = LifecycleFailure.NOT_PERSISTED) }
            return null
        }
        val gen = claimGeneration(present)
        present.forEach { contextId ->
            contextStatus[contextId] = (contextStatus[contextId] ?: ContextStatus(gen, EngineEnforcement.ENFORCED))
                .copy(generation = gen, failure = null, operation = LifecycleOperationState.RESUMING)
        }
        bumpRevision()
        gen
    }

    /**
     * Removes the records of [contextIds] that [gen] owns, in one write, and
     * forgets their generations. Returns the removed ones: empty when [gen]
     * owns none of them, null when the write failed, and then nothing changed.
     */
    fun removeRecords(contextIds: Collection<String>, gen: Long): List<String>? = synchronized(lock) {
        val owned = ownedBy(contextIds, gen)
        if (owned.isEmpty()) return emptyList()
        val written = mutateContexts(keepOnFailure = false) { records -> owned.forEach { records.remove(it) } }
        if (!written) return null
        owned.forEach { generations.remove(contextKey(it)) }
        owned
    }

    /**
     * A new generation for [contextIds], superseding whatever owned them, for
     * an operation that changes no phase at first (a release, a deletion step).
     */
    fun claim(contextIds: Collection<String>, operation: LifecycleOperationState = LifecycleOperationState.IDLE): Long = synchronized(lock) {
        loadedOrNull()
        val gen = claimGeneration(contextIds)
        contextIds.forEach { contextId ->
            contextStatus[contextId]?.let { contextStatus[contextId] = it.copy(generation = gen, operation = operation) }
        }
        bumpRevision()
        gen
    }

    /**
     * Deletion, first half (D28): `deletionPending` with the phase each had,
     * and the data deletions of [deleteDataOf], storage of the owner without a
     * record whose data the user asked to delete with it (D29), all written in
     * one write before the container's row is deleted. Returns whether it is
     * on disk, confirmed durable, as the row delete it allows needs; nothing
     * changed otherwise, unless an earlier call wrote it (then the caller
     * cancels the deletion).
     */
    fun beginDeletion(ownerId: String, deleteDataOf: Collection<String> = emptyList()): Boolean = synchronized(lock) {
        val state = loadedOrNull() ?: return false
        val owned = state.contexts.filterValues { it.ownerId == ownerId && it.phase != ContextPhase.DELETION_PENDING }
        val intents = deleteDataOf.filter { it !in state.contexts && state.dataDeletions[it] != ownerId }
        if (owned.isEmpty() && intents.isEmpty() && !holdsOwnerData(state, ownerId)) return true
        if (owned.isNotEmpty() || intents.isNotEmpty()) {
            val written = mutateContexts(
                keepOnFailure = false,
                durable = true,
                deletions = { pending -> intents.forEach { pending[it] = ownerId } },
            ) { records ->
                owned.forEach { (id, record) ->
                    records[id] = record.copy(phase = ContextPhase.DELETION_PENDING, previousPhase = record.phase, wakeTabId = null)
                }
            }
            if (!written) return false
            owned.keys.forEach { nextGeneration(contextKey(it)) }
        }
        deletingOwners += ownerId
        // The row goes once this answers true: what an earlier call wrote must
        // survive a power loss too, though a write since was not confirmed.
        isDeletionDurable(state, ownerId) || writeState(state) == Written.YES
    }

    /** Whether [ownerId] has records or data deletions, which its deletion has to settle. */
    private fun holdsOwnerData(state: Loaded, ownerId: String): Boolean =
        state.contexts.values.any { it.ownerId == ownerId } || ownerId in state.dataDeletions.values

    /** Whether [ownerId]'s records and data deletions are what the last confirmed write holds. */
    private fun isDeletionDurable(state: Loaded, ownerId: String): Boolean =
        state.contexts.filterValues { it.ownerId == ownerId } == state.durableContexts.filterValues { it.ownerId == ownerId } &&
            state.dataDeletions.filterValues { it == ownerId } == state.durableDataDeletions.filterValues { it == ownerId }

    /**
     * The row was not deleted: each `deletionPending` context of [ownerId] goes
     * back to the phase it had, and its data deletions are dropped. A failed
     * write keeps that in memory; the next start's owner reconciliation
     * restores it from disk anyway.
     */
    fun cancelDeletion(ownerId: String): Boolean = synchronized(lock) {
        val state = loadedOrNull() ?: return false
        deletingOwners -= ownerId
        val pending = state.contexts.filterValues { it.ownerId == ownerId && it.phase == ContextPhase.DELETION_PENDING }
        if (pending.isEmpty() && ownerId !in state.dataDeletions.values) return true
        mutateContexts(keepOnFailure = true, deletions = { it.values.removeAll { owner -> owner == ownerId } }) { records ->
            pending.forEach { (id, record) ->
                // Whatever ran for it was stopped by the deletion.
                val back = settledAfterRefusal(record.previousPhase ?: ContextPhase.FROZEN)
                records[id] = record.copy(phase = back, previousPhase = null)
            }
        }
    }

    /** The contexts whose data deletion [ownerId]'s deletion asked for and which are not recorded yet. */
    fun dataDeletionsOf(ownerId: String): List<String> = synchronized(lock) {
        loadedOrNull()?.dataDeletions?.filterValues { it == ownerId }?.keys?.sorted().orEmpty()
    }

    /**
     * Deletion, after the row delete: [ownerId]'s data deletions become
     * `releasing` records, which restrict their storage from here on and which
     * the release procedure deletes (D32). Returns whether it was written (also
     * when there was nothing to write); the deletions stay otherwise, and the
     * next start's owner reconciliation records them, the row being gone.
     */
    fun takeDataDeletions(ownerId: String): Boolean = synchronized(lock) {
        val state = loadedOrNull() ?: return false
        val taken = state.dataDeletions.filterValues { it == ownerId }.keys
        if (taken.isEmpty()) return true
        mutateContexts(keepOnFailure = false, deletions = { it.keys.removeAll(taken) }) { records ->
            taken.forEach { id -> records.putIfAbsent(id, ContextRecord(ownerId, ContextPhase.RELEASING)) }
        }
    }

    /**
     * The release procedure's first step (D32): `releasing` for [contextIds],
     * under a new generation, which it returns. Null when the write failed.
     */
    fun beginRelease(contextIds: Collection<String>): Long? = synchronized(lock) {
        val state = loadedOrNull() ?: return null
        val present = contextIds.filter { it in state.contexts }
        if (present.isEmpty()) return null
        val written = mutateContexts(keepOnFailure = false) { records ->
            present.forEach { id ->
                records[id] = records.getValue(id).copy(phase = ContextPhase.RELEASING, previousPhase = null, wakeTabId = null)
            }
        }
        if (!written) return null
        val gen = claimGeneration(present)
        updateStatus(present) { it.copy(generation = gen, failure = null) }
        gen
    }

    /**
     * Owner reconciliation (5.5), FULL start in normal mode: [existingOwnerIds]
     * are the containers in tab.db. Returns the contexts whose release is due.
     */
    fun reconcileOwners(existingOwnerIds: Set<String>): List<String> = synchronized(lock) {
        val state = loadedOrNull() ?: return emptyList()
        val due = mutableListOf<String>()
        // A data deletion whose container is still there was asked for with a
        // deletion that did not happen; one whose container is gone is due.
        // Only what an earlier process left: a deletion that began in this
        // one, its row maybe not deleted yet, settles its own.
        val deletions = state.dataDeletions.filterValues { it !in deletingOwners }
        mutateContexts(keepOnFailure = true, deletions = { it.keys.removeAll(deletions.keys) }) { records ->
            deletions.forEach { (id, ownerId) ->
                if (ownerId !in existingOwnerIds && id !in records) {
                    records[id] = ContextRecord(ownerId, ContextPhase.RELEASING)
                    due += id
                }
            }
            state.contexts.forEach { (id, record) ->
                if (record.ownerId in deletingOwners) return@forEach
                val ownerExists = record.ownerId != null && record.ownerId in existingOwnerIds
                when {
                    record.phase == ContextPhase.ORPHANED -> Unit
                    record.phase == ContextPhase.DELETION_PENDING && ownerExists -> {
                        // The process restarted since: a freeze it was in is over (5.6).
                        val back = when (val previous = record.previousPhase) {
                            null, ContextPhase.FREEZING, ContextPhase.FAILED -> ContextPhase.FROZEN
                            else -> previous
                        }
                        records[id] = record.copy(phase = back, previousPhase = null)
                    }
                    record.phase == ContextPhase.DELETION_PENDING || record.phase == ContextPhase.RELEASING -> {
                        records[id] = record.copy(phase = ContextPhase.RELEASING, previousPhase = null)
                        due += id
                    }
                    !ownerExists -> records[id] = record.copy(phase = ContextPhase.ORPHANED, previousPhase = null, wakeTabId = null)
                    else -> Unit
                }
            }
        }
        due
    }

    /**
     * The reconstruction (D23, 5.6), first durable step: [records] replace the
     * recovery record, in normal mode. From here a restart is safe. The engine
     * keeps `"*"` until [endWildcard]. Returns whether it was written.
     */
    fun installReconstruction(records: Map<String, ContextRecord>): Boolean = synchronized(lock) {
        val state = loadedOrNull() ?: return false
        if (!state.inRecovery) return false
        val before = Triple(state.contexts, state.recoveryOnDisk, state.recoverySince)
        val apply = {
            state.contexts = records
            state.recoveryOnDisk = false
            state.recoverySince = null
        }
        val restore = {
            state.contexts = before.first
            state.recoveryOnDisk = before.second
            state.recoverySince = before.third
        }
        apply()
        // An unconfirmed write puts the recovery record back on disk, unless it
        // cannot, and then the reconstruction is what it shows.
        if (writeOrRevert(state, apply, restore) != Written.YES) {
            logger.error("Could not write the reconstructed records; recovery stays")
            restore()
            return false
        }
        records.keys.forEach { contextId ->
            contextStatus[contextId] = ContextStatus(nextGeneration(contextKey(contextId)), EngineEnforcement.ENFORCED)
        }
        bumpRevision()
        true
    }

    /** The engine acknowledged lifting `"*"`: recovery is over in this process too. */
    fun endWildcard() = synchronized(lock) {
        val state = loadedOrNull() ?: return
        if (state.recoveryOnDisk || !state.wildcard) return
        state.wildcard = false
        bumpRevision()
    }

    /** Marks [tabId] as torn down by a freeze, so its pane lets go of the page first. */
    fun markFreezeTeardown(tabId: String, tearingDown: Boolean) {
        synchronized(lock) {
            if (tearingDown) freezeTeardowns.add(tabId) else freezeTeardowns.remove(tabId)
        }
    }

    /** Whether a freeze is tearing [tabId] down right now. */
    fun isFreezeTeardown(tabId: String): Boolean = synchronized(lock) { tabId in freezeTeardowns }

    private fun toJson(state: Loaded): JSONObject {
        val tabs = JSONObject()
        state.holds.forEach { (tabId, hold) ->
            if (hold.persistent && hold.committed) tabs.put(tabId, JSONObject().put(KEY_HOLD, HOLD_MANUAL))
        }
        val contexts = JSONObject()
        state.contexts.forEach { (contextId, record) ->
            val entry = JSONObject().put(KEY_PHASE, record.phase.json)
            record.ownerId?.let { entry.put(KEY_OWNER, it) }
            record.previousPhase?.let { entry.put(KEY_PREVIOUS, it.json) }
            record.wakeTabId?.let { entry.put(KEY_WAKE_TAB, it) }
            if (record.recovered) entry.put(KEY_RECOVERED, true)
            contexts.put(contextId, entry)
        }
        val json = JSONObject()
            .put(KEY_VERSION, FORMAT_VERSION)
            .put(KEY_MODE, if (state.recoveryOnDisk) MODE_RECOVERY else MODE_NORMAL)
            .put(KEY_TABS, tabs)
            .put(KEY_CONTEXTS, contexts)
        state.recoverySince?.let { json.put(KEY_SINCE, it) }
        if (state.dataDeletions.isNotEmpty()) {
            json.put(KEY_DATA_DELETIONS, JSONObject().also { entries -> state.dataDeletions.forEach { (id, owner) -> entries.put(id, owner) } })
        }
        return json
    }

    internal fun setStorageForTest(storage: JsonStore?) {
        synchronized(lock) {
            this.storage = storage
            loaded = null
            unloaded = null
            generations.clear()
            contextStatus.clear()
            freezeTeardowns.clear()
            deletingOwners.clear()
            holdsUnwritten = false
            lastGeneration = 0L
            revision = 0L
            _revisions.value = 0L
            _heldTabs.value = emptyMap()
        }
    }

    internal fun resetForTest() = setStorageForTest(null)

    const val FILE_NAME = "tab_lifecycle.json"

    /** Every non-default context, as GeckoView names it. */
    const val ALL_CONTEXTS = StorageController.ALL_SESSION_CONTEXTS

    private const val FORMAT_VERSION = 1
    private const val KEY_VERSION = "version"
    private const val KEY_MODE = "mode"
    private const val KEY_SINCE = "since"
    private const val KEY_TABS = "tabs"
    private const val KEY_HOLD = "hold"
    private const val KEY_CONTEXTS = "contexts"
    private const val KEY_PHASE = "phase"
    private const val KEY_OWNER = "owner"
    private const val KEY_PREVIOUS = "previous"
    private const val KEY_WAKE_TAB = "wakeTab"
    private const val KEY_RECOVERED = "recovered"
    private const val KEY_DATA_DELETIONS = "dataDeletions"
    private const val HOLD_MANUAL = "manual"
    private const val MODE_NORMAL = "normal"
    private const val MODE_RECOVERY = "recovery"
}
