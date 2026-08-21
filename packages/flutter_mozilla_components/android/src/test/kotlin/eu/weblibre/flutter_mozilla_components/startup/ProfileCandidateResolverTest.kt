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
import kotlin.test.assertNull
import kotlin.test.assertTrue
import org.json.JSONObject

private const val OLDEST = "0199a0b1-1111-7111-8111-111111111111"
private const val MIDDLE = "0199a0b1-2222-7222-8222-222222222222"
private const val NEWEST = "0199a0b1-3333-7333-8333-333333333333"

/** Mirrors `apps/weblibre/test/core/startup/profile_discovery_test.dart`. */
class ProfileCandidateResolverTest {

    private lateinit var filesDir: File
    private lateinit var paths: StartupPaths

    @BeforeTest
    fun setUp() {
        filesDir = Files.createTempDirectory("weblibre_profiles").toFile()
        paths = StartupPaths(filesDir)
        paths.profilesDir.mkdirs()
    }

    @AfterTest
    fun tearDown() {
        filesDir.deleteRecursively()
    }

    private fun writeProfile(
        profileId: String,
        name: String = "Profile",
        dirName: String = "profile-$profileId",
        metadataId: String = profileId,
        rawMetadata: String? = null,
        metadata: Boolean = true,
    ) {
        val dir = File(paths.profilesDir, dirName)
        dir.mkdirs()
        if (metadata) {
            File(dir, StartupPaths.PROFILE_METADATA_FILE_NAME).writeText(
                rawMetadata ?: JSONObject()
                    .put("id", metadataId)
                    .put("name", name)
                    .toString(),
            )
        }
    }

    // --- single-profile validation ---------------------------------------------

    @Test
    fun validateAgreesWithScanProfileForProfile() {
        writeProfile(OLDEST)
        writeProfile(MIDDLE, rawMetadata = "{ broken")
        writeProfile(NEWEST, metadata = false)

        val listed = ProfileDiscovery.scan(paths.profilesDir).profileIds.toSet()

        for (profileId in listOf(OLDEST, MIDDLE, NEWEST)) {
            assertEquals(
                profileId in listed,
                ProfileDiscovery.validate(paths.profilesDir, profileId),
                "validate disagreed with scan for $profileId",
            )
        }
    }

    @Test
    fun validateRefusesAProfileThatWasNeverCreated() {
        writeProfile(OLDEST)

        assertFalse(ProfileDiscovery.validate(paths.profilesDir, MIDDLE))
        assertFalse(ProfileDiscovery.validate(paths.profilesDir, "not-a-uuid"))
    }

    // --- canonical names -------------------------------------------------------

    @Test
    fun canonicalNamesRoundTrip() {
        assertEquals("profile-$OLDEST", ProfileUuid.dirName(OLDEST))
        assertEquals(OLDEST, ProfileUuid.fromDirName("profile-$OLDEST"))
    }

    @Test
    fun nonCanonicalSpellingsAreRejected() {
        assertNull(ProfileUuid.fromDirName("profile-${OLDEST.uppercase()}"))
        assertNull(ProfileUuid.fromDirName("profile-${OLDEST.replace("-", "")}"))
        assertNull(ProfileUuid.fromDirName("profile-$OLDEST "))
        assertNull(ProfileUuid.fromDirName("profile-not-a-uuid"))
        assertNull(ProfileUuid.fromDirName(OLDEST))

        // `java.util.UUID.fromString` would happily accept this; the shared rule
        // must not, or Kotlin would see a profile Dart refuses.
        assertNull(ProfileUuid.fromDirName("profile-1-1-1-1-1"))
    }

    // --- discovery -------------------------------------------------------------

    @Test
    fun profilesAreSortedByCanonicalUuidWhichIsCreationOrder() {
        writeProfile(NEWEST, name = "Newest")
        writeProfile(OLDEST, name = "Oldest")
        writeProfile(MIDDLE, name = "Middle")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertEquals(listOf("Oldest", "Middle", "Newest"), discovery.profiles.map { it.name })
        assertTrue(discovery.damaged.isEmpty())
    }

    @Test
    fun oneDamagedProfileDoesNotHideTheOthers() {
        writeProfile(OLDEST, name = "Good")
        writeProfile(MIDDLE, metadata = false)
        writeProfile(NEWEST, rawMetadata = "{ broken")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertEquals(listOf("Good"), discovery.profiles.map { it.name })
        assertEquals(
            setOf(ProfileDefect.MISSING_METADATA, ProfileDefect.UNREADABLE_METADATA),
            discovery.damaged.map { it.defect }.toSet(),
        )
    }

    @Test
    fun metadataMustHaveTheExactShapeDartRequires() {
        // Dart's generated `Profile.fromJson` casts `id` and `name` to String and
        // `authSettings` to a map. Anything looser accepted here could be committed
        // by a headless start and then rejected by the Flutter engine — and because
        // the process profile is immutable, that surfaces as an unrecoverable
        // mismatch rather than as a skipped profile.
        writeProfile(OLDEST, rawMetadata = """{"id":"$OLDEST"}""")
        writeProfile(MIDDLE, rawMetadata = """{"id":"$MIDDLE","name":null}""")
        writeProfile(NEWEST, rawMetadata = """{"id":"$NEWEST","name":7}""")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertTrue(discovery.profiles.isEmpty())
        assertEquals(3, discovery.damaged.size)
        assertTrue(discovery.damaged.all { it.defect == ProfileDefect.UNREADABLE_METADATA })
    }

    @Test
    fun aNonObjectAuthSettingsIsRefused() {
        writeProfile(
            OLDEST,
            rawMetadata = """{"id":"$OLDEST","name":"Default","authSettings":"nope"}""",
        )

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertTrue(discovery.profiles.isEmpty())
        assertEquals(ProfileDefect.UNREADABLE_METADATA, discovery.damaged.single().defect)
    }

    @Test
    fun anAbsentAuthSettingsIsFineBecauseDartDefaultsIt() {
        writeProfile(OLDEST, rawMetadata = """{"id":"$OLDEST","name":"Default"}""")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertEquals(listOf("Default"), discovery.profiles.map { it.name })
    }

    @Test
    fun aNonStringIdIsRefused() {
        writeProfile(OLDEST, rawMetadata = """{"id":7,"name":"Default"}""")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertTrue(discovery.profiles.isEmpty())
        assertEquals(ProfileDefect.UNREADABLE_METADATA, discovery.damaged.single().defect)
    }

    @Test
    fun metadataClaimingADifferentUuidIsRefused() {
        writeProfile(OLDEST, metadataId = MIDDLE)

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertTrue(discovery.profiles.isEmpty())
        assertEquals(ProfileDefect.METADATA_UUID_MISMATCH, discovery.damaged.single().defect)
    }

    @Test
    fun aNonCanonicalDirectoryNameIsDamagedNotSilentlyIgnored() {
        writeProfile(OLDEST, dirName = "profile-${OLDEST.uppercase()}")

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertTrue(discovery.profiles.isEmpty())
        assertEquals(ProfileDefect.NON_CANONICAL_NAME, discovery.damaged.single().defect)
    }

    @Test
    fun unrelatedEntriesAreNeitherProfilesNorDamage() {
        File(paths.profilesDir, "weblibre_maintenance").mkdirs()
        paths.currentProfileFile.writeText(OLDEST)
        writeProfile(OLDEST)

        val discovery = ProfileDiscovery.scan(paths.profilesDir)

        assertEquals(1, discovery.profiles.size)
        assertTrue(discovery.damaged.isEmpty())
    }

    // --- candidate rules -------------------------------------------------------

    @Test
    fun ruleOneAValidCurrentProfileWins() {
        val candidate = ProfileCandidateResolver.resolve(NEWEST, listOf(OLDEST, NEWEST))

        assertEquals(NEWEST, candidate.profileId)
        assertEquals(ProfileCandidateSource.CURRENT_PROFILE, candidate.source)
    }

    @Test
    fun ruleTwoOtherwiseTheLexicographicallySmallestUuid() {
        val candidate = ProfileCandidateResolver.resolve(
            null,
            listOf(NEWEST, MIDDLE, OLDEST),
        )

        assertEquals(OLDEST, candidate.profileId)
        assertEquals(ProfileCandidateSource.OLDEST_PROFILE, candidate.source)
    }

    @Test
    fun aCurrentProfileThatNoLongerValidatesFallsBack() {
        val candidate = ProfileCandidateResolver.resolve(NEWEST, listOf(MIDDLE))

        assertEquals(MIDDLE, candidate.profileId)
        assertEquals(ProfileCandidateSource.OLDEST_PROFILE, candidate.source)
    }

    @Test
    fun ruleThreeNoValidProfileMeansNoCandidate() {
        val candidate = ProfileCandidateResolver.resolve(OLDEST, emptyList())

        assertFalse(candidate.isPresent)
        assertEquals(ProfileCandidateSource.NONE, candidate.source)
    }

    @Test
    fun resolutionOnDiskReadsButNeverWritesCurrentProfile() {
        writeProfile(OLDEST)
        writeProfile(MIDDLE)

        val candidate = ProfileCandidateResolver.resolveOnDisk(paths)

        assertEquals(OLDEST, candidate.profileId)
        assertFalse(paths.currentProfileFile.exists())
    }

    @Test
    fun aDamagedCurrentProfileTargetIsSkippedNotBooted() {
        writeProfile(OLDEST)
        writeProfile(MIDDLE, rawMetadata = "{ broken")
        paths.currentProfileFile.writeText(MIDDLE)

        assertEquals(OLDEST, ProfileCandidateResolver.resolveOnDisk(paths).profileId)
    }

    @Test
    fun aNonCanonicalCurrentProfileValueIsIgnored() {
        writeProfile(OLDEST)
        paths.currentProfileFile.writeText("not-a-uuid")

        assertNull(ProfileCandidateResolver.readCurrentProfile(paths))
    }
}
