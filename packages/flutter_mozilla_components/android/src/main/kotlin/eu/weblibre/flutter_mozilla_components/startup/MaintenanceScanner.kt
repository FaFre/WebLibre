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

const val MAINTENANCE_JOURNAL_VERSION = 1

enum class MaintenanceJournalKind(val id: String) {
    RESTORE("restore"),
    DELETE("delete");

    companion object {
        fun tryFromId(id: String?): MaintenanceJournalKind? = MaintenanceJournalKind.entries.firstOrNull { it.id == id }
    }
}

/**
 * Restore-over phases. Order matters: `VERIFIED` is the durable commit barrier and
 * `MOVE_OLD_PREPARED` is the point after which the target directory no longer holds
 * the user's data.
 */
enum class RestorePhase(val id: String) {
    CREATED("created"),
    STAGED("staged"),
    VALIDATED("validated"),
    PARTICIPANTS_PREPARED("participantsPrepared"),
    MOVE_OLD_PREPARED("moveOldPrepared"),
    OLD_MOVED("oldMoved"),
    INSTALL_PREPARED("installPrepared"),
    INSTALLED("installed"),
    PARTICIPANTS_APPLYING("participantsApplying"),
    PARTICIPANTS_APPLIED("participantsApplied"),
    VERIFIED("verified"),
    CLEANUP_PREPARED("cleanupPrepared"),
    CLEANUP_PENDING("cleanupPending"),
    COMPLETED("completed");

    val isPastCommitBarrier: Boolean get() = ordinal >= VERIFIED.ordinal
    val isDestructive: Boolean get() = ordinal >= MOVE_OLD_PREPARED.ordinal

    companion object {
        fun tryFromId(id: String?): RestorePhase? = RestorePhase.entries.firstOrNull { it.id == id }
    }
}

/** Delete phases. Forward-only; the barrier is `OWNERSHIP_SNAPSHOTTED`. */
enum class DeletePhase(val id: String) {
    CREATED("created"),
    QUIESCED("quiesced"),
    OWNERSHIP_SNAPSHOTTED("ownershipSnapshotted"),
    JOBS_PREPARED("jobsPrepared"),
    JOBS_DELETED("jobsDeleted"),
    EXTERNAL_PREPARED("externalPrepared"),
    EXTERNAL_DELETED("externalDeleted"),
    NATIVE_STATE_PREPARED("nativeStatePrepared"),
    NATIVE_STATE_DELETED("nativeStateDeleted"),
    SHARED_CREDENTIALS_PREPARED("sharedCredentialsPrepared"),
    SHARED_CREDENTIALS_RECONCILED("sharedCredentialsReconciled"),
    INTERNAL_PREPARED("internalPrepared"),
    INTERNAL_DELETED("internalDeleted"),
    COMPLETED("completed");

    val isPastCommitBarrier: Boolean get() = ordinal >= OWNERSHIP_SNAPSHOTTED.ordinal

    companion object {
        fun tryFromId(id: String?): DeletePhase? = DeletePhase.entries.firstOrNull { it.id == id }
    }
}

data class MaintenanceJournalSummary(
    val taskId: String,
    val kindId: String,
    val phaseId: String,
    val targetProfileId: String,
) {
    val kind: MaintenanceJournalKind? get() = MaintenanceJournalKind.tryFromId(kindId)

    val restorePhase: RestorePhase?
        get() = if (kind == MaintenanceJournalKind.RESTORE) RestorePhase.tryFromId(phaseId) else null

    val deletePhase: DeletePhase?
        get() = if (kind == MaintenanceJournalKind.DELETE) DeletePhase.tryFromId(phaseId) else null

    val isUnrecognised: Boolean
        get() = kind == null || (restorePhase == null && deletePhase == null)

    val isComplete: Boolean
        get() = restorePhase == RestorePhase.COMPLETED || deletePhase == DeletePhase.COMPLETED

    val requiresRecovery: Boolean get() = isUnrecognised || !isComplete
}

data class UnreadableJournal(val path: String, val reason: String)

data class RestoreArtifact(
    val taskId: String,
    val hasStaging: Boolean,
    val hasOld: Boolean,
) {
    val isEmpty: Boolean get() = !hasStaging && !hasOld
}

/**
 * Durable maintenance evidence, read before any profile consumer runs.
 *
 * This is deliberately independent of `startup_config.json`: a lost or corrupt
 * config must not be able to release the reservation, because the filesystem — not
 * the task list — is what proves a destructive operation was in flight.
 */
data class MaintenanceScan(
    val journals: List<MaintenanceJournalSummary>,
    val unreadableJournals: List<UnreadableJournal>,
    val artifacts: List<RestoreArtifact>,
) {
    val incompleteJournals: List<MaintenanceJournalSummary>
        get() = journals.filter { it.requiresRecovery }

    val hasDurableEvidence: Boolean
        get() = unreadableJournals.isNotEmpty() ||
            incompleteJournals.isNotEmpty() ||
            artifacts.any { !it.isEmpty }

    /** Profiles a journal says are mid-operation; none may become the candidate. */
    val profilesUnderMaintenance: Set<String>
        get() = incompleteJournals.map { it.targetProfileId }.toSet()

    companion object {
        val EMPTY = MaintenanceScan(emptyList(), emptyList(), emptyList())

        fun scan(paths: StartupPaths): MaintenanceScan {
            val journals = mutableListOf<MaintenanceJournalSummary>()
            val unreadable = mutableListOf<UnreadableJournal>()

            paths.maintenanceJournalsDir.listFiles()?.forEach { file ->
                if (!file.isFile || !file.name.endsWith(".json")) return@forEach

                when (val result = AtomicJsonFile(file).read()) {
                    is AtomicJsonFile.Read.Absent -> Unit
                    is AtomicJsonFile.Read.Corrupt ->
                        // Never quarantined: this is the only evidence that a
                        // destructive operation was in flight.
                        unreadable += UnreadableJournal(file.path, result.reason)
                    is AtomicJsonFile.Read.Present -> {
                        val taskId = result.json.stringOrEmpty("taskId")
                        val targetProfileId = result.json.stringOrEmpty("targetProfileId")
                        if (taskId.isEmpty() || targetProfileId.isEmpty()) {
                            unreadable += UnreadableJournal(
                                file.path,
                                "missing taskId/targetProfileId",
                            )
                        } else {
                            journals += MaintenanceJournalSummary(
                                taskId = taskId,
                                kindId = result.json.stringOrEmpty("kind"),
                                phaseId = result.json.stringOrEmpty("phase"),
                                targetProfileId = targetProfileId,
                            )
                        }
                    }
                }
            }

            val artifacts = paths.maintenanceRestoreDir.listFiles()
                ?.filter { it.isDirectory }
                ?.map { dir ->
                    RestoreArtifact(
                        taskId = dir.name,
                        hasStaging = hasContent(paths.restoreStagingDir(dir.name)),
                        hasOld = hasContent(paths.restoreOldDir(dir.name)),
                    )
                }
                ?: emptyList()

            return MaintenanceScan(journals, unreadable, artifacts)
        }

        private fun hasContent(dir: File): Boolean =
            dir.isDirectory && (dir.list()?.isNotEmpty() == true)
    }
}

/**
 * The startup-time verdict: must this process reserve maintenance, and must it
 * recover rather than merely execute queued work?
 */
data class MaintenanceReservation(
    val required: Boolean,
    val recoveryRequired: Boolean,
    val taskId: String?,
    val reason: String,
    val scan: MaintenanceScan,
) {
    companion object {
        val NONE = MaintenanceReservation(
            required = false,
            recoveryRequired = false,
            taskId = null,
            reason = "no maintenance evidence",
            scan = MaintenanceScan.EMPTY,
        )

        fun resolve(config: StartupConfig, scan: MaintenanceScan): MaintenanceReservation {
            val durable = scan.hasDurableEvidence
            val active = config.activeTasks

            if (!durable && active.isEmpty()) return NONE

            val recovery = (
                durable && (
                    scan.unreadableJournals.isNotEmpty() ||
                        scan.incompleteJournals.isNotEmpty() ||
                        scan.artifacts.any { it.hasOld }
                    )
                ) || config.requiresRecovery

            val incompleteIds = buildSet {
                scan.incompleteJournals.forEach { add(it.taskId) }
                scan.artifacts.filter { !it.isEmpty }.forEach { add(it.taskId) }
            }

            val taskId = active.firstOrNull { incompleteIds.contains(it.id) }?.id
                ?: incompleteIds.firstOrNull()
                ?: active.firstOrNull()?.id

            return MaintenanceReservation(
                required = true,
                recoveryRequired = recovery,
                taskId = taskId,
                reason = if (durable) {
                    "durable maintenance evidence on disk"
                } else {
                    "queued maintenance task"
                },
                scan = scan,
            )
        }

        fun resolve(paths: StartupPaths): MaintenanceReservation =
            resolve(StartupConfig.read(paths), MaintenanceScan.scan(paths))
    }
}
