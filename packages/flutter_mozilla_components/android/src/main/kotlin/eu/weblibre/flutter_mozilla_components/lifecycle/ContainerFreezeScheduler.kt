/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.applinks.MonotonicClock
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.launch
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore

/**
 * Finds containers due for an automatic freeze, for one `Core` (phase C2, 5.9
 * of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
 *
 * It only **detects**: a due container goes to Dart through [onDue], and Dart
 * runs its gated preflight with `automatic`. Nothing here starts a freeze
 * (D21): native's idea of a container's members is out of date whenever a tab
 * was moved in the database only.
 *
 * A container is **used** while one of its tabs is selected or on screen, at
 * the moment one leaves the screen, and while a custom tab or web app runs in
 * one of its contexts; its count also starts again when it is resumed. Its
 * time unused is counted in foreground time only, so
 * the setting means "after this long unused, counted while WebLibre is open":
 * hours in the background never freeze a container the moment WebLibre comes
 * back.
 *
 * **Due** once its schedule's time has passed unused, when none of its
 * contexts is restricted already, no member is "Keep awake" (D30), and no
 * loaded member has protected activity (D13). Evaluated once a minute while
 * WebLibre is in the foreground and some container has a schedule; a due
 * container is reported again at each evaluation until it is frozen or used.
 *
 * Main thread only.
 */
class ContainerFreezeScheduler(
    private val store: BrowserStore,
    private val probe: SleepBlockerProbe,
    private val presented: StateFlow<Set<String>>,
    private val onDue: (ownerId: String) -> Unit,
    private val policy: StateFlow<SleepPolicy> = TabSleepPolicies.current,
    private val foreground: StateFlow<Boolean> = ProcessForeground.isStarted,
    private val installForeground: () -> Unit = ProcessForeground::install,
    private val registry: TabLifecycleRegistry = TabLifecycleRegistry,
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
    private val tickMillis: Long = TICK_MILLIS,
) {
    private val scope = CoroutineScope(SupervisorJob() + mainDispatcher)

    private val foregroundClock = ForegroundClock(foreground, clock)

    /**
     * Foreground time at which each container was last used, first seen, or
     * last let go of by its records.
     */
    private val usedAt = mutableMapOf<String, Long>()

    /**
     * Containers last seen frozen, or with a freeze or Resume that did not
     * finish: their count starts again once nothing holds them.
     */
    private val held = mutableSetOf<String>()

    private var lastPresented: Set<String> = emptySet()

    private var started = false

    fun start() {
        if (started) return
        started = true
        scope.launch { installForeground() }
        scope.launch { foreground.collect(foregroundClock::sync) }
        val scheduled = policy.map { it.containers.isNotEmpty() }.distinctUntilChanged()
        scope.launchWhileActive(
            active = combine(foreground, scheduled) { inForeground, any -> inForeground && any },
            tickMillis = tickMillis,
            evaluate = ::evaluate,
            triggers = ::usage,
            onTrigger = ::noteUse,
        )
    }

    /** Stops for good. */
    fun retire() {
        scope.cancel()
    }

    private fun usage() = merge(
        presented,
        store.stateFlow.map { it.selectedTabId to it.customTabs.map { tab -> tab.contextId } }.distinctUntilChanged(),
        // A Resume, noticed when it happens.
        registry.revisions,
    )

    /**
     * Marks every container in use now as used: also the ones whose tab just
     * left the screen, which were in use until this moment.
     */
    internal fun noteUse() {
        val now = foregroundClock.now()
        val state = store.state
        val current = presented.value
        val shown = lastPresented + current + listOfNotNull(state.selectedTabId)
        lastPresented = current
        val inUse = state.tabs.filter { it.id in shown }.mapTo(HashSet()) { it.contextId }
        state.customTabs.mapTo(inUse) { it.contextId }
        for ((owner, schedule) in policy.value.containers) {
            if (schedule.contextIds.any { it in inUse }) usedAt[owner] = now
            noteHold(owner, now)
        }
    }

    /**
     * Frozen time is not unused time: a container resumed without one of its
     * tabs coming on screen counts from the Resume, rather than being due
     * again at once. Only a freeze that took counts; one rolled back while it
     * ran is retried as before.
     */
    private fun noteHold(owner: String, now: Long) {
        when (registry.ownerPhase(owner)) {
            ContextPhase.FROZEN, ContextPhase.FAILED, ContextPhase.RESUMING -> held += owner
            null -> if (held.remove(owner)) usedAt[owner] = now
            else -> Unit
        }
    }

    /** One evaluation: reports every container due now. */
    internal fun evaluate() {
        if (!foreground.value) return
        val current = policy.value
        usedAt.keys.retainAll(current.containers.keys)
        held.retainAll(current.containers.keys)
        if (current.containers.isEmpty()) return
        noteUse()
        if (registry.inRecovery()) return
        val now = foregroundClock.now()
        val state = store.state
        for ((owner, schedule) in current.containers) {
            val since = usedAt.getOrPut(owner) { now }
            if (now - since < schedule.afterMillis) continue
            // Frozen, freezing, failed, being deleted: the freeze's or the
            // user's, never the schedule's.
            if (schedule.contextIds.any { registry.isRestricted(it) }) continue
            if (!isIdle(state, schedule.contextIds, emptySet(), current)) continue
            onDue(owner)
        }
    }

    /**
     * Whether [ownerId] is still due, for a freeze that started from its due
     * event: asked by [ContainerFreeze] at barriers 1 and 2 and right before
     * barrier 4 (5.4), with the contexts and members Dart passed, which are
     * newer than the schedule's. Its own restriction is in place by then, so
     * that is not asked.
     */
    fun isStillDue(ownerId: String, contextIds: Collection<String>, memberTabIds: Set<String>): Boolean {
        val current = policy.value
        val schedule = current.containers[ownerId] ?: return false
        if (!isUnusedFor(ownerId, schedule.afterMillis)) return false
        return isIdle(store.state, contextIds.toSet(), memberTabIds, current)
    }

    /**
     * Whether [ownerId] went unused for at least [millis] of foreground time,
     * for what an automatic freeze may cut off ([ContainerFreeze]'s typed-text
     * allowance). Not whether it is due: [isStillDue] asks that.
     */
    fun isUnusedFor(ownerId: String, millis: Long): Boolean {
        if (!foreground.value) return false
        noteUse()
        val since = usedAt[ownerId] ?: return false
        return foregroundClock.now() - since >= millis
    }

    /**
     * Nothing of the container is in use or kept from freezing: no member
     * selected, on screen or "Keep awake", no custom tab or web app in its
     * contexts, and no loaded member with protected activity. A freeze from a
     * due event never asks, so every blocker defers it. Form input is the
     * freeze's to find, from GeckoView at barrier 2: the store's flag can
     * stay set long after a background page cleared its form
     * ([SleepBlockerProbe.isBlockedBesidesFormData]).
     */
    private fun isIdle(
        state: BrowserState,
        contextIds: Set<String>,
        memberTabIds: Set<String>,
        current: SleepPolicy,
    ): Boolean {
        if (state.customTabs.any { it.contextId in contextIds }) return false
        val members = state.tabs.filter { it.contextId in contextIds || it.id in memberTabIds }
        return members.none { tab ->
            tab.id == state.selectedTabId ||
                tab.id in presented.value ||
                tab.id in current.exemptTabIds ||
                (tab.engineState.engineSession != null && probe.isBlockedBesidesFormData(state, tab))
        }
    }

    companion object {
        const val TICK_MILLIS = 60_000L
    }
}
