/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.gecko.update

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** Every row of plan 7.6 stage 1. */
class InstallerReconcilerTest {
    private val expected = ExpectedArtifact(
        sha256 = "a".repeat(64),
        byteLength = 100,
        versionCode = 433,
        logicalReleaseSequence = 43,
        distribution = BuildDistribution.GITHUB,
        track = BuildTrack.STABLE,
        renderer = BuildRenderer.SKIA,
        abi = "arm64-v8a",
        authorizedUntilEpochMs = Long.MAX_VALUE,
    )

    private fun journal(phase: InstallerPhase, failure: NativeFailure? = null) = JournalRead.Present(
        JournalState(phase = phase, sessionId = 7, nonce = "n", expected = expected, failure = failure),
    )

    private fun decide(
        journal: JournalRead,
        installed: Long = 423,
        sessions: List<SessionView> = emptyList(),
        installedByUs: Boolean? = true,
        filling: Int? = null,
    ) = InstallerReconciler.decide(ReconcileInput(journal, installed, installedByUs, sessions, filling))

    @Test
    fun installedVersionReachedAfterCommitIsOurSuccess() {
        val d = decide(journal(InstallerPhase.COMMIT_REQUESTED), installed = 433)
        assertEquals(ReconcileResult.SUCCEEDED, d.reconciliation.result)
        assertTrue(d.reconciliation.ours)
        assertEquals(InstallerPhase.NONE, d.journal!!.phase)
        assertEquals(InstallerPhase.SUCCEEDED, d.journal!!.lastOutcome)
    }

    @Test
    fun anotherInstallerFinishedFirstAbandonsOurLeftoverSession() {
        val d = decide(
            journal(InstallerPhase.SESSION_CREATED),
            installed = 433,
            sessions = listOf(SessionView(7, Committedness.UNCOMMITTED)),
        )
        assertEquals(ReconcileResult.SUCCEEDED, d.reconciliation.result)
        assertFalse(d.reconciliation.ours)
        assertEquals(listOf(7), d.abandon)
    }

    @Test
    fun installedByAnotherPackageOnApi30IsNotOurs() {
        val d = decide(journal(InstallerPhase.COMMIT_REQUESTED), installed = 433, installedByUs = false)
        assertFalse(d.reconciliation.ours)
    }

    @Test
    fun uncommittedSessionIsAbandonedEvenWhenTheJournalSaysCommitRequested() {
        // Process death between writing commitRequested and calling commit().
        val d = decide(
            journal(InstallerPhase.COMMIT_REQUESTED),
            sessions = listOf(SessionView(7, Committedness.UNCOMMITTED)),
        )
        assertEquals(ReconcileResult.NONE, d.reconciliation.result)
        assertEquals(listOf(7), d.abandon)
        assertFalse(InstallerReconciler.holdsReservation(d))
    }

    @Test
    fun theSessionBeingFilledIsAReservationNotALeftover() {
        // commit() copies into it outside the lock; a reconciliation meanwhile
        // must neither abandon it nor let a second session start.
        val d = decide(
            journal(InstallerPhase.SESSION_CREATED),
            sessions = listOf(SessionView(7, Committedness.UNCOMMITTED), SessionView(9, Committedness.UNCOMMITTED)),
            filling = 7,
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertEquals(listOf(9), d.abandon)
        assertNull(d.journal)
        assertTrue(InstallerReconciler.holdsReservation(d))
    }

    @Test
    fun theSessionBeingFilledIsKeptWithAnUnreadableJournal() {
        val d = decide(
            JournalRead.Corrupt("bad"),
            sessions = listOf(SessionView(7, Committedness.UNCOMMITTED)),
            filling = 7,
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertTrue(d.abandon.isEmpty())
    }

    @Test
    fun anUncommittedSessionNobodyFillsIsStillAbandoned() {
        val d = decide(
            journal(InstallerPhase.SESSION_CREATED),
            sessions = listOf(SessionView(7, Committedness.UNCOMMITTED)),
            filling = 9,
        )
        assertEquals(ReconcileResult.NONE, d.reconciliation.result)
        assertEquals(listOf(7), d.abandon)
    }

    @Test
    fun committedSessionWithNoCallbackIsInProgressAndKept() {
        val d = decide(
            journal(InstallerPhase.COMMIT_REQUESTED),
            sessions = listOf(SessionView(7, Committedness.COMMITTED)),
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertTrue(d.abandon.isEmpty())
        assertNull(d.journal)
        assertTrue(InstallerReconciler.holdsReservation(d))
    }

    @Test
    fun unknownCommittednessIsNeverReadAsUncommitted() {
        val d = decide(
            journal(InstallerPhase.COMMIT_REQUESTED),
            sessions = listOf(SessionView(7, Committedness.UNKNOWN)),
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertTrue(d.abandon.isEmpty())
    }

    @Test
    fun pendingUserActionForTheLiveSessionIsAwaitingUserAction() {
        val d = decide(
            journal(InstallerPhase.PENDING_USER_ACTION),
            sessions = listOf(SessionView(7, Committedness.COMMITTED)),
        )
        assertEquals(ReconcileResult.AWAITING_USER_ACTION, d.reconciliation.result)
        assertTrue(InstallerReconciler.holdsReservation(d))
    }

    @Test
    fun nonTerminalWithoutSessionAndARecordedFailureIsThatFailure() {
        val d = decide(journal(InstallerPhase.COMMIT_REQUESTED, failure = NativeFailure.INSTALL_CONFLICT))
        assertEquals(ReconcileResult.FAILED, d.reconciliation.result)
        assertEquals(NativeFailure.INSTALL_CONFLICT, d.reconciliation.failure)
        assertEquals(InstallerPhase.NONE, d.journal!!.phase)
        assertEquals(InstallerPhase.FAILED, d.journal!!.lastOutcome)
    }

    @Test
    fun aCommitWithoutSessionAndNothingRecordedIsInstallUnknown() {
        val d = decide(journal(InstallerPhase.COMMIT_REQUESTED))
        assertEquals(ReconcileResult.FAILED, d.reconciliation.result)
        assertEquals(NativeFailure.INSTALL_UNKNOWN, d.reconciliation.failure)
    }

    @Test
    fun aSessionNeverCommittedAndSinceCleanedUpFailedNothing() {
        // The process died while filling it; Android removed it before the
        // next start. Nothing was committed, so there is no failure to show.
        val d = decide(journal(InstallerPhase.SESSION_CREATED))
        assertEquals(ReconcileResult.NONE, d.reconciliation.result)
        assertEquals(InstallerPhase.ABANDONED, d.journal!!.lastOutcome)
        assertFalse(InstallerReconciler.holdsReservation(d))
    }

    @Test
    fun anInterruptedAbandonmentIsAskedForAgain() {
        // The process died after recording abandonRequested and before
        // Android was asked; the committed session is still listed.
        val d = decide(
            journal(InstallerPhase.ABANDON_REQUESTED),
            sessions = listOf(SessionView(7, Committedness.COMMITTED), SessionView(8, Committedness.COMMITTED)),
        )
        assertEquals(listOf(7, 8), d.abandon)
        assertTrue(d.confirmAbandoned)
        // Still a reservation until Android's list drops it.
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertNull(d.journal)

        // The decision after abandoning: gone, so abandoned.
        val after = decide(journal(InstallerPhase.ABANDON_REQUESTED))
        assertEquals(ReconcileResult.NONE, after.reconciliation.result)
        assertEquals(InstallerPhase.ABANDONED, after.journal!!.lastOutcome)
        assertFalse(after.confirmAbandoned)
    }

    @Test
    fun missingJournalWithASealedSessionIsInProgressNotAbandoned() {
        val d = decide(JournalRead.Absent, sessions = listOf(SessionView(9, Committedness.COMMITTED)))
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertTrue(d.abandon.isEmpty())
    }

    @Test
    fun unreadableJournalDecidesByThePlatformAlone() {
        val d = decide(
            JournalRead.Corrupt("garbage"),
            sessions = listOf(
                SessionView(9, Committedness.COMMITTED),
                SessionView(10, Committedness.UNCOMMITTED),
            ),
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertEquals(listOf(10), d.abandon)
    }

    @Test
    fun aStraySessionAlongsideTheNamedOneIsAbandoned() {
        val d = decide(
            journal(InstallerPhase.COMMIT_REQUESTED),
            sessions = listOf(SessionView(7, Committedness.COMMITTED), SessionView(8, Committedness.COMMITTED)),
        )
        assertEquals(ReconcileResult.IN_PROGRESS, d.reconciliation.result)
        assertEquals(listOf(8), d.abandon)
    }

    @Test
    fun terminalEntriesAreHistoryNotAReservation() {
        for (phase in listOf(InstallerPhase.FAILED, InstallerPhase.ABANDONED, InstallerPhase.SUCCEEDED)) {
            val d = decide(journal(phase, failure = NativeFailure.INSTALL_CANCELLED))
            assertFalse(phase.name, InstallerReconciler.holdsReservation(d))
            // Retired: the session fields are cleared, so a late callback from
            // that session no longer matches anything.
            assertNull(phase.name, d.journal!!.sessionId)
            assertNull(phase.name, d.journal!!.nonce)
        }
    }

    @Test
    fun abandonRequestedWithTheSessionGoneIsAbandoned() {
        val d = decide(journal(InstallerPhase.ABANDON_REQUESTED))
        assertEquals(ReconcileResult.NONE, d.reconciliation.result)
        assertEquals(InstallerPhase.ABANDONED, d.journal!!.lastOutcome)
    }

    @Test
    fun aRetiredJournalWithNothingListedIsNone() {
        val d = decide(JournalRead.Present(JournalState().retired()))
        assertEquals(ReconcileResult.NONE, d.reconciliation.result)
        assertNull(d.journal)
    }
}
