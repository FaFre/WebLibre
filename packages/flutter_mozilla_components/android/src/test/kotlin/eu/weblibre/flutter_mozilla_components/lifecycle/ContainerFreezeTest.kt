/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.ContextReleaseResult
import eu.weblibre.flutter_mozilla_components.pigeons.EngineEnforcement
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeActivity
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeBlocker
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleOperationState
import eu.weblibre.flutter_mozilla_components.pigeons.ProtectedActivity
import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import java.io.IOException
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlin.test.assertTrue
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.action.DownloadAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.MediaSessionState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
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
 * Container freeze (5.4–5.6): every barrier's refusal leaves what the plan says
 * it leaves, engine commands always carry rising numbers and a rollback lift
 * follows an unconfirmed install (D22), Resume compensates a failed write (D33),
 * a Resume supersedes a running freeze, the release procedure only lifts after
 * push removal and an acknowledged clear (D32), and the reconstruction ends
 * recovery only once the engine confirmed it (D23).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class ContainerFreezeTest {
    private class MemoryStorage : JsonStore {
        var record: AtomicJsonFile.Read = AtomicJsonFile.Read.Absent
        var failWrites = false

        /**
         * How the next writes end, in turn, before [failWrites] decides: true
         * replaces the file without confirming it durable (its folder's sync
         * failed), false fails without replacing it.
         */
        val plan = ArrayDeque<Boolean>()

        override fun read(): AtomicJsonFile.Read = record

        override fun write(json: JSONObject) {
            when (plan.removeFirstOrNull()) {
                true -> {
                    record = AtomicJsonFile.Read.Present(JSONObject(json.toString()))
                    throw AtomicJsonFile.UnconfirmedWriteException("folder sync failed", IOException("EIO"))
                }
                false -> throw IOException("disk full")
                null -> Unit
            }
            if (failWrites) throw IOException("disk full")
            record = AtomicJsonFile.Read.Present(JSONObject(json.toString()))
        }

        override fun keepDamagedCopy() = Unit

        fun phaseOf(contextId: String): String? = (record as? AtomicJsonFile.Read.Present)
            ?.json?.optJSONObject("contexts")?.optJSONObject(contextId)?.optString("phase")

        /** The data deletions on disk, by context, with their container. */
        fun dataDeletions(): Map<String, String> {
            val entries = (record as? AtomicJsonFile.Read.Present)?.json?.optJSONObject("dataDeletions") ?: return emptyMap()
            return entries.keys().asSequence().associateWith { entries.getString(it) }
        }
    }

    private class MemoryJsonStore : JsonStore {
        var json: JSONObject? = null
        override fun read(): AtomicJsonFile.Read =
            json?.let { AtomicJsonFile.Read.Present(JSONObject(it.toString())) } ?: AtomicJsonFile.Read.Absent

        override fun write(json: JSONObject) {
            this.json = JSONObject(json.toString())
        }
    }

    /** Flushes at once, after [during]: what happens while a tab is flushed. */
    private class FakeFlusher(private val during: () -> Unit = {}) : SessionStateFlusher {
        override fun flush(session: EngineSession, onComplete: (Boolean) -> Unit) {
            during()
            onComplete(true)
        }
    }

    /** Applies every command unless told otherwise; records them in order. */
    private class FakeEngine : SessionContextEngine {
        val calls = mutableListOf<String>()
        val commands = mutableListOf<Long>()
        var install: suspend (List<String>, Long) -> List<CommandAck> = { ids, cmd -> ids.map { CommandAck(it, cmd, true, true) } }
        var lift: suspend (List<String>, Long) -> List<CommandAck> = { ids, cmd -> ids.map { CommandAck(it, cmd, true, false) } }
        var quiescence: suspend (List<String>, Long) -> List<QuiescenceAck> = { ids, cmd ->
            ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.QUIESCENT) }
        }
        var clear: suspend (String) -> Unit = {}
        var workers: List<String> = emptyList()

        override suspend fun install(contextIds: List<String>, cmd: Long): List<CommandAck> {
            calls += "install $contextIds"
            commands += cmd
            return install.invoke(contextIds, cmd)
        }

        override suspend fun lift(contextIds: List<String>, cmd: Long): List<CommandAck> {
            calls += "lift $contextIds"
            commands += cmd
            return lift.invoke(contextIds, cmd)
        }

        override suspend fun awaitQuiescence(contextIds: List<String>, cmd: Long, timeoutMillis: Long): List<QuiescenceAck> {
            calls += "quiesce $contextIds"
            commands += cmd
            return quiescence.invoke(contextIds, cmd)
        }

        override suspend fun clearData(contextId: String) {
            calls += "clear $contextId"
            clear.invoke(contextId)
        }

        override suspend fun contextsWithServiceWorkers(): List<String> = workers
    }

    private class FakePush : ContextPush {
        var removes = true
        var subscribed: Set<String> = emptySet()
        val removed = mutableListOf<String>()
        /** Each drain's contexts; null for every context no longer restricted. */
        val drained = mutableListOf<Collection<String>?>()

        override suspend fun removeSubscriptions(contextId: String): Boolean {
            removed += contextId
            return removes
        }

        override suspend fun contextsWithSubscriptions(): Set<String> = subscribed

        override suspend fun drainOutbox(contextIds: Collection<String>?) {
            drained += contextIds?.toList()
        }
    }

    private class RecordingEvents : ContextFreezeEvents {
        var changes = 0
        val progress = mutableListOf<Triple<String, Int, Int>>()
        override fun onChange() {
            changes++
        }

        override fun onProgress(ownerId: String, done: Int, total: Int) {
            progress += Triple(ownerId, done, total)
        }
    }

    private val registry = TabLifecycleRegistry
    private val storage = MemoryStorage()
    private val engine = FakeEngine()
    private val push = FakePush()
    private val events = RecordingEvents()
    private val sessionA: EngineSession = Mockito.mock(EngineSession::class.java)
    private val sessionOther: EngineSession = Mockito.mock(EngineSession::class.java)
    private var formData: Boolean? = false

    /** GeckoView's answers to the next form checks, in turn; [formData] once none is left. */
    private val formAnswers = ArrayDeque<Boolean?>()

    /** Whether the contexts were restricted when each form check was asked. */
    private val restrictedAtFormCheck = mutableListOf<Boolean>()

    /** Held until completed: the freeze's form checks wait for it when set. */
    private var formCheckGate: CompletableDeferred<Unit>? = null

    /** Print and PDF jobs, for every probe as in `Core`. */
    private val outputs = PageOutputTracker()

    /** Runs while a tab is flushed, between the freeze's check and the teardown. */
    private var duringFlush: () -> Unit = {}

    /** What an automatic freeze's re-checks answer, in turn; the last one repeats. */
    private var stillDue: List<Boolean> = listOf(true)
    private var dueChecks = 0

    private lateinit var store: BrowserStore
    private lateinit var lifecycle: TabLifecycle
    private lateinit var freeze: ContainerFreeze

    @Before
    fun setUp() {
        registry.setStorageForTest(storage)
        SessionContextCommands.resetForTest()
        RestrictedSessions.resetForTest()
        DownloadContexts.resetForTest(MemoryJsonStore())
        UndeliveredPushCounts.resetForTest(MemoryJsonStore())
        store = BrowserStore(
            BrowserState(
                tabs = listOf(
                    createTab("https://a.example", id = "a", contextId = "ctx", engineSession = sessionA),
                    createTab("https://u.example", id = "unloaded", contextId = "ctx"),
                    createTab("https://o.example", id = "other", contextId = "elsewhere", engineSession = sessionOther),
                ),
                selectedTabId = "other",
            ),
        )
        val probe = SleepBlockerProbe(outputs, hasChosenUploads = { false }, isPostResult = { false })
        lifecycle = TabLifecycle(
            store = store,
            probe = probe,
            panes = { null },
            events = {},
            registry = registry,
            flusher = FakeFlusher { duringFlush() },
            mainDispatcher = Dispatchers.Unconfined,
            flushTimeoutMillis = 100,
            formDataCheck = { formData },
        )
        freeze = newFreeze()
    }

    private fun newFreeze(
        backgroundRetryMillis: List<Long> = emptyList(),
        hasChosenUploads: (String) -> Boolean = { false },
        typedTextMayGo: Boolean = false,
    ) = ContainerFreeze(
        store = store,
        lifecycle = lifecycle,
        probe = SleepBlockerProbe(outputs, hasChosenUploads = hasChosenUploads, isPostResult = { false }),
        engine = engine,
        push = { push },
        panes = { null },
        events = events,
        registry = registry,
        formDataCheck = {
            restrictedAtFormCheck += registry.isRestricted("ctx")
            formCheckGate?.await()
            if (formAnswers.isEmpty()) formData else formAnswers.removeFirst()
        },
        stillDue = { stillDue[minOf(dueChecks++, stillDue.lastIndex)] },
        typedTextMayGo = { typedTextMayGo },
        mainDispatcher = Dispatchers.Unconfined,
        timeouts = ContainerFreeze.Timeouts(
            commandMillis = 100,
            quiescenceMillis = 100,
            answerMarginMillis = 50,
            clearMillis = 100,
            discoveryMillis = 100,
            writeRetryMillis = listOf(1),
            backgroundRetryMillis = backgroundRetryMillis,
        ),
    )

    @After
    fun tearDown() {
        registry.resetForTest()
        RestrictedSessions.resetForTest()
    }

    private fun request(
        members: Set<String> = setOf("a", "unloaded"),
        contexts: List<String> = listOf("ctx"),
        automatic: Boolean = false,
    ) = FreezeRequest("c1", contexts, members, stopMedia = false, discardPostResult = false, automatic = automatic)

    private fun runFreeze(request: FreezeRequest = request()) = runBlocking { freeze.freeze(request) }

    @Test
    fun `a freeze stopped by an error is left failed, still restricted`() {
        // Readable for the check before the intent, not for barrier 2's.
        var uploadChecks = 0
        freeze = newFreeze(
            hasChosenUploads = {
                if (uploadChecks++ > 0) throw IllegalStateException("uploads unreadable")
                false
            },
        )

        assertFailsWith<IllegalStateException> { runFreeze() }

        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(LifecycleOperationState.IDLE, registry.statusOf("ctx")?.operation)
    }

    @Test
    fun `a freeze restricts, tears the loaded tabs down without a sleep hold, waits for quiescence and commits`() {
        val outcome = runFreeze()

        assertNull(outcome.failure)
        assertEquals(ContextPhase.FROZEN, outcome.phase)
        assertEquals("frozen", storage.phaseOf("ctx"))
        assertEquals(listOf("install [ctx]", "quiesce [ctx]"), engine.calls)
        assertEquals(engine.commands.sorted(), engine.commands)
        assertNull(store.state.findTab("a")!!.engineState.engineSession)
        Mockito.verify(sessionA).close()
        // D26: the restriction holds the tab, not a sleep hold of its own.
        assertFalse(registry.isHeld("a"))
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(EngineEnforcement.ENFORCED, registry.statusOf("ctx")?.enforcement)
        assertEquals(listOf(Triple("c1", 1, 1)), events.progress)
        // Other contexts are untouched.
        assertTrue(store.state.findTab("other")!!.engineState.engineSession === sessionOther)
    }

    @Test
    fun `a tab of the contexts that Dart did not count refuses the freeze before anything is written`() {
        val outcome = runFreeze(request(members = setOf("a")))

        assertEquals(LifecycleFailure.CONTEXT_SHARED, outcome.failure)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `a member running outside the contexts refuses the freeze before anything is written`() {
        // An extension's tab runs in the default storage, filed with the container.
        store = BrowserStore(
            store.state.copy(tabs = store.state.tabs + createTab("https://e.example", id = "ext", engineSession = sessionOther)),
        )
        setUpWithStore()

        val outcome = runFreeze(request(members = setOf("a", "unloaded", "ext")))

        assertEquals(LifecycleFailure.MEMBER_OUTSIDE_CONTEXTS, outcome.failure)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `a custom tab in the contexts refuses the freeze`() {
        store = BrowserStore(
            store.state.copy(customTabs = listOf(createCustomTab("https://w.example", id = "pwa", contextId = "ctx"))),
        )
        setUpWithStore()

        assertEquals(LifecycleFailure.OPEN_IN_EXTERNAL_WINDOW, runFreeze().failure)
        assertTrue(engine.calls.isEmpty())
    }

    private fun setUpWithStore() {
        lifecycle = TabLifecycle(
            store = store,
            probe = SleepBlockerProbe(outputs, hasChosenUploads = { false }, isPostResult = { false }),
            panes = { null },
            events = {},
            registry = registry,
            flusher = FakeFlusher { duringFlush() },
            mainDispatcher = Dispatchers.Unconfined,
            flushTimeoutMillis = 100,
            formDataCheck = { formData },
        )
        freeze = newFreeze()
    }

    @Test
    fun `an automatic freeze still due commits like one the user asked for`() {
        val outcome = runFreeze(request(automatic = true))

        assertNull(outcome.failure)
        assertEquals("frozen", storage.phaseOf("ctx"))
        // Barriers 1 and 2, right before barrier 4, and right before the
        // teardown of its one loaded tab.
        assertEquals(4, dueChecks)
    }

    @Test
    fun `an automatic freeze no longer due at barrier 1 writes nothing and sends no command`() {
        stillDue = listOf(false)

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, outcome.failure)
        assertTrue(engine.calls.isEmpty())
        assertNull(storage.phaseOf("ctx"))
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `an automatic freeze used again during barrier 2 gives its intent up before any command`() {
        stillDue = listOf(true, false)

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, outcome.failure)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `an automatic freeze used again right before the teardown lifts its restriction and keeps the pages`() {
        stillDue = listOf(true, true, false)

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, outcome.failure)
        assertEquals(listOf("install [ctx]", "lift [ctx]"), engine.calls)
        assertEquals(engine.commands.sorted(), engine.commands)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        assertTrue(store.state.findTab("a")!!.engineState.engineSession === sessionA)
    }

    @Test
    fun `an automatic freeze used again during a tab's flush keeps that page and lifts its restriction`() {
        val sessionB: EngineSession = Mockito.mock(EngineSession::class.java)
        store = BrowserStore(
            store.state.copy(
                tabs = store.state.tabs + createTab("https://b.example", id = "b", contextId = "ctx", engineSession = sessionB),
            ),
        )
        setUpWithStore()
        // Due at barriers 1 and 2, before barrier 4 and before "a" goes; "b"
        // is selected while it is flushed.
        stillDue = listOf(true, true, true, true, false)

        val outcome = runFreeze(request(members = setOf("a", "b", "unloaded"), automatic = true))

        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, outcome.failure)
        assertEquals(listOf("install [ctx]", "lift [ctx]"), engine.calls)
        assertEquals(engine.commands.sorted(), engine.commands)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        // "a" went before; "b" keeps its page.
        assertNull(store.state.findTab("a")!!.engineState.engineSession)
        assertTrue(store.state.findTab("b")!!.engineState.engineSession === sessionB)
        Mockito.verify(sessionB, Mockito.never()).close()
        // What was deferred while it was restricted goes to Gecko now.
        assertEquals(listOf(listOf("ctx")), push.drained.map { it?.toList() })
    }

    @Test
    fun `an automatic freeze whose rollback is not acknowledged stays restricted as failed`() {
        stillDue = listOf(true, true, false)
        engine.lift = { _, _ -> emptyList() }

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.ROLLBACK_UNCONFIRMED, outcome.failure)
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(EngineEnforcement.UNCERTAIN, registry.statusOf("ctx")?.enforcement)
    }

    @Test
    fun `an automatic freeze never retries a container that has a record`() {
        registry.beginFreeze("c1", listOf("ctx"))

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.NO_LONGER_ELIGIBLE, outcome.failure)
        assertTrue(engine.calls.isEmpty())
        assertEquals(0, dueChecks)
    }

    @Test
    fun `an automatic freeze defers on media and ignores a confirmation`() {
        val playing = MediaSessionState(
            Mockito.mock(MediaSession.Controller::class.java),
            playbackState = MediaSession.PlaybackState.PLAYING,
        )
        store = BrowserStore(
            store.state.copy(
                tabs = store.state.tabs.map { if (it.id == "a") it.copy(mediaSessionState = playing) else it },
            ),
        )
        setUpWithStore()

        val outcome = runFreeze(request(automatic = true).copy(stopMedia = true))

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker("a", null, ProtectedActivity.MEDIA)), outcome.blockers)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `form input refuses at barrier 2, names the tab and touches no engine state`() {
        formData = true

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker("a", null, ProtectedActivity.FORM_DATA)), outcome.blockers)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
    }

    @Test
    fun `form input the user agreed to lose freezes`() {
        formData = true

        val outcome = runFreeze(request().copy(discardFormDataOf = setOf("a")))

        assertEquals(ContextPhase.FROZEN, outcome.phase)
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `form input agreed to lose in another tab still refuses`() {
        formData = true

        val outcome = runFreeze(request().copy(discardFormDataOf = setOf("someOtherTab")))

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker("a", null, ProtectedActivity.FORM_DATA)), outcome.blockers)
    }

    @Test
    fun `an automatic freeze takes form input only from a container unused long enough`() {
        formData = true
        stillDue = listOf(true)

        val early = runFreeze(request(automatic = true))
        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, early.failure)
        assertFalse(registry.isRestricted("ctx"))

        freeze = newFreeze(typedTextMayGo = true)
        val late = runFreeze(request(automatic = true))
        assertEquals(ContextPhase.FROZEN, late.phase)
    }

    @Test
    fun `an automatic freeze never takes form input the request claims was agreed to`() {
        formData = true
        stillDue = listOf(true)

        val outcome = runFreeze(request(automatic = true).copy(discardFormDataOf = setOf("a")))

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
    }

    @Test
    fun `a form check that gives no answer refuses at barrier 2, before anything is cut off`() {
        // At the teardown the same silence counts as form input: passed
        // here, it would leave the freeze failed with tabs unloaded.
        formData = null

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker("a", null, ProtectedActivity.FORM_DATA)), outcome.blockers)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
        assertSame(sessionA, store.state.findTab("a")?.engineState?.engineSession)
    }

    @Test
    fun `form input refuses before the intent is written, so nothing counts as restricted meanwhile`() {
        formData = true

        val outcome = runFreeze(request(automatic = true))

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        // A push arriving while GeckoView answered was delivered: the
        // contexts were not restricted yet, and nothing was written.
        assertEquals(listOf(false), restrictedAtFormCheck)
        assertEquals(AtomicJsonFile.Read.Absent, storage.record)
    }

    @Test
    fun `form input typed after the first check refuses at barrier 2 and lifts nothing`() {
        formAnswers += listOf(false, true)

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(false, true), restrictedAtFormCheck)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
    }

    @Test
    fun `a print started while a tab is flushed refuses its teardown and keeps the page`() {
        duringFlush = { outputs.onAction(store.state, EngineAction.PrintContentAction("a")) }

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker("a", null, ProtectedActivity.PRINT_OR_PDF)), outcome.blockers)
        assertTrue(store.state.findTab("a")!!.engineState.engineSession === sessionA)
        Mockito.verify(sessionA, Mockito.never()).close()
        // Restricted since barrier 3: left failed, for Retry or Resume.
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `media the user agreed to stop does not refuse the teardown`() {
        val playing = MediaSessionState(
            Mockito.mock(MediaSession.Controller::class.java),
            playbackState = MediaSession.PlaybackState.PLAYING,
        )
        store = BrowserStore(
            store.state.copy(
                tabs = store.state.tabs.map { if (it.id == "a") it.copy(mediaSessionState = playing) else it },
            ),
        )
        setUpWithStore()

        val outcome = runFreeze(request().copy(stopMedia = true))

        assertNull(outcome.failure)
        assertEquals("frozen", storage.phaseOf("ctx"))
        Mockito.verify(playing.controller).pause()
        Mockito.verify(sessionA).close()
    }

    @Test
    fun `a running download of unknown context refuses the freeze`() {
        store.dispatch(
            DownloadAction.AddDownloadAction(
                DownloadState("https://d.example/file", id = "dl", status = DownloadState.Status.DOWNLOADING),
            ),
        )

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals(listOf(FreezeBlocker(null, "dl", ProtectedActivity.UNATTRIBUTED_DOWNLOAD)), outcome.blockers)
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `a paused download of the container is no blocker`() {
        DownloadContexts.record("dl", "ctx")
        store.dispatch(
            DownloadAction.AddDownloadAction(
                DownloadState("https://d.example/file", id = "dl", status = DownloadState.Status.PAUSED),
            ),
        )

        assertNull(runFreeze().failure)
    }

    @Test
    fun `an unconfirmed install is rolled back with a newer lift, and only an acknowledged one clears the intent`() {
        engine.install = { _, _ -> throw IOException("no answer") }

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.ENGINE_REFUSED, outcome.failure)
        assertEquals(listOf("install [ctx]", "lift [ctx]"), engine.calls)
        assertTrue(engine.commands[1] > engine.commands[0])
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        // The tab was never torn down.
        assertTrue(store.state.findTab("a")!!.engineState.engineSession === sessionA)
    }

    @Test
    fun `when neither the install nor its rollback is confirmed the contexts stay restricted as failed`() {
        engine.install = { _, _ -> CompletableDeferred<List<CommandAck>>().await() }
        engine.lift = { _, _ -> CompletableDeferred<List<CommandAck>>().await() }

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.ROLLBACK_UNCONFIRMED, outcome.failure)
        assertEquals(ContextPhase.FAILED, outcome.phase)
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(EngineEnforcement.UNCERTAIN, registry.statusOf("ctx")?.enforcement)
    }

    @Test
    fun `an acknowledgment of another command number does not count`() {
        engine.install = { ids, cmd -> ids.map { CommandAck(it, cmd - 1, true, true) } }

        assertEquals(LifecycleFailure.ENGINE_REFUSED, runFreeze().failure)
    }

    @Test
    fun `a quiescence timeout leaves the freeze failed with what still runs, restriction kept`() {
        engine.quiescence = { ids, cmd ->
            ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.TIMED_OUT, setOf(FreezeActivity.CONNECTIONS)) }
        }

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.QUIESCENCE_TIMED_OUT, outcome.failure)
        assertEquals(setOf(FreezeActivity.CONNECTIONS), outcome.stillRunning)
        assertEquals(listOf("ctx"), outcome.unsettled)
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `a freeze intent that cannot be written does nothing`() {
        storage.failWrites = true

        assertEquals(LifecycleFailure.NOT_PERSISTED, runFreeze().failure)
        assertTrue(engine.calls.isEmpty())
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `a skipped push tells Dart, so the placeholder's count follows`() {
        runFreeze()
        val before = events.changes

        UndeliveredPushCounts.increment("ctx")

        assertEquals(before + 1, events.changes)
    }

    @Test
    fun `Resume lifts, forgets the records, drains the outbox and keeps tabs' own sleep holds`() {
        runFreeze()
        registry.completeSleep("unloaded", registry.beginSleep("unloaded", SleepHoldKind.MANUAL, private = false))
        UndeliveredPushCounts.increment("ctx")
        engine.calls.clear()

        val outcome = runBlocking { freeze.resume("c1", wakeTabId = "a") }

        assertNull(outcome.failure)
        assertNull(outcome.phase)
        assertEquals(listOf("lift [ctx]"), engine.calls)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        assertEquals(listOf(listOf("ctx")), push.drained.map { it?.toList() })
        assertEquals(0, UndeliveredPushCounts.countOf("ctx"))
        assertTrue(registry.isHeld("unloaded"))
    }

    @Test
    fun `a Resume that lifted only some contexts keeps the hold of a tab in the others`() {
        store = BrowserStore(
            store.state.copy(tabs = store.state.tabs + createTab("https://b.example", id = "b", contextId = "ctx2")),
        )
        setUpWithStore()
        runFreeze(request(members = setOf("a", "unloaded", "b"), contexts = listOf("ctx", "ctx2")))
        registry.completeSleep("b", registry.beginSleep("b", SleepHoldKind.MANUAL, private = false))
        engine.lift = { ids, cmd -> ids.map { CommandAck(it, cmd, it == "ctx", false) } }

        val outcome = runBlocking { freeze.resume("c1", wakeTabId = "b") }

        assertEquals(LifecycleFailure.ROLLBACK_UNCONFIRMED, outcome.failure)
        assertFalse(registry.isRestricted("ctx"))
        assertTrue(registry.isRestricted("ctx2"))
        // Its context still restricted: the Wake did not happen.
        assertTrue(registry.isHeld("b"))
    }

    @Test
    fun `an answer to a reinstall arriving after a newer Resume took over sets nothing`() = runBlocking {
        runFreeze()
        engine.calls.clear()
        // beginResume writes, then the record removals fail until told otherwise.
        var failWrites = true
        var writes = 0
        registry.setStorageForTest(object : JsonStore {
            override fun read() = storage.read()
            override fun write(json: JSONObject) {
                writes++
                if (failWrites && writes > 1) throw IOException("disk full")
                storage.write(json)
            }
            override fun keepDamagedCopy() = Unit
        })
        val reinstallAnswer = CompletableDeferred<Unit>()
        engine.install = { ids, cmd ->
            reinstallAnswer.await()
            ids.map { CommandAck(it, cmd, true, true) }
        }
        val first = async(start = CoroutineStart.UNDISPATCHED) { freeze.resume("c1", wakeTabId = null) }
        while ("install [ctx]" !in engine.calls) kotlinx.coroutines.delay(1)

        // A second Resume takes the contexts over; its lift is not confirmed.
        failWrites = false
        engine.lift = { ids, cmd -> ids.map { CommandAck(it, cmd, false, false) } }
        assertEquals(LifecycleFailure.ROLLBACK_UNCONFIRMED, freeze.resume("c1", wakeTabId = null).failure)
        assertEquals(EngineEnforcement.UNCERTAIN, registry.statusOf("ctx")?.enforcement)

        reinstallAnswer.complete(Unit)

        assertEquals(LifecycleFailure.SUPERSEDED, first.await().failure)
        // Not the old operation's "enforced": the engine's state is the newer one's to say.
        assertEquals(EngineEnforcement.UNCERTAIN, registry.statusOf("ctx")?.enforcement)
        assertEquals(ContextPhase.RESUMING, registry.recordOf("ctx")?.phase)
    }

    @Test
    fun `when the record cannot be removed after the lift, the restriction is installed again`() {
        runFreeze()
        engine.calls.clear()
        // beginResume writes, then every removal fails.
        var writes = 0
        val failing = object : JsonStore {
            override fun read() = storage.read()
            override fun write(json: JSONObject) {
                writes++
                if (writes > 1) throw IOException("disk full")
                storage.write(json)
            }
            override fun keepDamagedCopy() = Unit
        }
        // A fresh process view of the same record.
        registry.setStorageForTest(failing)

        val outcome = runBlocking { freeze.resume("c1", wakeTabId = null) }

        assertEquals(LifecycleFailure.NOT_PERSISTED, outcome.failure)
        assertEquals(listOf("lift [ctx]", "install [ctx]"), engine.calls)
        assertEquals(ContextPhase.RESUMING, registry.recordOf("ctx")?.phase)
        assertEquals(EngineEnforcement.ENFORCED, registry.statusOf("ctx")?.enforcement)
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `an unconfirmed reinstall leaves the enforcement uncertain, and the retry removes the records only after a confirmed lift`() {
        runFreeze()
        engine.calls.clear()
        var failWrites = true
        var writes = 0
        val failing = object : JsonStore {
            override fun read() = storage.read()
            override fun write(json: JSONObject) {
                writes++
                if (failWrites && writes > 1) throw IOException("disk full")
                storage.write(json)
            }
            override fun keepDamagedCopy() = Unit
        }
        registry.setStorageForTest(failing)
        freeze = newFreeze(backgroundRetryMillis = List(50) { 5L })
        engine.install = { ids, cmd -> ids.map { CommandAck(it, cmd, false, false) } }
        // The Resume's own lift is confirmed, the first retry's is not.
        var lifts = 0
        engine.lift = { ids, cmd -> ids.map { CommandAck(it, cmd, lifts++ != 1, false) } }

        val outcome = runBlocking { freeze.resume("c1", wakeTabId = null) }

        assertEquals(LifecycleFailure.NOT_PERSISTED, outcome.failure)
        assertEquals(EngineEnforcement.UNCERTAIN, registry.statusOf("ctx")?.enforcement)
        assertTrue(registry.isRestricted("ctx"))

        failWrites = false
        repeat(200) {
            if (!registry.isRestricted("ctx")) return@repeat
            Thread.sleep(10)
        }
        assertFalse(registry.isRestricted("ctx"))
        // Removed after a lift that was confirmed, not after the first retry's.
        assertEquals(listOf("lift [ctx]", "install [ctx]", "lift [ctx]", "lift [ctx]"), engine.calls)
    }

    @Test
    fun `a Resume during a freeze supersedes it, and the freeze writes nothing afterwards`() = runBlocking {
        val installAnswer = CompletableDeferred<Unit>()
        engine.install = { ids, cmd ->
            installAnswer.await()
            ids.map { CommandAck(it, cmd, true, true) }
        }
        val running = async(start = CoroutineStart.UNDISPATCHED) { freeze.freeze(request()) }
        assertTrue(registry.isRestricted("ctx"))

        val resumed = freeze.resume("c1", wakeTabId = null)
        installAnswer.complete(Unit)
        val frozen = running.await()

        assertNull(resumed.failure)
        assertEquals(LifecycleFailure.SUPERSEDED, frozen.failure)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        // The Resume's lift came after the install, with a higher number.
        assertEquals(listOf("install [ctx]", "lift [ctx]"), engine.calls)
        assertTrue(engine.commands[1] > engine.commands[0])
        // The tab was never torn down.
        assertTrue(store.state.findTab("a")!!.engineState.engineSession === sessionA)
    }

    @Test
    fun `a retired freeze becomes failed with the restriction kept`() = runBlocking {
        val installAnswer = CompletableDeferred<Unit>()
        engine.install = { ids, cmd ->
            installAnswer.await()
            ids.map { CommandAck(it, cmd, true, true) }
        }
        val running = async(start = CoroutineStart.UNDISPATCHED) { freeze.freeze(request()) }

        freeze.retire()

        assertEquals(LifecycleFailure.COMPONENTS_REPLACED, running.await().failure)
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `a deletion that could not be written leaves a running freeze to finish, and retiring still settles it`() = runBlocking {
        val installAnswer = CompletableDeferred<Unit>()
        engine.install = { ids, cmd ->
            installAnswer.await()
            ids.map { CommandAck(it, cmd, true, true) }
        }
        val running = async(start = CoroutineStart.UNDISPATCHED) { freeze.freeze(request()) }

        storage.failWrites = true
        assertEquals(LifecycleFailure.NOT_PERSISTED, freeze.beginDeletion("c1").failure)
        storage.failWrites = false
        freeze.retire()

        assertEquals(LifecycleFailure.COMPONENTS_REPLACED, running.await().failure)
        assertEquals("failed", storage.phaseOf("ctx"))
    }

    @Test
    fun `a commit that could not be written still freezes, and says it is not on disk`() {
        engine.quiescence = { ids, cmd ->
            storage.failWrites = true
            ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.QUIESCENT) }
        }

        val outcome = runFreeze()

        assertNull(outcome.failure)
        assertEquals(ContextPhase.FROZEN, outcome.phase)
        assertEquals("freezing", storage.phaseOf("ctx"))
        assertEquals(LifecycleFailure.NOT_PERSISTED, registry.statusOf("ctx")?.failure)
    }

    @Test
    fun `a freeze none of whose writes was confirmed durable is reported incomplete, still restricted`() {
        // The intent replaced the file without its folder being synced, and
        // putting the old one back failed: it counts as written, not durable.
        storage.plan += listOf(true, false)
        engine.quiescence = { ids, cmd ->
            storage.failWrites = true
            ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.QUIESCENT) }
        }

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.NOT_PERSISTED, outcome.failure)
        assertEquals(ContextPhase.FAILED, outcome.phase)
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(EngineEnforcement.ENFORCED, registry.statusOf("ctx")?.enforcement)

        // A Retry once the disk works writes it, and the freeze stands.
        storage.failWrites = false
        engine.quiescence = { ids, cmd -> ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.QUIESCENT) } }
        val retried = runFreeze()
        assertNull(retried.failure)
        assertEquals(ContextPhase.FROZEN, retried.phase)
        assertEquals("frozen", storage.phaseOf("ctx"))
    }

    @Test
    fun `the site data of a never frozen container is written down before its row goes, restricting nothing`() {
        assertNull(runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }.failure)

        assertEquals(mapOf("ctx" to "c1"), storage.dataDeletions())
        assertFalse(registry.isRestricted("ctx"))

        // The row stays after all.
        runBlocking { freeze.cancelDeletion("c1") }
        assertEquals(emptyMap(), storage.dataDeletions())
        assertTrue(push.removed.isEmpty())
    }

    @Test
    fun `deleting a never frozen container with its site data restricts its storage, then releases it`() {
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }

        val outcome = runBlocking { freeze.completeDeletion("c1") }

        assertNull(outcome.failure)
        assertTrue(outcome.unsettled.isEmpty())
        assertEquals(listOf("ctx"), push.removed)
        // Restricted in the engine, acknowledged, before anything is cleared.
        assertEquals(listOf("install [ctx]", "clear ctx", "lift [ctx]"), engine.calls)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        assertEquals(emptyMap(), storage.dataDeletions())
    }

    @Test
    fun `site data of a never frozen container that could not be deleted stays releasing and restricted`() {
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }
        engine.clear = { throw IOException("quota manager failed") }

        val outcome = runBlocking { freeze.completeDeletion("c1") }

        assertEquals(LifecycleFailure.CLEANUP_FAILED, outcome.failure)
        assertEquals(listOf("ctx"), outcome.unsettled)
        assertEquals("releasing", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertEquals(EngineEnforcement.ENFORCED, registry.statusOf("ctx")?.enforcement)
    }

    @Test
    fun `storage the engine did not confirm restricted is left releasing, nothing of it cleaned up`() {
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }
        engine.install = { ids, cmd -> ids.map { CommandAck(it, cmd, applied = false, restricted = false) } }

        val outcome = runBlocking { freeze.completeDeletion("c1") }

        assertEquals(LifecycleFailure.ENGINE_REFUSED, outcome.failure)
        assertEquals(listOf("ctx"), outcome.unsettled)
        assertTrue(push.removed.isEmpty())
        assertFalse("clear ctx" in engine.calls)
        assertEquals("releasing", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `a Resume while a Retry asks about protected activity stops the Retry before its intent`() = runBlocking {
        // A freeze that failed with a tab still loaded.
        val gen = assertNotNull(registry.beginFreeze("c1", listOf("ctx")))
        registry.setPhase(listOf("ctx"), gen, ContextPhase.FAILED)
        val answer = CompletableDeferred<Unit>()
        formCheckGate = answer

        val retry = async(start = CoroutineStart.UNDISPATCHED) { freeze.freeze(request()) }
        assertNull(freeze.resume("c1", null).failure)
        assertFalse(registry.isRestricted("ctx"))
        answer.complete(Unit)

        assertEquals(LifecycleFailure.SUPERSEDED, retry.await().failure)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
        assertFalse(engine.calls.any { it.startsWith("install") })
        assertSame(sessionA, store.state.findTab("a")?.engineState?.engineSession)
    }

    @Test
    fun `a data deletion not confirmed durable refuses the row delete and is not kept`() {
        // Replaced without its folder synced, and the old file not put back:
        // a power loss could undo it after the row went.
        storage.plan += listOf(true, false)

        val outcome = runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }

        assertEquals(LifecycleFailure.NOT_PERSISTED, outcome.failure)
        assertEquals(emptyList(), registry.dataDeletionsOf("c1"))
        assertFalse(registry.isRestricted("ctx"))
    }

    @Test
    fun `the start's reconciliation leaves a deletion that began in this process to it`() {
        runFreeze()
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("other")) }

        // The engine came up while the deletion ran, its row not deleted yet.
        runBlocking { freeze.reconcileOwners(setOf("c1")) }

        assertEquals("deletionPending", storage.phaseOf("ctx"))
        assertEquals(listOf("other"), registry.dataDeletionsOf("c1"))
        val outcome = runBlocking { freeze.completeDeletion("c1") }
        assertNull(outcome.failure)
        assertEquals(listOf("ctx", "other"), push.removed.sorted())
        assertFalse(registry.isRestricted("ctx"))
        assertFalse(registry.isRestricted("other"))
    }

    @Test
    fun `a data deletion left by a process that ended is released once its container is gone`() {
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }

        // The process ended after the row delete; the next start.
        registry.setStorageForTest(storage)
        runBlocking { freeze.reconcileOwners(emptySet()) }

        assertEquals(listOf("ctx"), push.removed)
        assertTrue("clear ctx" in engine.calls)
        assertNull(storage.phaseOf("ctx"))
        assertEquals(emptyMap(), storage.dataDeletions())
    }

    @Test
    fun `a data deletion left by a process that ended before the row delete is dropped`() {
        runBlocking { freeze.beginDeletion("c1", deleteDataOf = listOf("ctx")) }

        registry.setStorageForTest(storage)
        runBlocking { freeze.reconcileOwners(setOf("c1")) }

        assertTrue(push.removed.isEmpty())
        assertFalse("clear ctx" in engine.calls)
        assertFalse(registry.isRestricted("ctx"))
        assertEquals(emptyMap(), storage.dataDeletions())
    }

    @Test
    fun `a release says it deleted the data only of contexts with a record`() {
        runFreeze()
        runBlocking { freeze.beginDeletion("c1") }

        val results = runBlocking { freeze.release(listOf("ctx", "unrecorded")) }

        assertEquals(
            listOf(ContextReleaseResult("unrecorded", true, null, false), ContextReleaseResult("ctx", true, null, true)),
            results,
        )
        assertFalse("clear unrecorded" in engine.calls)
    }

    @Test
    fun `deleting a frozen container keeps it restricted until push removal and an acknowledged clear`() {
        runFreeze()
        engine.calls.clear()

        assertNull(runBlocking { freeze.beginDeletion("c1") }.failure)
        assertEquals("deletionPending", storage.phaseOf("ctx"))

        engine.clear = { throw IOException("quota manager failed") }
        val failed = runBlocking { freeze.completeDeletion("c1") }
        assertEquals(LifecycleFailure.CLEANUP_FAILED, failed.failure)
        assertEquals("releasing", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertFalse("lift [ctx]" in engine.calls)

        engine.clear = {}
        val released = runBlocking { freeze.release(listOf("ctx")) }
        assertEquals(listOf(ContextReleaseResult("ctx", true, null, true)), released)
        assertEquals(listOf("ctx", "ctx"), push.removed)
        assertFalse(registry.isRestricted("ctx"))
        assertNull(storage.phaseOf("ctx"))
    }

    @Test
    fun `a push subscription that could not be removed keeps the context releasing`() {
        runFreeze()
        runBlocking { freeze.beginDeletion("c1") }
        push.removes = false

        val outcome = runBlocking { freeze.completeDeletion("c1") }

        assertEquals(LifecycleFailure.CLEANUP_FAILED, outcome.failure)
        assertTrue(registry.isRestricted("ctx"))
    }

    @Test
    fun `a cancelled deletion puts the frozen phase back`() {
        runFreeze()
        runBlocking { freeze.beginDeletion("c1") }

        runBlocking { freeze.cancelDeletion("c1") }

        assertEquals("frozen", storage.phaseOf("ctx"))
    }

    @Test
    fun `in recovery a freeze, a Resume, a release and a deletion are refused`() {
        storage.record = AtomicJsonFile.Read.Corrupt("malformed json")
        registry.setStorageForTest(storage)

        assertEquals(LifecycleFailure.RECOVERY_PENDING, runFreeze().failure)
        assertEquals(LifecycleFailure.RECOVERY_PENDING, runBlocking { freeze.resume("c1", null) }.failure)
        assertEquals(
            listOf(ContextReleaseResult("ctx", false, LifecycleFailure.RECOVERY_PENDING, false)),
            runBlocking { freeze.release(listOf("ctx")) },
        )
        // Nothing would record the container's contexts, so nothing would
        // delete their data once its row is gone.
        assertEquals(LifecycleFailure.RECOVERY_PENDING, runBlocking { freeze.beginDeletion("c1") }.failure)
        assertTrue(engine.calls.isEmpty())
    }

    @Test
    fun `the reconstruction freezes owners, orphans what still has workers or subscriptions, and lifts the wildcard last`() {
        storage.record = AtomicJsonFile.Read.Corrupt("malformed json")
        registry.setStorageForTest(storage)
        engine.workers = listOf("ctx", "deletedWithWorker", "isolatedUnassigned")
        push.subscribed = setOf("deletedWithPush")

        runBlocking {
            freeze.reconstruct(mapOf("c1" to listOf("ctx")), unfreezable = setOf("isolatedUnassigned"))
        }
        val snapshot = registry.snapshot()

        assertFalse(snapshot.recovery)
        assertEquals(
            mapOf(
                "ctx" to ContextPhase.FROZEN,
                "deletedWithPush" to ContextPhase.ORPHANED,
                "deletedWithWorker" to ContextPhase.ORPHANED,
            ),
            snapshot.contexts.associate { it.contextId to it.record.phase },
        )
        assertTrue(registry.recordOf("ctx")!!.recovered)
        assertEquals(
            listOf("install [ctx, deletedWithPush, deletedWithWorker]", "lift [*]"),
            engine.calls,
        )
        assertFalse(registry.isRestricted("isolatedUnassigned"))
        // Changes deferred under the wildcard for a context it alone
        // restricted are handed over now, not at the next start.
        assertEquals(listOf<Collection<String>?>(null), push.drained)
    }

    @Test
    fun `an unconfirmed wildcard lift keeps every context restricted in this process`() {
        storage.record = AtomicJsonFile.Read.Corrupt("malformed json")
        registry.setStorageForTest(storage)
        engine.lift = { ids, cmd -> ids.map { CommandAck(it, cmd, false, true) } }

        runBlocking { freeze.reconstruct(mapOf("c1" to listOf("ctx")), emptySet()) }
        val snapshot = registry.snapshot()

        assertTrue(snapshot.recovery)
        assertTrue(registry.isRestricted("anything"))
        assertTrue(push.drained.isEmpty())
        // A restart is safe: explicit records on disk, normal mode.
        assertEquals("frozen", storage.phaseOf("ctx"))
    }

    @Test
    fun `owner reconciliation releases a deleted container's pending contexts in the background`() {
        runFreeze()
        runBlocking { freeze.beginDeletion("c1") }

        // The process ended after the row delete; the next start.
        registry.setStorageForTest(storage)
        runBlocking { freeze.reconcileOwners(existingOwnerIds = emptySet()) }

        // Dispatchers.Unconfined: the background release ran to completion.
        assertFalse(registry.isRestricted("ctx"))
        assertTrue("clear ctx" in engine.calls)
    }

    @Test
    fun `a freeze given up at barrier 2 hands what it deferred to Gecko, as no Resume will`() {
        UndeliveredPushCounts.increment("ctx")
        // Form input typed after the check before the intent.
        formAnswers += listOf(false, true)

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertFalse(registry.isRestricted("ctx"))
        assertEquals(listOf(listOf("ctx")), push.drained.map { it?.toList() })
        assertEquals(0, UndeliveredPushCounts.countOf("ctx"))
    }

    @Test
    fun `retrying a failed freeze keeps the contexts restricted when it is refused`() {
        engine.quiescence = { ids, cmd -> ids.map { QuiescenceAck(it, cmd, QuiescenceStatus.TIMED_OUT) } }
        runFreeze()
        assertEquals("failed", storage.phaseOf("ctx"))
        formData = true
        // The tab was torn down; bring one back that has form input.
        store = BrowserStore(
            store.state.copy(
                tabs = store.state.tabs.map {
                    if (it.id == "a") createTab("https://a.example", id = "a", contextId = "ctx", engineSession = sessionA) else it
                },
            ),
        )
        setUpWithStore()

        val outcome = runFreeze()

        assertEquals(LifecycleFailure.PROTECTED_ACTIVITY, outcome.failure)
        assertEquals("failed", storage.phaseOf("ctx"))
        assertTrue(registry.isRestricted("ctx"))
        assertNotNull(registry.statusOf("ctx"))
        // Still restricted: what waits for it waits for its Resume.
        assertTrue(push.drained.isEmpty())
    }
}
