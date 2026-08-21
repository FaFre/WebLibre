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
import kotlin.test.assertNotEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

private const val TARGET_PROFILE = "0199a0b1-1111-7111-8111-111111111111"

/**
 * The Dart half of this contract lives in
 * `apps/weblibre/test/features/user/domain/services/profile_restart_request_test.dart`,
 * which checks the same record from the consuming side.
 */
class RestartAuthorizationStoreTest {
    private lateinit var filesDir: File
    private lateinit var paths: StartupPaths
    private lateinit var store: RestartAuthorizationStore

    private val now = 1_000_000L

    @BeforeTest
    fun setUp() {
        filesDir = Files.createTempDirectory("weblibre_restart_auth").toFile()
        paths = StartupPaths(filesDir)
        store = RestartAuthorizationStore(paths)
    }

    @AfterTest
    fun tearDown() {
        filesDir.deleteRecursively()
    }

    @Test
    fun issuingWritesOnlyTheHashOfTheToken() {
        // The token travels on the intent. A copy of this file — through a
        // backup, say — must not let anything forge a request.
        val token = store.issue(TARGET_PROFILE, now)
        val record = checkNotNull(store.read())

        assertEquals(restartAuthorizationTokenHash(token), record.tokenHash)
        assertFalse(paths.restartAuthorizationFile.readText().contains(token))
    }

    @Test
    fun theRecordBindsTheProfileTheUserAnsweredFor() {
        store.issue(TARGET_PROFILE.uppercase(), now)

        // Lowercased on the way in, because the id is compared as a string and
        // two spellings of one UUID must not read as two profiles.
        assertEquals(TARGET_PROFILE, checkNotNull(store.read()).targetProfileId)
    }

    @Test
    fun everyTokenIsDifferent() {
        assertNotEquals(store.issue(TARGET_PROFILE, now), store.issue(TARGET_PROFILE, now))
    }

    @Test
    fun theRecordExpires() {
        store.issue(TARGET_PROFILE, now)
        val record = checkNotNull(store.read())

        assertFalse(record.isExpiredAt(now + RESTART_AUTHORIZATION_TTL_MS - 1))
        assertTrue(record.isExpiredAt(now + RESTART_AUTHORIZATION_TTL_MS))
    }

    @Test
    fun theNewestAnswerWins() {
        val first = store.issue(TARGET_PROFILE, now)
        val second = store.issue(TARGET_PROFILE, now)
        val record = checkNotNull(store.read())

        // One dialog, one restart: a user who answered twice meant the second
        // answer, and the first request must no longer match.
        assertEquals(restartAuthorizationTokenHash(second), record.tokenHash)
        assertNotEquals(restartAuthorizationTokenHash(first), record.tokenHash)
    }

    @Test
    fun nothingOnDiskMeansNothingAuthorized() {
        assertNull(store.read())
    }

    @Test
    fun anUnreadableRecordAuthorizesNothing() {
        store.issue(TARGET_PROFILE, now)
        paths.restartAuthorizationFile.writeText("{ not json")

        assertNull(store.read())
    }

    @Test
    fun aRecordMissingItsBindingsIsNotARecord() {
        paths.restartAuthorizationFile.parentFile?.mkdirs()
        paths.restartAuthorizationFile.writeText(
            """{"version":1,"tokenHash":"abc","createdAt":"2026-08-21T10:00:00.000Z",""" +
                """"expiresAt":"2026-08-21T10:02:00.000Z"}""",
        )

        // No target profile: an authorization for "some restart" would let a
        // redirected intent pick the profile.
        assertNull(store.read())
    }

    @Test
    fun clearingRemovesIt() {
        store.issue(TARGET_PROFILE, now)

        assertTrue(store.clear())
        assertNull(store.read())
    }

    @Test
    fun theRecordRoundTripsThroughItsOwnSerializer() {
        store.issue(TARGET_PROFILE, now)
        val record = checkNotNull(store.read())

        assertEquals(record, RestartAuthorization.tryFromJson(record.toJson()))
    }
}
