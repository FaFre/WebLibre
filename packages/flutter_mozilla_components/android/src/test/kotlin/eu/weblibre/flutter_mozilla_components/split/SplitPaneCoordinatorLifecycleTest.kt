/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import android.content.Context
import android.os.Looper
import android.view.ContextThemeWrapper
import android.view.View
import eu.weblibre.flutter_mozilla_components.lifecycle.JsonStore
import eu.weblibre.flutter_mozilla_components.lifecycle.PageOutputTracker
import eu.weblibre.flutter_mozilla_components.lifecycle.PresentationMemory
import eu.weblibre.flutter_mozilla_components.lifecycle.SleepBlockerProbe
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycle
import eu.weblibre.flutter_mozilla_components.lifecycle.SleepHoldKind
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycleRegistry
import eu.weblibre.flutter_mozilla_components.pigeons.FrozenPlaceholderLabel
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPairState
import eu.weblibre.flutter_mozilla_components.pigeons.SplitPaneMode
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewLabels
import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.tabs.TabsUseCases
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

/**
 * Sleeping tabs in the panes (5.1, D10): a sleeping tab wakes when it comes on
 * screen and its routing is in place, and otherwise shows its placeholder,
 * whose Wake only asks Dart. Rebuilding the panes is not coming on screen.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class SplitPaneCoordinatorLifecycleTest {
    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    /**
     * Records creations; there is no engine to carry them out, so a pane asks
     * again on every reconcile, as it does while AC's creation runs.
     */
    private class Creations : Middleware<BrowserState, BrowserAction> {
        val tabIds = mutableListOf<String>()

        override fun invoke(
            store: Store<BrowserState, BrowserAction>,
            next: (BrowserAction) -> Unit,
            action: BrowserAction,
        ) {
            if (action is EngineAction.CreateEngineSessionAction) {
                tabIds += action.tabId
                return
            }
            next(action)
        }
    }

    private val registry = TabLifecycleRegistry
    private lateinit var context: Context
    private lateinit var store: BrowserStore
    private lateinit var creations: Creations
    private lateinit var mirror: SplitStateMirrorStore
    private val memory = PresentationMemory()
    private val wakeRequests = mutableListOf<String>()
    private var revision = 0L
    private lateinit var coordinator: SplitPaneCoordinator
    private lateinit var layout: SplitPaneLayout

    @Before
    fun setUp() {
        registry.setStorageForTest(NoStorage)
        context = ContextThemeWrapper(
            RuntimeEnvironment.getApplication(),
            com.google.android.material.R.style.Theme_MaterialComponents_Light,
        )
        creations = Creations()
        mirror = SplitStateMirrorStore()
        store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", engineSession = Mockito.mock(EngineSession::class.java)),
                    createTab("https://b.example", id = "b"),
                    createTab("https://c.example", id = "c"),
                    createTab("https://f.example", id = "f", contextId = "ctx-work"),
                ),
                selectedTabId = "a",
            ),
            middleware = listOf(creations),
        )
    }

    @After
    fun tearDown() {
        coordinator.stop()
        registry.resetForTest()
    }

    private fun startCoordinator() {
        layout = SplitPaneLayout(context)
        coordinator = SplitPaneCoordinator(
            store = store,
            tabsUseCases = TabsUseCases(store),
            sessionUseCases = SessionUseCases(store),
            layout = layout,
            firstPane = PaneView(context, InertEngineView(context)),
            createPane = { PaneView(context, InertEngineView(context)) },
            events = { null },
            onFocusedEngineView = {},
            mirror = mirror,
            mainDispatcher = Dispatchers.Unconfined,
            registry = registry,
            onWakeRequested = { wakeRequests += it },
            presentation = memory,
        )
        coordinator.start()
        coordinator.reconcileNow()
    }

    /**
     * Lays the panes out at [width]×[height] px, as a window of that size
     * does, and runs what the layout posted. Two panes of the pairs below
     * need 568 px side by side.
     */
    private fun layOut(width: Int, height: Int) {
        layout.measure(
            View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY),
        )
        layout.layout(0, 0, width, height)
        shadowOf(Looper.getMainLooper()).idle()
    }

    private fun hold(tabId: String) =
        registry.completeSleep(tabId, registry.beginSleep(tabId, SleepHoldKind.MANUAL, private = false))

    private fun select(tabId: String) {
        store.dispatch(TabListAction.SelectTabAction(tabId))
        coordinator.reconcileNow()
    }

    private fun paneOf(tabId: String) = coordinator.paneViews.single { it.boundTabId == tabId }

    private fun pushPair(first: String, second: String, mode: SplitPaneMode) {
        mirror.accept(
            SplitViewState(
                epoch = "e",
                revision = ++revision,
                pair = SplitPairState(
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
                minPaneWidthDp = 280.0,
                minPaneHeightDp = 200.0,
                dragMinPaneWidthDp = 120.0,
                dragMinPaneHeightDp = 100.0,
                dividerColorArgb = 0,
                gripColorArgb = 0,
                dragPreviewColorArgb = 0,
                placeholderColorArgb = 0xFFFFFFFF,
                onPlaceholderColorArgb = 0xFF000000,
                labels = SplitViewLabels("divider", "options", "crashed", "reload", "asleep", "wake", "frozen", "resume", emptyList()),
            ),
        )
        coordinator.reconcileNow()
    }

    @Test
    fun aSleepingTabThatComesOnScreenShowsItsPlaceholderAndWakeOnlyAsks() {
        startCoordinator()
        hold("b")

        select("b")

        assertTrue(registry.isHeld("b"))
        assertTrue(creations.tabIds.isEmpty())
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("b").placeholderKind)

        clickPlaceholderButton(paneOf("b"))
        assertEquals(listOf("b"), wakeRequests)
        assertTrue(registry.isHeld("b"))
    }

    @Test
    fun aTabPutToSleepOnScreenStaysAsleepWhenShownAgain() {
        startCoordinator()
        hold("a")
        store.dispatch(EngineAction.UnlinkEngineSessionAction("a"))
        coordinator.reconcileNow()

        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("a").placeholderKind)
        assertTrue(registry.isHeld("a"))

        select("b")
        select("a")

        assertTrue(registry.isHeld("a"))
        assertFalse("a" in creations.tabIds)
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("a").placeholderKind)
    }

    @Test
    fun aRebuiltCoordinatorDoesNotWakeWhatWasAlreadyOnScreen() {
        startCoordinator()
        hold("a")
        store.dispatch(EngineAction.UnlinkEngineSessionAction("a"))
        coordinator.reconcileNow()
        coordinator.stop()

        // A configuration change builds the panes anew, over the same memory.
        startCoordinator()

        assertTrue(registry.isHeld("a"))
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("a").placeholderKind)
    }

    @Test
    fun aTabSleptByTheOperationWakesOnlyWhenWoken() {
        startCoordinator()
        val lifecycle = TabLifecycle(
            store = store,
            probe = SleepBlockerProbe(PageOutputTracker(), hasChosenUploads = { false }),
            panes = { coordinator },
            events = {},
            registry = registry,
            flusher = { _, onComplete -> onComplete(true) },
            mainDispatcher = Dispatchers.Unconfined,
            formDataCheck = { false },
        )

        val slept = runBlocking { lifecycle.sleep(listOf("a"), stopMedia = false, discardPostResult = false) }
        assertTrue(slept.single().asleep)
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("a").placeholderKind)

        select("b")
        select("a")
        assertTrue(registry.isHeld("a"))
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("a").placeholderKind)

        // Wake, as Dart does after its routing check: the page comes back.
        lifecycle.wake("a")

        assertFalse(registry.isHeld("a"))
        assertTrue("a" in creations.tabIds)
        assertNull(paneOf("a").placeholderKind)
    }

    @Test
    fun aHeldTabThatStillHasItsPageKeepsShowingIt() {
        startCoordinator()
        registry.beginSleep("a", SleepHoldKind.MANUAL, private = false)
        coordinator.reconcileNow()

        assertNull(paneOf("a").placeholderKind)
        assertTrue(paneOf("a").attachedSession != null)
    }

    @Test
    fun aCollapsedPartnerStaysAsleep() {
        startCoordinator()
        hold("b")

        pushPair("a", "b", SplitPaneMode.FOCUSED_ONLY)

        assertTrue(registry.isHeld("b"))
        assertTrue(creations.tabIds.isEmpty())
    }

    @Test
    fun aPartnerShownBesideTheSelectedTabShowsItsPlaceholder() {
        startCoordinator()
        layOut(1200, 800)
        hold("b")

        pushPair("a", "b", SplitPaneMode.SIDE_BY_SIDE)

        assertTrue(registry.isHeld("b"))
        assertTrue(creations.tabIds.isEmpty())
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("b").placeholderKind)
    }

    @Test
    fun aPartnerTheLayoutHasNoRoomForIsNotPresentedUntilItFits() {
        startCoordinator()
        layOut(400, 800)
        hold("b")

        pushPair("a", "b", SplitPaneMode.SIDE_BY_SIDE)
        layOut(400, 800)

        // Drawn as the focused pane alone: not on screen, so not presented to
        // the schedulers.
        assertTrue(registry.isHeld("b"))
        assertTrue(creations.tabIds.isEmpty())
        assertEquals(setOf("a"), memory.tabIds)

        // Room for both, as after a rotation: on screen, still asleep.
        layOut(1200, 800)

        assertTrue(registry.isHeld("b"))
        assertTrue(creations.tabIds.isEmpty())
        assertEquals(setOf("a", "b"), memory.tabIds)
    }

    @Test
    fun aRebuiltLayoutDoesNotWakeAPartnerThatWasAlreadyOnScreen() {
        startCoordinator()
        layOut(1200, 800)
        pushPair("a", "b", SplitPaneMode.SIDE_BY_SIDE)
        hold("b")
        coordinator.reconcileNow()
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("b").placeholderKind)
        coordinator.stop()

        // A configuration change builds the panes anew, over the same memory,
        // and lays them out a moment later.
        startCoordinator()
        layOut(1200, 800)

        assertTrue(registry.isHeld("b"))
        assertEquals(PaneView.PlaceholderKind.SLEEPING, paneOf("b").placeholderKind)
    }

    @Test
    fun aFrozenTabShowsItsContainersOwnTitleAndDetail() {
        startCoordinator()
        registry.beginFreeze("work", listOf("ctx-work"))
        mirror.accept(
            SplitViewState(
                epoch = "e",
                revision = ++revision,
                pair = null,
                minPaneWidthDp = 280.0,
                minPaneHeightDp = 200.0,
                dragMinPaneWidthDp = 120.0,
                dragMinPaneHeightDp = 100.0,
                dividerColorArgb = 0,
                gripColorArgb = 0,
                dragPreviewColorArgb = 0,
                placeholderColorArgb = 0xFFFFFFFF,
                onPlaceholderColorArgb = 0xFF000000,
                labels = SplitViewLabels(
                    "divider", "options", "crashed", "reload", "asleep", "wake",
                    "This container is frozen", "Resume",
                    listOf(FrozenPlaceholderLabel("work", "Work is frozen", "2 messages were skipped")),
                ),
            ),
        )

        select("f")

        assertEquals(PaneView.PlaceholderKind.FROZEN, paneOf("f").placeholderKind)
        assertTrue(creations.tabIds.isEmpty())
        assertEquals(listOf("Work is frozen", "2 messages were skipped"), visibleTexts(paneOf("f")))
    }

    private fun visibleTexts(pane: PaneView): List<String> {
        fun collect(view: android.view.View): List<String> = when {
            view.visibility != android.view.View.VISIBLE -> emptyList()
            view is com.google.android.material.button.MaterialButton -> emptyList()
            view is android.widget.TextView -> listOf(view.text.toString())
            view is android.view.ViewGroup -> (0 until view.childCount).flatMap { collect(view.getChildAt(it)) }
            else -> emptyList()
        }
        return collect(pane)
    }

    private fun clickPlaceholderButton(pane: PaneView) {
        fun find(view: android.view.View): com.google.android.material.button.MaterialButton? = when (view) {
            is com.google.android.material.button.MaterialButton -> view
            is android.view.ViewGroup -> (0 until view.childCount).firstNotNullOfOrNull { find(view.getChildAt(it)) }
            else -> null
        }
        requireNotNull(find(pane)).performClick()
    }
}
