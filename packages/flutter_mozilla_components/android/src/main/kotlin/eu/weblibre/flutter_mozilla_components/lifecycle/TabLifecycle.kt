/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleOperationState
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import eu.weblibre.flutter_mozilla_components.pigeons.TabLifecycleState
import eu.weblibre.flutter_mozilla_components.pigeons.TabResidency
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepHold
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepResult
import eu.weblibre.flutter_mozilla_components.split.BrowserPanes
import eu.weblibre.flutter_mozilla_components.split.installedRoutingCovers
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.support.base.log.logger.Logger

/** What [TabLifecycle.unloadForFreeze] did. */
enum class FreezeUnload {
    UNLOADED,

    /** Closed, or without a page already. */
    GONE,
    SUPERSEDED,

    /** An automatic freeze whose container is no longer due ([TabLifecycle.unloadForFreeze]'s `stillDue`). */
    NO_LONGER_DUE,
    FLUSH_TIMED_OUT,
    FLUSH_FAILED,
    SESSION_CHANGED,

    /** Activity the freeze would cut off; [FreezeUnloadResult.blockers] names it. */
    PROTECTED_ACTIVITY,
}

/** [TabLifecycle.unloadForFreeze]'s [outcome], with what refused it. */
data class FreezeUnloadResult(
    val outcome: FreezeUnload,
    val blockers: List<ProtectedActivity> = emptyList(),
)

/** Where tab lifecycle changes go: Dart's `onTabLifecycleChange`. */
fun interface TabLifecycleEvents {
    fun onTabLifecycleChange(state: TabLifecycleState)
}

/**
 * Asks the engine whether a page holds form input right now: true or false,
 * or null when it gave no answer.
 */
fun interface FormDataCheck {
    suspend fun containsFormData(session: EngineSession): Boolean?
}

/**
 * GeckoView's own check (`GeckoSession.containsFormData`, through
 * [EngineSession.checkForFormData]), bounded by [timeoutMillis]. The store's
 * `hasFormData` is not this: AC refreshes it only when a tab is deselected, not
 * while someone types.
 */
class EngineFormDataCheck(
    private val timeoutMillis: Long = TabLifecycle.FORM_DATA_TIMEOUT_MILLIS,
) : FormDataCheck {
    @Suppress("DEPRECATION") // Observable.register/unregister without an owner.
    override suspend fun containsFormData(session: EngineSession): Boolean? {
        val answer = CompletableDeferred<Boolean?>()
        val observer = object : EngineSession.Observer {
            override fun onCheckForFormData(containsFormData: Boolean, adjustPriority: Boolean) {
                answer.complete(containsFormData)
            }

            override fun onCheckForFormDataException(throwable: Throwable) {
                answer.complete(null)
            }
        }
        session.register(observer)
        return try {
            session.checkForFormData(adjustPriority = false)
            withTimeoutOrNull(timeoutMillis) { answer.await() }
        } finally {
            session.unregister(observer)
        }
    }
}

/**
 * Tab sleep for one `Core` (5.2 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
 * the operations, and the events that report every tab's lifecycle to Dart.
 *
 * The holds themselves live in the process-wide [TabLifecycleRegistry]; this
 * only runs the steps between placing a hold and committing it. A components
 * rebuild replaces this object without tearing the old one down, so the outgoing
 * one is [retire]d: its operations stop, release the holds they placed, and
 * report [LifecycleFailure.COMPONENTS_REPLACED].
 *
 * **What "asleep" means (F23):** the hold is in force at B1 and B2, the session
 * is unlinked, and Gecko was asked to close it. Gecko finishes that on its own
 * time, so a page can run a moment longer; nothing recreates it until the tab is
 * woken. No removal is dispatched, so no tombstone, recently-closed entry or
 * isolation cleanup can follow.
 *
 * Everything runs on the main thread, where the store's reducers and the panes
 * run, so no other code interleaves with a teardown.
 */
class TabLifecycle(
    private val store: BrowserStore,
    private val probe: SleepBlockerProbe,
    private val panes: () -> BrowserPanes?,
    private val events: TabLifecycleEvents,
    private val registry: TabLifecycleRegistry = TabLifecycleRegistry,
    private val flusher: SessionStateFlusher = GeckoSessionStateFlusher,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
    private val flushTimeoutMillis: Long = FLUSH_TIMEOUT_MILLIS,
    private val formDataCheck: FormDataCheck = EngineFormDataCheck(),
    /** Whether the installed routing covers a tab's context, as the panes ask it. */
    private val routingCovers: (TabSessionState) -> Boolean = ::installedRoutingCovers,
) {
    private val logger = Logger("TabLifecycle")

    private val scope = CoroutineScope(SupervisorJob() + mainDispatcher)

    /** The tabs a sleep is running on, with the generation it owns. */
    private val operations = MutableStateFlow<Map<String, Long>>(emptyMap())

    private var started = false

    /** Starts reporting every tab's lifecycle; once. */
    fun start() {
        if (started) return
        started = true
        scope.launch {
            var reported = emptyMap<String, TabLifecycleState>()
            // Only what the states are made of: progress, titles and icons
            // change the store far more often than that.
            val tabs = store.stateFlow
                .map { state -> state.tabs.map { TabFacts(it.id, it.contextId, residencyOf(it)) } }
                .distinctUntilChanged()
            combine(tabs, registry.heldTabs, operations, registry.revisions) { tabs, held, ops, _ ->
                val restricted = registry.restrictedAmong(tabs.map { it.contextId })
                tabs.associate { tab ->
                    tab.id to stateOf(tab.id, tab.residency, held[tab.id]?.kind, tab.id in ops, tab.contextId in restricted)
                }
            }.collect { states ->
                states.forEach { (tabId, state) ->
                    if (reported[tabId] != state) events.onTabLifecycleChange(state)
                }
                reported = states
            }
        }
    }

    /**
     * Stops this `Core`'s work for good: running sleeps stop at their next step
     * and release their holds. Holds already committed stay, in the registry.
     */
    fun retire() {
        scope.cancel()
    }

    /** Every tab's state now. */
    fun states(): List<TabLifecycleState> {
        val held = registry.heldTabs.value
        val ops = operations.value
        val tabs = store.state.tabs
        val restricted = registry.restrictedAmong(tabs.map { it.contextId })
        return tabs.map { tab ->
            stateOf(tab.id, residencyOf(tab), held[tab.id]?.kind, tab.id in ops, tab.contextId in restricted)
        }
    }

    /** [tabId]'s state now, as [states] reports it; null when it is not open. */
    fun stateNow(tabId: String): TabLifecycleState? {
        val tab = store.state.findTab(tabId) ?: return null
        return stateOf(
            tab.id,
            residencyOf(tab),
            registry.holdOf(tab.id),
            tab.id in operations.value,
            registry.isRestricted(tab.contextId),
        )
    }

    /**
     * A Wake the user asked for (a sleeping tab never wakes by coming on
     * screen, D10): only while [routingCovers] its context (D34), so that
     * nothing of it goes out another way, and only while its context is not
     * restricted: a frozen container's tab could not load, and without its
     * hold it would load after a Resume, which leaves sleeping tabs asleep
     * (D26). Returns whether it was woken; false for a
     * tab that is not open.
     */
    fun wakeRequested(tabId: String): Boolean {
        val tab = store.state.findTab(tabId) ?: return false
        if (registry.isRestricted(tab.contextId)) return false
        if (!routingCovers(tab)) return false
        wake(tabId)
        return true
    }

    /**
     * Clears [tabId]'s hold. A tab on screen is presented again at once, which
     * creates its session; any other loads when shown or reached.
     */
    fun wake(tabId: String) {
        registry.wake(tabId)
        val panes = panes() ?: return
        if (tabId in panes.visibleTabIds) panes.reconcileNow()
    }

    /**
     * Puts every tab of [tabIds] to sleep, side by side, and reports each.
     * Form input is cut off only in the tabs of [discardFormDataOf], those the
     * user was asked about.
     */
    suspend fun sleep(
        tabIds: List<String>,
        stopMedia: Boolean,
        discardPostResult: Boolean,
        discardFormDataOf: Set<String> = emptySet(),
    ): List<TabSleepResult> {
        val confirmed = buildSet {
            if (stopMedia) add(ProtectedActivity.MEDIA)
            if (discardPostResult) add(ProtectedActivity.POST_RESULT)
        }
        val running = tabIds.distinct().map { tabId ->
            val tabConfirmed = if (tabId in discardFormDataOf) confirmed + ProtectedActivity.FORM_DATA else confirmed
            tabId to scope.async { sleepOne(tabId, SleepHoldKind.MANUAL, tabConfirmed, persist = false) { true } }
        }
        val results = running.map { (tabId, operation) -> runCatching { operation.awaitOrReplaced(tabId) } }
        // One write for the whole batch ("Sleep all tabs"), not one per tab:
        // each rewrites the record and syncs it with its folder, on the main
        // thread. What any sleep threw, cancellation included, is thrown after.
        registry.persistPendingHolds()
        return results.map { it.getOrThrow() }
    }

    /**
     * Puts [tabId] to sleep for the scheduler (5.9): an automatic hold, never
     * in place of one already there (a manual sleep since the pick refuses
     * it, [LifecycleFailure.NO_LONGER_ELIGIBLE]), nothing asked and nothing
     * cut off (any blocker defers it) but form input when [discardFormData]
     * (a tab off screen long enough, [TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS]),
     * and [stillEligible] re-run with the identity checks right before the
     * teardown, so a tab shown, selected or kept awake during its flush stays
     * loaded.
     */
    suspend fun sleepAutomatically(
        tabId: String,
        discardFormData: Boolean = false,
        stillEligible: () -> Boolean,
    ): TabSleepResult {
        val confirmed = if (discardFormData) setOf(ProtectedActivity.FORM_DATA) else emptySet()
        return scope.async { sleepOne(tabId, SleepHoldKind.AUTOMATIC, confirmed, stillEligible = stillEligible) }
            .awaitOrReplaced(tabId)
    }

    /** The sleep's result; when this Core was retired meanwhile, a refusal, while the caller's own cancellation goes on. */
    private suspend fun Deferred<TabSleepResult>.awaitOrReplaced(tabId: String): TabSleepResult = try {
        await()
    } catch (e: CancellationException) {
        if (scope.isActive) throw e
        failed(tabId, LifecycleFailure.COMPONENTS_REPLACED)
    }

    /** Whether a sleep is running on [tabId]. */
    fun isSleeping(tabId: String): Boolean = tabId in operations.value

    /**
     * Barrier 4 of a container freeze for one tab (5.4): flush, revalidate,
     * close, unlink, as a sleep does, but **without a sleep hold**: the
     * context's restriction keeps the tab unloaded, and Resume must leave it
     * an ordinary unloaded tab (D26). [stillOwned] is the freeze's generation
     * check, re-run right before the teardown, and so is [stillDue], an
     * automatic freeze's check that its container is still unused: a member
     * selected, shown or kept awake during the flush or the form check keeps
     * its page, and the freeze is rolled back.
     *
     * The freeze checked its tabs' activity before it restricted them, maybe
     * several tabs ago, so the tab's is checked again here, as a sleep's is:
     * a print, a recording or form input started since refuses unless the
     * user [confirmed] it, since an unload cannot be taken back. Downloads
     * are not: the restriction refuses new ones (A4), and the freeze checks
     * the running ones per download once its contexts are quiet (5.11).
     */
    suspend fun unloadForFreeze(
        tabId: String,
        confirmed: Set<ProtectedActivity>,
        stillDue: () -> Boolean = { true },
        stillOwned: () -> Boolean,
    ): FreezeUnloadResult {
        val tab = store.state.findTab(tabId) ?: return FreezeUnloadResult(FreezeUnload.GONE)
        val session = tab.engineState.engineSession ?: return FreezeUnloadResult(FreezeUnload.GONE)
        if (ProtectedActivity.MEDIA in confirmed) tab.mediaSessionState?.controller?.pause()

        when (flush(session)) {
            null -> return FreezeUnloadResult(FreezeUnload.FLUSH_TIMED_OUT)
            false -> return FreezeUnloadResult(FreezeUnload.FLUSH_FAILED)
            true -> Unit
        }
        // Form input the user agreed to lose needs no answer from GeckoView.
        val formData = if (ProtectedActivity.FORM_DATA in confirmed) null else formDataCheck.containsFormData(session) ?: true

        if (!stillOwned()) return FreezeUnloadResult(FreezeUnload.SUPERSEDED)
        if (!stillDue()) return FreezeUnloadResult(FreezeUnload.NO_LONGER_DUE)
        val now = store.state.findTab(tabId) ?: return FreezeUnloadResult(FreezeUnload.GONE)
        if (now.engineState.engineSession !== session) return FreezeUnloadResult(FreezeUnload.SESSION_CHANGED)
        val blockers = probe.blockersOf(store.state, now).withFormData(formData)
            .filter { it != ProtectedActivity.DOWNLOAD && it !in confirmed }
        if (blockers.isNotEmpty()) return FreezeUnloadResult(FreezeUnload.PROTECTED_ACTIVITY, blockers)

        // Teardown in this main-thread turn: the pane lets go of the page first.
        registry.markFreezeTeardown(tabId, true)
        try {
            panes()?.let { panes -> if (tabId in panes.visibleTabIds) panes.reconcileNow() }
            session.close()
            store.dispatch(EngineAction.UnlinkEngineSessionAction(tabId))
        } finally {
            registry.markFreezeTeardown(tabId, false)
        }
        return FreezeUnloadResult(FreezeUnload.UNLOADED)
    }

    /**
     * Unloads [tabId]'s session without saving anything: a session linked while
     * its context was restricted holds only an empty page (see
     * [RestrictedSessions]), and the tab's kept state restores when it is shown.
     *
     * Unlinked before it closes, as AC's `SuspendMiddleware` does, so a pane
     * showing it lets go of it first; the context is no longer restricted, so
     * that pane asks for the tab's page again at once.
     */
    fun discardRestrictedSession(tabId: String) {
        val session = store.state.findTab(tabId)?.engineState?.engineSession ?: return
        store.dispatch(EngineAction.UnlinkEngineSessionAction(tabId))
        panes()?.let { panes -> if (tabId in panes.visibleTabIds) panes.reconcileNow() }
        session.close()
    }

    /**
     * One sleep. Without [persist] a hold it commits is written by the
     * caller's [TabLifecycleRegistry.persistPendingHolds].
     */
    private suspend fun sleepOne(
        tabId: String,
        kind: SleepHoldKind,
        confirmed: Set<ProtectedActivity>,
        persist: Boolean = true,
        stillEligible: () -> Boolean,
    ): TabSleepResult {
        val tab = store.state.findTab(tabId) ?: return failed(tabId, LifecycleFailure.UNKNOWN_TAB)
        // Asleep already, with no page to cut off: nothing is checked, since a
        // refusal would release the hold it has, one the user may have
        // confirmed a POST result for ("Sleep all tabs" a second time). An
        // automatic hold becomes the user's.
        if (kind == SleepHoldKind.MANUAL && tab.engineState.engineSession == null && tabId !in operations.value) {
            when (registry.holdOf(tabId)) {
                SleepHoldKind.MANUAL -> return TabSleepResult(tabId, asleep = true, failure = null, blockers = emptyList())
                SleepHoldKind.AUTOMATIC -> return commit(tabId, registry.beginSleep(tabId, kind, private = tab.content.private), persist)
                null -> Unit
            }
        }
        val gen = if (kind == SleepHoldKind.AUTOMATIC) {
            // Never in place of a hold: the tab was put to sleep, or is being,
            // since the scheduler picked it.
            registry.beginAutomaticSleep(tabId, private = tab.content.private)
                ?: return failed(tabId, LifecycleFailure.NO_LONGER_ELIGIBLE)
        } else {
            registry.beginSleep(tabId, kind, private = tab.content.private)
        }
        operations.value = operations.value + (tabId to gen)
        return try {
            runSleep(tabId, gen, confirmed, persist, stillEligible)
        } catch (e: Throwable) {
            // Cancelled, or something it called threw (the flusher, the form
            // check, the teardown): no operation owns the hold any more, and
            // a hold nothing releases would keep the tab from loading.
            registry.releaseSleep(tabId, gen)
            throw e
        } finally {
            if (operations.value[tabId] == gen) operations.value = operations.value - tabId
        }
    }

    private suspend fun runSleep(
        tabId: String,
        gen: Long,
        confirmed: Set<ProtectedActivity>,
        persist: Boolean,
        stillEligible: () -> Boolean,
    ): TabSleepResult {
        // A hold is in force from here on: B1 drops new creations, and AC's
        // creation gate refuses one that was already accepted (B2). Every
        // refusal releases it.
        // Reported without what the user agreed to cut off: a form check
        // skipped for confirmed input leaves the store's flag, which must not
        // take the blame for what did refuse.
        fun refuse(failure: LifecycleFailure, blockers: List<ProtectedActivity> = emptyList()): TabSleepResult {
            registry.releaseSleep(tabId, gen)
            return failed(tabId, failure, blockers.filter { it !in confirmed })
        }

        //
        // A first look at the form input, to refuse before the flush; without
        // an answer the store's last value stands until the final check.
        val firstFormData = store.state.findTab(tabId)?.engineState?.engineSession
            ?.takeIf { ProtectedActivity.FORM_DATA !in confirmed }
            ?.let { formDataCheck.containsFormData(it) }

        var tab = current(tabId, gen) ?: return lost(tabId, gen)
        if (!stillEligible()) return refuse(LifecycleFailure.NO_LONGER_ELIGIBLE)
        val blockers = probe.blockersOf(store.state, tab).withFormData(firstFormData)
        if (blockers.any { it !in confirmed }) return refuse(LifecycleFailure.PROTECTED_ACTIVITY, blockers)
        if (ProtectedActivity.MEDIA in blockers) {
            tab.mediaSessionState?.controller?.pause()
        }

        val session = tab.engineState.engineSession
            // Unloaded, or a creation in flight that the gate now refuses.
            ?: return commit(tabId, gen, persist)

        when (flush(session)) {
            null -> return refuse(LifecycleFailure.FLUSH_TIMED_OUT)
            false -> return refuse(LifecycleFailure.FLUSH_FAILED)
            true -> Unit
        }

        // The final check asks GeckoView again: anything typed during the flush
        // is in no state that was saved. No answer counts as form input, since
        // an unload cannot be taken back. Form input the user agreed to lose
        // needs no answer.
        val finalFormData = if (ProtectedActivity.FORM_DATA in confirmed) null else formDataCheck.containsFormData(session) ?: true

        // Revalidate: still ours, still there, same session, nothing new to cut off.
        tab = current(tabId, gen) ?: return lost(tabId, gen)
        if (tab.engineState.engineSession !== session) return refuse(LifecycleFailure.SESSION_CHANGED)
        if (!stillEligible()) return refuse(LifecycleFailure.NO_LONGER_ELIGIBLE)
        val now = probe.blockersOf(store.state, tab).withFormData(finalFormData)
        if (now.any { it !in confirmed }) return refuse(LifecycleFailure.PROTECTED_ACTIVITY, now)

        // Teardown, in this same main-thread turn: the panes let go of the
        // page first, and nothing runs between the check and the close.
        if (!registry.markTearingDown(tabId, gen)) return lost(tabId, gen)
        panes()?.let { panes -> if (tabId in panes.visibleTabIds) panes.reconcileNow() }
        session.close()
        store.dispatch(EngineAction.UnlinkEngineSessionAction(tabId))
        return commit(tabId, gen, persist)
    }

    /** The tab while [gen] still owns it, or null. */
    private fun current(tabId: String, gen: Long): TabSessionState? {
        if (registry.generation(tabId) != gen) return null
        return store.state.findTab(tabId)
    }

    /** Why [current] answered null: a newer operation, or the tab closed. */
    private fun lost(tabId: String, gen: Long): TabSleepResult =
        if (registry.generation(tabId) != gen) {
            failed(tabId, LifecycleFailure.SUPERSEDED)
        } else {
            failed(tabId, LifecycleFailure.UNKNOWN_TAB)
        }

    private fun commit(tabId: String, gen: Long, persist: Boolean): TabSleepResult =
        if (registry.completeSleep(tabId, gen, persist)) {
            TabSleepResult(tabId, asleep = true, failure = null, blockers = emptyList())
        } else {
            lost(tabId, gen)
        }

    /** True or false from the flusher, null on timeout. */
    private suspend fun flush(session: EngineSession): Boolean? {
        val done = CompletableDeferred<Boolean>()
        flusher.flush(session) { done.complete(it) }
        return withTimeoutOrNull(flushTimeoutMillis) { done.await() }
    }

    private fun failed(
        tabId: String,
        failure: LifecycleFailure,
        blockers: List<ProtectedActivity> = emptyList(),
    ): TabSleepResult {
        logger.debug("Tab $tabId not put to sleep: $failure $blockers")
        return TabSleepResult(tabId, asleep = false, failure = failure, blockers = blockers)
    }

    /** What a tab's lifecycle state is made of, of everything the store holds for it. */
    private data class TabFacts(val id: String, val contextId: String?, val residency: TabResidency)

    companion object {
        const val FLUSH_TIMEOUT_MILLIS = 3_000L
        const val FORM_DATA_TIMEOUT_MILLIS = 1_000L

        internal fun stateOf(
            tabId: String,
            residency: TabResidency,
            hold: SleepHoldKind?,
            sleeping: Boolean,
            contextFrozen: Boolean,
        ): TabLifecycleState = TabLifecycleState(
            tabId = tabId,
            residency = residency,
            sleepHold = when (hold) {
                SleepHoldKind.MANUAL -> TabSleepHold.MANUAL
                SleepHoldKind.AUTOMATIC -> TabSleepHold.AUTOMATIC
                null -> TabSleepHold.NONE
            },
            operation = if (sleeping) LifecycleOperationState.SLEEPING else LifecycleOperationState.IDLE,
            contextFrozen = contextFrozen,
        )

        internal fun residencyOf(tab: TabSessionState): TabResidency = when {
            tab.engineState.crashed -> TabResidency.CRASHED
            tab.engineState.engineSession != null -> TabResidency.RESIDENT
            tab.engineState.initializing -> TabResidency.INITIALIZING
            else -> TabResidency.UNLOADED
        }
    }
}
