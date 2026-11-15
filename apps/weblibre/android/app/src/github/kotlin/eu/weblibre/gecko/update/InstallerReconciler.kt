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

/** Whether Android says a session was committed (7.6, "Committed, per API level"). */
enum class Committedness { COMMITTED, UNCOMMITTED, UNKNOWN }

/** One of our sessions in `packageInstaller.mySessions`. */
data class SessionView(val sessionId: Int, val committed: Committedness)

data class ReconcileInput(
    val journal: JournalRead,
    val installedVersionCode: Long,
    /** On API 30+, whether WebLibre is the installing package of record. */
    val installedByUs: Boolean?,
    val sessions: List<SessionView>,
    /**
     * The session [SessionInstaller.commit] is filling right now, in this
     * process. Not committed yet, but a reservation, never a leftover.
     */
    val fillingSessionId: Int? = null,
)

data class ReconcileDecision(
    val reconciliation: InstallerReconciliation,
    /** Sessions to abandon before anything else happens. */
    val abandon: List<Int>,
    /** The journal to write, or null to leave it as it is. */
    val journal: JournalState?,
    /**
     * Decide again once [abandon] is applied: this replays an abandonment
     * the process died in the middle of, and only Android's session list
     * afterwards shows whether it took.
     */
    val confirmAbandoned: Boolean = false,
)

/**
 * Stage 1 of recovery (plan 7.6): what is Android doing? Inputs are only the
 * native journal, the installed version code and Android's own session list,
 * so missing or damaged Dart state can never make a live installation vanish
 * from the accounting.
 *
 * Pure, so every row of the table is a unit test. [SessionInstaller] applies
 * the decision.
 */
object InstallerReconciler {
    fun decide(input: ReconcileInput): ReconcileDecision {
        val state = (input.journal as? JournalRead.Present)?.state

        // Unknown is never read as uncommitted. The session being filled is
        // live although not committed yet: abandoning it would pull it from
        // under the commit that is copying into it.
        fun live(view: SessionView) =
            view.committed != Committedness.UNCOMMITTED || view.sessionId == input.fillingSessionId

        // Journal absent or unreadable: the platform alone decides each session.
        if (state == null) {
            val (live, dead) = input.sessions.partition(::live)
            return ReconcileDecision(
                reconciliation = reconciliation(
                    if (live.isNotEmpty()) ReconcileResult.IN_PROGRESS else ReconcileResult.NONE,
                ),
                abandon = dead.map { it.sessionId },
                journal = null,
            )
        }

        val named = input.sessions.firstOrNull { it.sessionId == state.sessionId }
        val strays = input.sessions.filter { it !== named }.map { it.sessionId }
        val expected = state.expected

        // Finished: the installed version reached the expected one. Ours only
        // if our session reached commit; a leftover session of ours is
        // abandoned, because another installer finished first.
        if (expected != null && state.phase != InstallerPhase.NONE &&
            input.installedVersionCode >= expected.versionCode
        ) {
            val ours = state.phase.reachedCommit && input.installedByUs != false
            val done = state.copy(phase = InstallerPhase.SUCCEEDED).retired()
            return ReconcileDecision(
                reconciliation = reconciliation(ReconcileResult.SUCCEEDED, ours = ours, expected = expected),
                abandon = input.sessions.map { it.sessionId },
                journal = done,
            )
        }

        if (named != null) {
            if (!live(named)) {
                // Process death between `commitRequested` and `commit()`, or
                // before it: no reservation remains.
                return ReconcileDecision(
                    reconciliation = reconciliation(ReconcileResult.NONE),
                    abandon = listOf(named.sessionId) + strays,
                    journal = state.copy(phase = InstallerPhase.ABANDONED).retired(),
                )
            }
            if (state.phase == InstallerPhase.ABANDON_REQUESTED) {
                // The process died between recording the cancel and asking
                // Android: ask again. Still in progress until Android's list
                // drops the session, which the decision after this one sees.
                return ReconcileDecision(
                    reconciliation = reconciliation(ReconcileResult.IN_PROGRESS, expected = expected),
                    abandon = listOf(named.sessionId) + strays,
                    journal = null,
                    confirmAbandoned = true,
                )
            }
            val result = if (state.phase == InstallerPhase.PENDING_USER_ACTION) {
                ReconcileResult.AWAITING_USER_ACTION
            } else {
                ReconcileResult.IN_PROGRESS
            }
            return ReconcileDecision(
                reconciliation = reconciliation(result, expected = expected),
                abandon = strays,
                journal = null,
            )
        }

        // No session of ours that the journal names.
        return when {
            state.phase == InstallerPhase.NONE -> ReconcileDecision(
                reconciliation = reconciliation(ReconcileResult.NONE),
                abandon = strays,
                journal = null,
            )

            // `sessionCreated`: the process died while filling the session,
            // and Android has since cleaned it up. Nothing was committed, so
            // nothing failed to install.
            state.phase == InstallerPhase.ABANDON_REQUESTED || state.phase == InstallerPhase.ABANDONED ||
                state.phase == InstallerPhase.SESSION_CREATED ->
                ReconcileDecision(
                    reconciliation = reconciliation(ReconcileResult.NONE),
                    abandon = strays,
                    journal = state.copy(phase = InstallerPhase.ABANDONED).retired(),
                )

            state.phase == InstallerPhase.SUCCEEDED -> ReconcileDecision(
                // The callback said so, but the version did not change (the
                // case above handles the one where it did). Report what Android
                // shows: nothing in progress.
                reconciliation = reconciliation(ReconcileResult.NONE),
                abandon = strays,
                journal = state.retired(),
            )

            else -> {
                // Failed, or a commit was asked for (`commitRequested`,
                // `pendingUserAction`): the install ended without succeeding.
                // A `commitRequested` whose `commit()` never ran leaves its
                // session behind (handled above) until Android expires it
                // days later; by then a commit that did run is the likelier
                // story, and an outcome nobody heard is reported, not hidden.
                val failure = state.failure ?: NativeFailure.INSTALL_UNKNOWN
                ReconcileDecision(
                    reconciliation = reconciliation(ReconcileResult.FAILED, failure = failure, detail = state.lastMessage, expected = expected),
                    abandon = strays,
                    journal = state.copy(phase = InstallerPhase.FAILED, failure = failure).retired(),
                )
            }
        }
    }

    private fun reconciliation(
        result: ReconcileResult,
        ours: Boolean = false,
        failure: NativeFailure? = null,
        detail: String? = null,
        expected: ExpectedArtifact? = null,
    ) = InstallerReconciliation(
        result = result,
        ours = ours,
        failure = failure,
        detail = detail,
        expected = expected,
    )

    /** A live reservation blocks a new session (7.5 step 7). */
    fun holdsReservation(decision: ReconcileDecision): Boolean =
        decision.reconciliation.result == ReconcileResult.IN_PROGRESS ||
            decision.reconciliation.result == ReconcileResult.AWAITING_USER_ACTION
}
