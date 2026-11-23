/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import org.json.JSONObject
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Automatic tab sleep (5.9): which tabs qualify, the idle rule and the soft
 * resident limit, and the re-check right before the teardown (a tab selected,
 * kept awake or with the policy turned off during its flush stays loaded).
 * Off by default, and nothing evaluates in the background.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class TabSleepSchedulerTest {
    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    private class FakeFlusher : SessionStateFlusher {
        var answer: Boolean = true
        var during: () -> Unit = {}
        val flushed = mutableListOf<EngineSession>()

        override fun flush(session: EngineSession, onComplete: (Boolean) -> Unit) {
            flushed += session
            during()
            onComplete(answer)
        }
    }

    private val registry = TabLifecycleRegistry
    private var now = 0L
    private val uploads = mutableSetOf<String>()

    /** The tabs the probe was asked about, in order. */
    private val probed = mutableListOf<String>()

    /** The sessions GeckoView reports form input for. */
    private val typing = mutableSetOf<EngineSession>()
    private val flusher = FakeFlusher()
    private val presented = MutableStateFlow(setOf("a"))
    private val policy = MutableStateFlow(SleepPolicy.OFF)
    private val foreground = MutableStateFlow(true)

    private lateinit var store: BrowserStore
    private lateinit var scheduler: TabSleepScheduler

    private fun session(): EngineSession = Mockito.mock(EngineSession::class.java)

    @Before
    fun setUp() {
        registry.setStorageForTest(NoStorage)
        store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", engineSession = session()),
                    createTab("https://b.example", id = "b", engineSession = session()),
                    createTab("https://c.example", id = "c", engineSession = session()),
                    createTab("https://u.example", id = "unloaded"),
                ),
                selectedTabId = "a",
            ),
        )
        val probe = SleepBlockerProbe(
            PageOutputTracker(now = { now }),
            hasChosenUploads = {
                probed += it
                it in uploads
            },
            isPostResult = { false },
        )
        val lifecycle = TabLifecycle(
            store = store,
            probe = probe,
            panes = { null },
            events = {},
            registry = registry,
            flusher = flusher,
            mainDispatcher = Dispatchers.Unconfined,
            flushTimeoutMillis = 100,
            formDataCheck = { it in typing },
        )
        scheduler = TabSleepScheduler(
            store = store,
            lifecycle = lifecycle,
            probe = probe,
            presented = presented,
            policy = policy,
            foreground = foreground,
            installForeground = {},
            registry = registry,
            clock = { now },
            mainDispatcher = Dispatchers.Unconfined,
            tickMillis = Long.MAX_VALUE / 4,
        )
        scheduler.start()
    }

    @After
    fun tearDown() {
        scheduler.retire()
        registry.resetForTest()
    }

    private fun policy(idleMinutes: Long = 10, residentLimit: Int? = null, exempt: Set<String> = emptySet()) =
        SleepPolicy(
            enabled = true,
            idleMillis = idleMinutes * 60_000L,
            residentLimit = residentLimit,
            exemptTabIds = exempt,
        )

    private fun minutes(n: Long) = n * 60_000L

    private fun held(): Map<String, SleepHoldKind> = registry.heldTabs.value.mapValues { it.value.kind }

    private fun evaluate() = runBlocking { scheduler.evaluate() }

    @Test
    fun `off by default, nothing is put to sleep`() {
        now = minutes(120)
        evaluate()

        assertEquals(emptyMap(), held())
        assertEquals(emptyList(), flusher.flushed)
    }

    @Test
    fun `tabs off screen for the idle time sleep, the selected one and unloaded ones do not`() {
        policy.value = policy(idleMinutes = 10)
        assertEquals(emptyMap(), held())

        now = minutes(10)
        evaluate()

        assertEquals(mapOf("b" to SleepHoldKind.AUTOMATIC, "c" to SleepHoldKind.AUTOMATIC), held())
    }

    @Test
    fun `a sleep that throws backs that tab off, and the others still sleep`() {
        val sessionB = store.state.findTab("b")!!.engineState.engineSession
        flusher.during = { if (flusher.flushed.last() === sessionB) throw IllegalStateException("engine broke") }
        policy.value = policy(idleMinutes = 10)

        now = minutes(10)
        evaluate()

        assertEquals(mapOf("c" to SleepHoldKind.AUTOMATIC), held())
        // Backed off: not tried again at the next evaluation.
        val flushes = flusher.flushed.size
        now = minutes(11)
        evaluate()
        assertEquals(flushes, flusher.flushed.size)
    }

    @Test
    fun `the blockers are asked only of the tabs about to be picked`() {
        policy.value = policy(idleMinutes = 10)

        probed.clear()
        assertEquals(emptyList(), scheduler.candidates(store.state, policy.value, minutes(5)))
        assertEquals(emptyList(), probed)

        assertEquals(
            listOf("b" to TabSleepScheduler.Reason.IDLE, "c" to TabSleepScheduler.Reason.IDLE),
            scheduler.candidates(store.state, policy.value, minutes(10)),
        )
        assertEquals(setOf("b", "c"), probed.toSet())
    }

    @Test
    fun `nothing evaluates while the app is in the background, and that time is not idle`() {
        policy.value = policy(idleMinutes = 10)
        now = minutes(4)
        foreground.value = false

        now = minutes(60)
        evaluate()
        assertEquals(emptyMap(), held())

        // Back in the foreground: evaluated at once, but only the 4 minutes
        // used count, so nothing is due all at once.
        foreground.value = true
        assertEquals(emptyMap(), held())

        now = minutes(66)
        evaluate()
        assertEquals(setOf("b", "c"), held().keys)
    }

    @Test
    fun `the resident limit takes the tab off screen longest, only while over it`() {
        presented.value = setOf("a", "c")
        policy.value = policy(idleMinutes = 60, residentLimit = 2)
        now = minutes(1)
        presented.value = setOf("a")

        now = minutes(2)
        evaluate()

        // Three loaded, limit two: b has been off screen since 0, c since 1 min.
        assertEquals(mapOf("b" to SleepHoldKind.AUTOMATIC), held())
        evaluate()
        assertEquals(setOf("b"), held().keys)
    }

    @Test
    fun `a tab presented in the last 30 seconds is no candidate`() {
        presented.value = setOf("a", "b", "c")
        policy.value = policy(idleMinutes = 60, residentLimit = 1)
        now = minutes(5)
        presented.value = setOf("a")

        now = minutes(5) + 10_000
        evaluate()
        assertEquals(emptyMap(), held())

        now = minutes(5) + 30_000
        evaluate()
        assertEquals(setOf("b", "c"), held().keys)
    }

    @Test
    fun `kept awake tabs and tabs doing something are left alone`() {
        uploads += "c"
        policy.value = policy(idleMinutes = 10, exempt = setOf("b"))

        now = minutes(30)
        evaluate()

        assertEquals(emptyMap(), held())
    }

    @Test
    fun `a form flag the store kept since the tab was deselected does not keep it awake once GeckoView says the form is clear`() {
        // AC refreshes the flag only when a tab is deselected: the page
        // cleared its form or navigated away in the background since.
        store.dispatch(ContentAction.UpdateHasFormDataAction("b", containsFormData = true))
        policy.value = policy(idleMinutes = 10)

        now = minutes(10)
        evaluate()

        // The sleep asked GeckoView, which answers false here.
        assertEquals(SleepHoldKind.AUTOMATIC, held()["b"])
    }

    @Test
    fun `a loading tab gets two minutes before it can sleep`() {
        policy.value = policy(idleMinutes = 10)
        now = minutes(10)
        store.dispatch(ContentAction.UpdateLoadingStateAction("b", true))
        evaluate()
        assertEquals(setOf("c"), held().keys)

        now = minutes(12)
        evaluate()
        assertEquals(setOf("b", "c"), held().keys)
    }

    @Test
    fun `a tab selected during its flush stays loaded, and is tried again later`() {
        policy.value = policy(idleMinutes = 10, exempt = setOf("c"))
        now = minutes(10)
        flusher.during = {
            store.dispatch(TabListAction.SelectTabAction("b"))
            presented.value = setOf("b")
        }
        evaluate()

        assertNull(held()["b"])

        flusher.during = {}
        store.dispatch(TabListAction.SelectTabAction("a"))
        presented.value = setOf("a")
        now += minutes(10)
        evaluate()
        assertEquals(setOf("b"), held().keys)
    }

    @Test
    fun `kept awake or the policy turned off during the flush keeps the tab`() {
        policy.value = policy(idleMinutes = 10, exempt = setOf("c"))
        now = minutes(10)
        flusher.during = { policy.value = policy(idleMinutes = 10, exempt = setOf("b", "c")) }
        evaluate()
        assertEquals(emptyMap(), held())

        policy.value = policy(idleMinutes = 10, exempt = setOf("c"))
        flusher.during = { policy.value = SleepPolicy.OFF }
        evaluate()
        assertEquals(emptyMap(), held())
    }

    @Test
    fun `a failed sleep backs off before the next try`() {
        policy.value = policy(idleMinutes = 10, exempt = setOf("c"))
        now = minutes(10)
        flusher.answer = false
        evaluate()
        assertEquals(1, flusher.flushed.size)

        flusher.answer = true
        evaluate()
        assertEquals(1, flusher.flushed.size)

        now += TabSleepScheduler.FIRST_BACKOFF_MILLIS
        evaluate()
        assertEquals(setOf("b"), held().keys)
    }

    @Test
    fun `typed text keeps a tab loaded for an hour off screen, then it sleeps like any other`() {
        typing += store.state.tabs.first { it.id == "b" }.engineState.engineSession!!
        policy.value = policy(idleMinutes = 10)

        now = minutes(10)
        evaluate()
        assertEquals(setOf("c"), held().keys)

        // Not tried again while its text may not go: nothing flushed for it.
        now = minutes(59)
        evaluate()
        assertEquals(setOf("c"), held().keys)

        now = TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS
        evaluate()
        assertEquals(setOf("b", "c"), held().keys)
    }

    @Test
    fun `with an idle time over an hour, typed text waits for the idle time`() {
        typing += store.state.tabs.first { it.id == "b" }.engineState.engineSession!!
        policy.value = policy(idleMinutes = 90)

        now = TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS
        evaluate()
        assertEquals(emptySet<String>(), held().keys)

        now = minutes(90)
        evaluate()
        assertEquals(setOf("b", "c"), held().keys)
    }

    @Test
    fun `the resident limit takes typed text only after the idle time, when that is longer than an hour`() {
        typing += store.state.tabs.first { it.id == "b" }.engineState.engineSession!!
        policy.value = policy(idleMinutes = 240, residentLimit = 1, exempt = setOf("c"))

        // Over the limit: b is picked for it, but its text is not an hour old
        // and not as old as the idle time.
        now = TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS
        evaluate()
        assertEquals(emptySet<String>(), held().keys)

        now = minutes(239)
        evaluate()
        assertEquals(emptySet<String>(), held().keys)

        now = minutes(240)
        evaluate()
        assertEquals(setOf("b"), held().keys)
    }

    @Test
    fun `a tab waiting for its typed text follows a shorter idle time at once`() {
        typing += store.state.tabs.first { it.id == "b" }.engineState.engineSession!!
        policy.value = policy(idleMinutes = 240, residentLimit = 1, exempt = setOf("c"))

        // Picked for the limit after an hour, refused for its text: under a
        // four-hour idle time it has to wait for that.
        now = TabSleepScheduler.TYPED_TEXT_GRACE_MILLIS
        evaluate()
        assertEquals(emptySet<String>(), held().keys)

        // The idle time goes down to 30 minutes: the hour, long past, counts.
        policy.value = policy(idleMinutes = 30, residentLimit = 1, exempt = setOf("c"))
        now += minutes(1)
        evaluate()
        assertEquals(setOf("b"), held().keys)
    }
}
