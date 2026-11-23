/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import android.content.ComponentCallbacks2
import android.content.Context
import android.content.res.Configuration
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import eu.weblibre.flutter_mozilla_components.applinks.MonotonicClock
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepResult
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.support.base.log.logger.Logger

/**
 * Whether some activity of this process is started: the only time automatic
 * sleep evaluates (5.9), so nothing is put to sleep in the background.
 */
object ProcessForeground : DefaultLifecycleObserver {
    private val started = MutableStateFlow(false)

    val isStarted: StateFlow<Boolean> = started.asStateFlow()

    private var installed = false

    /** Main thread only, as ProcessLifecycleOwner is. Once per process. */
    fun install() {
        if (installed) return
        installed = true
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    override fun onStart(owner: LifecycleOwner) {
        started.value = true
    }

    override fun onStop(owner: LifecycleOwner) {
        started.value = false
    }
}

/**
 * Time spent in the foreground, for idle rules that must not count time in the
 * background: whatever was left alone while WebLibre was away would otherwise
 * all come due at once when it is back (5.9). Its owner feeds it every
 * foreground change ([sync]). Main thread only.
 */
internal class ForegroundClock(
    private val foreground: StateFlow<Boolean>,
    private val clock: MonotonicClock,
) {
    /** Foreground time before the current foreground interval. */
    private var before = 0L

    /** When the current foreground interval began; null in the background. */
    private var since: Long? = null

    fun sync(inForeground: Boolean) {
        val now = clock.elapsedRealtime()
        val start = since
        if (inForeground && start == null) since = now
        if (!inForeground && start != null) {
            before += now - start
            since = null
        }
    }

    /** Time spent in the foreground since this clock was made. */
    fun now(): Long {
        sync(foreground.value)
        return before + (since?.let { clock.elapsedRealtime() - it } ?: 0L)
    }
}

/**
 * While the latest of [active] is true: [evaluate] at once and every
 * [tickMillis], and [onTrigger] on each of [triggers]. Every value of [active]
 * starts over, so a changed policy evaluates at once.
 */
internal fun CoroutineScope.launchWhileActive(
    active: Flow<Boolean>,
    tickMillis: Long,
    evaluate: suspend () -> Unit,
    triggers: () -> Flow<*>,
    onTrigger: suspend () -> Unit,
) = launch {
    active.collectLatest { on ->
        if (!on) return@collectLatest
        coroutineScope {
            launch {
                while (true) {
                    evaluate()
                    delay(tickMillis)
                }
            }
            launch { triggers().collect { onTrigger() } }
        }
    }
}

/**
 * Automatic tab sleep for one `Core` (phase T2, 5.9 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
 *
 * Evaluates once a minute, and at once when the selection, the presented set,
 * the loaded tabs or the policy change, or the system trims memory, but only
 * while the process is in the foreground and the policy is on. It records when
 * each tab left the screen, which nothing else does (F19), in foreground time
 * ([ForegroundClock]): a tab is idle only while WebLibre is used, so returning
 * after a while away does not unload every tab off screen at once.
 *
 * **Never candidates:** tabs without a loaded page, the selected tab, tabs on
 * screen or presented in the last [RECENTLY_PRESENTED_MILLIS], "Keep awake"
 * tabs, tabs already held or being put to sleep, tabs with protected activity
 * (D13), tabs loading for less than [LOADING_GRACE_MILLIS], and tabs backing off
 * after a failed attempt. Custom tabs and web apps are not in the tab list.
 *
 * **Idle rule:** off screen for the policy's idle time. **Resident limit:** soft;
 * while more tabs than the limit have a page loaded, the eligible tab off screen
 * longest goes next. **Typed text:** form input defers a tab until it was off
 * screen for [TYPED_TEXT_GRACE_MILLIS], or the idle time if longer, whichever
 * rule picked it; then it
 * goes like any other (D13), so a search page left long ago does not stay
 * loaded for good, and text typed a moment ago is kept.
 *
 * Each candidate goes through [TabLifecycle.sleepAutomatically], which re-runs
 * [isStillEligible] right before the teardown, so a tab that was selected, shown
 * or kept awake during its flush stays loaded. Never asks and never cuts
 * anything off but that typed text: any other blocker defers the tab.
 *
 * Main thread only.
 */
class TabSleepScheduler(
    private val store: BrowserStore,
    private val lifecycle: TabLifecycle,
    private val probe: SleepBlockerProbe,
    private val presented: StateFlow<Set<String>>,
    private val policy: StateFlow<SleepPolicy> = TabSleepPolicies.current,
    private val foreground: StateFlow<Boolean> = ProcessForeground.isStarted,
    private val installForeground: () -> Unit = ProcessForeground::install,
    private val context: Context? = null,
    private val registry: TabLifecycleRegistry = TabLifecycleRegistry,
    private val clock: MonotonicClock = MonotonicClock.SYSTEM,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
    private val tickMillis: Long = TICK_MILLIS,
) {
    /** Why a tab was picked, which its re-check before teardown asks again. */
    enum class Reason { IDLE, RESIDENT_LIMIT }

    private class Backoff(val until: Long, val delayMillis: Long)

    private val logger = Logger("TabSleepScheduler")

    private val scope = CoroutineScope(SupervisorJob() + mainDispatcher)

    private val foregroundClock = ForegroundClock(foreground, clock)

    /** When each tab off screen left it, or was first seen off screen. */
    private val offScreenSince = mutableMapOf<String, Long>()

    /** When each loading tab was first seen loading. */
    private val loadingSince = mutableMapOf<String, Long>()

    private val backoff = mutableMapOf<String, Backoff>()

    /**
     * Tabs refused only for their typed text, waiting until it may go. Not a
     * [backoff]: that wait follows the current policy's idle time, so it is
     * worked out again at each evaluation ([typedTextMayGo]).
     */
    private val waitingForTypedText = mutableSetOf<String>()

    private var lastPresented: Set<String> = emptySet()

    private val evaluating = Mutex()

    private val memoryPressure = MutableSharedFlow<Unit>(extraBufferCapacity = 1)

    private val memoryCallbacks = object : ComponentCallbacks2 {
        override fun onTrimMemory(level: Int) {
            memoryPressure.tryEmit(Unit)
        }

        override fun onConfigurationChanged(newConfig: Configuration) = Unit

        @Deprecated("Deprecated in Java")
        override fun onLowMemory() {
            memoryPressure.tryEmit(Unit)
        }
    }

    private var started = false

    fun start() {
        if (started) return
        started = true
        context?.registerComponentCallbacks(memoryCallbacks)
        scope.launch { installForeground() }
        scope.launch { foreground.collect(foregroundClock::sync) }
        scope.launch { presented.collect(::onPresented) }
        scope.launchWhileActive(
            active = combine(foreground, policy) { inForeground, current -> inForeground && current.enabled },
            tickMillis = tickMillis,
            evaluate = ::evaluate,
            triggers = ::triggers,
            onTrigger = ::evaluate,
        )
    }

    /** Stops for good; a sleep it started stops with its `Core`'s lifecycle. */
    fun retire() {
        scope.cancel()
        context?.unregisterComponentCallbacks(memoryCallbacks)
    }

    private fun triggers() = merge(
        store.stateFlow
            .map { state ->
                state.selectedTabId to state.tabs.map { it.id to (it.engineState.engineSession != null) }
            }
            .distinctUntilChanged()
            .drop(1),
        presented.drop(1),
        memoryPressure,
    )

    private fun onPresented(tabIds: Set<String>) {
        val now = foregroundClock.now()
        (lastPresented - tabIds).forEach { offScreenSince[it] = now }
        tabIds.forEach { offScreenSince.remove(it) }
        // Shown again: its text may have changed, and its time off screen
        // starts over anyway.
        waitingForTypedText.removeAll(tabIds)
        lastPresented = tabIds
    }

    /**
     * One evaluation; skipped while another is still running its sleeps.
     *
     * Runs in this scheduler's own coroutines on the main thread, where
     * nothing handles what escapes: a sleep that throws (the engine's flush,
     * form check or teardown) backs off that tab like any failed sleep, and
     * the others are still tried. Cancellation goes on.
     */
    internal suspend fun evaluate() {
        if (!evaluating.tryLock()) return
        try {
            if (!active()) return
            val now = foregroundClock.now()
            note(store.state, now)
            val picks = try {
                candidates(store.state, policy.value, now)
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                logger.warn("Could not pick tabs to put to sleep; trying again at the next evaluation", e)
                return
            }
            for ((tabId, reason) in picks) {
                if (!active()) break
                val typedTextMayGo = typedTextMayGo(tabId, now, policy.value)
                val result = try {
                    lifecycle.sleepAutomatically(tabId, discardFormData = typedTextMayGo) {
                        isStillEligible(tabId, reason)
                    }
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    logger.warn("Automatic sleep of $tabId failed", e)
                    onFailed(tabId, failure = null)
                    continue
                }
                if (result.asleep) {
                    backoff.remove(tabId)
                    waitingForTypedText.remove(tabId)
                } else if (!typedTextMayGo && result.isTypedTextOnly()) {
                    // Kept only for the typed text: tried again once it may go.
                    waitingForTypedText += tabId
                } else {
                    onFailed(tabId, result.failure)
                }
            }
        } finally {
            evaluating.unlock()
        }
    }

    private fun active() = foreground.value && policy.value.enabled

    /** Keeps the clocks of every open tab, and forgets closed ones. */
    private fun note(state: BrowserState, now: Long) {
        val open = state.tabs.mapTo(HashSet()) { it.id }
        offScreenSince.keys.retainAll(open)
        loadingSince.keys.retainAll(open)
        backoff.keys.retainAll(open)
        waitingForTypedText.retainAll(open)
        for (tab in state.tabs) {
            if (tab.id !in presented.value) offScreenSince.putIfAbsent(tab.id, now)
            if (tab.content.loading) loadingSince.putIfAbsent(tab.id, now) else loadingSince.remove(tab.id)
        }
    }

    /** The tabs to put to sleep now, in order, each with why. */
    internal fun candidates(state: BrowserState, policy: SleepPolicy, now: Long): List<Pair<String, Reason>> {
        val (idleLong, notIdle) = state.tabs
            .filter { tab -> isEligible(tab, state, policy, now, recheck = false) }
            .sortedBy { offScreenSince[it.id] ?: now }
            .partition { now - (offScreenSince[it.id] ?: now) >= policy.idleMillis }
        val idle = idleLong.filter { isUnblocked(state, it) }
        val picks = idle.map { it.id to Reason.IDLE }.toMutableList()

        val limit = policy.residentLimit ?: return picks
        val over = residentCount(state) - idle.size - limit
        if (over > 0) {
            notIdle.asSequence()
                .filter { isUnblocked(state, it) }
                .take(over)
                .forEach { picks += it.id to Reason.RESIDENT_LIMIT }
        }
        return picks
    }

    /**
     * The whole predicate again, right before [tabId]'s teardown (5.2,
     * "Automatic"): everything but the hold and operation its own sleep holds,
     * and the blockers, which the sleep checks itself with GeckoView's answer.
     */
    internal fun isStillEligible(tabId: String, reason: Reason): Boolean {
        val state = store.state
        val tab = state.findTab(tabId) ?: return false
        val current = policy.value
        val now = foregroundClock.now()
        if (!foreground.value || !current.enabled) return false
        if (!isEligible(tab, state, current, now, recheck = true)) return false
        return when (reason) {
            Reason.IDLE -> now - (offScreenSince[tabId] ?: now) >= current.idleMillis
            Reason.RESIDENT_LIMIT -> current.residentLimit?.let { residentCount(state) > it } == true
        }
    }

    private fun isEligible(
        tab: TabSessionState,
        state: BrowserState,
        policy: SleepPolicy,
        now: Long,
        recheck: Boolean,
    ): Boolean {
        if (tab.engineState.engineSession == null) return false
        if (tab.id == state.selectedTabId) return false
        if (tab.id in presented.value) return false
        val leftScreen = offScreenSince[tab.id] ?: return false
        if (now - leftScreen < RECENTLY_PRESENTED_MILLIS) return false
        if (tab.id in policy.exemptTabIds) return false
        if (tab.content.loading && now - (loadingSince[tab.id] ?: now) < LOADING_GRACE_MILLIS) return false
        // A freezing or frozen container's tabs are the freeze's (5.9); also
        // re-checked right before the teardown.
        if (registry.isRestricted(tab.contextId)) return false
        if (recheck) return true
        if (registry.isHeld(tab.id) || lifecycle.isSleeping(tab.id)) return false
        if (tab.id in waitingForTypedText && !typedTextMayGo(tab.id, now, policy)) return false
        return backoff[tab.id]?.let { now < it.until } != true
    }

    /**
     * Whether [tab] has nothing a sleep would cut off, form input aside,
     * which the sleep asks GeckoView about ([SleepBlockerProbe.isBlockedBesidesFormData]).
     * Asked only of the tabs about to be picked, last: it writes out the
     * tab's saved state and looks for chosen uploads on disk, on the main
     * thread.
     */
    private fun isUnblocked(state: BrowserState, tab: TabSessionState): Boolean =
        !probe.isBlockedBesidesFormData(state, tab)

    /**
     * Whether [tabId] was off screen long enough that its typed text may go:
     * [TYPED_TEXT_GRACE_MILLIS], or the idle time if longer, also for a tab
     * the resident limit picks before its idle time (D13).
     */
    private fun typedTextMayGo(tabId: String, now: Long, policy: SleepPolicy): Boolean =
        offScreenSince[tabId]?.let { now - it >= maxOf(TYPED_TEXT_GRACE_MILLIS, policy.idleMillis) } == true

    private fun TabSleepResult.isTypedTextOnly() =
        failure == LifecycleFailure.PROTECTED_ACTIVITY && blockers == listOf(ProtectedActivity.FORM_DATA)

    private fun residentCount(state: BrowserState) = state.tabs.count { it.engineState.engineSession != null }

    private fun onFailed(tabId: String, failure: LifecycleFailure?) {
        when (failure) {
            // Not the tab's doing: picked again when it qualifies.
            LifecycleFailure.NO_LONGER_ELIGIBLE,
            LifecycleFailure.SUPERSEDED,
            LifecycleFailure.UNKNOWN_TAB,
            LifecycleFailure.COMPONENTS_REPLACED,
            -> return
            else -> Unit
        }
        val previous = backoff[tabId]?.delayMillis
        val delayMillis = previous?.let { (it * 2).coerceAtMost(MAX_BACKOFF_MILLIS) } ?: FIRST_BACKOFF_MILLIS
        backoff[tabId] = Backoff(until = foregroundClock.now() + delayMillis, delayMillis = delayMillis)
        logger.debug("Automatic sleep of $tabId failed ($failure); next try in ${delayMillis / 1000} s")
    }

    companion object {
        const val TICK_MILLIS = 60_000L
        const val RECENTLY_PRESENTED_MILLIS = 30_000L
        const val LOADING_GRACE_MILLIS = 2 * 60_000L
        const val FIRST_BACKOFF_MILLIS = 5 * 60_000L
        const val MAX_BACKOFF_MILLIS = 60 * 60_000L

        /** How long typed text keeps a tab off screen, or a container unused, loaded. */
        const val TYPED_TEXT_GRACE_MILLIS = 60 * 60_000L
    }
}
