/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.content.Context
import android.graphics.Bitmap
import android.view.ContextThemeWrapper
import android.widget.FrameLayout
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPaneMode
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewLabels
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import kotlin.test.fail
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.emptyFlow
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CrashAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentCaptor
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * Which engine view renders which session. GeckoView allows one display per
 * session, so a session rendered by a second view before the first released
 * it fails the test at once.
 */
private class Displays {
    val log = mutableListOf<String>()
    private val owners = mutableMapOf<EngineSession, FakeEngineView>()

    fun render(view: FakeEngineView, session: EngineSession) {
        val owner = owners[session]
        if (owner != null && owner !== view) {
            fail("${view.name} rendered a session ${owner.name} still shows")
        }
        owners.entries.removeAll { it.value === view }
        owners[session] = view
        log += "render ${view.name} ${names[session]}"
    }

    fun release(view: FakeEngineView) {
        owners.entries.removeAll { it.value === view }
        log += "release ${view.name}"
    }

    val names = mutableMapOf<EngineSession, String>()
}

private class FakeEngineView(
    context: Context,
    val name: String,
    private val displays: Displays,
) : FrameLayout(context), EngineView {
    var clearableSelection = false
    var selectionCleared = false
    var pendingThumbnail: ((Bitmap?) -> Unit)? = null

    override fun render(session: EngineSession) = displays.render(this, session)
    override fun release() = displays.release(this)
    override fun canClearSelection(): Boolean = clearableSelection
    override fun clearSelection() {
        selectionCleared = true
    }

    override val verticalScrollPosition: Flow<Float> = emptyFlow()
    override val verticalScrollDelta: Flow<Float> = emptyFlow()
    override fun captureThumbnail(onFinish: (Bitmap?) -> Unit) {
        pendingThumbnail = onFinish
    }

    override fun setVerticalClipping(clippingHeight: Int) = Unit
    override fun setDynamicToolbarMaxHeight(height: Int) = Unit
    override fun setActivityContext(context: Context?) = Unit
    override fun addWindowInsetsListener(
        key: String,
        listener: androidx.core.view.OnApplyWindowInsetsListener?,
    ) = Unit
    override fun removeWindowInsetsListener(key: String) = Unit
    override var selectionActionDelegate: SelectionActionDelegate? = null
}

/**
 * Records every action, then lets it through, except the navigation that
 * AC's engine middleware would carry out (there is no engine here).
 */
private class CapturingMiddleware : Middleware<BrowserState, BrowserAction> {
    val actions = mutableListOf<BrowserAction>()

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        actions += action
        if (action is EngineAction.GoBackAction || action is EngineAction.GoForwardAction) return
        next(action)
    }
}

/** Mockito's `any()` for a non-null Kotlin parameter. */
private fun <T> anyNonNull(fallback: T): T = Mockito.any<T>() ?: fallback

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class SplitPaneCoordinatorTest {
    private lateinit var context: Context
    private lateinit var displays: Displays
    private lateinit var captured: CapturingMiddleware
    private lateinit var store: BrowserStore
    private lateinit var mirror: SplitStateMirrorStore
    private lateinit var coordinator: SplitPaneCoordinator
    private val views = mutableListOf<FakeEngineView>()
    private var revision = 0L

    private val pendingNames = mutableMapOf<EngineSession, String>()

    private fun session(name: String): EngineSession =
        Mockito.mock(EngineSession::class.java).also { pendingNames[it] = name }

    private val sessionA = session("sA")
    private val sessionB = session("sB")
    private val sessionC = session("sC")

    private fun pane(): PaneView {
        val view = FakeEngineView(context, "view${views.size}", displays)
        views += view
        return PaneView(context, view)
    }

    @Before
    fun setUp() {
        context = ContextThemeWrapper(
            RuntimeEnvironment.getApplication(),
            com.google.android.material.R.style.Theme_MaterialComponents_Light,
        )
        displays = Displays().apply { names.putAll(pendingNames) }
        captured = CapturingMiddleware()
        mirror = SplitStateMirrorStore()
    }

    private fun start(
        selected: String = "a",
        sessions: Map<String, EngineSession> = mapOf("a" to sessionA, "b" to sessionB, "c" to sessionC),
    ) {
        store = BrowserStore(
            initialState = BrowserState(
                tabs = listOf("a", "b", "c").map { id ->
                    createTab("https://$id.example", id = id, engineSession = sessions[id])
                },
                selectedTabId = selected,
            ),
            middleware = listOf(captured),
        )
        val layout = SplitPaneLayout(context)
        coordinator = SplitPaneCoordinator(
            store = store,
            tabsUseCases = TabsUseCases(store),
            sessionUseCases = SessionUseCases(store),
            layout = layout,
            firstPane = pane(),
            createPane = { pane() },
            events = { null },
            onFocusedEngineView = {},
            mirror = mirror,
            mainDispatcher = Dispatchers.Unconfined,
        )
        coordinator.start()
        coordinator.reconcileNow()
    }

    private fun pushPair(
        first: String,
        second: String,
        mode: SplitPaneMode = SplitPaneMode.SIDE_BY_SIDE,
    ) {
        push(
            SplitPairState(
                pairId = "p",
                firstTabId = first,
                secondTabId = second,
                mode = mode,
                ratio = 0.5,
                dividerDp = 8.0,
                draggable = true,
                firstAccentArgb = 0,
                secondAccentArgb = 0,
            ),
        )
    }

    private fun push(pair: SplitPairState?) {
        mirror.accept(
            SplitViewState(
                epoch = "e",
                revision = ++revision,
                pair = pair,
                minPaneWidthDp = 280.0,
                minPaneHeightDp = 200.0,
                dragMinPaneWidthDp = 120.0,
                dragMinPaneHeightDp = 100.0,
                dividerColorArgb = 0,
                gripColorArgb = 0,
                dragPreviewColorArgb = 0,
                placeholderColorArgb = 0xFFFFFFFF,
                onPlaceholderColorArgb = 0xFF000000,
                labels = SplitViewLabels("divider", "options", "crashed", "reload"),
            ),
        )
        coordinator.reconcileNow()
    }

    private fun select(tabId: String) {
        store.dispatch(TabListAction.SelectTabAction(tabId))
        coordinator.reconcileNow()
    }

    private fun paneOf(tabId: String) = coordinator.paneViews.single { it.boundTabId == tabId }

    @Test
    fun theOtherPageOnScreenIsRaisedToHighPriority() {
        start()
        pushPair("a", "b")

        // The selected tab is AC's to raise; the page beside it is ours.
        Mockito.verify(sessionB).updateSessionPriority(EngineSession.SessionPriority.HIGH)
        Mockito.verify(sessionA, Mockito.never())
            .updateSessionPriority(EngineSession.SessionPriority.HIGH)

        // Focus moves: the page left behind is still on screen, so it is
        // raised, and the newly selected one is not lowered.
        select("b")
        Mockito.verify(sessionA).updateSessionPriority(EngineSession.SessionPriority.HIGH)
        Mockito.verify(sessionB, Mockito.never()).checkForFormData(Mockito.anyBoolean())
    }

    @Test
    fun aPageLeavingTheScreenGoesBackToAcsRule() {
        start()
        pushPair("a", "b")

        // Only this page: the partner is hidden, and lowered as AC lowers a
        // tab that is no longer shown.
        pushPair("a", "b", mode = SplitPaneMode.FOCUSED_ONLY)
        Mockito.verify(sessionB).checkForFormData(true)

        pushPair("a", "b")
        Mockito.verify(sessionB, Mockito.times(2))
            .updateSessionPriority(EngineSession.SessionPriority.HIGH)

        // Ended: the same.
        push(null)
        Mockito.verify(sessionB, Mockito.times(2)).checkForFormData(true)
        Mockito.verify(sessionA, Mockito.never()).checkForFormData(Mockito.anyBoolean())
    }

    @Test
    fun aTabWithoutSessionIsCreatedThenRenderedOnceLinked() {
        start(sessions = mapOf("b" to sessionB))

        assertTrue(
            captured.actions.any { it is EngineAction.CreateEngineSessionAction && it.tabId == "a" },
        )
        assertEquals("a", paneOf("a").boundTabId)
        assertNull(paneOf("a").attachedSession)

        store.dispatch(EngineAction.LinkEngineSessionAction("a", sessionA))
        coordinator.reconcileNow()

        assertSame(sessionA, paneOf("a").attachedSession)
        assertEquals(listOf("render view0 sA"), displays.log)
    }

    @Test
    fun aSessionReplacedUnderTheSameIdIsReleasedBeforeTheNewOneRenders() {
        start()
        val replacement = session("sA2").also { displays.names[it] = "sA2" }

        store.dispatch(EngineAction.UnlinkEngineSessionAction("a"))
        coordinator.reconcileNow()
        assertNull(paneOf("a").attachedSession)

        store.dispatch(EngineAction.LinkEngineSessionAction("a", replacement))
        coordinator.reconcileNow()

        assertEquals(listOf("render view0 sA", "release view0", "render view0 sA2"), displays.log)
        assertSame(replacement, paneOf("a").attachedSession)
    }

    @Test
    fun aPairShowsBothTabsKeepingTheFocusedOneOnItsPane() {
        start()
        pushPair("a", "b")

        assertEquals(2, coordinator.paneViews.size)
        // The selected tab stays on the pane it was on; the partner gets the new one.
        assertEquals("a", coordinator.paneViews[0].boundTabId)
        assertEquals("b", coordinator.paneViews[1].boundTabId)
        assertEquals(setOf("a", "b"), coordinator.visibleTabIds)
        assertEquals(listOf("render view0 sA", "render view1 sB"), displays.log)
        assertSame(views[0], coordinator.focusedEngineView)
    }

    @Test
    fun swappingAndMovingFocusNeverRebinds() {
        start()
        pushPair("a", "b")
        displays.log.clear()

        pushPair("b", "a")
        select("b")

        assertEquals(emptyList(), displays.log)
        assertSame(views[1], coordinator.focusedEngineView)
    }

    @Test
    fun panesTradingTabsNeverShowOneSessionTwice() {
        start()
        pushPair("a", "b")
        // A pair replaced by one sharing a tab, then an unrelated tab, then
        // a pair in the other order: Displays fails on any double display.
        pushPair("b", "c")
        select("b")
        select("c")
        pushPair("c", "a")
        select("a")
        pushPair("b", "a", SplitPaneMode.STACKED)

        assertEquals(setOf("a", "b"), coordinator.visibleTabIds)
    }

    @Test
    fun anUnrelatedTabIsShownAloneAndThePairComesBack() {
        start()
        pushPair("a", "b")

        select("c")
        assertEquals(setOf("c"), coordinator.visibleTabIds)
        assertEquals(setOf("c"), coordinator.lastPresentedTabIds)

        select("b")
        assertEquals(setOf("a", "b"), coordinator.visibleTabIds)
    }

    @Test
    fun fullscreenShowsTheRequestingPaneAlone() {
        start()
        pushPair("a", "b")

        store.dispatch(ContentAction.FullScreenChangedAction("a", true))
        coordinator.reconcileNow()
        assertEquals(setOf("a"), coordinator.visibleTabIds)

        store.dispatch(ContentAction.FullScreenChangedAction("a", false))
        coordinator.reconcileNow()
        assertEquals(setOf("a", "b"), coordinator.visibleTabIds)
    }

    @Test
    fun aCrashedMemberShowsThePlaceholderAndReattachesOnRestore() {
        start()
        pushPair("a", "b")

        store.dispatch(CrashAction.SessionCrashedAction("b"))
        coordinator.reconcileNow()
        assertTrue(paneOf("b").isShowingCrashPlaceholder)
        assertNull(paneOf("b").attachedSession)
        assertFalse(paneOf("a").isShowingCrashPlaceholder)

        store.dispatch(CrashAction.RestoreCrashedSessionAction("b"))
        coordinator.reconcileNow()
        assertFalse(paneOf("b").isShowingCrashPlaceholder)
        assertSame(sessionB, paneOf("b").attachedSession)
    }

    @Test
    fun stoppingReleasesEverythingButRemembersWhatWasPresented() {
        start()
        pushPair("a", "b")

        coordinator.stop()

        assertTrue(coordinator.paneViews.all { it.attachedSession == null })
        assertEquals(emptySet(), coordinator.visibleTabIds)
        assertEquals(setOf("a", "b"), coordinator.lastPresentedTabIds)
    }

    @Test
    fun backClearsASelectionFirst() {
        start()
        views[0].clearableSelection = true

        assertTrue(coordinator.onBackPressed())
        assertTrue(views[0].selectionCleared)
        Mockito.verify(sessionA, Mockito.never()).processBackPressed(anyNonNull { _ -> })
    }

    @Test
    fun backLetsThePageHandleItThenFallsBackToHistory() {
        start()
        store.dispatch(ContentAction.UpdateBackNavigationStateAction("a", true))

        assertTrue(coordinator.onBackPressed())

        @Suppress("UNCHECKED_CAST")
        val callback = ArgumentCaptor.forClass(Function1::class.java)
            as ArgumentCaptor<(Boolean) -> Unit>
        Mockito.verify(sessionA).processBackPressed(callback.capture() ?: { _ -> })
        assertFalse(captured.actions.any { it is EngineAction.GoBackAction })

        // The page did not handle it.
        callback.value(false)
        assertTrue(captured.actions.any { it is EngineAction.GoBackAction && it.tabId == "a" })
    }

    @Test
    fun backWithNoHistoryIsNotHandled() {
        start()
        assertFalse(coordinator.onBackPressed())
    }
}
