/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepResult
import eu.weblibre.flutter_mozilla_components.split.BrowserPanes
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.DownloadAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.MediaSessionAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSessionState
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.mediasession.MediaSession
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Putting a tab to sleep (5.2): what refuses it, what each failure leaves
 * behind (always the tab as it was, never a stray hold), and the teardown when
 * it goes through.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class TabSleepOperationTest {
    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    /** Answers each flush with [answer], or never when it is null. */
    private class FakeFlusher(var answer: Boolean? = true) : SessionStateFlusher {
        val flushed = mutableListOf<EngineSession>()
        var during: () -> Unit = {}

        override fun flush(session: EngineSession, onComplete: (Boolean) -> Unit) {
            flushed += session
            during()
            answer?.let(onComplete)
        }
    }

    private class FakePanes(
        override val visibleTabIds: Set<String>,
        private val onReconcile: () -> Unit = {},
    ) : BrowserPanes {
        var reconciles = 0
        override val focusedEngineView: EngineView? = null
        override val allEngineViews: List<EngineView> = emptyList()
        override val lastPresentedTabIds: Set<String> get() = visibleTabIds
        override fun engineViewFor(tabId: String): EngineView? = null
        override fun isDividerHitOnScreen(rawX: Float, rawY: Float) = false
        override fun reconcileNow() {
            reconciles++
            onReconcile()
        }
    }

    private val registry = TabLifecycleRegistry
    private val sessionA: EngineSession = Mockito.mock(EngineSession::class.java)
    private val sessionB: EngineSession = Mockito.mock(EngineSession::class.java)
    private val uploads = mutableSetOf<String>()
    private val postResults = mutableSetOf<String>()
    private var clock = 0L
    private val outputs = PageOutputTracker(maxJobMillis = 1_000, now = { clock })
    private val flusher = FakeFlusher()

    /** GeckoView's answers to the form-data checks, in order; then false. */
    private val formAnswers = ArrayDeque<Boolean?>()
    private var formChecks = 0
    private var panes: FakePanes? = null

    private lateinit var store: BrowserStore
    private lateinit var lifecycle: TabLifecycle

    @Before
    fun setUp() {
        registry.setStorageForTest(NoStorage)
        store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", engineSession = sessionA),
                    createTab("https://b.example", id = "b", engineSession = sessionB),
                    createTab("https://u.example", id = "unloaded"),
                ),
                selectedTabId = "a",
            ),
        )
        lifecycle = TabLifecycle(
            store = store,
            probe = SleepBlockerProbe(
                outputs,
                hasChosenUploads = { it in uploads },
                isPostResult = { state ->
                    state != null &&
                        postResults.any { id -> store.state.findTab(id)?.engineState?.engineSessionState === state }
                },
            ),
            panes = { panes },
            events = {},
            registry = registry,
            flusher = flusher,
            mainDispatcher = Dispatchers.Unconfined,
            flushTimeoutMillis = 100,
            formDataCheck = {
                formChecks++
                if (formAnswers.isEmpty()) false else formAnswers.removeFirst()
            },
        )
    }

    @After
    fun tearDown() = registry.resetForTest()

    private fun sleep(
        vararg tabIds: String,
        stopMedia: Boolean = false,
        discardPostResult: Boolean = false,
        discardFormDataOf: Set<String> = emptySet(),
    ): List<TabSleepResult> = runBlocking {
        lifecycle.sleep(tabIds.toList(), stopMedia, discardPostResult, discardFormDataOf)
    }

    private fun session(tabId: String) = store.state.findTab(tabId)?.engineState?.engineSession

    @Test
    fun `a sleeping tab is flushed, closed and unlinked, and stays held`() {
        val result = sleep("a").single()

        assertTrue(result.asleep)
        assertEquals(listOf(sessionA), flusher.flushed)
        Mockito.verify(sessionA).close()
        assertNull(session("a"))
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("a"))
        // The other tab is untouched.
        assertSame(sessionB, session("b"))
    }

    @Test
    fun `a tab on screen lets go of its page before the session closes`() {
        val order = mutableListOf<String>()
        Mockito.doAnswer { order += "close"; null }.`when`(sessionA).close()
        panes = FakePanes(setOf("a")) {
            order += "reconcile tearingDown=${registry.heldTabs.value["a"]?.tearingDown}"
        }

        sleep("a")

        assertEquals(listOf("reconcile tearingDown=true", "close"), order)
    }

    @Test
    fun `a session linked while restricted is let go of by its pane before it closes`() {
        val order = mutableListOf<String>()
        Mockito.doAnswer { order += "close"; null }.`when`(sessionA).close()
        panes = FakePanes(setOf("a")) { order += "reconcile linked=${session("a") != null}" }

        lifecycle.discardRestrictedSession("a")

        assertEquals(listOf("reconcile linked=false", "close"), order)
    }

    @Test
    fun `an unloaded tab is held without a flush`() {
        val result = sleep("unloaded").single()

        assertTrue(result.asleep)
        assertTrue(flusher.flushed.isEmpty())
        assertTrue(registry.isHeld("unloaded"))
    }

    @Test
    fun `form input, an upload, a print, a recording and a download refuse, and leave no hold`() {
        formAnswers += true
        uploads += "a"
        outputs.onAction(store.state, EngineAction.PrintContentAction("a"))
        store.dispatch(
            DownloadAction.AddDownloadAction(
                DownloadState("https://a.example/f", sessionId = "a", status = DownloadState.Status.DOWNLOADING),
            ),
        )

        val result = sleep("a", stopMedia = true, discardPostResult = true).single()

        assertFalse(result.asleep)
        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, result.failure)
        assertEquals(
            listOf(
                ProtectedActivity.FORM_DATA,
                ProtectedActivity.UPLOAD,
                ProtectedActivity.PRINT_OR_PDF,
                ProtectedActivity.DOWNLOAD,
            ),
            result.blockers,
        )
        assertFalse(registry.isHeld("a"))
        assertSame(sessionA, session("a"))
        assertTrue(flusher.flushed.isEmpty())
    }

    @Test
    fun `playing media asks, and a confirmed sleep pauses it`() {
        val controller = Mockito.mock(MediaSession.Controller::class.java)
        store.dispatch(MediaSessionAction.ActivatedMediaSessionAction("a", controller))
        store.dispatch(MediaSessionAction.UpdateMediaPlaybackStateAction("a", MediaSession.PlaybackState.PLAYING))

        val asked = sleep("a").single()
        assertEquals(listOf(ProtectedActivity.MEDIA), asked.blockers)
        assertFalse(registry.isHeld("a"))

        val confirmed = sleep("a", stopMedia = true).single()
        assertTrue(confirmed.asleep)
        Mockito.verify(controller).pause()
    }

    @Test
    fun `a POST result asks, and only a confirmed sleep goes through`() {
        store.dispatch(
            EngineAction.UpdateEngineSessionStateAction("a", Mockito.mock(EngineSessionState::class.java)),
        )
        postResults += "a"

        assertEquals(listOf(ProtectedActivity.POST_RESULT), sleep("a").single().blockers)
        assertTrue(sleep("a", discardPostResult = true).single().asleep)
    }

    @Test
    fun `sleeping a tab asleep already keeps its hold, though its POST result was confirmed only once`() {
        val writes = mutableListOf<JSONObject>()
        registry.setStorageForTest(object : JsonStore {
            override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
            override fun write(json: JSONObject) {
                writes += JSONObject(json.toString())
            }
            override fun keepDamagedCopy() = Unit
        })
        store.dispatch(
            EngineAction.UpdateEngineSessionStateAction("a", Mockito.mock(EngineSessionState::class.java)),
        )
        postResults += "a"
        assertTrue(sleep("a", discardPostResult = true).single().asleep)

        // "Sleep all tabs" again, which confirms nothing.
        val again = sleep("a").single()

        assertTrue(again.asleep)
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("a"))
        assertEquals(setOf("a"), writes.last().getJSONObject("tabs").keys().asSequence().toSet())
    }

    @Test
    fun `sleeping a tab the scheduler put to sleep makes its hold the user's without asking`() {
        postResults += "unloaded"
        store.dispatch(
            EngineAction.UpdateEngineSessionStateAction("unloaded", Mockito.mock(EngineSessionState::class.java)),
        )
        registry.beginAutomaticSleep("unloaded", private = false)?.let { registry.completeSleep("unloaded", it) }

        val result = sleep("unloaded").single()

        assertTrue(result.asleep)
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("unloaded"))
    }

    @Test
    fun `a Wake leaves a frozen container's tab asleep with its hold`() {
        store.dispatch(TabListAction.AddTabAction(createTab("https://f.example", id = "frozen", contextId = "ctx")))
        assertTrue(sleep("frozen").single().asleep)
        assertNotNull(registry.beginFreeze("c1", listOf("ctx")))

        assertFalse(lifecycle.wakeRequested("frozen"))
        assertTrue(registry.isHeld("frozen"))
    }

    @Test
    fun `a flush that does not answer in time leaves the tab loaded`() {
        flusher.answer = null

        val result = sleep("a").single()

        assertEquals(LifecycleFailure.FLUSH_TIMED_OUT, result.failure)
        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `a flush that throws releases the hold`() {
        flusher.during = { throw IllegalStateException("flusher broke") }

        assertFailsWith<IllegalStateException> { sleep("a") }

        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `an automatic sleep of a tab put to sleep since the pick leaves its manual hold and its record`() {
        val writes = mutableListOf<JSONObject>()
        registry.setStorageForTest(object : JsonStore {
            override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
            override fun write(json: JSONObject) {
                writes += JSONObject(json.toString())
            }
            override fun keepDamagedCopy() = Unit
        })
        assertTrue(sleep("b").single().asleep)
        val written = writes.size

        // The scheduler picked "b" while it was loaded, and reaches it now.
        val result = runBlocking { lifecycle.sleepAutomatically("b") { true } }

        assertFalse(result.asleep)
        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, result.failure)
        assertEquals(SleepHoldKind.MANUAL, registry.holdOf("b"))
        assertEquals(written, writes.size)
        assertEquals(setOf("b"), writes.last().getJSONObject("tabs").keys().asSequence().toSet())
    }

    @Test
    fun `sleeping several tabs writes their holds once`() {
        val writes = mutableListOf<JSONObject>()
        registry.setStorageForTest(object : JsonStore {
            override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
            override fun write(json: JSONObject) {
                writes += JSONObject(json.toString())
            }
            override fun keepDamagedCopy() = Unit
        })

        val results = sleep("a", "b", "unloaded")

        assertTrue(results.all { it.asleep })
        assertEquals(1, writes.size)
        assertEquals(setOf("a", "b", "unloaded"), writes.single().getJSONObject("tabs").keys().asSequence().toSet())
    }

    @Test
    fun `a Wake goes through only while the installed routing covers the tab`() {
        var covers = false
        lifecycle = TabLifecycle(
            store = store,
            probe = SleepBlockerProbe(outputs, hasChosenUploads = { false }, isPostResult = { false }),
            panes = { null },
            events = {},
            registry = registry,
            flusher = flusher,
            mainDispatcher = Dispatchers.Unconfined,
            flushTimeoutMillis = 100,
            formDataCheck = { false },
            routingCovers = { covers },
        )
        assertTrue(sleep("b").single().asleep)

        assertFalse(lifecycle.wakeRequested("b"))
        assertTrue(registry.isHeld("b"))

        covers = true
        assertTrue(lifecycle.wakeRequested("b"))
        assertFalse(registry.isHeld("b"))
        assertFalse(lifecycle.wakeRequested("closed"))
    }

    @Test
    fun `a print job ends with its session or its tab, whether or not anyone asks`() {
        outputs.onAction(store.state, EngineAction.PrintContentAction("a"))
        outputs.onAction(store.state, EngineAction.SaveToPdfAction("b"))
        assertEquals(2, outputs.jobCount())

        outputs.onAction(store.state, EngineAction.UnlinkEngineSessionAction("a"))
        outputs.onAction(store.state, TabListAction.RemoveTabAction("b"))

        assertEquals(0, outputs.jobCount())
    }

    @Test
    fun `an expired print job is dropped when the next one starts`() {
        outputs.onAction(store.state, EngineAction.PrintContentAction("a"))
        clock = 2_000

        outputs.onAction(store.state, EngineAction.PrintContentAction("b"))

        assertEquals(1, outputs.jobCount())
    }

    @Test
    fun `a failed flush leaves the tab loaded`() {
        flusher.answer = false

        assertEquals(LifecycleFailure.FLUSH_FAILED, sleep("a").single().failure)
        assertFalse(registry.isHeld("a"))
    }

    @Test
    fun `a wake during the flush wins`() {
        flusher.during = { registry.wake("a") }

        val result = sleep("a").single()

        assertEquals(LifecycleFailure.SUPERSEDED, result.failure)
        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `a session replaced during the flush is not closed`() {
        val replacement = Mockito.mock(EngineSession::class.java)
        flusher.during = { store.dispatch(EngineAction.LinkEngineSessionAction("a", replacement)) }

        val result = sleep("a").single()

        assertEquals(LifecycleFailure.SESSION_CHANGED, result.failure)
        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
        Mockito.verify(replacement, Mockito.never()).close()
    }

    @Test
    fun `form input typed during the flush refuses at the final check`() {
        // AC's cached flag stays false while someone types; only GeckoView's
        // own answer after the flush sees the input.
        formAnswers += listOf(false, true)

        val result = sleep("a").single()

        assertEquals(2, formChecks)
        assertEquals(listOf(ProtectedActivity.FORM_DATA), result.blockers)
        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `no answer at the final form check keeps the tab loaded`() {
        formAnswers += listOf(false, null)

        val result = sleep("a").single()

        assertEquals(listOf(ProtectedActivity.FORM_DATA), result.blockers)
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `form input the user agreed to lose does not refuse`() {
        formAnswers += listOf(true, true)

        val result = sleep("a", discardFormDataOf = setOf("a")).single()

        assertTrue(result.asleep)
        Mockito.verify(sessionA).close()
        // Its answer could not change anything, so GeckoView is not asked.
        assertEquals(0, formChecks)
    }

    @Test
    fun `a refusal after agreeing to lose form input blames only what refused`() {
        // The form was submitted after the question: the store still flags
        // its input, and the page is now a POST result nobody agreed to.
        store.dispatch(ContentAction.UpdateHasFormDataAction("a", true))
        store.dispatch(
            EngineAction.UpdateEngineSessionStateAction("a", Mockito.mock(EngineSessionState::class.java)),
        )
        postResults += "a"

        val result = sleep("a", discardFormDataOf = setOf("a")).single()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, result.failure)
        assertEquals(listOf(ProtectedActivity.POST_RESULT), result.blockers)
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `form input agreed to lose in one tab still refuses in another`() {
        formAnswers += listOf(true, true)

        val result = sleep("a", discardFormDataOf = setOf("b")).single()

        assertEquals(listOf(ProtectedActivity.FORM_DATA), result.blockers)
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `form input cleared since the store saw it does not refuse`() {
        store.dispatch(ContentAction.UpdateHasFormDataAction("a", true))

        assertTrue(sleep("a").single().asleep)
    }

    @Test
    fun `a print that reached the page refuses until it ends`() {
        outputs.onAction(store.state, EngineAction.PrintContentAction("a"))
        assertEquals(listOf(ProtectedActivity.PRINT_OR_PDF), sleep("a").single().blockers)

        outputs.onAction(store.state, EngineAction.PrintContentCompletedAction("a"))
        assertTrue(sleep("a").single().asleep)
    }

    @Test
    fun `a print request a tab without a session never ran does not count`() {
        // The request waits for a session the creation guard may never allow;
        // its follow-up, once a session exists, is what counts.
        outputs.onAction(store.state, EngineAction.PrintContentAction("unloaded"))

        assertTrue(sleep("unloaded").single().asleep)
    }

    @Test
    fun `a print with no end stops counting with its session or its time`() {
        outputs.onAction(store.state, EngineAction.SaveToPdfAction("a"))
        outputs.onAction(store.state, EngineAction.PrintContentAction("b"))

        // Cancelled print dialogs and empty PDFs report nothing.
        store.dispatch(EngineAction.UnlinkEngineSessionAction("a"))
        assertTrue(sleep("a").single().asleep)

        clock += 1_001
        assertTrue(sleep("b").single().asleep)
    }

    @Test
    fun `retiring the components stops a sleep and releases its hold`() = runBlocking {
        flusher.answer = null
        val running = async(start = CoroutineStart.UNDISPATCHED) {
            lifecycle.sleep(listOf("a"), stopMedia = false, discardPostResult = false)
        }
        assertTrue(registry.isHeld("a"))

        lifecycle.retire()

        assertEquals(LifecycleFailure.COMPONENTS_REPLACED, running.await().single().failure)
        assertFalse(registry.isHeld("a"))
        Mockito.verify(sessionA, Mockito.never()).close()
    }

    @Test
    fun `an unknown tab is reported, and several tabs are answered in order`() {
        val results = sleep("missing", "b")

        assertEquals(listOf("missing", "b"), results.map { it.tabId })
        assertEquals(LifecycleFailure.UNKNOWN_TAB, results[0].failure)
        assertTrue(results[1].asleep)
    }

    @Test
    fun `waking clears the hold and presents a tab on screen again`() {
        sleep("a")
        val shown = FakePanes(setOf("a"))
        panes = shown

        lifecycle.wake("a")

        assertFalse(registry.isHeld("a"))
        assertEquals(1, shown.reconciles)
    }
}
