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

import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import java.io.File
import java.nio.file.Files

class InstallerJournalTest {
    private lateinit var dir: File
    private lateinit var journal: InstallerJournal

    private val expected = ExpectedArtifact(
        sha256 = "b".repeat(64),
        byteLength = 5,
        versionCode = 433,
        logicalReleaseSequence = 43,
        distribution = BuildDistribution.GITHUB,
        track = BuildTrack.STABLE,
        renderer = BuildRenderer.SKIA,
        abi = "arm64-v8a",
        authorizedUntilEpochMs = 123,
    )

    @Before
    fun setUp() {
        dir = Files.createTempDirectory("journal").toFile()
        journal = InstallerJournal(File(dir, "installer_journal.json"))
    }

    @After
    fun tearDown() {
        dir.deleteRecursively()
    }

    @Test
    fun absentIsAbsentAndDamageIsNeverAbsence() {
        assertTrue(journal.read() is JournalRead.Absent)
        File(dir, "installer_journal.json").writeText("{not json")
        assertTrue(journal.read() is JournalRead.Corrupt)
    }

    @Test
    fun roundTripsEveryField() {
        val state = JournalState(
            phase = InstallerPhase.PENDING_USER_ACTION,
            sessionId = 7,
            nonce = "nonce",
            expected = expected,
            failure = null,
            lastMessage = "msg",
        )
        journal.write(state)
        assertEquals(state, (journal.read() as JournalRead.Present).state)
    }

    @Test
    fun writesLeaveNoTempFileBehind() {
        journal.write(JournalState(phase = InstallerPhase.SESSION_CREATED, sessionId = 1, nonce = "n", expected = expected))
        assertEquals(listOf("installer_journal.json"), dir.list()!!.toList())
    }

    @Test
    fun retiringMovesTheOutcomeAndClearsTheSession() {
        val retired = JournalState(
            phase = InstallerPhase.FAILED,
            sessionId = 7,
            nonce = "n",
            expected = expected,
            failure = NativeFailure.INSTALL_CONFLICT,
        ).retired()
        assertEquals(InstallerPhase.NONE, retired.phase)
        assertNull(retired.sessionId)
        assertNull(retired.nonce)
        assertEquals(InstallerPhase.FAILED, retired.lastOutcome)
        assertEquals(NativeFailure.INSTALL_CONFLICT, retired.lastOutcomeFailure)
    }

    @Test
    fun keepsTheFileSpellingOfPhasesAndFailures() {
        journal.write(JournalState(phase = InstallerPhase.FAILED, sessionId = 1, nonce = "n", failure = NativeFailure.INSTALL_CONFLICT).retired())
        val json = org.json.JSONObject(File(dir, "installer_journal.json").readText())
        assertEquals("none", json.getString("phase"))
        assertEquals("failed", json.getString("lastOutcome"))
        assertEquals("installConflict", json.getString("lastOutcomeFailure"))
    }

    @Test
    fun anUnknownPhaseOrFailureIsDamage() {
        File(dir, "installer_journal.json").writeText("""{"phase":"paused"}""")
        assertTrue(journal.read() is JournalRead.Corrupt)
        File(dir, "installer_journal.json").writeText("""{"phase":"failed","failure":"installMaybe"}""")
        assertTrue(journal.read() is JournalRead.Corrupt)
    }

    @Test
    fun aMalformedDigestInTheJournalIsDamage() {
        File(dir, "installer_journal.json").writeText(
            """{"phase":"commitRequested","sessionId":1,"nonce":"n","expected":{"sha256":"../x"}}""",
        )
        assertTrue(journal.read() is JournalRead.Corrupt)
    }

    @Test
    fun installerStatusesMapToFailureKinds() {
        assertEquals(NativeFailure.INSTALL_CANCELLED, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_ABORTED))
        assertEquals(NativeFailure.INSTALL_BLOCKED, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_BLOCKED))
        assertEquals(NativeFailure.INSTALL_CONFLICT, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_CONFLICT))
        assertEquals(NativeFailure.INSTALL_INCOMPATIBLE, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_INCOMPATIBLE))
        assertEquals(NativeFailure.APK_INVALID, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_INVALID))
        assertEquals(NativeFailure.INSTALL_STORAGE, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE_STORAGE))
        assertEquals(NativeFailure.INSTALL_UNKNOWN, SessionInstaller.failureKind(android.content.pm.PackageInstaller.STATUS_FAILURE))
    }
}
