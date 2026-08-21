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
package eu.weblibre.flutter_mozilla_components.startup

import java.io.File
import java.nio.file.Files
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertIs
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"
private const val PROFILE_B = "0199a0b1-2222-7222-8222-222222222222"
private const val MISSING = "0199a0b1-9999-7999-8999-999999999999"

class StartupArbiterTest {

    private lateinit var filesDir: File
    private lateinit var paths: StartupPaths
    private lateinit var writer: RecordingWriter
    private var now: Long = 1_000_000L

    private val ui = StartupOwner(StartupOwnerType.UI, "engine-ui")
    private val headless = StartupOwner(StartupOwnerType.HEADLESS, "engine-headless")

    private class RecordingWriter : CommittedProfileWriter {
        val persisted = mutableListOf<String>()
        var failWith: Throwable? = null

        override fun persist(profileId: String) {
            failWith?.let { throw it }
            persisted += profileId
        }
    }

    @BeforeTest
    fun setUp() {
        filesDir = Files.createTempDirectory("weblibre_arbiter").toFile()
        paths = StartupPaths(filesDir)
        paths.profilesDir.mkdirs()
        paths.maintenanceJournalsDir.mkdirs()
        paths.maintenanceRestoreDir.mkdirs()
        writer = RecordingWriter()
        StartupArbiter.resetForTest()
    }

    @AfterTest
    fun tearDown() {
        StartupArbiter.resetForTest()
        filesDir.deleteRecursively()
    }

    private fun writeProfile(profileId: String, name: String = "Profile") {
        val dir = File(paths.profilesDir, "profile-$profileId")
        dir.mkdirs()
        File(dir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", profileId).put("name", name).toString(),
        )
    }

    private fun initialize() {
        StartupArbiter.initialize(paths, writer) { now }
    }

    private fun advance(millis: Long) {
        now += millis
    }

    // --- initialization --------------------------------------------------------

    @Test
    fun beforeInitializationNothingIsCommittedAndStartupIsUnavailable() {
        assertIs<StartupState.Uninitialized>(StartupArbiter.currentState())
        assertEquals(
            StartupDirectiveKind.UNAVAILABLE,
            StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).kind,
        )
    }

    @Test
    fun initializationResolvesTheCandidateButDoesNotCommit() {
        writeProfile(PROFILE_B)
        writeProfile(PROFILE_A)
        initialize()

        val state = assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertEquals(PROFILE_A, state.candidateProfileId)
        assertTrue(writer.persisted.isEmpty())
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun peekAnswersTheProfileQuestionWithoutSettlingIt() {
        // What a background worker needs before it does anything irreversible:
        // is this queued job even for the profile this process would serve? A
        // worker that had to commit to find out let a stale push job answer the
        // picker the user was going to be shown.
        writeProfile(PROFILE_A)
        initialize()

        assertEquals(paths.relativeProfilePath(PROFILE_A), StartupArbiter.peekProfileFolder())

        assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertTrue(writer.persisted.isEmpty())
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun peekAgreesWithTheCommittedProfileOnceThereIsOne() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.tryCommitExternal(requestedProfileId = null, trusted = false)

        assertEquals(StartupArbiter.boundProfileFolder(), StartupArbiter.peekProfileFolder())
    }

    @Test
    fun peekWithholdsAnAnswerWhileMaintenanceOwnsTheProcess() {
        // Not "no" but "not knowable yet". A caller that read this as a mismatch
        // would drop a queued message over a reservation that resolves later.
        writeProfile(PROFILE_A)
        File(paths.maintenanceJournalsDir, "task-1.json").writeText(
            JSONObject()
                .put("taskId", "task-1")
                .put("kind", "restore")
                .put("phase", "oldMoved")
                .put("targetProfileId", PROFILE_A)
                .toString(),
        )
        initialize()

        assertNull(StartupArbiter.peekProfileFolder())
    }

    @Test
    fun peekWithholdsAnAnswerWithNoValidProfile() {
        initialize()

        assertNull(StartupArbiter.peekProfileFolder())
    }

    @Test
    fun initializationIsIdempotent() {
        writeProfile(PROFILE_A)
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId
        initialize()

        // A second initialize must not throw the live selection away.
        val state = assertIs<StartupState.Selecting>(StartupArbiter.currentState())
        assertEquals(leaseId, state.leaseId)
    }

    @Test
    fun aValidCurrentProfileBeatsTheOldestOne() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_B)
        initialize()

        assertEquals(
            PROFILE_B,
            assertIs<StartupState.Unresolved>(StartupArbiter.currentState()).candidateProfileId,
        )
    }

    @Test
    fun firstRunHasNoCandidate() {
        initialize()

        assertNull(
            assertIs<StartupState.Unresolved>(StartupArbiter.currentState()).candidateProfileId,
        )
    }

    // --- selection -------------------------------------------------------------

    @Test
    fun aUiOwnerTakesTheSelectionLeaseAndCommits() {
        writeProfile(PROFILE_A)
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertEquals(StartupDirectiveKind.SELECT, directive.kind)
        assertEquals(PROFILE_A, directive.candidateProfileId)
        assertFalse(directive.showPicker)

        assertTrue(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_A))

        val state = assertIs<StartupState.Committed>(StartupArbiter.currentState())
        assertEquals(PROFILE_A, state.profileId)
        assertEquals("weblibre_profiles/profile-$PROFILE_A", state.relativePath)
        assertEquals(listOf(PROFILE_A), writer.persisted)
    }

    @Test
    fun thePickerIsShownOnlyForAUiOwnerWithPromptOnAndTwoProfiles() {
        writeProfile(PROFILE_A)
        initialize()

        // Prompt on, but only one profile: nothing to choose.
        assertFalse(StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY).showPicker)

        writeProfile(PROFILE_B)
        StartupArbiter.resetForTest()
        initialize()
        assertTrue(StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY).showPicker)

        StartupArbiter.resetForTest()
        initialize()
        assertFalse(StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).showPicker)

        StartupArbiter.resetForTest()
        initialize()
        assertFalse(
            StartupArbiter.beginStartup(headless, ProfilePromptMode.BROWSER_ONLY).showPicker,
        )
    }

    @Test
    fun anExplicitSwitchDoesNotPromptEvenWithPromptOn() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }

        // Both conditions for a picker hold — a UI owner, prompting on, two valid
        // profiles — but the user answered this question in the switch screen and
        // the restart is only how the answer is carried out.
        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertEquals(PROFILE_B, directive.candidateProfileId)
        assertFalse(directive.showPicker)
    }

    @Test
    fun theSuppressedPickerReturnsOnTheNextOrdinaryStart() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }
        val switched = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertTrue(StartupArbiter.commitSelection(switched.leaseId!!, PROFILE_B))

        // Suppression is scoped to the one launch the switch caused. A cold start
        // after it has no request to apply, so "ask" behaves as configured again.
        StartupArbiter.resetForTest()
        StartupArbiter.initialize(paths, writer) { now }

        assertTrue(StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY).showPicker)
    }

    @Test
    fun anEngineThatAsksTwiceAfterASwitchIsStillNotPrompted() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }

        val first = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertFalse(first.showPicker)

        // An Activity recreation resumes the same lease; a rotation mid-startup
        // must not resurrect the picker the switch already answered.
        val second = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertEquals(first.leaseId, second.leaseId)
        assertFalse(second.showPicker)
    }

    @Test
    fun aReleasedLeaseKeepsTheSwitchFromBecomingAQuestion() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertTrue(StartupArbiter.releaseSelection(directive.leaseId!!, "test"))

        // Handing back a lease means this owner stopped resolving, not that the
        // user withdrew the switch that named the candidate.
        val retry = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertEquals(PROFILE_B, retry.candidateProfileId)
        assertFalse(retry.showPicker)
    }

    @Test
    fun theSameEngineResumesItsOwnLeaseInsteadOfPromptingTwice() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val first = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        val second = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        assertEquals(StartupDirectiveKind.SELECT, second.kind)
        assertEquals(first.leaseId, second.leaseId)
    }

    @Test
    fun aDifferentEngineIsRefusedWhileAnotherHoldsTheSelection() {
        writeProfile(PROFILE_A)
        initialize()

        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        val other = StartupArbiter.beginStartup(
            StartupOwner(StartupOwnerType.UI, "engine-other"),
            ProfilePromptMode.BROWSER_ONLY,
        )
        assertEquals(StartupDirectiveKind.UNAVAILABLE, other.kind)
    }

    @Test
    fun aStaleLeaseCannotCommit() {
        writeProfile(PROFILE_A)
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertTrue(StartupArbiter.releaseSelection(directive.leaseId!!, "user cancelled"))

        val reacquired = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertNotEquals(directive.leaseId, reacquired.leaseId)

        assertFalse(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_A))
        assertIs<StartupState.Selecting>(StartupArbiter.currentState())
    }

    @Test
    fun committingAProfileThatDoesNotExistIsRefused() {
        writeProfile(PROFILE_A)
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertFalse(StartupArbiter.commitSelection(directive.leaseId!!, MISSING))
        assertTrue(writer.persisted.isEmpty())
    }

    @Test
    fun aFailedPersistLeavesTheProcessUncommitted() {
        writeProfile(PROFILE_A)
        initialize()
        writer.failWith = java.io.IOException("disk full")

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertFalse(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_A))

        assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun anAlreadyCommittedProcessReportsCommittedRatherThanPrompting() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_B)

        val second = StartupArbiter.beginStartup(
            StartupOwner(StartupOwnerType.UI, "engine-2"),
            ProfilePromptMode.BROWSER_ONLY,
        )
        assertEquals(StartupDirectiveKind.COMMITTED, second.kind)
        assertEquals(PROFILE_B, second.profileId)
        assertFalse(second.showPicker)
    }

    // --- selection watchdog ----------------------------------------------------

    @Test
    fun anIdleSelectionCommitsTheCandidate() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        advance(StartupArbiter.SELECTION_TIMEOUT_MS)

        assertEquals(PROFILE_A, StartupArbiter.committedProfileId())
    }

    @Test
    fun aHeartbeatKeepsTheSelectionAlive() {
        writeProfile(PROFILE_A)
        initialize()
        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY).leaseId!!

        advance(StartupArbiter.SELECTION_TIMEOUT_MS - 1)
        assertTrue(StartupArbiter.heartbeatSelection(leaseId))

        advance(StartupArbiter.SELECTION_TIMEOUT_MS - 1)
        assertIs<StartupState.Selecting>(StartupArbiter.currentState())
    }

    @Test
    fun aStaleHeartbeatDoesNotRenewTheLease() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        assertFalse(StartupArbiter.heartbeatSelection("not-the-lease"))
    }

    @Test
    fun anIdleSelectionOnFirstRunStaysUnresolvedInsteadOfInventingAProfile() {
        initialize()
        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        advance(StartupArbiter.SELECTION_TIMEOUT_MS)

        assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertTrue(writer.persisted.isEmpty())
    }

    // --- external / headless entry points --------------------------------------

    @Test
    fun aHeadlessCallerCommitsTheCandidateWhileUnresolved() {
        writeProfile(PROFILE_A)
        initialize()

        val result = StartupArbiter.tryCommitExternal(null, trusted = false)
        assertIs<ExternalCommitResult.CommittedRequested>(result)
        assertEquals(PROFILE_A, result.profileId)
    }

    @Test
    fun aHeadlessCallerRetriesRatherThanRacingThePicker() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        assertEquals(
            ExternalCommitResult.SelectionInProgress,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
        assertIs<StartupState.Selecting>(StartupArbiter.currentState())
    }

    @Test
    fun anUntrustedProfileHintCannotSelectAProfile() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val result = StartupArbiter.tryCommitExternal(PROFILE_B, trusted = false)

        // Falls back to the candidate; the spoofable hint is ignored entirely.
        assertIs<ExternalCommitResult.CommittedRequested>(result)
        assertEquals(PROFILE_A, result.profileId)
    }

    @Test
    fun aTrustedLaunchBindsItsOwnProfileWhileUnresolved() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val result = StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true)

        assertIs<ExternalCommitResult.CommittedRequested>(result)
        assertEquals(PROFILE_B, result.profileId)
    }

    @Test
    fun honorShortcutProfileOffFallsBackToTheCandidate() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val result = StartupArbiter.tryCommitExternal(
            PROFILE_B,
            trusted = true,
            honorShortcutProfile = false,
        )

        assertIs<ExternalCommitResult.CommittedRequested>(result)
        assertEquals(PROFILE_A, result.profileId)
    }

    @Test
    fun aTrustedLaunchCannotCommitAProfileWhoseMetadataIsDamaged() {
        // Authenticating the launch proves the caller may name PROFILE_B. It does
        // not prove PROFILE_B still parses — and committing a profile Dart's
        // discovery skips would bind the process to something Flutter refuses,
        // which the immutable process profile makes unrecoverable.
        writeProfile(PROFILE_A)
        File(paths.profilesDir, "profile-$PROFILE_B").mkdirs()
        File(
            File(paths.profilesDir, "profile-$PROFILE_B"),
            StartupPaths.PROFILE_METADATA_FILE_NAME,
        ).writeText("""{ "id": "$PROFILE_B" }""")
        initialize()

        val result = StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true)

        assertIs<ExternalCommitResult.NoValidProfile>(result)
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun aBareDirectoryWithNoMetadataIsNotCommittable() {
        writeProfile(PROFILE_A)
        File(paths.profilesDir, "profile-$PROFILE_B").mkdirs()
        initialize()

        assertIs<ExternalCommitResult.NoValidProfile>(
            StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true),
        )

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertFalse(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_B))
    }

    @Test
    fun aProfileWhoseMetadataClaimsAnotherUuidIsNotCommittable() {
        writeProfile(PROFILE_A)
        val dir = File(paths.profilesDir, "profile-$PROFILE_B")
        dir.mkdirs()
        File(dir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
            JSONObject().put("id", PROFILE_A).put("name", "Impostor").toString(),
        )
        initialize()

        assertIs<ExternalCommitResult.NoValidProfile>(
            StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true),
        )
    }

    @Test
    fun aTrustedLaunchAnswersAnOpenSelection() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)

        val result = StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true)
        val answered = assertIs<ExternalCommitResult.AnsweredSelection>(result)
        assertEquals(PROFILE_B, answered.profileId)
        assertEquals(directive.leaseId, answered.leaseId)
        assertEquals(PROFILE_B, StartupArbiter.committedProfileId())

        // The lease the picker still holds can no longer commit anything.
        assertFalse(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_A))
        assertEquals(PROFILE_B, StartupArbiter.committedProfileId())
    }

    @Test
    fun aTrustedLaunchIntoADifferentCommittedProfileNeverRebinds() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()
        StartupArbiter.tryCommitExternal(PROFILE_A, trusted = true)

        val result = StartupArbiter.tryCommitExternal(PROFILE_B, trusted = true)

        val mismatch = assertIs<ExternalCommitResult.AlreadyCommittedDifferent>(result)
        assertEquals(PROFILE_A, mismatch.profileId)
        assertEquals(PROFILE_A, StartupArbiter.committedProfileId())
        assertEquals(listOf(PROFILE_A), writer.persisted)
    }

    @Test
    fun firstRunRefusesAHeadlessCallerRatherThanCreatingAProfile() {
        initialize()

        assertEquals(
            ExternalCommitResult.NoValidProfile,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
    }

    // --- maintenance -----------------------------------------------------------

    private fun writeIncompleteJournal(taskId: String = "task-1") {
        paths.journalFile(taskId).writeText(
            JSONObject()
                .put("taskId", taskId)
                .put("kind", MaintenanceJournalKind.RESTORE.id)
                .put("phase", RestorePhase.OLD_MOVED.id)
                .put("targetProfileId", PROFILE_A)
                .put("updatedAt", "2026-08-18T00:00:00.000Z")
                .toString(),
        )
    }

    @Test
    fun durableEvidenceReservesMaintenanceInsteadOfResolvingACandidate() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val state = assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertEquals("task-1", state.taskId)
        assertTrue(state.recoveryRequired)
    }

    @Test
    fun everyProfileConsumerIsRefusedWhileMaintenanceOwnsTheProcess() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        assertEquals(
            ExternalCommitResult.MaintenanceRefused,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
        assertEquals(
            ExternalCommitResult.MaintenanceRefused,
            StartupArbiter.tryCommitExternal(PROFILE_A, trusted = true),
        )
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun theMaintenanceOwnerGetsALeaseAndFencesItsBoundaries() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertEquals(StartupDirectiveKind.MAINTENANCE, directive.kind)
        assertEquals("task-1", directive.maintenanceTaskId)
        assertTrue(directive.recoveryRequired)

        val leaseId = directive.leaseId!!
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "moveOldPrepared"))
        assertFalse(StartupArbiter.assertMaintenanceLease("stale", "task-1", "moveOldPrepared"))
        assertFalse(StartupArbiter.assertMaintenanceLease(leaseId, "task-2", "moveOldPrepared"))
    }

    @Test
    fun anExpiredMaintenanceLeaseKeepsTheReservationAndDemandsARestart() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)

        val state = assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertTrue(state.recoveryRequired)
        assertTrue(StartupArbiter.restartRequiredForRecovery)

        // The stale holder must not be able to keep mutating the profile.
        assertFalse(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))
        assertNull(StartupArbiter.committedProfileId())
    }

    @Test
    fun anExpiredMaintenanceLeaseCannotBeReacquiredInTheSameProcess() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)

        // The watchdog has no timer thread: expiry is evaluated on the next
        // observation, so the flag is only set once something looks at the state.
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertTrue(StartupArbiter.restartRequiredForRecovery)

        // Handing out a second lease here would resume destructive work in the
        // very process that just stalled, against state whose consistency is now
        // unknown. The reservation is kept until a new process picks it up.
        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertEquals(StartupDirectiveKind.UNAVAILABLE, directive.kind)
        assertEquals(StartupArbiter.RESTART_REQUIRED_REASON, directive.reason)
        assertTrue(directive.recoveryRequired)
        assertNull(directive.leaseId)

        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertEquals(
            ExternalCommitResult.MaintenanceRefused,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
    }

    @Test
    fun aFreshProcessMayTakeTheReservationTheStalledOneGaveUp() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)

        // `restartRequiredForRecovery` is per-process by design: the next process
        // reads the same durable evidence and is allowed to recover from it.
        StartupArbiter.resetForTest()
        initialize()

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertEquals(StartupDirectiveKind.MAINTENANCE, directive.kind)
        assertNotNull(directive.leaseId)
    }

    @Test
    fun aLateHeartbeatRenewsRatherThanExpiring() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        // Nothing observed the state while the deadline passed — which is exactly
        // what a frozen process looks like. The owner coming back and saying so is
        // proof of liveness, not grounds for demanding a recovery.
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS * 5)
        assertTrue(StartupArbiter.heartbeatMaintenance(leaseId))

        assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
        assertFalse(StartupArbiter.restartRequiredForRecovery)
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))
    }

    @Test
    fun aLateBoundaryAssertionIsAlsoHonoured() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS * 5)
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))
        assertFalse(StartupArbiter.restartRequiredForRecovery)
    }

    @Test
    fun aStaleHolderStillCannotRenewPastATakeover() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        // Something *did* observe the expiry, so the reservation moved on. Renewing
        // late must not be able to walk it back — that is the fencing the deadline
        // exists for.
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())

        assertFalse(StartupArbiter.heartbeatMaintenance(leaseId))
        assertFalse(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
    }

    @Test
    fun aHeldDeadlineDoesNotExpireWhileTheOwnerIsNotRunning() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        assertTrue(StartupArbiter.holdMaintenanceHeartbeat(leaseId, true))

        // A push broadcast, an incoming intent — anything can unfreeze the process
        // and observe the state before the user comes back. None of it may retire a
        // lease whose owner was never given the chance to beat.
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS * 10)
        assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
        assertFalse(StartupArbiter.restartRequiredForRecovery)

        assertTrue(StartupArbiter.holdMaintenanceHeartbeat(leaseId, false))
        val resumed = assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
        assertFalse(resumed.heartbeatHeld)
    }

    @Test
    fun releasingTheHoldPutsTheDeadlineBack() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        StartupArbiter.holdMaintenanceHeartbeat(leaseId, true)
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS * 3)
        assertTrue(StartupArbiter.holdMaintenanceHeartbeat(leaseId, false))

        // Released means watched again: a resumed owner that then stalls is exactly
        // what the deadline is for.
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertTrue(StartupArbiter.restartRequiredForRecovery)
    }

    @Test
    fun workContinuingInTheBackgroundDoesNotUndoTheHold() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        StartupArbiter.holdMaintenanceHeartbeat(leaseId, true)

        // A task runs behind a backgrounded app, so `keepAlive` keeps beating and
        // boundaries keep being crossed. Both say the owner is *running*, which is
        // a different question from whether it is on screen — and if either
        // released the hold, the backup would undo its own protection every
        // fifteen seconds and be caught out by the next freeze.
        assertTrue(StartupArbiter.heartbeatMaintenance(leaseId))
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))

        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS * 4)
        val state = assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
        assertTrue(state.heartbeatHeld)
        assertFalse(StartupArbiter.restartRequiredForRecovery)
    }

    @Test
    fun aDestroyedEngineHandsBackItsMaintenanceLease() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        StartupArbiter.holdMaintenanceHeartbeat(leaseId, true)

        // Android destroying a backgrounded activity is routine, and MainActivity
        // destroys the cached engine with it. A held lease never expires, so
        // without this the replacement engine would be told "maintenance owned by
        // <dead engine>" for the life of the process.
        assertTrue(StartupArbiter.abandonEngine(ui.engineId))
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())

        // Proven loss, not suspected loss: the destroyed isolate cannot still be
        // mutating, so the replacement engine may recover rather than being
        // refused until the process is killed.
        assertFalse(StartupArbiter.restartRequiredForRecovery)
        val directive = StartupArbiter.beginStartup(
            StartupOwner(StartupOwnerType.UI, "engine-2"),
            ProfilePromptMode.OFF,
        )
        assertEquals(StartupDirectiveKind.MAINTENANCE, directive.kind)
        assertNotNull(directive.leaseId)
        assertTrue(directive.recoveryRequired)
    }

    @Test
    fun aDestroyedEngineHandsBackItsSelectionLease() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertTrue(StartupArbiter.abandonEngine(ui.engineId))

        val directive = StartupArbiter.beginStartup(
            StartupOwner(StartupOwnerType.UI, "engine-2"),
            ProfilePromptMode.BROWSER_ONLY,
        )
        assertEquals(StartupDirectiveKind.SELECT, directive.kind)
        assertTrue(directive.showPicker)
    }

    @Test
    fun abandoningSomeoneElsesEngineChangesNothing() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        assertFalse(StartupArbiter.abandonEngine("engine-2"))
        assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))
    }

    @Test
    fun onlyTheLeaseHolderMayHoldTheDeadline() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)

        assertFalse(StartupArbiter.holdMaintenanceHeartbeat("stale", true))
        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS)
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
    }

    @Test
    fun aBoundaryAssertionCountsAsALivenessSignal() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS - 1)
        assertTrue(StartupArbiter.assertMaintenanceLease(leaseId, "task-1", "installed"))

        advance(StartupArbiter.MAINTENANCE_HEARTBEAT_TIMEOUT_MS - 1)
        assertIs<StartupState.Maintenance>(StartupArbiter.currentState())
    }

    @Test
    fun finishingMaintenanceOnlySucceedsOnceTheEvidenceIsGone() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!

        // Evidence still on disk: the reservation is kept, not released.
        assertFalse(StartupArbiter.finishMaintenance(leaseId))
        assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())

        paths.journalFile("task-1").delete()
        val secondLease = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        assertTrue(StartupArbiter.finishMaintenance(secondLease))

        val state = assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertEquals(PROFILE_A, state.candidateProfileId)
    }

    @Test
    fun finishingMaintenanceDoesNotAskWhichProfileToOpen() {
        // A backup, restore or deletion restarts the process; the user asked for
        // the operation, not for a different profile. Prompting afterwards made
        // them re-answer a question they never asked.
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        paths.journalFile("task-1").delete()
        assertTrue(StartupArbiter.finishMaintenance(leaseId))

        val state = assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertEquals(PROFILE_A, state.candidateProfileId)
        assertTrue(state.candidateIsRestartTarget)

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertEquals(StartupDirectiveKind.SELECT, directive.kind)
        assertFalse(directive.showPicker)
    }

    @Test
    fun finishingMaintenanceStillAsksWhenThereIsNoProfileToReturnTo() {
        // The suppression is about *returning*, so it has to stop applying the
        // moment the candidate is a fallback rather than the profile this process
        // was serving. Here `current_profile` names a profile that no longer
        // validates, and choosing between what is left is a real question.
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(MISSING)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        paths.journalFile("task-1").delete()
        assertTrue(StartupArbiter.finishMaintenance(leaseId))

        val state = assertIs<StartupState.Unresolved>(StartupArbiter.currentState())
        assertFalse(state.candidateIsRestartTarget)

        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.BROWSER_ONLY)
        assertEquals(StartupDirectiveKind.SELECT, directive.kind)
        assertTrue(directive.showPicker)
    }

    @Test
    fun suspendingMaintenanceReturnsToTheReservationRatherThanReleasingIt() {
        writeProfile(PROFILE_A)
        writeIncompleteJournal()
        initialize()

        val leaseId = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).leaseId!!
        assertTrue(StartupArbiter.suspendMaintenance(leaseId, "task-1"))

        val reserved = assertIs<StartupState.MaintenanceReserved>(StartupArbiter.currentState())
        assertEquals("task-1", reserved.taskId)
        assertTrue(reserved.recoveryRequired)

        // The suspended lease is spent; profile access stays refused.
        assertFalse(StartupArbiter.heartbeatMaintenance(leaseId))
        assertEquals(
            ExternalCommitResult.MaintenanceRefused,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
    }

    // --- restart ---------------------------------------------------------------

    @Test
    fun preparingARestartRefusesProfileAccessButCanBeAborted() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.tryCommitExternal(null, trusted = false)

        assertTrue(StartupArbiter.prepareRestart(PROFILE_B, "profileSwitch"))
        assertEquals(
            ExternalCommitResult.Terminating,
            StartupArbiter.tryCommitExternal(null, trusted = false),
        )
        assertEquals(
            StartupDirectiveKind.UNAVAILABLE,
            StartupArbiter.beginStartup(headless, ProfilePromptMode.OFF).kind,
        )

        assertTrue(StartupArbiter.abortRestart())
        val restored = assertIs<StartupState.Committed>(StartupArbiter.currentState())
        assertEquals(PROFILE_A, restored.profileId)
    }

    @Test
    fun onceRestartingThereIsNoWayBack() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.prepareRestart(PROFILE_A, "maintenance")
        assertTrue(StartupArbiter.confirmRestarting())

        assertFalse(StartupArbiter.abortRestart())
        assertFalse(StartupArbiter.prepareRestart(PROFILE_A, "again"))
        assertIs<StartupState.Restarting>(StartupArbiter.currentState())
    }

    @Test
    fun aRestartRequestFromThisProcessIsNeverHonoured() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val selfIssued = RestartRequest(
            requestId = "req-1",
            reason = "profileSwitch",
            processInstanceId = StartupArbiter.processInstanceId,
            stateId = RestartRequestState.PENDING.id,
            createdAtMillis = now,
            expiresAtMillis = now + 60_000,
            targetProfileId = PROFILE_B,
        )

        assertFalse(StartupArbiter.applyRestartTarget(selfIssued))
        assertEquals(
            PROFILE_A,
            assertIs<StartupState.Unresolved>(StartupArbiter.currentState()).candidateProfileId,
        )
    }

    @Test
    fun aRestartRequestFromTheOldProcessOverridesTheCandidate() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val request = RestartRequest(
            requestId = "req-1",
            reason = "profileSwitch",
            processInstanceId = "the-old-process",
            stateId = RestartRequestState.PENDING.id,
            createdAtMillis = now,
            expiresAtMillis = now + 60_000,
            targetProfileId = PROFILE_B,
        )

        assertTrue(StartupArbiter.applyRestartTarget(request))
        assertEquals(
            PROFILE_B,
            assertIs<StartupState.Unresolved>(StartupArbiter.currentState()).candidateProfileId,
        )
    }

    @Test
    fun anExpiredRestartRequestIsIgnored() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val request = RestartRequest(
            requestId = "req-1",
            reason = "profileSwitch",
            processInstanceId = "the-old-process",
            stateId = RestartRequestState.PENDING.id,
            createdAtMillis = now - 120_000,
            expiresAtMillis = now - 60_000,
            targetProfileId = PROFILE_B,
        )

        assertFalse(StartupArbiter.applyRestartTarget(request))
    }

    // --- commitment callbacks ---------------------------------------------------

    @Test
    fun committedCallbacksRunOnceAndOutsideTheArbitrationMonitor() {
        writeProfile(PROFILE_A)
        initialize()

        val seen = mutableListOf<String>()
        StartupArbiter.onCommitted { profileId, relativePath ->
            // Re-entering the arbiter from a callback must not deadlock.
            seen += "$profileId:${StartupArbiter.committedProfileId()}:$relativePath"
        }

        StartupArbiter.tryCommitExternal(null, trusted = false)
        StartupArbiter.currentState()

        assertEquals(
            listOf("$PROFILE_A:$PROFILE_A:weblibre_profiles/profile-$PROFILE_A"),
            seen,
        )
    }

    @Test
    fun oneFailingCallbackDoesNotBlockTheOthers() {
        writeProfile(PROFILE_A)
        initialize()

        var second = false
        StartupArbiter.onCommitted { _, _ -> throw IllegalStateException("boom") }
        StartupArbiter.onCommitted { _, _ -> second = true }

        StartupArbiter.tryCommitExternal(null, trusted = false)

        assertTrue(second)
    }

    @Test
    fun registeringAfterCommitmentFiresImmediately() {
        writeProfile(PROFILE_A)
        initialize()
        StartupArbiter.tryCommitExternal(null, trusted = false)

        var fired = false
        StartupArbiter.onCommitted { _, _ -> fired = true }

        assertTrue(fired)
    }

    // --- concurrency ------------------------------------------------------------

    @Test
    fun concurrentCommitAttemptsProduceExactlyOneCommittedProfile() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val threads = 16
        val executor = Executors.newFixedThreadPool(threads)
        val start = CountDownLatch(1)
        val done = CountDownLatch(threads)

        try {
            repeat(threads) { index ->
                executor.execute {
                    start.await()
                    val target = if (index % 2 == 0) PROFILE_A else PROFILE_B
                    StartupArbiter.tryCommitExternal(target, trusted = true)
                    done.countDown()
                }
            }
            start.countDown()
            assertTrue(done.await(10, TimeUnit.SECONDS))
        } finally {
            executor.shutdownNow()
        }

        val committed = StartupArbiter.committedProfileId()
        assertTrue(committed == PROFILE_A || committed == PROFILE_B)
        assertEquals(listOf(committed), writer.persisted)
    }

    @Test
    fun aWorkerRacingTheUiEitherWinsOutrightOrAdoptsTheUiChoice() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        initialize()

        val executor = Executors.newFixedThreadPool(2)
        val start = CountDownLatch(1)
        val done = CountDownLatch(2)

        try {
            executor.execute {
                start.await()
                val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
                directive.leaseId?.let { StartupArbiter.commitSelection(it, PROFILE_B) }
                done.countDown()
            }
            executor.execute {
                start.await()
                StartupArbiter.tryCommitExternal(null, trusted = false)
                done.countDown()
            }
            start.countDown()
            assertTrue(done.await(10, TimeUnit.SECONDS))
        } finally {
            executor.shutdownNow()
        }

        // Whoever won, the process has exactly one profile and persisted it once.
        val committed = StartupArbiter.committedProfileId()
        assertTrue(committed == PROFILE_A || committed == PROFILE_B)
        assertEquals(listOf(committed), writer.persisted)
    }

    // --- restart request consumption --------------------------------------------

    private fun writeRestartRequest(
        targetProfileId: String?,
        processInstanceId: String = "other-process",
        state: RestartRequestState = RestartRequestState.PENDING,
        expiresAtMillis: Long = now + 60_000L,
    ): RestartRequest {
        val request = RestartRequest(
            requestId = "req-1",
            reason = "profileSwitch",
            processInstanceId = processInstanceId,
            stateId = state.id,
            createdAtMillis = now,
            expiresAtMillis = expiresAtMillis,
            targetProfileId = targetProfileId,
        )
        RestartRequestStore(paths).write(request)
        return request
    }

    @Test
    fun aPendingRestartOverridesTheCandidateOnTheNextStart() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }

        // The old process deliberately never rewrote current_profile, so the
        // request is the only thing that knows the switch happened.
        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertEquals(PROFILE_B, directive.candidateProfileId)
    }

    @Test
    fun anAppliedRestartIsNotReplayed() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B, state = RestartRequestState.APPLIED)

        StartupArbiter.initialize(paths, writer) { now }

        assertEquals(
            PROFILE_A,
            StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).candidateProfileId,
        )
    }

    @Test
    fun anExpiredRestartIsIgnored() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(PROFILE_B, expiresAtMillis = now - 1)

        StartupArbiter.initialize(paths, writer) { now }

        assertEquals(
            PROFILE_A,
            StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).candidateProfileId,
        )
    }

    @Test
    fun aRestartTargetThatNoLongerValidatesIsIgnored() {
        writeProfile(PROFILE_A)
        paths.currentProfileFile.writeText(PROFILE_A)
        writeRestartRequest(MISSING)

        StartupArbiter.initialize(paths, writer) { now }

        assertEquals(
            PROFILE_A,
            StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF).candidateProfileId,
        )
    }

    @Test
    fun committingClearsTheAppliedRestartSoItCannotRepeat() {
        writeProfile(PROFILE_A)
        writeProfile(PROFILE_B)
        writeRestartRequest(PROFILE_B)

        StartupArbiter.initialize(paths, writer) { now }
        val directive = StartupArbiter.beginStartup(ui, ProfilePromptMode.OFF)
        assertTrue(StartupArbiter.commitSelection(directive.leaseId!!, PROFILE_B))

        // Left behind, the next process would switch to B again over whatever the
        // user chose in between.
        assertNull(RestartRequestStore(paths).read())
    }
}
