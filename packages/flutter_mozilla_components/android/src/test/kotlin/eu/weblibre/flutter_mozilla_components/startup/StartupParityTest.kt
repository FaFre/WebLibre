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

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The Kotlin half of the startup contract parity suite.
 *
 * Every assertion here is mirrored in
 * `apps/weblibre/test/core/startup/startup_parity_test.dart` and reads the same
 * fixture files. A divergence between the two parsers is not cosmetic: Kotlin
 * decides whether to reserve maintenance before any profile consumer runs, and
 * Dart decides what the picker and the task queue do. If they disagree, Gecko can
 * end up on one profile while Dart opens another's databases.
 */
class StartupParityTest {

    // --- startup_config_full.json ---------------------------------------------

    private fun full() = StartupConfig.fromJson(
        StartupFixtures.read("startup_config_full.json"),
    )

    @Test
    fun fullConfigParsesPromptModeAndShortcutPolicy() {
        val config = full()
        assertEquals(1, config.version)
        assertEquals(ProfilePromptMode.BROWSER_ONLY, config.profilePrompt)
        assertFalse(config.honorShortcutProfile)
    }

    @Test
    fun fullConfigParsesEveryTask() {
        val config = full()
        assertEquals(3, config.pendingTasks.size)
        assertEquals(
            listOf("backup", "restoreOver", "delete"),
            config.pendingTasks.map { it.actionId },
        )
        assertTrue(config.pendingTasks.none { it.isQuarantined })
    }

    @Test
    fun completedTasksDoNotHoldTheMaintenanceReservation() {
        val config = full()
        assertEquals(2, config.activeTasks.size)
        assertTrue(config.requiresMaintenance)
    }

    @Test
    fun aRunningTaskMeansThePreviousProcessDiedMidOperation() {
        assertTrue(full().requiresRecovery)
    }

    @Test
    fun optionalTaskFieldsSurviveTheRoundTrip() {
        val restore = full().pendingTasks.first { it.id.endsWith("0002") }
        assertEquals(MaintenanceAction.RESTORE_OVER, restore.action)
        assertEquals(MaintenanceTaskState.RUNNING, restore.state)
        assertEquals("Work", restore.profileName)
        assertEquals("0199a0b1-2222-7222-8222-222222222222", restore.profileId)
    }

    // --- startup_config_tolerant.json -----------------------------------------

    private fun tolerant() = StartupConfig.fromJson(
        StartupFixtures.read("startup_config_tolerant.json"),
    )

    @Test
    fun anUnknownPromptModeFallsBackToOff() {
        assertEquals(ProfilePromptMode.OFF, tolerant().profilePrompt)
    }

    @Test
    fun aNonBooleanShortcutPolicyFallsBackToTheDefault() {
        assertTrue(tolerant().honorShortcutProfile)
    }

    @Test
    fun unaddressableAndDuplicateEntriesAreDropped() {
        assertEquals(
            listOf(
                "0199a0b1-0000-7000-8000-00000000000a",
                "0199a0b1-0000-7000-8000-00000000000b",
                "0199a0b1-0000-7000-8000-00000000000c",
            ),
            tolerant().pendingTasks.map { it.id },
        )
    }

    @Test
    fun theSurvivingDuplicateIsTheFirstOne() {
        val task = tolerant().pendingTasks.first { it.id.endsWith("000a") }
        assertEquals("backup", task.actionId)
        assertEquals("Default", task.profileName)
    }

    @Test
    fun unknownActionAndStateAreQuarantinedIndividually() {
        val config = tolerant()

        val unknownAction = config.pendingTasks.first { it.id.endsWith("000b") }
        assertTrue(unknownAction.isQuarantined)
        assertNull(unknownAction.action)
        assertEquals("teleport", unknownAction.actionId)
        assertEquals(MaintenanceTaskState.FAILED, unknownAction.effectiveState)

        val unknownState = config.pendingTasks.first { it.id.endsWith("000c") }
        assertTrue(unknownState.isQuarantined)
        assertNull(unknownState.state)
        assertEquals("levitating", unknownState.stateId)
        assertEquals(MaintenanceTaskState.FAILED, unknownState.effectiveState)
    }

    @Test
    fun aQuarantinedTaskNeitherRunsNorBlocksTheValidOne() {
        val config = tolerant()
        assertEquals(
            listOf("0199a0b1-0000-7000-8000-00000000000a"),
            config.activeTasks.map { it.id },
        )
        assertTrue(config.requiresMaintenance)
        assertFalse(config.requiresRecovery)
    }

    // --- startup_config_minimal.json ------------------------------------------

    @Test
    fun minimalConfigYieldsTheDocumentedDefaults() {
        val config = StartupConfig.fromJson(
            StartupFixtures.read("startup_config_minimal.json"),
        )
        assertEquals(1, config.version)
        assertEquals(ProfilePromptMode.OFF, config.profilePrompt)
        assertTrue(config.honorShortcutProfile)
        assertTrue(config.pendingTasks.isEmpty())
        assertFalse(config.requiresMaintenance)
    }

    // --- restart_request.json --------------------------------------------------

    @Test
    fun restartRequestParsesIntoAnActionableRequest() {
        val request = assertNotNull(
            RestartRequest.tryFromJson(StartupFixtures.read("restart_request.json")),
        )

        assertEquals("0199a0b2-0000-7000-8000-000000000001", request.requestId)
        assertEquals("0199a0b1-2222-7222-8222-222222222222", request.targetProfileId)
        assertEquals("0199a0b3-0000-7000-8000-00000000000f", request.brokerEntryId)
        assertEquals("profileSwitch", request.reason)
        assertEquals(RestartRequestState.PENDING, request.state)
        assertNull(request.appliedAtMillis)
        assertEquals(utcMillis("2026-08-18T11:00:00.000Z"), request.createdAtMillis)
        assertEquals(utcMillis("2026-08-18T11:05:00.000Z"), request.expiresAtMillis)

        val beforeExpiry = utcMillis("2026-08-18T11:01:00.000Z")
        assertTrue(request.isActionableFor("other-process", beforeExpiry))

        // The alarm reaching the process that wrote the request is never honoured.
        assertFalse(
            request.isActionableFor("0199a0b4-0000-7000-8000-0000000000aa", beforeExpiry),
        )
        assertFalse(
            request.isActionableFor("other-process", utcMillis("2026-08-18T11:05:00.000Z")),
        )
    }

    // --- startup_intent_queue.json ---------------------------------------------

    private fun queue() = StartupIntentQueue.fromJson(
        StartupFixtures.read("startup_intent_queue.json"),
    )

    @Test
    fun intentEntriesAreOrderedBySequenceAndUnaddressableOnesDropped() {
        val queue = queue()
        assertEquals(listOf(1L, 2L, 3L), queue.entries.map { it.sequence })
        assertEquals(4L, queue.nextSequence)
    }

    @Test
    fun onlyTrustedClassificationsCarryAProfileHint() {
        val entries = queue().entries

        val pwa = entries[0]
        assertEquals(LaunchClassification.TRUSTED_PWA, pwa.classification)
        assertEquals(
            "0199a0b1-2222-7222-8222-222222222222",
            pwa.effectiveTrustedProfileId,
        )

        val regular = entries[1]
        assertEquals(LaunchClassification.REGULAR, regular.classification)
        assertNotNull(regular.trustedProfileId)
        assertNull(regular.effectiveTrustedProfileId)

        val unknown = entries[2]
        assertEquals(LaunchClassification.UNKNOWN, unknown.classification)
        assertNull(unknown.effectiveTrustedProfileId)
    }

    @Test
    fun theCallerThatSentALaunchSurvivesTheQueue() {
        // Never re-derived on the way out: at replay time `getReferrer()` names
        // this app, and the gatekeeper reads that as internal.
        val entries = queue().entries
        assertEquals("com.example.sender", entries[1].callerPackage)
        assertNull(entries[0].callerPackage)
    }

    @Test
    fun extrasKeepPrimitivesAndStringListsOnly() {
        val extras = queue().entries[1].extras
        assertEquals(
            setOf("string", "int", "bool", "stringList"),
            extras.keys.toSet(),
        )
        assertEquals(listOf("a", "b"), extras["stringList"])
    }

    @Test
    fun claimsAndAcknowledgementGateDelivery() {
        val entries = queue().entries
        val owner = "0199a0b4-0000-7000-8000-0000000000aa"
        val claimed = utcMillis("2026-08-18T11:10:00.000Z")
        val afterClaimExpiry = utcMillis("2026-08-18T11:12:00.000Z")

        val entry = entries[0]

        // The claim holder keeps its own entry.
        assertTrue(entry.isDeliverableAt(claimed, owner, "engine_id"))

        // Another process cannot take a live claim.
        assertFalse(entry.isDeliverableAt(claimed, "someone-else", "engine_id"))

        // Neither can a replacement engine *in the same process*: MainActivity can
        // build a second engine after a non-finishing destroy, and re-delivering to
        // it would duplicate an intent the first engine is still handling.
        assertFalse(entry.isDeliverableAt(claimed, owner, "engine-2"))

        // Once the claim expires anyone may recover it.
        assertTrue(entry.isDeliverableAt(afterClaimExpiry, "someone-else", "engine-2"))

        // Acknowledged entries are never replayed.
        assertFalse(entries[2].isDeliverableAt(afterClaimExpiry, "anyone", "engine-2"))
    }

    // --- maintenance journals ---------------------------------------------------

    private fun journalSummary(name: String): MaintenanceJournalSummary {
        val json = StartupFixtures.read(name)
        return MaintenanceJournalSummary(
            taskId = json.optString("taskId"),
            kindId = json.optString("kind"),
            phaseId = json.optString("phase"),
            targetProfileId = json.optString("targetProfileId"),
        )
    }

    @Test
    fun anInFlightRestoreRequiresRecovery() {
        val journal = journalSummary("maintenance_journal_restore.json")

        assertEquals(MaintenanceJournalKind.RESTORE, journal.kind)
        assertEquals(RestorePhase.OLD_MOVED, journal.restorePhase)
        assertFalse(journal.isUnrecognised)
        assertFalse(journal.isComplete)
        assertTrue(journal.requiresRecovery)
        assertFalse(journal.restorePhase!!.isPastCommitBarrier)
        assertTrue(journal.restorePhase!!.isDestructive)
    }

    @Test
    fun aCompletedDeleteDoesNot() {
        val journal = journalSummary("maintenance_journal_delete.json")

        assertEquals(MaintenanceJournalKind.DELETE, journal.kind)
        assertEquals(DeletePhase.COMPLETED, journal.deletePhase)
        assertTrue(journal.isComplete)
        assertFalse(journal.requiresRecovery)
        assertTrue(journal.deletePhase!!.isPastCommitBarrier)
    }

    @Test
    fun anUnrecognisedJournalIsNeverOptimisticallyIgnored() {
        val journal = journalSummary("maintenance_journal_unknown.json")

        assertNull(journal.kind)
        assertTrue(journal.isUnrecognised)
        assertTrue(journal.requiresRecovery)
    }

    // --- JSON null handling -----------------------------------------------------

    @Test
    fun explicitJsonNullsReadBackAsNullNotAsTheStringNull() {
        // `JSONObject.optString` returns "null" for a stored JSON null on Android
        // and the fallback on the JVM. Neither is what Dart writes or reads, so the
        // records must not use it — this pins that they do not.
        val request = assertNotNull(
            RestartRequest.tryFromJson(StartupFixtures.read("restart_request_nulls.json")),
        )

        assertNull(request.targetProfileId)
        assertNull(request.brokerEntryId)
        assertNull(request.appliedAtMillis)
        assertEquals("", request.reason)
        assertEquals(RestartRequestState.PENDING, request.state)

        val entry = assertNotNull(
            StartupIntentQueue.fromJson(
                StartupFixtures.read("startup_intent_queue_nulls.json"),
            ).entries.firstOrNull(),
        )

        assertNull(entry.action)
        assertNull(entry.dataUri)
        assertNull(entry.mimeType)
        assertNull(entry.trustedProfileId)
        assertNull(entry.callerPackage)
        assertNull(entry.payloadDirName)
        assertNull(entry.claim)
        assertEquals(LaunchClassification.UNKNOWN, entry.classification)
    }

    @Test
    fun aRestartRequestRoundTripsThroughItsOwnSerializer() {
        val original = assertNotNull(
            RestartRequest.tryFromJson(StartupFixtures.read("restart_request.json")),
        )

        val reparsed = assertNotNull(RestartRequest.tryFromJson(original.toJson()))
        assertEquals(original, reparsed)
    }

    @Test
    fun anIntentQueueRoundTripsThroughItsOwnSerializer() {
        val original = queue()
        val reparsed = StartupIntentQueue.fromJson(original.toJson())

        assertEquals(original.nextSequence, reparsed.nextSequence)
        assertEquals(original.entries, reparsed.entries)
    }

    private fun utcMillis(iso: String): Long = assertNotNull(Iso8601.parse(iso))
}
