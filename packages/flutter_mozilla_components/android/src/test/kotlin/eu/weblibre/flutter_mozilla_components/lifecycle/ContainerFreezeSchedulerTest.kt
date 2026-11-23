/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createCustomTab
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
 * Automatic container freeze's due detection (C2, 5.9): a container is due
 * after its time unused, counted in foreground time only; selection, the
 * screen, a custom tab, "Keep awake" (D30) and protected activity keep it from
 * being due; a restricted container is never reported, and a resumed one counts
 * from the Resume; a due container is reported again at each evaluation; and
 * the re-check a freeze asks for uses the members Dart passed.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class ContainerFreezeSchedulerTest {
    private object NoStorage : JsonStore {
        override fun read(): AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        override fun write(json: JSONObject) = Unit
        override fun keepDamagedCopy() = Unit
    }

    private val registry = TabLifecycleRegistry
    private var now = 0L
    private val uploads = mutableSetOf<String>()
    private val presented = MutableStateFlow(setOf("a"))
    private val policy = MutableStateFlow(SleepPolicy.OFF)
    private val foreground = MutableStateFlow(true)
    private val due = mutableListOf<String>()

    private lateinit var store: BrowserStore
    private lateinit var scheduler: ContainerFreezeScheduler

    private fun session(): EngineSession = Mockito.mock(EngineSession::class.java)

    private fun minutes(n: Long) = n * 60_000L

    @Before
    fun setUp() {
        registry.setStorageForTest(NoStorage)
        store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", engineSession = session()),
                    createTab("https://m.example", id = "m", contextId = "ctx1", engineSession = session()),
                    createTab("https://n.example", id = "n", contextId = "ctx1"),
                    createTab("https://o.example", id = "o", contextId = "other", engineSession = session()),
                ),
                selectedTabId = "a",
            ),
        )
        policy.value = schedule()
        scheduler = ContainerFreezeScheduler(
            store = store,
            probe = SleepBlockerProbe(PageOutputTracker(now = { now }), hasChosenUploads = { it in uploads }, isPostResult = { false }),
            presented = presented,
            onDue = { due += it },
            policy = policy,
            foreground = foreground,
            installForeground = {},
            registry = registry,
            clock = { now },
            mainDispatcher = Dispatchers.Unconfined,
            tickMillis = Long.MAX_VALUE / 4,
        )
        scheduler.start()
        due.clear()
    }

    @After
    fun tearDown() {
        scheduler.retire()
        registry.resetForTest()
    }

    private fun schedule(afterMinutes: Long = 10, exempt: Set<String> = emptySet()) = SleepPolicy.OFF.copy(
        exemptTabIds = exempt,
        containers = mapOf("c1" to AutoFreezeSchedule(setOf("ctx1"), minutes(afterMinutes))),
    )

    private fun evaluateAt(millis: Long): List<String> {
        now = millis
        due.clear()
        scheduler.evaluate()
        return due.toList()
    }

    @Test
    fun `a container unused for its time is due, counted in foreground time only`() {
        assertEquals(emptyList(), evaluateAt(minutes(9)))

        foreground.value = false
        now = minutes(300)
        foreground.value = true
        due.clear()

        // Nine minutes in the foreground, however long it was away.
        assertEquals(emptyList(), evaluateAt(minutes(300) + 30_000))
        assertEquals(listOf("c1"), evaluateAt(minutes(301)))
    }

    @Test
    fun `a member on screen keeps it in use, and leaving the screen starts the count`() {
        now = minutes(5)
        presented.value = setOf("m")
        assertEquals(emptyList(), evaluateAt(minutes(30)))

        presented.value = setOf("a")
        assertEquals(emptyList(), evaluateAt(minutes(39)))
        assertEquals(listOf("c1"), evaluateAt(minutes(40)))
    }

    @Test
    fun `a selected member keeps it in use`() {
        store.dispatch(TabListAction.SelectTabAction("n"))

        assertEquals(emptyList(), evaluateAt(minutes(60)))
    }

    @Test
    fun `a custom tab in one of its contexts keeps it in use`() {
        store.dispatch(
            CustomTabListAction.AddCustomTabAction(createCustomTab("https://w.example", id = "pwa", contextId = "ctx1")),
        )

        assertEquals(emptyList(), evaluateAt(minutes(60)))
    }

    @Test
    fun `a kept-awake member keeps it from being due`() {
        policy.value = schedule(exempt = setOf("n"))

        assertEquals(emptyList(), evaluateAt(minutes(60)))
    }

    @Test
    fun `protected activity of a loaded member defers it`() {
        uploads += "m"
        assertEquals(emptyList(), evaluateAt(minutes(60)))

        uploads.clear()
        assertEquals(listOf("c1"), evaluateAt(minutes(61)))
    }

    @Test
    fun `a restricted container is never reported`() {
        registry.beginFreeze("c1", listOf("ctx1"))

        assertEquals(emptyList(), evaluateAt(minutes(60)))
    }

    @Test
    fun `a resumed container counts its time unused from the Resume`() {
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("ctx1")))
        registry.setPhase(listOf("ctx1"), gen, ContextPhase.FROZEN)
        assertEquals(emptyList(), evaluateAt(minutes(60)))

        // Resumed from its menu: none of its tabs came on screen.
        now = minutes(61)
        assertNotNull(registry.removeRecords(listOf("ctx1"), gen))

        assertEquals(emptyList(), evaluateAt(minutes(62)))
        assertEquals(emptyList(), evaluateAt(minutes(70)))
        assertEquals(listOf("c1"), evaluateAt(minutes(71)))
    }

    @Test
    fun `a freeze rolled back while it ran leaves the count as it was`() {
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("ctx1")))
        assertEquals(emptyList(), evaluateAt(minutes(10)))

        registry.abandonFreeze(listOf("ctx1"), gen, LifecycleFailure.PROTECTED_ACTIVITY)

        assertEquals(listOf("c1"), evaluateAt(minutes(11)))
    }

    @Test
    fun `a due container is reported again at each evaluation`() {
        assertEquals(listOf("c1"), evaluateAt(minutes(10)))
        assertEquals(listOf("c1"), evaluateAt(minutes(11)))
    }

    @Test
    fun `nothing is reported in the background or without a schedule`() {
        foreground.value = false
        assertEquals(emptyList(), evaluateAt(minutes(60)))

        foreground.value = true
        policy.value = SleepPolicy.OFF
        assertEquals(emptyList(), evaluateAt(minutes(120)))
    }

    @Test
    fun `the re-check uses the members Dart passed, and the schedule in force`() {
        now = minutes(20)
        assertTrue(scheduler.isStillDue("c1", listOf("ctx1"), setOf("m", "n")))

        // A tab moved in by the database only, still running elsewhere.
        store.dispatch(TabListAction.SelectTabAction("o"))
        assertFalse(scheduler.isStillDue("c1", listOf("ctx1"), setOf("m", "n", "o")))
        // Not among the members, its selection is another container's.
        assertTrue(scheduler.isStillDue("c1", listOf("ctx1"), setOf("m", "n")))

        assertFalse(scheduler.isStillDue("unscheduled", listOf("ctx1"), setOf("m", "n")))
        foreground.value = false
        assertFalse(scheduler.isStillDue("c1", listOf("ctx1"), setOf("m", "n")))
    }

    @Test
    fun `the re-check fails once a member was used since`() {
        now = minutes(20)
        presented.value = setOf("m")
        presented.value = setOf("a")

        assertFalse(scheduler.isStillDue("c1", listOf("ctx1"), setOf("m", "n")))
    }
}
