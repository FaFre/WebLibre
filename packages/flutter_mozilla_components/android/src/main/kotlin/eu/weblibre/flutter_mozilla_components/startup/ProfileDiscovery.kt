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

import eu.weblibre.flutter_mozilla_components.PwaConstants
import java.io.File
import org.json.JSONObject

/**
 * Canonical profile identifier handling, kept bit-compatible with Dart's
 * `UuidValue.withValidation` (strict RFC 9562) plus the lowercase-only rule that
 * `parseCanonicalProfileDirName` adds.
 *
 * `java.util.UUID.fromString` is deliberately not used: it accepts short groups
 * such as `1-1-1-1-1` and ignores version/variant bits, so it would classify
 * directories as profiles that Dart refuses — exactly the kind of divergence the
 * shared candidate rule exists to prevent.
 */
object ProfileUuid {
    private val STRICT = Regex(
        "^[0-9a-f]{8}-[0-9a-f]{4}-[0-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
    )

    private const val NIL = "00000000-0000-0000-0000-000000000000"
    private const val MAX = "ffffffff-ffff-ffff-ffff-ffffffffffff"

    /** True when [value] is a canonical, lowercase, RFC 9562 profile UUID. */
    fun isCanonical(value: String): Boolean =
        value == NIL || value == MAX || STRICT.matches(value)

    /** Canonical directory name for a profile UUID. */
    fun dirName(profileId: String): String =
        "${PwaConstants.PROFILE_DIR_PREFIX}$profileId"

    /**
     * Parses a directory *base name* back into a profile UUID, or `null` unless the
     * name is exactly canonical. Two spellings of one UUID would otherwise be two
     * directories claiming the same identity.
     */
    fun fromDirName(name: String): String? {
        if (!name.startsWith(PwaConstants.PROFILE_DIR_PREFIX)) return null
        val raw = name.substring(PwaConstants.PROFILE_DIR_PREFIX.length)
        return if (isCanonical(raw)) raw else null
    }
}

/** Why a profile directory was excluded from the candidate set. */
enum class ProfileDefect {
    NON_CANONICAL_NAME,
    MISSING_METADATA,
    UNREADABLE_METADATA,
    METADATA_UUID_MISMATCH,
}

data class DamagedProfile(
    val path: String,
    val defect: ProfileDefect,
    val detail: String? = null,
)

data class DiscoveredProfile(
    val profileId: String,
    val directory: File,
    val name: String,
)

/** The verdict on a single profile directory. */
sealed interface ProfileInspection {
    data class Valid(val profile: DiscoveredProfile) : ProfileInspection
    data class Damaged(val damage: DamagedProfile) : ProfileInspection
}

/**
 * The validated view of the profiles root.
 *
 * [profiles] is sorted by canonical UUID. `Profile.getNewProfileId()` returns a
 * time-ordered UUIDv7, so that is also creation order, which is what makes the
 * fallback candidate rule pick the oldest profile.
 */
data class ProfileDiscovery(
    val profiles: List<DiscoveredProfile>,
    val damaged: List<DamagedProfile>,
) {
    val profileIds: List<String> get() = profiles.map { it.profileId }

    fun contains(profileId: String): Boolean = profiles.any { it.profileId == profileId }

    companion object {
        val EMPTY = ProfileDiscovery(emptyList(), emptyList())

        /**
         * Enumerates and validates [profilesDir]. A damaged profile is recorded and
         * skipped; it never aborts the scan, because one unreadable `metadata.json`
         * must not remove every other profile from the picker.
         */
        fun scan(profilesDir: File): ProfileDiscovery {
            val entries = profilesDir.listFiles() ?: return EMPTY

            val profiles = mutableListOf<DiscoveredProfile>()
            val damaged = mutableListOf<DamagedProfile>()

            for (entry in entries) {
                if (!entry.isDirectory) continue
                if (!entry.name.startsWith(PwaConstants.PROFILE_DIR_PREFIX)) continue

                when (val inspection = inspect(entry)) {
                    is ProfileInspection.Valid -> profiles += inspection.profile
                    is ProfileInspection.Damaged -> damaged += inspection.damage
                }
            }

            profiles.sortBy { it.profileId }

            return ProfileDiscovery(profiles, damaged)
        }

        /**
         * Validates a single profile by id, without enumerating the others.
         *
         * This is the check every commit must pass, including a commit from an
         * authenticated PWA or shortcut. Authenticating the *launch* proves the
         * caller may name a profile; it proves nothing about whether that profile
         * is still intact. A trusted launch that bound a profile whose metadata has
         * since been damaged would commit the process to a profile Flutter then
         * refuses, and because the process profile is immutable that surfaces as an
         * unrecoverable failure at engine setup rather than as a skipped profile.
         */
        fun validate(profilesDir: File, profileId: String): Boolean {
            if (!ProfileUuid.isCanonical(profileId)) return false
            val directory = File(profilesDir, ProfileUuid.dirName(profileId))
            return inspect(directory) is ProfileInspection.Valid
        }

        /**
         * The single validation rule, applied to one directory.
         *
         * [scan] and [validate] share it on purpose: a commit path that validated
         * more loosely than enumeration would be able to bind a profile the picker
         * refuses to list.
         */
        fun inspect(directory: File): ProfileInspection {
            if (!directory.isDirectory) {
                return ProfileInspection.Damaged(
                    DamagedProfile(directory.path, ProfileDefect.MISSING_METADATA, "not a directory"),
                )
            }

            val profileId = ProfileUuid.fromDirName(directory.name)
                ?: return ProfileInspection.Damaged(
                    DamagedProfile(directory.path, ProfileDefect.NON_CANONICAL_NAME),
                )

            val metadataFile = File(directory, StartupPaths.PROFILE_METADATA_FILE_NAME)
            if (!metadataFile.isFile) {
                return ProfileInspection.Damaged(
                    DamagedProfile(directory.path, ProfileDefect.MISSING_METADATA),
                )
            }

            val metadata = try {
                JSONObject(metadataFile.readText())
            } catch (error: Throwable) {
                return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.UNREADABLE_METADATA,
                        error.message,
                    ),
                )
            }

            // Exactly the shape Dart's generated `Profile.fromJson` requires:
            // `id` and `name` are cast to `String` there, and `authSettings`,
            // when present, is cast to a map. Accepting anything looser here
            // would let a headless start commit a profile the Flutter engine
            // then refuses.
            val rawId = metadata.stringOrNull("id")
                ?: return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.UNREADABLE_METADATA,
                        "missing or non-string id",
                    ),
                )

            if (!metadata.hasString("name")) {
                return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.UNREADABLE_METADATA,
                        "missing or non-string name",
                    ),
                )
            }

            if (metadata.has("authSettings") &&
                !metadata.isNull("authSettings") &&
                metadata.optJSONObject("authSettings") == null
            ) {
                return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.UNREADABLE_METADATA,
                        "authSettings is not an object",
                    ),
                )
            }

            val metadataId = rawId.lowercase()
            if (!ProfileUuid.isCanonical(metadataId)) {
                return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.UNREADABLE_METADATA,
                        "invalid id '$metadataId'",
                    ),
                )
            }

            if (metadataId != profileId) {
                return ProfileInspection.Damaged(
                    DamagedProfile(
                        directory.path,
                        ProfileDefect.METADATA_UUID_MISMATCH,
                        metadataId,
                    ),
                )
            }

            return ProfileInspection.Valid(
                DiscoveredProfile(
                    profileId = profileId,
                    directory = directory,
                    name = metadata.stringOrEmpty("name"),
                ),
            )
        }
    }
}
