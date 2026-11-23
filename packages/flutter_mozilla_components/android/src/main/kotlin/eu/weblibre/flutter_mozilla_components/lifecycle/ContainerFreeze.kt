/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.ContextReleaseResult
import eu.weblibre.flutter_mozilla_components.pigeons.EngineEnforcement
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeActivity
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeBlocker
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import eu.weblibre.flutter_mozilla_components.split.BrowserPanes
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.cancel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.support.base.log.logger.Logger

/** Push, as the freeze needs it (5.5, 5.8). */
interface ContextPush {
    /**
     * Removes the native push subscriptions whose scope names [contextId]
     * (E7) and unregisters them with the distributor. True when none is left.
     */
    suspend fun removeSubscriptions(contextId: String): Boolean

    /** The contexts that have native push subscriptions; null when unknown. */
    suspend fun contextsWithSubscriptions(): Set<String>?

    /**
     * Hands the deferred subscription changes of [contextIds] to Gecko (D25),
     * or, when null, every one whose context is no longer restricted.
     */
    suspend fun drainOutbox(contextIds: Collection<String>?)
}

/** Where freeze changes go: Dart's `onContextFreezeChange` and progress. */
interface ContextFreezeEvents {
    fun onChange()

    fun onProgress(ownerId: String, done: Int, total: Int)
}

/** What a container operation did; for messages only (D27). */
data class FreezeOutcome(
    val ownerId: String,
    /** The owner's phase afterwards, null when it has no restricted context. */
    val phase: ContextPhase?,
    val revision: Long,
    val failure: LifecycleFailure? = null,
    val blockers: List<FreezeBlocker> = emptyList(),
    val stillRunning: Set<FreezeActivity> = emptySet(),
    val unsettled: List<String> = emptyList(),
)

/** A freeze request from Dart's gated preflight (D21). */
data class FreezeRequest(
    val ownerId: String,
    val contextIds: List<String>,
    val memberTabIds: Set<String>,
    val stopMedia: Boolean,
    val discardPostResult: Boolean,
    val automatic: Boolean,
    /** The members whose form input the user agreed to lose. */
    val discardFormDataOf: Set<String> = emptySet(),
)

/**
 * Container freeze for one `Core` (5.3–5.6 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the barriers of a freeze,
 * Resume with its compensation (D33), the deletion of a frozen container (D28),
 * the one release procedure (D32), owner reconciliation and the reconstruction
 * after a damaged registry (D23).
 *
 * The record lives in the process-wide [TabLifecycleRegistry]; this only runs
 * the steps between its writes. Every step that depends on a phase runs after
 * that phase was written, and every engine command carries a fresh number from
 * [SessionContextCommands], so a later command always supersedes an earlier one
 * in Gecko (D22). Generations own registry writes: a Resume, a deletion or a
 * newer freeze takes the contexts over, and the older operation stops at its
 * next checkpoint without writing anything.
 *
 * Runs on the main thread, where the store's reducers and the panes run. A
 * components rebuild replaces this object without tearing the old one down, so
 * the outgoing one is [retire]d: its freezes become `failed` with the
 * restriction kept (3.5).
 */
class ContainerFreeze(
    private val store: BrowserStore,
    private val lifecycle: TabLifecycle,
    private val probe: SleepBlockerProbe,
    private val engine: SessionContextEngine,
    private val push: () -> ContextPush?,
    private val panes: () -> BrowserPanes?,
    private val events: ContextFreezeEvents,
    private val registry: TabLifecycleRegistry = TabLifecycleRegistry,
    private val restrictedSessions: RestrictedSessions = RestrictedSessions,
    private val downloads: DownloadContexts = DownloadContexts,
    private val undeliveredPush: UndeliveredPushCounts = UndeliveredPushCounts,
    private val formDataCheck: FormDataCheck = EngineFormDataCheck(),
    /**
     * Whether the container of an automatic freeze is still due (C2, 5.9):
     * [ContainerFreezeScheduler.isStillDue]. Without a scheduler nothing is.
     */
    private val stillDue: (FreezeRequest) -> Boolean = { false },
    /**
     * Whether an automatic freeze may unload its tabs' form input: its
     * container went unused for [TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS]
     * ([ContainerFreezeScheduler.isUnusedFor]). Without a scheduler it may not.
     */
    private val typedTextMayGo: (FreezeRequest) -> Boolean = { false },
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
    private val timeouts: Timeouts = Timeouts(),
) {
    /** Engine bounds (5.4); S1 confirmed the defaults with ample room. */
    data class Timeouts(
        val commandMillis: Long = 5_000,
        val quiescenceMillis: Long = 30_000,
        /** Beyond the engine's own quiescence bound, for the answer to arrive. */
        val answerMarginMillis: Long = 5_000,
        val clearMillis: Long = 30_000,
        val discoveryMillis: Long = 10_000,
        /** Between attempts of a failed registry write after a lift (D33). */
        val writeRetryMillis: List<Long> = listOf(200, 1_000),
        /** Background attempts once the compensation could not be confirmed. */
        val backgroundRetryMillis: List<Long> = listOf(5_000, 30_000, 120_000),
    )

    private val logger = Logger("ContainerFreeze")
    private val scope = CoroutineScope(SupervisorJob() + mainDispatcher)

    /** Freezes running, by owner, with the generation and contexts they own. */
    private val freezes = mutableMapOf<String, Pair<Long, List<String>>>()

    /** Resumes running, by owner, with the generation they own. */
    private val resumes = mutableMapOf<String, Long>()

    /**
     * Freezes asking for protected activity before their intent, by owner:
     * nothing is written or claimed yet, so a Resume or a deletion cancels one
     * by taking it off here, and it stops without writing anything.
     */
    private val preflights = mutableMapOf<String, Any>()

    init {
        // A push skipped for a restricted context changes only its count, so
        // the snapshot Dart shows has to be sent for it too (5.8).
        scope.launch { undeliveredPush.changes.drop(1).collect { events.onChange() } }
    }

    // --- Freeze ----------------------------------------------------------

    /** The barriers of 5.4 for [request]. Only Dart's gated preflight calls this (D21). */
    suspend fun freeze(request: FreezeRequest): FreezeOutcome = onMain(request.ownerId) {
        val owner = request.ownerId
        val contexts = request.contextIds.distinct().sorted()
        if (registry.inRecovery()) return@onMain outcome(owner, LifecycleFailure.RECOVERY_PENDING)
        if (contexts.isEmpty()) return@onMain outcome(owner, LifecycleFailure.CONTEXT_SHARED)
        // Activity that would refuse it at barrier 2, asked before anything is
        // written: from the intent on, the contexts count as restricted, and a
        // push that arrives while GeckoView answers the form check is consumed
        // for good, though the freeze is then given up. An automatic freeze's
        // pick ignores the store's form flag, so this is where a page with
        // form input stops it. Barrier 2 asks again, under the guard, for what
        // started since. From the checks below to the intent's write, nothing
        // suspends. A second request while one runs is ignored (5.4), and a
        // Resume ("Stop freezing and resume") or a deletion meanwhile cancels
        // this one, which has claimed nothing it could supersede yet.
        if (owner in freezes || owner in preflights) return@onMain outcome(owner)
        val preflight = Any()
        preflights[owner] = preflight
        var cancelled = false
        val early = try {
            blockersOf(contexts, confirmedActivity(request))
        } finally {
            cancelled = preflights[owner] !== preflight
            if (!cancelled) preflights.remove(owner)
        }
        if (cancelled) return@onMain outcome(owner, LifecycleFailure.SUPERSEDED)
        if (early.isNotEmpty()) return@onMain outcome(owner, LifecycleFailure.PROTECTED_ACTIVITY, blockers = early)
        if (registry.inRecovery()) return@onMain outcome(owner, LifecycleFailure.RECOVERY_PENDING)
        if (owner in freezes) return@onMain outcome(owner)

        val records = contexts.associateWith { registry.recordOf(it) }
        val foreign = records.values.any { record ->
            // A phase no Resume lifts: the context is on its way out.
            record != null && (record.ownerId != owner || record.phase !in RESUMABLE)
        }
        if (foreign) return@onMain outcome(owner, LifecycleFailure.CONTEXT_SHARED)
        // An automatic freeze only ever starts from nothing: a failed or
        // frozen container is the user's to retry or resume.
        if (request.automatic && records.values.any { it != null }) {
            return@onMain outcome(owner, LifecycleFailure.NO_LONGER_ELIGIBLE)
        }
        if (records.values.all { it?.phase == ContextPhase.FROZEN }) return@onMain outcome(owner)

        // Barrier 1: the native half of the preflight. Nothing to undo.
        membershipFailure(contexts, request.memberTabIds)?.let { failure ->
            return@onMain outcome(owner, failure)
        }
        if (request.automatic && !stillDue(request)) {
            return@onMain outcome(owner, LifecycleFailure.NO_LONGER_ELIGIBLE)
        }

        // Barrier 2: durable intent. From here B1/B2 hold every tab of the
        // contexts, and the window and download gates refuse for them.
        val gen = registry.beginFreeze(owner, contexts)
            ?: return@onMain outcome(owner, LifecycleFailure.NOT_PERSISTED)
        freezes[owner] = gen to contexts
        events.onChange()
        try {
            runFreeze(request, contexts, gen, previous = records.filterValues { it != null }.mapValues { it.value!! })
        } catch (e: CancellationException) {
            // Retired: retire() wrote the failure while the restriction stays.
            throw e
        } catch (e: Exception) {
            // Something it called threw. Whether the engine restricts the
            // contexts is not known, so they stay restricted, `failed` rather
            // than `freezing` with no operation behind it: Retry or Resume.
            logger.error("Freeze of $owner stopped by an error", e)
            registry.setPhase(contexts, gen, ContextPhase.FAILED)
            throw e
        } finally {
            if (freezes[owner]?.first == gen) freezes.remove(owner)
            // A tab on screen without a page shows the placeholder its phase asks for.
            panes()?.reconcileNow()
            events.onChange()
        }
    }

    /**
     * Barriers 2 (its re-checks) to 6. [previous] holds the records the
     * contexts had before (a Retry of a failed freeze): a refusal puts those
     * back, restricted, and only contexts restricted by this operation are
     * rolled back or forgotten.
     */
    private suspend fun runFreeze(
        request: FreezeRequest,
        contexts: List<String>,
        gen: Long,
        previous: Map<String, ContextRecord>,
    ): FreezeOutcome {
        val owner = request.ownerId
        val fresh = contexts.filter { it !in previous }
        val abandon: suspend (LifecycleFailure) -> Boolean = { failure ->
            abandonFreeze(contexts, gen, failure, previous)
        }
        // Barrier 2's re-checks, under the guard and before any traffic is cut:
        // a tab, a call or an upload started after Dart's preflight is caught
        // here rather than cut off by the restriction.
        membershipFailure(contexts, request.memberTabIds)?.let { found ->
            val failure = if (found == LifecycleFailure.CONTEXT_SHARED) LifecycleFailure.MEMBERSHIP_CHANGED else found
            abandon(failure)
            return outcome(owner, failure)
        }
        val blockers = blockersOf(contexts, confirmedActivity(request))
        if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
        if (blockers.isNotEmpty()) {
            abandon(LifecycleFailure.PROTECTED_ACTIVITY)
            return outcome(owner, LifecycleFailure.PROTECTED_ACTIVITY, blockers = blockers)
        }
        // Used while GeckoView answered about form input: defer (5.9).
        if (request.automatic && !stillDue(request)) {
            abandon(LifecycleFailure.NO_LONGER_ELIGIBLE)
            return outcome(owner, LifecycleFailure.NO_LONGER_ELIGIBLE)
        }

        // Barrier 3: the engine restriction, acknowledged.
        val install = SessionContextCommands.next()
        val installed = command { engine.install(contexts, install) }
        if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
        if (!acknowledged(installed, contexts, install, restricted = true)) {
            // Uncertain: the install may have partly applied, or its answer may
            // be late. A lift with a higher number supersedes it for good. Only
            // contexts this operation restricted are lifted: the others were
            // restricted before and stay so (a newer install can only add).
            registry.setEnforcement(fresh, EngineEnforcement.UNCERTAIN)
            return rollBack(owner, contexts, fresh, gen, LifecycleFailure.ENGINE_REFUSED, abandon)
        }
        registry.setEnforcement(contexts, EngineEnforcement.ENFORCED)

        // An automatic freeze re-checks right before the teardown, the last
        // point where nothing is lost by deferring: the pages are still loaded.
        // And again right before each tab's teardown, after its flush and form
        // check: a member selected or kept awake meanwhile keeps its page.
        val due = { !request.automatic || stillDue(request) }
        if (!due()) {
            return rollBack(owner, contexts, fresh, gen, LifecycleFailure.NO_LONGER_ELIGIBLE, abandon)
        }

        // Barrier 4: preservation and teardown, from the live store, so a tab
        // that appeared after barrier 2 (a window request already pending) is
        // torn down too. Tabs get no sleep hold: the restriction holds them.
        val attempted = mutableSetOf<String>()
        var done = 0
        while (true) {
            if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
            val resident = store.state.tabs.filter { tab ->
                tab.contextId in contexts && tab.engineState.engineSession != null && tab.id !in attempted
            }
            val tab = resident.firstOrNull() ?: break
            attempted += tab.id
            val total = done + resident.size
            val result = lifecycle.unloadForFreeze(tab.id, confirmedActivity(request)(tab.id), stillDue = due) { registry.owns(contexts, gen) }
            val failure = when (result.outcome) {
                FreezeUnload.UNLOADED, FreezeUnload.GONE -> null
                FreezeUnload.SUPERSEDED -> return outcome(owner, LifecycleFailure.SUPERSEDED)
                // The tabs unloaded before it stay unloaded, as ordinary
                // unloaded tabs once the lift is acknowledged.
                FreezeUnload.NO_LONGER_DUE ->
                    return rollBack(owner, contexts, fresh, gen, LifecycleFailure.NO_LONGER_ELIGIBLE, abandon)
                FreezeUnload.FLUSH_TIMED_OUT -> LifecycleFailure.FLUSH_TIMED_OUT
                FreezeUnload.FLUSH_FAILED -> LifecycleFailure.FLUSH_FAILED
                FreezeUnload.SESSION_CHANGED -> LifecycleFailure.SESSION_CHANGED
                FreezeUnload.PROTECTED_ACTIVITY -> LifecycleFailure.PROTECTED_ACTIVITY
            }
            if (failure != null) {
                if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
                registry.setPhase(contexts, gen, ContextPhase.FAILED, failure)
                return outcome(owner, failure, blockers = result.blockers.map { FreezeBlocker(tab.id, null, it) })
            }
            done += 1
            events.onProgress(owner, done, total)
        }

        // Barrier 5: quiescence, acknowledged. Only now, so the engine never
        // waits for work it would have to cause itself.
        val wait = SessionContextCommands.next()
        val quiet = withTimeoutOrNull(timeouts.quiescenceMillis + timeouts.answerMarginMillis) {
            attempt("Quiescence wait failed") { engine.awaitQuiescence(contexts, wait, timeouts.quiescenceMillis) }
        }
        if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
        val acks = quiet?.filter { it.cmd == wait }?.associateBy { it.contextId }
        val unsettled = contexts.filter { acks?.get(it)?.status != QuiescenceStatus.QUIESCENT }
        if (unsettled.isNotEmpty()) {
            val superseded = unsettled.any {
                acks?.get(it)?.status == QuiescenceStatus.SUPERSEDED || acks?.get(it)?.status == QuiescenceStatus.NOT_RESTRICTED
            }
            // A command this operation did not send changed the contexts: what
            // the engine enforces is not known any more.
            if (superseded) registry.setEnforcement(unsettled, EngineEnforcement.UNCERTAIN)
            val failure = if (superseded) LifecycleFailure.SUPERSEDED else LifecycleFailure.QUIESCENCE_TIMED_OUT
            registry.setPhase(contexts, gen, ContextPhase.FAILED, failure)
            return outcome(
                owner,
                failure,
                stillRunning = unsettled.flatMapTo(mutableSetOf()) { acks?.get(it)?.leftovers.orEmpty() },
                unsettled = unsettled,
            )
        }
        val running = downloadBlockers(contexts)
        if (running.isNotEmpty()) {
            registry.setPhase(contexts, gen, ContextPhase.FAILED, LifecycleFailure.PROTECTED_ACTIVITY)
            return outcome(owner, LifecycleFailure.PROTECTED_ACTIVITY, blockers = running)
        }

        // Barrier 6: commit. A failed write leaves `freezing` on disk, which
        // the next start turns into `frozen` as well, so the freeze stands;
        // the contexts record `notPersisted` like any phase left unwritten.
        // Unless no write of the intent was confirmed durable either: a power
        // loss could then bring the contexts back unrestricted, so the freeze
        // is reported incomplete, its restriction kept, until a Retry writes it.
        if (!registry.setPhase(contexts, gen, ContextPhase.FROZEN) && !registry.isDurablyRecorded(contexts)) {
            if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
            registry.setPhase(contexts, gen, ContextPhase.FAILED, LifecycleFailure.NOT_PERSISTED)
            return outcome(owner, LifecycleFailure.NOT_PERSISTED)
        }
        return outcome(owner)
    }

    /**
     * Lifts the contexts this operation restricted ([fresh]) with a command
     * that supersedes its install, and abandons the freeze with [failure] once
     * the lift is acknowledged. Contexts restricted before stay so (a newer
     * install can only add). Unacknowledged, the contexts stay restricted as
     * `failed` (D22).
     */
    private suspend fun rollBack(
        owner: String,
        contexts: List<String>,
        fresh: List<String>,
        gen: Long,
        failure: LifecycleFailure,
        abandon: suspend (LifecycleFailure) -> Boolean,
    ): FreezeOutcome {
        val rollback = SessionContextCommands.next()
        val lifted = if (fresh.isEmpty()) emptyList() else command { engine.lift(fresh, rollback) }
        if (!registry.owns(contexts, gen)) return outcome(owner, LifecycleFailure.SUPERSEDED)
        return if (fresh.isEmpty() || acknowledged(lifted, fresh, rollback, restricted = false)) {
            registry.setEnforcement(fresh, EngineEnforcement.LIFTED)
            abandon(failure)
            outcome(owner, failure)
        } else {
            registry.setEnforcement(fresh, EngineEnforcement.UNCERTAIN)
            registry.setPhase(contexts, gen, ContextPhase.FAILED, LifecycleFailure.ROLLBACK_UNCONFIRMED)
            outcome(owner, LifecycleFailure.ROLLBACK_UNCONFIRMED)
        }
    }

    /**
     * Abandons the freeze [gen] of [contexts] ([TabLifecycleRegistry.abandonFreeze]),
     * giving those in [previous] their records back, and settles the contexts it
     * left unrestricted as a Resume settles the ones it lifts ([afterRelease]):
     * a push subscription change deferred meanwhile goes to Gecko now, since
     * no Resume is left to hand it over (D25). Returns whether it was written.
     */
    private suspend fun abandonFreeze(
        contexts: List<String>,
        gen: Long,
        failure: LifecycleFailure,
        previous: Map<String, ContextRecord>,
    ): Boolean {
        val written = registry.abandonFreeze(contexts, gen, failure, restore = previous)
        if (written) afterRelease(contexts.filter { it !in previous && !registry.isRestricted(it) })
        return written
    }

    /**
     * What the user agreed to cut off, per tab, as of this check. An automatic
     * freeze never asks: it cuts off nothing but form input of a container
     * unused for long enough ([typedTextMayGo]), asked again at each check. A
     * manual one cuts off form input only in the tabs the user was asked about.
     */
    private fun confirmedActivity(request: FreezeRequest): (tabId: String) -> Set<ProtectedActivity> {
        if (request.automatic) {
            val confirmed = if (typedTextMayGo(request)) setOf(ProtectedActivity.FORM_DATA) else emptySet()
            return { confirmed }
        }
        val confirmed = buildSet {
            if (request.stopMedia) add(ProtectedActivity.MEDIA)
            if (request.discardPostResult) add(ProtectedActivity.POST_RESULT)
        }
        return { tabId -> if (tabId in request.discardFormDataOf) confirmed + ProtectedActivity.FORM_DATA else confirmed }
    }

    /**
     * The barrier 1 checks: the members Dart saw and nothing else in the
     * contexts, every member running in one of them, and no external window
     * (D18). A member outside them (an extension's tab, which runs in the
     * default storage, filed with the container) would keep running: the
     * teardown and the quiescence reach only the contexts.
     */
    private fun membershipFailure(contexts: List<String>, members: Set<String>): LifecycleFailure? {
        val state = store.state
        if (state.customTabs.any { it.contextId in contexts }) return LifecycleFailure.OPEN_IN_EXTERNAL_WINDOW
        if (state.tabs.any { it.contextId in contexts && it.id !in members }) return LifecycleFailure.CONTEXT_SHARED
        if (state.tabs.any { it.id in members && it.contextId !in contexts }) return LifecycleFailure.MEMBER_OUTSIDE_CONTEXTS
        return null
    }

    /**
     * Protected activity of every loaded tab of [contexts] (D13), with the form
     * input as GeckoView reports it now, plus running downloads (5.11). No
     * answer counts as form input, as at the teardown
     * ([TabLifecycle.unloadForFreeze]): passed here, the same silence there
     * would leave the freeze `failed` with its first tabs already unloaded.
     */
    private suspend fun blockersOf(
        contexts: List<String>,
        confirmed: (tabId: String) -> Set<ProtectedActivity>,
    ): List<FreezeBlocker> {
        val tabs = store.state.tabs.filter { it.contextId in contexts && it.engineState.engineSession != null }
        val confirmedOf = tabs.associate { it.id to confirmed(it.id) }
        // Form input the user agreed to lose needs no answer from GeckoView.
        val formData = coroutineScope {
            tabs.filter { ProtectedActivity.FORM_DATA !in confirmedOf.getValue(it.id) }.map { tab ->
                async { tab.id to tab.engineState.engineSession?.let { formDataCheck.containsFormData(it) } }
            }.awaitAll().toMap()
        }
        val state = store.state
        val tabBlockers = tabs.flatMap { tab ->
            val current = state.tabs.firstOrNull { it.id == tab.id } ?: return@flatMap emptyList()
            val tabConfirmed = confirmedOf.getValue(tab.id)
            val answer = if (ProtectedActivity.FORM_DATA in tabConfirmed) null else formData[tab.id] ?: true
            probe.blockersOf(state, current).withFormData(answer)
                // Downloads are reported per download below.
                .filter { it != ProtectedActivity.DOWNLOAD && it !in tabConfirmed }
                .map { FreezeBlocker(tab.id, null, it) }
        }
        return tabBlockers + downloadBlockers(contexts)
    }

    /**
     * Running or starting downloads of [contexts], or of unknown context
     * (5.11). Paused and failed ones are not blockers: the gate keeps them from
     * resuming.
     */
    private fun downloadBlockers(contexts: List<String>): List<FreezeBlocker> =
        store.state.downloads.values
            .filter { it.status == DownloadState.Status.DOWNLOADING || it.status == DownloadState.Status.INITIATED }
            .mapNotNull { download ->
                when (val context = downloads.contextOf(download.id)) {
                    null -> FreezeBlocker(null, download.id, ProtectedActivity.UNATTRIBUTED_DOWNLOAD)
                    in contexts -> FreezeBlocker(null, download.id, ProtectedActivity.DOWNLOAD)
                    else -> null
                }
            }

    // --- Resume ----------------------------------------------------------

    /**
     * Resume (5.5, step 2 onward): `resuming` written, an acknowledged lift,
     * one write that removes the lifted contexts' records, then the push outbox
     * drained and [wakeTabId] woken. Routing is checked by Dart before (D34).
     * Also "Stop freezing and resume": its new generation stops a running freeze.
     */
    suspend fun resume(ownerId: String, wakeTabId: String?): FreezeOutcome = onMain(ownerId) {
        if (registry.inRecovery()) return@onMain outcome(ownerId, LifecycleFailure.RECOVERY_PENDING)
        // A freeze still asking for protected activity has claimed nothing a
        // generation could supersede: taken off, it stops before its intent.
        preflights.remove(ownerId)
        val contexts = registry.contextsOf(ownerId).filter { registry.recordOf(it)?.phase in RESUMABLE }
        if (contexts.isEmpty()) {
            wakeTabId?.let(::wakeIfRunnable)
            return@onMain outcome(ownerId)
        }
        val gen = registry.beginResume(contexts, wakeTabId)
            ?: return@onMain outcome(ownerId, LifecycleFailure.NOT_PERSISTED)
        resumes[ownerId] = gen
        events.onChange()
        try {
            runResume(ownerId, contexts, gen, wakeTabId)
        } finally {
            if (resumes[ownerId] == gen) resumes.remove(ownerId)
            events.onChange()
        }
    }

    private suspend fun runResume(ownerId: String, contexts: List<String>, gen: Long, wakeTabId: String?): FreezeOutcome {
        val lift = SessionContextCommands.next()
        val acks = command { engine.lift(contexts, lift) }
        if (!registry.owns(contexts, gen)) return outcome(ownerId, LifecycleFailure.SUPERSEDED)
        val lifted = appliedAmong(acks, contexts, lift, restricted = false)
        val unacknowledged = contexts - lifted.toSet()
        if (unacknowledged.isNotEmpty()) {
            // Still `resuming`; what the engine does is not known.
            registry.setEnforcement(unacknowledged, EngineEnforcement.UNCERTAIN)
            registry.setFailure(unacknowledged, gen, LifecycleFailure.ROLLBACK_UNCONFIRMED)
        }
        if (lifted.isEmpty()) return outcome(ownerId, LifecycleFailure.ROLLBACK_UNCONFIRMED, unsettled = unacknowledged)
        registry.setEnforcement(lifted, EngineEnforcement.LIFTED)

        val removed = removeAfterLift(lifted, gen)
        if (removed == null) {
            if (!registry.owns(lifted, gen)) return outcome(ownerId, LifecycleFailure.SUPERSEDED)
            return outcome(ownerId, LifecycleFailure.NOT_PERSISTED, unsettled = contexts)
        }
        afterRelease(removed)
        wakeTabId?.let(::wakeIfRunnable)
        panes()?.reconcileNow()
        return outcome(
            ownerId,
            if (unacknowledged.isEmpty()) null else LifecycleFailure.ROLLBACK_UNCONFIRMED,
            unsettled = unacknowledged,
        )
    }

    /**
     * Wakes [tabId] for a Resume, once nothing restricts its context any more.
     * A Resume that lifted only some of the owner's contexts leaves a tab of
     * the others its own hold (D26): woken now, a later Resume would load it
     * without the Wake the user was told did not happen.
     */
    private fun wakeIfRunnable(tabId: String) {
        val tab = store.state.tabs.firstOrNull { it.id == tabId } ?: return
        if (registry.isRestricted(tab.contextId)) return
        lifecycle.wake(tabId)
    }

    /**
     * The record removal after an acknowledged lift (D33): retried, then the
     * restriction re-installed for exactly those contexts so engine and record
     * agree again. Returns the removed contexts, or null when the records stay
     * (with the enforcement each ended in), or when a newer operation took the
     * contexts over meanwhile.
     */
    private suspend fun removeAfterLift(lifted: List<String>, gen: Long): List<String>? {
        registry.removeRecords(lifted, gen)?.let { return it }
        for (pause in timeouts.writeRetryMillis) {
            delay(pause)
            if (!registry.owns(lifted, gen)) return null
            registry.removeRecords(lifted, gen)?.let { return it }
        }
        val reinstall = SessionContextCommands.next()
        val acks = command { engine.install(lifted, reinstall) }
        // A newer operation (a second Resume) took the contexts over while the
        // engine answered: what it records stands, not this answer.
        if (!registry.owns(lifted, gen)) return null
        if (acknowledged(acks, lifted, reinstall, restricted = true)) {
            registry.setEnforcement(lifted, EngineEnforcement.ENFORCED)
            registry.setFailure(lifted, gen, LifecycleFailure.NOT_PERSISTED)
            return null
        }
        // The reinstall was not confirmed, so whether the engine runs the
        // contexts is not known: say so. The records stay, and the next start
        // restricts at init. A background retry lifts again, and removes the
        // records only once that lift is confirmed: removed while the
        // reinstall took effect, they would leave pages blocked with no
        // record to resume.
        registry.setEnforcement(lifted, EngineEnforcement.UNCERTAIN)
        registry.setFailure(lifted, gen, LifecycleFailure.NOT_PERSISTED)
        scope.launch {
            for (pause in timeouts.backgroundRetryMillis) {
                delay(pause)
                if (!registry.owns(lifted, gen)) return@launch
                val relift = SessionContextCommands.next()
                val reliftAcks = command { engine.lift(lifted, relift) }
                if (!registry.owns(lifted, gen)) return@launch
                if (!acknowledged(reliftAcks, lifted, relift, restricted = false)) continue
                registry.setEnforcement(lifted, EngineEnforcement.LIFTED)
                events.onChange()
                val removed = registry.removeRecords(lifted, gen) ?: continue
                afterRelease(removed)
                panes()?.reconcileNow()
                events.onChange()
                return@launch
            }
        }
        return null
    }

    /**
     * Steps 3–4 of Resume, and the end of a release: the deferred subscription
     * changes reach Gecko, the skipped-message count resets, and tabs woken
     * while restricted lose their empty page so their kept state restores.
     * Tabs' own sleep holds stay (D26).
     */
    private suspend fun afterRelease(contextIds: List<String>) {
        if (contextIds.isEmpty()) return
        undeliveredPush.reset(contextIds)
        restrictedSessions.release(contextIds).forEach { lifecycle.discardRestrictedSession(it) }
        attempt("Could not drain the push outbox; the next start does") { push()?.drainOutbox(contextIds) }
    }

    // --- Deletion and release --------------------------------------------

    /**
     * Deletion, first half (D28): before the row delete. Refused in recovery:
     * the wildcard restricts the owner's contexts without a record of them, so
     * nothing would be recorded, and nothing released once the row is gone.
     * [deleteDataOf] is storage of the owner without a record whose data the
     * user asked to delete with it (D29): written as a data deletion in the
     * same write, which restricts nothing until the row is gone, so that a
     * process ending after the row delete still has it to retry.
     */
    suspend fun beginDeletion(ownerId: String, deleteDataOf: List<String> = emptyList()): FreezeOutcome = onMain(ownerId) {
        if (registry.inRecovery()) return@onMain outcome(ownerId, LifecycleFailure.RECOVERY_PENDING)
        val written = registry.beginDeletion(ownerId, deleteDataOf)
        // Its new generations stop a running freeze or Resume of the owner at
        // the next checkpoint. Unwritten, nothing took the contexts over: the
        // operation runs on, and stays tracked so that a second request is
        // still ignored and [retire] still settles it.
        if (written) {
            freezes.remove(ownerId)
            resumes.remove(ownerId)
            preflights.remove(ownerId)
        }
        events.onChange()
        outcome(ownerId, if (written) null else LifecycleFailure.NOT_PERSISTED)
    }

    /** The row delete did not happen. */
    suspend fun cancelDeletion(ownerId: String): FreezeOutcome = onMain(ownerId) {
        val written = registry.cancelDeletion(ownerId)
        events.onChange()
        outcome(ownerId, if (written) null else LifecycleFailure.NOT_PERSISTED)
    }

    /**
     * Deletion, second half: the release procedure for each context, also
     * one whose release was already pending (its record not written as
     * `deletionPending`, which it does not need), and for the storage of each
     * data deletion [beginDeletion] wrote, recorded `releasing` first: its push
     * subscriptions go, the clear is acknowledged, and every start retries
     * what is left. [FreezeOutcome.unsettled] names those left.
     */
    suspend fun completeDeletion(ownerId: String): FreezeOutcome = onMain(ownerId) {
        // Unwritten, the next start records them: the row is gone.
        val untaken = if (registry.takeDataDeletions(ownerId)) emptyList() else registry.dataDeletionsOf(ownerId)
        events.onChange()
        val pending = registry.contextsOf(ownerId).filter {
            registry.recordOf(it)?.phase.let { phase ->
                phase == ContextPhase.DELETION_PENDING || phase == ContextPhase.RELEASING
            }
        }
        val results = release(pending) + untaken.map { ContextReleaseResult(it, false, LifecycleFailure.NOT_PERSISTED, false) }
        val failed = results.filterNot { it.released }
        outcome(
            ownerId,
            failed.firstNotNullOfOrNull { it.failure },
            unsettled = failed.map { it.contextId },
        )
    }

    /**
     * The one release procedure (D32): `releasing` written, the context's push
     * subscriptions removed and its data cleared with an acknowledgment, then,
     * only when both succeeded, an acknowledged lift and the record removed.
     * Anything else leaves it `releasing`: restricted at init, push consumed,
     * retried on every FULL start. A context without a record is released at
     * once (its caller's own cleanup applies).
     */
    suspend fun release(contextIds: List<String>): List<ContextReleaseResult> = onMain(
        { contextIds.distinct().map { ContextReleaseResult(it, false, LifecycleFailure.COMPONENTS_REPLACED, false) } },
    ) {
        val contexts = contextIds.distinct()
        if (contexts.isEmpty()) return@onMain emptyList()
        if (registry.inRecovery()) {
            return@onMain contexts.map { ContextReleaseResult(it, false, LifecycleFailure.RECOVERY_PENDING, false) }
        }
        val recorded = contexts.filter { registry.recordOf(it) != null }
        // Nothing of theirs is cleared here: the caller's own cleanup applies.
        val unrecorded = (contexts - recorded.toSet()).map { ContextReleaseResult(it, true, null, false) }
        if (recorded.isEmpty()) return@onMain unrecorded
        val gen = registry.beginRelease(recorded)
            ?: return@onMain unrecorded + recorded.map { ContextReleaseResult(it, false, LifecycleFailure.NOT_PERSISTED, false) }
        events.onChange()
        try {
            val unenforced = enforceBeforeRelease(recorded, gen)
            unrecorded + unenforced.map { ContextReleaseResult(it, false, LifecycleFailure.ENGINE_REFUSED, false) } +
                coroutineScope {
                    (recorded - unenforced.toSet()).map { contextId -> async { releaseOne(contextId, gen) } }.awaitAll()
                }
        } finally {
            events.onChange()
        }
    }

    /**
     * Installs the restriction, acknowledged, for those of [contexts] the
     * engine does not restrict yet: storage of a container that was never
     * frozen, whose data is deleted with it, or one a lift left unrestricted.
     * Its service workers and connections must not run while the data is
     * deleted, nor after a clear that fails until the next start restricts it
     * at init. Returns those the engine did not confirm: nothing of theirs is
     * cleaned up, they stay `releasing` (refused, [LifecycleFailure.ENGINE_REFUSED]),
     * and the next start, which restricts them at init, releases them.
     */
    private suspend fun enforceBeforeRelease(contexts: List<String>, gen: Long): List<String> {
        val lifted = contexts.filter { registry.statusOf(it)?.enforcement != EngineEnforcement.ENFORCED }
        if (lifted.isEmpty()) return emptyList()
        val install = SessionContextCommands.next()
        val acks = command { engine.install(lifted, install) }
        val applied = appliedAmong(acks, lifted, install, restricted = true)
        val refused = lifted - applied.toSet()
        if (!registry.owns(lifted, gen)) return lifted
        registry.setEnforcement(applied, EngineEnforcement.ENFORCED)
        registry.setEnforcement(refused, EngineEnforcement.UNCERTAIN)
        registry.setFailure(refused, gen, LifecycleFailure.ENGINE_REFUSED)
        return refused
    }

    private suspend fun releaseOne(contextId: String, gen: Long): ContextReleaseResult {
        val (subscriptionsRemoved, cleared) = removeSubscriptionsAndClear(contextId)
        if (!registry.owns(listOf(contextId), gen)) return ContextReleaseResult(contextId, false, LifecycleFailure.SUPERSEDED, cleared)
        if (!subscriptionsRemoved || !cleared) {
            registry.setFailure(listOf(contextId), gen, LifecycleFailure.CLEANUP_FAILED)
            return ContextReleaseResult(contextId, false, LifecycleFailure.CLEANUP_FAILED, cleared)
        }
        val lift = SessionContextCommands.next()
        val acks = command { engine.lift(listOf(contextId), lift) }
        if (!registry.owns(listOf(contextId), gen)) return ContextReleaseResult(contextId, false, LifecycleFailure.SUPERSEDED, true)
        if (!acknowledged(acks, listOf(contextId), lift, restricted = false)) {
            registry.setEnforcement(listOf(contextId), EngineEnforcement.UNCERTAIN)
            registry.setFailure(listOf(contextId), gen, LifecycleFailure.ROLLBACK_UNCONFIRMED)
            return ContextReleaseResult(contextId, false, LifecycleFailure.ROLLBACK_UNCONFIRMED, true)
        }
        registry.setEnforcement(listOf(contextId), EngineEnforcement.LIFTED)
        val removed = removeAfterLift(listOf(contextId), gen)
            ?: return ContextReleaseResult(
                contextId,
                false,
                if (registry.owns(listOf(contextId), gen)) LifecycleFailure.NOT_PERSISTED else LifecycleFailure.SUPERSEDED,
                true,
            )
        afterRelease(removed)
        return ContextReleaseResult(contextId, true, null, true)
    }

    /**
     * Removes [contextId]'s push subscriptions and clears its data with an
     * acknowledgment: whether each succeeded.
     */
    private suspend fun removeSubscriptionsAndClear(contextId: String): Pair<Boolean, Boolean> {
        val subscriptionsRemoved = attempt("Could not remove the push subscriptions of $contextId") {
            push()?.removeSubscriptions(contextId)
        } ?: false
        val cleared = withTimeoutOrNull(timeouts.clearMillis) {
            attempt("Could not clear the data of $contextId") { engine.clearData(contextId) } != null
        } ?: false
        return subscriptionsRemoved to cleared
    }

    /**
     * Owner reconciliation (5.5), FULL start in normal mode, at the gate's
     * seeding. Releases that are due run in the background afterwards.
     */
    suspend fun reconcileOwners(existingOwnerIds: Set<String>) = onMain({}) {
        if (!registry.inRecovery()) {
            val due = registry.reconcileOwners(existingOwnerIds)
            if (due.isNotEmpty()) scope.launch { release(due) }
        }
        events.onChange()
    }

    /**
     * The reconstruction (D23, 5.6, step 2), recovery mode only: [owners]'
     * contexts become `frozen` (flagged recovered), every other context with
     * a service-worker registration (E10) or a push subscription becomes
     * `orphaned`, and the rest, [unfreezable] included, are released. The
     * records are written in normal mode first, so a restart from here is safe;
     * then the contexts are installed explicitly and `"*"` is lifted, both
     * acknowledged. Anything unconfirmed keeps recovery (in memory) until the
     * next start.
     */
    suspend fun reconstruct(owners: Map<String, List<String>>, unfreezable: Set<String>) = onMain({}) {
        check(registry.inRecovery()) { "Reconstruction is for recovery mode only" }
        val withWorkers = withTimeoutOrNull(timeouts.discoveryMillis) {
            attempt("Could not list the contexts with service workers; recovery stays") {
                engine.contextsWithServiceWorkers()
            }
        } ?: return@onMain
        val withSubscriptions = attempt("Could not list the push subscriptions") { push()?.contextsWithSubscriptions() }
            ?: run {
                logger.warn("Push subscriptions unknown; recovery stays")
                return@onMain
            }

        val records = mutableMapOf<String, ContextRecord>()
        owners.forEach { (ownerId, contexts) ->
            contexts.forEach { records[it] = ContextRecord(ownerId, ContextPhase.FROZEN, recovered = true) }
        }
        (withWorkers + withSubscriptions).forEach { contextId ->
            if (contextId !in records && contextId !in unfreezable) {
                records[contextId] = ContextRecord(null, ContextPhase.ORPHANED)
            }
        }
        if (!registry.installReconstruction(records)) return@onMain
        events.onChange()

        val explicit = records.keys.sorted()
        val installed = explicit.isEmpty() || run {
            val install = SessionContextCommands.next()
            acknowledged(command { engine.install(explicit, install) }, explicit, install, restricted = true)
        }
        if (!installed) {
            registry.setEnforcement(explicit, EngineEnforcement.UNCERTAIN)
            logger.warn("The reconstructed contexts were not confirmed installed; every context stays restricted until the next start")
            return@onMain
        }
        val liftAll = SessionContextCommands.next()
        val wildcard = listOf(TabLifecycleRegistry.ALL_CONTEXTS)
        if (acknowledged(command { engine.lift(wildcard, liftAll) }, wildcard, liftAll, restricted = false)) {
            registry.endWildcard()
            // A tab on screen whose context no record restricts now loads:
            // the panes follow held tabs, not the registry.
            panes()?.reconcileNow()
            // Subscription changes deferred under the wildcard, for contexts
            // it alone restricted: the start's drain skipped them, and no
            // Resume or release will reach them. Those of contexts still
            // restricted stay in the outbox.
            attempt("Could not drain the push outbox; the next start does") { push()?.drainOutbox(null) }
        } else {
            logger.warn("Lifting \"*\" was not confirmed; every context stays restricted until the next start")
        }
        events.onChange()
    }

    // --- Lifetime --------------------------------------------------------

    /**
     * Stops this `Core`'s operations for good (3.5): every running freeze
     * becomes `failed`, written, with the restriction left in place (the
     * process did not die, so pages may still run). A running Resume stays
     * `resuming`, which the new `Core` shows as not finished.
     */
    fun retire() {
        freezes.forEach { (_, owned) ->
            val (gen, contexts) = owned
            registry.setPhase(contexts, gen, ContextPhase.FAILED, LifecycleFailure.COMPONENTS_REPLACED)
        }
        resumes.forEach { (ownerId, gen) ->
            registry.setFailure(registry.contextsOf(ownerId), gen, LifecycleFailure.COMPONENTS_REPLACED)
        }
        freezes.clear()
        resumes.clear()
        preflights.clear()
        scope.cancel()
    }

    // --- Helpers ---------------------------------------------------------

    /** An engine command bounded by its timeout; null when it failed or timed out. */
    private suspend fun command(block: suspend () -> List<CommandAck>): List<CommandAck>? =
        withTimeoutOrNull(timeouts.commandMillis) { attempt("Engine command failed") { block() } }

    /**
     * [block]'s value, or null (logged) when it threw. Cancellation is never
     * caught: a retired operation has to stop, not carry on with a null.
     */
    private suspend inline fun <T> attempt(what: String, block: () -> T): T? = try {
        block()
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        logger.warn(what, e)
        null
    }

    /** Those of [contexts] that answered [cmd] as applied, with [restricted]. */
    private fun appliedAmong(acks: List<CommandAck>?, contexts: List<String>, cmd: Long, restricted: Boolean): List<String> {
        val byContext = acks?.filter { it.cmd == cmd }?.associateBy { it.contextId } ?: return emptyList()
        return contexts.filter { byContext[it]?.let { ack -> ack.applied && ack.restricted == restricted } == true }
    }

    /** Whether every one of [contexts] answered [cmd] as applied, with [restricted]. */
    private fun acknowledged(acks: List<CommandAck>?, contexts: List<String>, cmd: Long, restricted: Boolean): Boolean =
        acks != null && appliedAmong(acks, contexts, cmd, restricted).size == contexts.size

    private fun phaseOf(ownerId: String): ContextPhase? = registry.ownerPhase(ownerId)

    private fun outcome(
        ownerId: String,
        failure: LifecycleFailure? = null,
        blockers: List<FreezeBlocker> = emptyList(),
        stillRunning: Set<FreezeActivity> = emptySet(),
        unsettled: List<String> = emptyList(),
    ) = FreezeOutcome(ownerId, phaseOf(ownerId), registry.revision(), failure, blockers, stillRunning, unsettled)

    /**
     * Runs [block] in this object's scope on the main thread. When this object
     * is retired meanwhile, answers [retired] instead; the caller's own
     * cancellation goes on.
     */
    private suspend fun <T> onMain(retired: () -> T, block: suspend CoroutineScope.() -> T): T {
        if (!scope.isActive) return retired()
        val operation = scope.async(block = block)
        return try {
            operation.await()
        } catch (e: CancellationException) {
            if (scope.isActive) throw e
            retired()
        }
    }

    private suspend fun onMain(ownerId: String, block: suspend CoroutineScope.() -> FreezeOutcome): FreezeOutcome =
        onMain({ outcome(ownerId, LifecycleFailure.COMPONENTS_REPLACED) }, block)

    companion object {
        /** Phases a Resume lifts. */
        private val RESUMABLE = setOf(ContextPhase.FREEZING, ContextPhase.FROZEN, ContextPhase.FAILED, ContextPhase.RESUMING)
    }
}
