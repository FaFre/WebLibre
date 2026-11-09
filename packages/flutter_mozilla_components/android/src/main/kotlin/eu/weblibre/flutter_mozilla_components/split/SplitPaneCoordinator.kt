/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.graphics.Color
import android.view.View
import com.google.android.material.color.MaterialColors
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSplitViewEvents
import eu.weblibre.flutter_mozilla_components.pigeons.SplitAxis
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPaneMode
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import mozilla.components.browser.state.action.CrashAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.LastAccessAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.feature.UserInteractionHandler

/**
 * Presents the main browser's tabs in up to two panes, replacing AC's
 * `SessionFeature` in the main browser fragment.
 *
 * The presentation is a pure function of the store and the split mirror: the
 * selected tab, plus its partner while the mirror's pair contains it. Native
 * selection stays the authority, and Dart never computes bindings.
 *
 * Each reconcile has two steps. First the tabs are assigned to panes
 * ([planBindings]), keeping a pane on a tab that is still visible. Then each
 * pane's view is brought to its tab's current engine session, releasing
 * everything that changes before attaching anything, so one session is never
 * attached to two views (GeckoView allows one display per session).
 */
internal class SplitPaneCoordinator(
    private val store: BrowserStore,
    private val tabsUseCases: TabsUseCases,
    private val sessionUseCases: SessionUseCases,
    private val layout: SplitPaneLayout,
    firstPane: PaneView,
    /** Builds the second pane on the first split; the coordinator adds it to the layout. */
    private val createPane: () -> PaneView,
    private val events: () -> GeckoSplitViewEvents?,
    /** Told whenever the focused pane's engine view may have changed. */
    private val onFocusedEngineView: (EngineView) -> Unit,
    /** Told once a pane was created, to apply per-view settings to it. */
    private val onPaneCreated: (PaneView) -> Unit = {},
    private val mirror: SplitStateMirrorStore = SplitStateMirror,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
    private val currentTimeMillis: () -> Long = System::currentTimeMillis,
) : LifecycleAwareFeature, UserInteractionHandler, BrowserPanes, SplitPaneLayout.Listener {

    private val panes = mutableListOf(firstPane)
    private var scope: CoroutineScope? = null
    private var started = false
    private var reconciling = false

    /**
     * The inputs of the last reconcile. A push from Dart reconciles at once
     * ([reconcileNow]); the store collector then sees the same inputs and
     * skips them.
     */
    private var lastReconciledKey: ReconcileKey? = null

    /** The selection the last reconcile presented, to tell a change apart. */
    private var lastSelectedTabId: String? = null

    /** See [lastPresentedTabIds]; kept when stopping. */
    private var presentedTabIds: Set<String> = emptySet()

    /**
     * The sessions this coordinator raised to HIGH priority: pages on screen
     * that are not the selected tab, which AC's `SessionPrioritizationMiddleware`
     * leaves at DEFAULT. See [updatePriorities].
     */
    private val raisedSessions = mutableMapOf<String, EngineSession>()

    private val onMirrorCleared: () -> Unit = { layout.cancelDividerStream() }

    init {
        setUpPane(firstPane)
        layout.listener = this
    }

    private fun setUpPane(pane: PaneView) {
        pane.onFocusEntered = { activate(it) }
        if (pane.parent == null) {
            layout.addView(pane)
        }
    }

    val paneViews: List<PaneView> get() = panes.toList()

    // Lifecycle ----------------------------------------------------------

    override fun start() {
        if (started) return
        started = true
        mirror.addClearListener(onMirrorCleared)
        panes.forEach { pane -> pane.features.forEach { it.start() } }
        scope = store.flowScoped(dispatcher = mainDispatcher) { flow ->
            combine(flow, mirror.state) { state, split -> reconcileKey(state, split) }
                .distinctUntilChanged()
                .collect { key -> if (key != lastReconciledKey) reconcile() }
        }
    }

    override fun stop() {
        if (!started) return
        started = false
        mirror.removeClearListener(onMirrorCleared)
        scope?.cancel()
        scope = null
        lastReconciledKey = null
        layout.cancelDividerStream()
        panes.forEach { pane -> pane.features.forEach { it.stop() } }
        releaseAll()
    }

    /** The inputs of a reconcile; anything else changing needs no work. */
    private data class TabKey(
        val id: String,
        val session: EngineSession?,
        val crashed: Boolean,
        val firstContentfulPaint: Boolean,
        val fullScreen: Boolean,
    )

    private data class ReconcileKey(
        val selectedTabId: String?,
        val split: SplitViewState?,
        val tabs: List<TabKey?>,
    )

    private fun reconcileKey(state: BrowserState, split: SplitViewState?): ReconcileKey {
        val ids = listOfNotNull(
            state.selectedTabId,
            split?.pair?.firstTabId,
            split?.pair?.secondTabId,
        ).distinct()
        return ReconcileKey(
            state.selectedTabId,
            split,
            ids.map { id ->
                state.findTab(id)?.let { tab ->
                    TabKey(
                        tab.id,
                        tab.engineState.engineSession,
                        tab.engineState.crashed,
                        tab.content.firstContentfulPaint,
                        tab.content.fullScreen,
                    )
                }
            },
        )
    }

    override fun reconcileNow() = reconcile()

    // Reconcile ----------------------------------------------------------

    /** The pair to show for [state], or null for single presentation. */
    private fun activePair(state: BrowserState, split: SplitViewState?): SplitPairState? {
        val selected = state.selectedTab ?: return null
        val pair = split?.pair ?: return null
        if (pair.firstTabId == pair.secondTabId) return null
        if (selected.id != pair.firstTabId && selected.id != pair.secondTabId) return null
        if (state.findTab(pair.firstTabId) == null || state.findTab(pair.secondTabId) == null) {
            return null
        }
        // Fullscreen shows the requesting pane alone, at once, and restores
        // the pair on exit.
        if (selected.content.fullScreen) return null
        return pair
    }

    private fun reconcile() {
        if (!started || reconciling) return
        reconciling = true
        try {
            reconcileInternal()
        } finally {
            reconciling = false
        }
    }

    private fun reconcileInternal() {
        val state = store.state
        val split = mirror.state.value
        lastReconciledKey = reconcileKey(state, split)
        val selected = state.selectedTab
        if (selected == null) {
            releaseAll()
            return
        }

        val pair = activePair(state, split)
        val targets = if (pair != null) {
            listOf(pair.firstTabId, pair.secondTabId)
        } else {
            listOf(selected.id)
        }
        while (panes.size < targets.size) {
            val pane = createPane()
            panes += pane
            setUpPane(pane)
            if (started) pane.features.forEach { it.start() }
            onPaneCreated(pane)
        }

        // 1. Tab assignment.
        val plan = planBindings(panes.map { it.boundTabId }, targets)
        panes.forEachIndexed { index, pane ->
            val next = plan[index]
            if (pane.boundTabId != next) {
                stampLastVisible(pane)
                pane.boundTabId = next
            }
        }

        // 2. Session attachment: every release before any attach.
        val tabs = panes.map { pane -> pane.boundTabId?.let { state.findTab(it) } }
        panes.forEachIndexed { index, pane ->
            val attached = pane.attachedSession ?: return@forEachIndexed
            if (attached !== desiredSession(tabs[index])) {
                pane.detach()
            }
        }
        panes.forEachIndexed { index, pane -> bringUp(pane, tabs[index], split) }

        // 3. Presentation.
        val focusedPane = panes.first { it.boundTabId == selected.id }
        layout.apply(spec(pair, split, focusedPane))
        presentedTabIds = if (pair != null && pair.mode != SplitPaneMode.FOCUSED_ONLY) {
            targets.toSet()
        } else {
            setOf(selected.id)
        }
        updatePriorities(state, selected.id)

        onFocusedEngineView(focusedPane.engineView)

        // Native focus follows a selection made elsewhere (tray, shortcut,
        // action), but only while the page area has focus: the address bar
        // keeps focus while it is being edited. Only on a change of the
        // selection, so the divider keeps keyboard focus while it is moved.
        val selectionChanged = selected.id != lastSelectedTabId
        lastSelectedTabId = selected.id
        if (selectionChanged && layout.hasFocus() && !focusedPane.hasFocus()) {
            focusedPane.engineView.asView().requestFocus()
        }
    }

    /**
     * Keeps every page on screen at HIGH priority.
     *
     * AC's `SessionPrioritizationMiddleware` raises the selected tab and
     * lowers the tab selected before it (through `checkForFormData`), which is
     * right while only the selected tab is visible. In a split the other page
     * is visible too; at DEFAULT its content process drops to a background
     * binding, where loads stall and the page's state (progress, security)
     * stops arriving until it is selected (seen on device: a page beside the
     * selected one took 52 s to finish loading).
     *
     * A page leaving the screen goes back to AC's rule: DEFAULT, or HIGH for
     * a while if it holds form data. A later DEFAULT from AC for a page still
     * on screen is undone by [PresentedPanePriorityMiddleware].
     */
    private fun updatePriorities(state: BrowserState, selectedTabId: String) {
        val wanted = presentedTabIds - selectedTabId
        raisedSessions.entries.removeAll { (tabId, session) ->
            val current = state.findTab(tabId)?.engineState?.engineSession
            val keep = tabId in wanted && current === session
            if (!keep && tabId != selectedTabId && current === session) {
                session.checkForFormData()
            }
            !keep
        }
        wanted.forEach { tabId ->
            val session = state.findTab(tabId)?.engineState?.engineSession ?: return@forEach
            if (raisedSessions[tabId] !== session) {
                session.updateSessionPriority(EngineSession.SessionPriority.HIGH)
                raisedSessions[tabId] = session
            }
        }
    }

    private fun desiredSession(tab: TabSessionState?): EngineSession? =
        tab?.takeUnless { it.engineState.crashed }?.engineState?.engineSession

    private fun bringUp(pane: PaneView, tab: TabSessionState?, split: SplitViewState?) {
        if (tab == null) {
            pane.hideCrashPlaceholder()
            return
        }

        if (tab.engineState.crashed) {
            showCrashPlaceholder(pane, tab.id, split)
            return
        }
        pane.hideCrashPlaceholder()

        if (tab.content.firstContentfulPaint) {
            pane.engineView.asView().visibility = View.VISIBLE
        }

        val session = tab.engineState.engineSession
        when {
            // Requested here, rendered by the reconcile its link triggers.
            session == null -> store.dispatch(EngineAction.CreateEngineSessionAction(tab.id))
            pane.attachedSession !== session -> {
                pane.attach(session)
                pane.refreshHiddenSurfaces()
                store.dispatch(LastAccessAction.UpdateLastAccessAction(tab.id, currentTimeMillis()))
            }
        }
    }

    private fun showCrashPlaceholder(pane: PaneView, tabId: String, split: SplitViewState?) {
        val labels = split?.labels
        pane.showCrashPlaceholder(
            // Dart sends the localized labels once its theme is known and
            // leaves them empty before that.
            title = labels?.crashedTitle?.takeIf { it.isNotEmpty() } ?: DEFAULT_CRASHED_TITLE,
            reload = labels?.crashedReload?.takeIf { it.isNotEmpty() } ?: DEFAULT_CRASHED_RELOAD,
            backgroundColor = split?.placeholderColorArgb?.toInt()
                ?: MaterialColors.getColor(
                    pane,
                    com.google.android.material.R.attr.colorSurface,
                    Color.WHITE,
                ),
            foregroundColor = split?.onPlaceholderColorArgb?.toInt()
                ?: MaterialColors.getColor(
                    pane,
                    com.google.android.material.R.attr.colorOnSurface,
                    Color.BLACK,
                ),
            onReload = { store.dispatch(CrashAction.RestoreCrashedSessionAction(tabId)) },
        )
    }

    private fun spec(
        pair: SplitPairState?,
        split: SplitViewState?,
        focusedPane: PaneView,
    ): SplitPaneLayout.Spec {
        val firstPane = pair?.let { p -> panes.first { it.boundTabId == p.firstTabId } }
        val secondPane = pair?.let { p -> panes.first { it.boundTabId == p.secondTabId } }
        return SplitPaneLayout.Spec(
            requested = when (pair?.mode) {
                SplitPaneMode.SIDE_BY_SIDE -> PaneArrangement.SIDE_BY_SIDE
                SplitPaneMode.STACKED -> PaneArrangement.STACKED
                SplitPaneMode.FOCUSED_ONLY, null -> PaneArrangement.SINGLE
            },
            first = firstPane ?: focusedPane,
            second = secondPane,
            focused = focusedPane,
            ratio = pair?.ratio ?: 0.5,
            dividerDp = pair?.dividerDp ?: 0.0,
            draggable = pair?.draggable ?: false,
            minWidthDp = split?.minPaneWidthDp ?: DEFAULT_MIN_WIDTH_DP,
            minHeightDp = split?.minPaneHeightDp ?: DEFAULT_MIN_HEIGHT_DP,
            dragMinWidthDp = split?.dragMinPaneWidthDp ?: DEFAULT_DRAG_MIN_WIDTH_DP,
            dragMinHeightDp = split?.dragMinPaneHeightDp ?: DEFAULT_DRAG_MIN_HEIGHT_DP,
            firstAccent = pair?.firstAccentArgb?.toInt() ?: Color.TRANSPARENT,
            secondAccent = pair?.secondAccentArgb?.toInt() ?: Color.TRANSPARENT,
            dividerColor = split?.dividerColorArgb?.toInt() ?: Color.TRANSPARENT,
            gripColor = split?.gripColorArgb?.toInt() ?: Color.TRANSPARENT,
            dragPreviewColor = split?.dragPreviewColorArgb?.toInt() ?: Color.TRANSPARENT,
            dividerDescription = split?.labels?.dividerDescription.orEmpty(),
            dividerOptionsAction = split?.labels?.dividerOptionsAction.orEmpty(),
            pairId = pair?.pairId,
        )
    }

    private fun stampLastVisible(pane: PaneView) {
        val tabId = pane.boundTabId ?: return
        if (store.state.findTab(tabId) != null) {
            store.dispatch(LastAccessAction.UpdateLastVisibleAtAction(tabId, currentTimeMillis()))
        }
    }

    private fun releaseAll() {
        panes.forEach { pane ->
            stampLastVisible(pane)
            pane.detach()
            pane.boundTabId = null
            pane.hideCrashPlaceholder()
        }
    }

    // Input --------------------------------------------------------------

    /**
     * Makes [pane]'s tab the selected one: a pointer down or input focus in a
     * pane that is not focused. Idempotent, so a pointer down followed by the
     * focus change it causes selects once.
     */
    private fun activate(pane: PaneView) {
        if (reconciling || !started) return
        if (!pane.isPaneShown) return
        val tabId = pane.boundTabId ?: return
        if (store.state.selectedTabId == tabId) return
        if (store.state.findTab(tabId) == null) return

        tabsUseCases.selectTab(tabId)
        val epoch = mirror.epoch ?: return
        events()?.onPaneActivated(EventSequence.next(), epoch, tabId) { }
    }

    override fun onPaneTouched(pane: PaneView) = activate(pane)

    override fun onRatioCommitted(axis: SplitAxis, ratio: Double) {
        val split = mirror.state.value ?: return
        val pair = split.pair ?: return
        events()?.onRatioCommitted(EventSequence.next(), split.epoch, pair.pairId, axis, ratio) { }
    }

    override fun onDividerCollapsed(kept: PaneView) {
        val split = mirror.state.value ?: return
        val pair = split.pair ?: return
        val keptTabId = kept.boundTabId ?: return
        // The kept page is shown alone, and the page shown alone is the
        // selected one: select it first, as a touch on it would.
        activate(kept)
        events()?.onDividerCollapsed(EventSequence.next(), split.epoch, pair.pairId, keptTabId) { }
    }

    override fun onHandleTapped() {
        val split = mirror.state.value ?: return
        val pair = split.pair ?: return
        events()?.onHandleTapped(EventSequence.next(), split.epoch, pair.pairId) { }
    }

    /**
     * AC's `SessionFeature.onBackPressed`, on the focused pane: clear a text
     * selection first, then let the page handle Back, then go back in history.
     */
    override fun onBackPressed(): Boolean {
        val tab = store.state.selectedTab ?: return false
        val engineView = engineViewFor(tab.id)

        if (engineView?.canClearSelection() == true) {
            engineView.clearSelection()
            return true
        }

        if (tab.content.canGoBack) {
            val engineSession = tab.engineState.engineSession
            if (engineSession != null) {
                engineSession.processBackPressed { handled ->
                    if (!handled) {
                        sessionUseCases.goBack(tab.id)
                    }
                }
            } else {
                sessionUseCases.goBack(tab.id)
            }
            return true
        }

        return false
    }

    override fun onForwardPressed(): Boolean {
        val tab = store.state.selectedTab ?: return false
        if (tab.content.canGoForward) {
            sessionUseCases.goForward(tab.id)
            return true
        }
        return false
    }

    // BrowserPanes -------------------------------------------------------

    override val focusedEngineView: EngineView?
        get() = store.state.selectedTabId?.let { engineViewFor(it) }

    override val allEngineViews: List<EngineView>
        get() = panes.map { it.engineView }

    override val visibleTabIds: Set<String>
        get() = panes.filter { it.isPaneShown }.mapNotNull { it.boundTabId }.toSet()

    override val lastPresentedTabIds: Set<String>
        get() = presentedTabIds

    override fun engineViewFor(tabId: String): EngineView? =
        panes.firstOrNull { it.boundTabId == tabId }?.engineView

    override fun isDividerHitOnScreen(rawX: Float, rawY: Float): Boolean =
        layout.isDividerHitOnScreen(rawX, rawY)

    companion object {
        private const val DEFAULT_MIN_WIDTH_DP = 280.0
        private const val DEFAULT_MIN_HEIGHT_DP = 200.0
        private const val DEFAULT_DRAG_MIN_WIDTH_DP = 48.0
        private const val DEFAULT_DRAG_MIN_HEIGHT_DP = 48.0

        // Only shown before Dart pushed its localized labels once.
        private const val DEFAULT_CRASHED_TITLE = "This page crashed"
        private const val DEFAULT_CRASHED_RELOAD = "Reload"
    }
}
