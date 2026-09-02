/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.startup

import androidx.annotation.MainThread
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.ext.flow
import mozilla.components.support.base.log.logger.Logger

/**
 * Holds one view-less GeckoSession open across startup, so Gecko runs the part
 * of its own startup that it gates on a chrome window existing.
 *
 * `GeckoSession.open()` is what creates `chrome://geckoview/content/geckoview.xhtml`,
 * and that window's script is the only thing on Android that notifies
 * `extensions-late-startup` and `browser-delayed-startup-finished`. Background
 * scripts of already-installed extensions wait on the first, via
 * `ExtensionParent.browserStartupPromise`; `SafeBrowsing.init()`,
 * `Blocklist.loadBlocklistAsync()` and `RemoteSecuritySettings.init()` are
 * scheduled next to it. Without a window none of it runs — which is why a cold
 * start that never opens a tab has no ad blocking, no container routing and no
 * native port from any built-in extension: every one of them opens its bridge
 * with `browser.runtime.connectNative(...)` from a background script that has
 * not been allowed to start.
 *
 * The window needs no EngineView and no compositor, only the UI thread, so this
 * session is never rendered, never navigated and never put in the
 * `BrowserStore`. It exists as the window and nothing else, and it is given
 * back as soon as something else holds one. Closing the last window does not
 * shut Gecko down — `nsAppShell` enters `EnterLastWindowClosingSurvivalArea` —
 * and the notifications are one-shot, so the unblocking is permanent for the
 * process.
 *
 * The same technique, for the same underlying reason, is used for headless push
 * delivery in `Push.deliverMessage`.
 */
object EngineWarmupSession {
    private val logger = Logger("engine_warmup")

    /** Why the warm-up session stopped being worth holding. */
    @VisibleForTesting
    internal enum class CloseReason {
        /** A background script connected: the delayed startup has run. */
        EXTENSION_READY,

        /** A real session is holding a window open now. */
        REAL_SESSION,

        /** Neither was observed in time; give the window back regardless. */
        CEILING,
    }

    /** The session, narrowed to the one thing closing it needs. */
    @VisibleForTesting
    internal fun interface Handle {
        fun close()
    }

    /**
     * How long to hold the window when neither close signal arrives.
     *
     * `geckoview.js` schedules its startup work with `InitLater` (idle
     * dispatch, 15 s cap) and can defer `extensions-late-startup` by a further
     * 5 s while an applink navigation is pending, so this has to clear both
     * with room to spare. Past that, holding the window longer is not buying
     * anything a shorter wait did not already buy.
     */
    @VisibleForTesting
    internal var ceilingMs = 30_000L

    /**
     * Where the close-signal watcher runs. The UI thread, because closing the
     * session from it asserts that thread.
     */
    @VisibleForTesting
    internal var scopeFactory: () -> CoroutineScope =
        { CoroutineScope(Dispatchers.Main.immediate + SupervisorJob()) }

    /**
     * Set once the window has done its job, so a later components rebuild
     * (external -> full) does not open a second one. The delayed startup this
     * unblocks is per process, not per component generation.
     */
    @Volatile
    private var completed = false

    private var handle: Handle? = null
    private var job: Job? = null

    /**
     * Opens the warm-up session if this process still needs one.
     *
     * Idempotent, and a no-op once a real session is already holding a window
     * open — Gecko's delayed startup is then running off that one, and a second
     * window would be pure cost.
     *
     * Must run on the UI thread: both `Engine.createSession` and
     * `GeckoSession.open` assert it.
     */
    @MainThread
    fun start(components: Components) = startWith(
        hasLiveEngineSession = { components.core.store.state.hasLiveEngineSession() },
        openSession = {
            // Opens the GeckoSession — AC does that in GeckoEngineSession's
            // constructor — without rendering it anywhere. Deliberately no
            // loadUrl: the chrome window is created by open() alone, and a
            // navigation is the one thing that could record history or reach
            // the network from a session the user never asked for.
            val session = components.core.engine.createSession()
            Handle { session.close() }
        },
        realSessionSignal = {
            components.core.store.flow()
                .filter { it.hasLiveEngineSession() }
                .map { }
        },
        extensionReadySignal = {
            ContainerProxyFeature.extensionBackgroundStarted.filter { it }.map { }
        },
    )

    /**
     * [start], with everything that needs a live Gecko runtime passed in.
     *
     * Split out so the lifetime rules can be tested without one.
     */
    @MainThread
    @VisibleForTesting
    internal fun startWith(
        hasLiveEngineSession: () -> Boolean,
        openSession: () -> Handle?,
        realSessionSignal: () -> Flow<Unit>,
        extensionReadySignal: () -> Flow<Unit>,
    ) {
        if (completed || handle != null) return

        if (hasLiveEngineSession()) {
            logger.debug("A session already holds a window open; no warm-up needed")
            completed = true
            return
        }

        val opened = runCatching { openSession() }.getOrElse { error ->
            // Never fatal: without the warm-up the browser behaves exactly as
            // it did before this existed.
            logger.warn("Could not open the engine warm-up session", error)
            null
        } ?: return

        logger.debug("Opened the engine warm-up session")
        handle = opened

        job = scopeFactory().launch {
            val reason = awaitCloseSignal(
                extensionReady = extensionReadySignal(),
                realSession = realSessionSignal(),
                ceilingMs = ceilingMs,
            )
            logger.debug("Closing the engine warm-up session: $reason")
            completed = true
            closeHandle()
        }
    }

    /**
     * Drops the session because the components that own it are going away.
     *
     * Has to run before `EngineProvider.shutdown()`, so the runtime is never
     * torn down while this object still holds a window.
     *
     * Does not mark the warm-up complete: a teardown before either close signal
     * arrived leaves the process still needing a window, and the next [start]
     * should provide one.
     */
    @MainThread
    fun stop() {
        job?.cancel()
        job = null
        closeHandle()
    }

    private fun closeHandle() {
        val current = handle ?: return
        handle = null
        runCatching { current.close() }
            .onFailure { logger.warn("Failed to close the engine warm-up session", it) }
    }

    /**
     * Waits for the first sign that the window is no longer worth holding.
     *
     * Split out from [startWith] because it is the whole policy, and the part
     * most worth pinning down.
     */
    @VisibleForTesting
    internal suspend fun awaitCloseSignal(
        extensionReady: Flow<Unit>,
        realSession: Flow<Unit>,
        ceilingMs: Long,
    ): CloseReason =
        withTimeoutOrNull(ceilingMs) {
            // firstOrNull, not first: a signal flow that finishes without ever
            // emitting is a legitimate "nothing to report" — the store flow
            // closes with its subscription — and `first` answers that with an
            // exception, which would leave the window held for the life of the
            // process. Both that and the timeout mean the same thing here.
            merge(
                extensionReady.map { CloseReason.EXTENSION_READY },
                realSession.map { CloseReason.REAL_SESSION },
            ).firstOrNull()
        } ?: CloseReason.CEILING

    @VisibleForTesting
    internal fun resetForTest() {
        job?.cancel()
        job = null
        handle = null
        completed = false
        ceilingMs = 30_000L
        scopeFactory = { CoroutineScope(Dispatchers.Main.immediate + SupervisorJob()) }
    }

    @VisibleForTesting
    internal fun isOpenForTest(): Boolean = handle != null

    @VisibleForTesting
    internal fun isCompletedForTest(): Boolean = completed
}

/**
 * Whether any tab or custom tab currently owns an engine session, i.e. whether
 * something other than the warm-up session is holding a chrome window open.
 */
private fun BrowserState.hasLiveEngineSession(): Boolean =
    tabs.any { it.engineState.engineSession != null } ||
        customTabs.any { it.engineState.engineSession != null }
