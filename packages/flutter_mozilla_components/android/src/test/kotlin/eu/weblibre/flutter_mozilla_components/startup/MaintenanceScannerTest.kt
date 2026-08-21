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
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.json.JSONArray
import org.json.JSONObject

private const val PROFILE_ID = "0199a0b1-1111-7111-8111-111111111111"

/** Mirrors `apps/weblibre/test/core/startup/maintenance_scanner_test.dart`. */
class MaintenanceScannerTest {

    private lateinit var filesDir: File
    private lateinit var paths: StartupPaths

    @BeforeTest
    fun setUp() {
        filesDir = Files.createTempDirectory("weblibre_maintenance").toFile()
        paths = StartupPaths(filesDir)
        paths.profilesDir.mkdirs()
        paths.maintenanceJournalsDir.mkdirs()
        paths.maintenanceRestoreDir.mkdirs()
    }

    @AfterTest
    fun tearDown() {
        filesDir.deleteRecursively()
    }

    private fun writeJournal(taskId: String, kind: String, phase: String) {
        paths.journalFile(taskId).writeText(
            JSONObject()
                .put("version", MAINTENANCE_JOURNAL_VERSION)
                .put("taskId", taskId)
                .put("kind", kind)
                .put("phase", phase)
                .put("targetProfileId", PROFILE_ID)
                .put("participants", JSONArray())
                .put("updatedAt", "2026-08-18T00:00:00.000Z")
                .toString(),
        )
    }

    private fun configWith(vararg tasks: Pair<String, MaintenanceTaskState>) = StartupConfig(
        pendingTasks = tasks.map { (id, state) ->
            MaintenanceTaskSummary(
                id = id,
                actionId = MaintenanceAction.BACKUP.id,
                stateId = state.id,
                profileId = PROFILE_ID,
                profileName = "Default",
            )
        },
    )

    @Test
    fun anEmptyWorkspaceProducesNoReservation() {
        val scan = MaintenanceScan.scan(paths)

        assertFalse(scan.hasDurableEvidence)
        val reservation = MaintenanceReservation.resolve(StartupConfig.DEFAULTS, scan)
        assertFalse(reservation.required)
        assertFalse(reservation.recoveryRequired)
    }

    @Test
    fun aCompletedJournalAloneDoesNotReserveMaintenance() {
        writeJournal("task-1", MaintenanceJournalKind.DELETE.id, DeletePhase.COMPLETED.id)

        val scan = MaintenanceScan.scan(paths)
        assertEquals(1, scan.journals.size)
        assertTrue(scan.incompleteJournals.isEmpty())
        assertFalse(scan.hasDurableEvidence)
    }

    @Test
    fun anIncompleteJournalReservesMaintenanceAndDemandsRecovery() {
        writeJournal("task-1", MaintenanceJournalKind.RESTORE.id, RestorePhase.OLD_MOVED.id)

        val reservation = MaintenanceReservation.resolve(
            StartupConfig.DEFAULTS,
            MaintenanceScan.scan(paths),
        )

        assertTrue(reservation.required)
        assertTrue(reservation.recoveryRequired)
        assertEquals("task-1", reservation.taskId)
        assertEquals(setOf(PROFILE_ID), reservation.scan.profilesUnderMaintenance)
    }

    @Test
    fun anUnreadableJournalIsReportedNotQuarantinedAway() {
        paths.journalFile("task-1").writeText("{ not json")

        val scan = MaintenanceScan.scan(paths)

        assertEquals(1, scan.unreadableJournals.size)
        assertTrue(scan.hasDurableEvidence)
        // The evidence must survive the scan, or the next process would boot the
        // possibly half-restored profile.
        assertTrue(paths.journalFile("task-1").exists())
    }

    @Test
    fun aJournalWithoutIdentifyingFieldsCountsAsUnreadable() {
        paths.journalFile("task-1").writeText("""{"phase":"staged"}""")

        val scan = MaintenanceScan.scan(paths)
        assertEquals(1, scan.unreadableJournals.size)
        assertTrue(scan.journals.isEmpty())
    }

    @Test
    fun restoreArtifactsReserveMaintenanceEvenWithNoConfigAtAll() {
        paths.restoreOldDir("task-1").mkdirs()
        File(paths.restoreOldDir("task-1"), "metadata.json").writeText("{}")

        val scan = MaintenanceScan.scan(paths)
        assertEquals(1, scan.artifacts.size)
        assertTrue(scan.artifacts.single().hasOld)
        assertFalse(scan.artifacts.single().hasStaging)

        val reservation = MaintenanceReservation.resolve(StartupConfig.DEFAULTS, scan)
        assertTrue(reservation.required)
        assertTrue(reservation.recoveryRequired)
        assertEquals("task-1", reservation.taskId)
    }

    @Test
    fun restoreArtifactsReserveMaintenanceEvenWithACorruptConfig() {
        paths.startupConfigFile.parentFile?.mkdirs()
        paths.startupConfigFile.writeText("{ this is not json")
        paths.restoreStagingDir("task-9").mkdirs()
        File(paths.restoreStagingDir("task-9"), "archive.part").writeText("x")

        // Reading the config yields defaults with no tasks…
        val config = StartupConfig.read(paths)
        assertTrue(config.pendingTasks.isEmpty())

        // …yet the filesystem evidence still holds the reservation.
        val reservation = MaintenanceReservation.resolve(config, MaintenanceScan.scan(paths))
        assertTrue(reservation.required)
        assertEquals("task-9", reservation.taskId)
        assertTrue(reservation.reason.contains("durable"))
    }

    @Test
    fun anEmptyRestoreWorkspaceIsNotEvidenceOnItsOwn() {
        paths.restoreWorkspaceDir("task-1").mkdirs()

        val scan = MaintenanceScan.scan(paths)
        assertTrue(scan.artifacts.single().isEmpty)
        assertFalse(scan.hasDurableEvidence)
    }

    @Test
    fun aQueuedTaskReservesMaintenanceWithoutDemandingRecovery() {
        val reservation = MaintenanceReservation.resolve(
            configWith("task-1" to MaintenanceTaskState.QUEUED),
            MaintenanceScan.scan(paths),
        )

        assertTrue(reservation.required)
        assertFalse(reservation.recoveryRequired)
        assertEquals("task-1", reservation.taskId)
        assertTrue(reservation.reason.contains("queued"))
    }

    @Test
    fun aTaskLeftRunningDemandsRecoveryEvenWithACleanWorkspace() {
        val reservation = MaintenanceReservation.resolve(
            configWith("task-1" to MaintenanceTaskState.RUNNING),
            MaintenanceScan.scan(paths),
        )

        assertTrue(reservation.required)
        assertTrue(reservation.recoveryRequired)
    }

    @Test
    fun theMidOperationTaskIsPreferredOverAnEarlierQueuedOne() {
        writeJournal("task-2", MaintenanceJournalKind.RESTORE.id, RestorePhase.INSTALLED.id)

        val reservation = MaintenanceReservation.resolve(
            configWith(
                "task-1" to MaintenanceTaskState.QUEUED,
                "task-2" to MaintenanceTaskState.RUNNING,
            ),
            MaintenanceScan.scan(paths),
        )

        assertEquals("task-2", reservation.taskId)
    }
}
