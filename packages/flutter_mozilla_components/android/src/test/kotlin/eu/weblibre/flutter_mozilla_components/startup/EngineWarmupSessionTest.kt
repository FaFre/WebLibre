/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.startup

import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.runBlocking

class EngineWarmupSessionTest {
    /** Stands in for the session, counting the closes the real one would get. */
    private class FakeSession {
        val closed = CountDownLatch(1)
        fun handle() = EngineWarmupSession.Handle { closed.countDown() }
        val isClosed get() = closed.count == 0L
    }

    private val extensionReady = MutableStateFlow(false)
    private val liveSession = MutableStateFlow(false)

    @AfterTest
    fun tearDown() {
        EngineWarmupSession.resetForTest()
    }

    private fun startWarmup(
        session: FakeSession = FakeSession(),
        hasLiveEngineSession: () -> Boolean = { false },
    ): FakeSession {
        EngineWarmupSession.scopeFactory =
            { CoroutineScope(Dispatchers.Default + SupervisorJob()) }
        EngineWarmupSession.startWith(
            hasLiveEngineSession = hasLiveEngineSession,
            openSession = { session.handle() },
            realSessionSignal = { liveSession.filter { it }.map { } },
            extensionReadySignal = { extensionReady.filter { it }.map { } },
        )
        return session
    }

    private fun FakeSession.awaitClose(): Boolean =
        closed.await(5, TimeUnit.SECONDS)

    /** A source that stays open and silent, like the real signals do. */
    private fun neverEmits(): Flow<Unit> = MutableStateFlow(false).filter { it }.map { }

    // ---- the close policy -------------------------------------------------

    @Test
    fun anExtensionBackgroundComingUpEndsTheWarmup() = runBlocking {
        assertEquals(
            EngineWarmupSession.CloseReason.EXTENSION_READY,
            EngineWarmupSession.awaitCloseSignal(
                extensionReady = flowOf(Unit),
                realSession = emptyFlow(),
                ceilingMs = 5_000L,
            ),
        )
    }

    @Test
    fun aRealSessionTakingOverEndsTheWarmup() = runBlocking {
        assertEquals(
            EngineWarmupSession.CloseReason.REAL_SESSION,
            EngineWarmupSession.awaitCloseSignal(
                extensionReady = emptyFlow(),
                realSession = flowOf(Unit),
                ceilingMs = 5_000L,
            ),
        )
    }

    /** The window is given back even when nothing ever proves it worked. */
    @Test
    fun theCeilingEndsTheWarmupOnItsOwn() = runBlocking {
        assertEquals(
            EngineWarmupSession.CloseReason.CEILING,
            EngineWarmupSession.awaitCloseSignal(
                extensionReady = neverEmits(),
                realSession = neverEmits(),
                ceilingMs = 50L,
            ),
        )
    }

    /**
     * A signal source that ends without ever firing reads as "nothing to
     * report", not as an error. The store flow closes with its subscription,
     * and an exception here would leave the window held for the life of the
     * process.
     */
    @Test
    fun aSignalSourceThatEndsWithoutFiringIsNotAnError() = runBlocking {
        assertEquals(
            EngineWarmupSession.CloseReason.CEILING,
            EngineWarmupSession.awaitCloseSignal(
                extensionReady = emptyFlow(),
                realSession = emptyFlow(),
                ceilingMs = 5_000L,
            ),
        )
    }

    /** Neither signal is required to arrive before the other is watched for. */
    @Test
    fun aSignalThatAlreadyHeldWhenTheWaitStartedStillCounts() = runBlocking {
        val alreadyTrue: Flow<Unit> = MutableStateFlow(true).filter { it }.map { }

        assertEquals(
            EngineWarmupSession.CloseReason.EXTENSION_READY,
            EngineWarmupSession.awaitCloseSignal(
                extensionReady = alreadyTrue,
                realSession = emptyFlow(),
                ceilingMs = 5_000L,
            ),
        )
    }

    // ---- lifetime ---------------------------------------------------------

    @Test
    fun aSessionThatAlreadyHoldsAWindowMakesTheWarmupUnnecessary() {
        val session = startWarmup(hasLiveEngineSession = { true })

        assertFalse(EngineWarmupSession.isOpenForTest(), "opened a redundant window")
        assertFalse(session.isClosed, "never opened, so nothing to close")
        assertTrue(EngineWarmupSession.isCompletedForTest())
    }

    @Test
    fun startIsIdempotent() {
        startWarmup()
        val second = FakeSession()

        EngineWarmupSession.startWith(
            hasLiveEngineSession = { false },
            openSession = { second.handle() },
            realSessionSignal = { emptyFlow() },
            extensionReadySignal = { emptyFlow() },
        )

        assertFalse(second.isClosed, "a second window was opened")
        assertTrue(EngineWarmupSession.isOpenForTest())
    }

    @Test
    fun theExtensionSignalClosesTheOpenSession() {
        val session = startWarmup()
        assertTrue(EngineWarmupSession.isOpenForTest())

        extensionReady.value = true

        assertTrue(session.awaitClose(), "warm-up session was not closed")
        assertTrue(EngineWarmupSession.isCompletedForTest())
    }

    @Test
    fun aRealSessionClosesTheOpenSession() {
        val session = startWarmup()

        liveSession.value = true

        assertTrue(session.awaitClose(), "warm-up session was not closed")
    }

    /** Once the window has done its job, a components rebuild must not reopen one. */
    @Test
    fun aCompletedWarmupIsNotRepeated() {
        val first = startWarmup()
        extensionReady.value = true
        assertTrue(first.awaitClose())

        val second = FakeSession()
        EngineWarmupSession.startWith(
            hasLiveEngineSession = { false },
            openSession = { second.handle() },
            realSessionSignal = { emptyFlow() },
            extensionReadySignal = { emptyFlow() },
        )

        assertFalse(EngineWarmupSession.isOpenForTest(), "reopened after completing")
    }

    @Test
    fun stopClosesTheSessionForShutdown() {
        val session = startWarmup()

        EngineWarmupSession.stop()

        assertTrue(session.isClosed, "shutdown left the window open")
        assertFalse(EngineWarmupSession.isOpenForTest())
    }

    /**
     * A teardown before either signal arrived is not proof the delayed startup
     * ran, so the next setup has to open a window again.
     */
    @Test
    fun stopDoesNotCountAsCompleting() {
        startWarmup()
        EngineWarmupSession.stop()

        assertFalse(EngineWarmupSession.isCompletedForTest())

        val second = FakeSession()
        EngineWarmupSession.startWith(
            hasLiveEngineSession = { false },
            openSession = { second.handle() },
            realSessionSignal = { emptyFlow() },
            extensionReadySignal = { emptyFlow() },
        )

        assertTrue(EngineWarmupSession.isOpenForTest(), "did not reopen after a teardown")
    }

    /** A runtime that refuses to open a session must not take startup with it. */
    @Test
    fun aFailedOpenIsSurvivable() {
        EngineWarmupSession.scopeFactory =
            { CoroutineScope(Dispatchers.Default + SupervisorJob()) }

        EngineWarmupSession.startWith(
            hasLiveEngineSession = { false },
            openSession = { error("no runtime") },
            realSessionSignal = { emptyFlow() },
            extensionReadySignal = { emptyFlow() },
        )

        assertFalse(EngineWarmupSession.isOpenForTest())
        assertFalse(EngineWarmupSession.isCompletedForTest())
    }
}
