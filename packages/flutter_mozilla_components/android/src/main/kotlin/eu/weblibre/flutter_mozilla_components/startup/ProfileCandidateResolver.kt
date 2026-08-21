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
import java.nio.charset.StandardCharsets

enum class ProfileCandidateSource {
    /** `current_profile` named a profile that still validates. */
    CURRENT_PROFILE,

    /** No usable `current_profile`, so the oldest valid profile was used. */
    OLDEST_PROFILE,

    /** First run, or every profile is damaged. */
    NONE,
}

data class ProfileCandidate(
    val profileId: String?,
    val source: ProfileCandidateSource,
) {
    val isPresent: Boolean get() = profileId != null

    companion object {
        val ABSENT = ProfileCandidate(null, ProfileCandidateSource.NONE)
    }
}

/**
 * The single deterministic candidate rule, mirrored by Dart's
 * `resolveProfileCandidate`:
 *
 * 1. use a valid `current_profile`;
 * 2. otherwise use the lexicographically smallest canonical profile UUID;
 * 3. otherwise there is no candidate.
 *
 * Resolution is read-only. `current_profile` is written by `ActiveProfile` alone,
 * and only as part of commitment — reading it must never repair it, or two
 * processes racing at startup would each "fix" it to a different value.
 *
 * Filesystem access time is deliberately not part of the rule. It is not stable
 * enough for arbitration and Kotlin could not reproduce Dart's tie-breaking.
 */
object ProfileCandidateResolver {

    fun resolve(currentProfile: String?, validProfiles: List<String>): ProfileCandidate {
        if (currentProfile != null && validProfiles.contains(currentProfile)) {
            return ProfileCandidate(currentProfile, ProfileCandidateSource.CURRENT_PROFILE)
        }

        val oldest = validProfiles.minOrNull()
            ?: return ProfileCandidate.ABSENT

        return ProfileCandidate(oldest, ProfileCandidateSource.OLDEST_PROFILE)
    }

    fun resolve(discovery: ProfileDiscovery, currentProfile: String?): ProfileCandidate =
        resolve(currentProfile, discovery.profileIds)

    /** Read-only candidate resolution against a real profiles root. */
    fun resolveOnDisk(paths: StartupPaths): ProfileCandidate =
        resolve(ProfileDiscovery.scan(paths.profilesDir), readCurrentProfile(paths))

    /**
     * Reads `current_profile` without repairing or rewriting it. A missing,
     * unreadable, or non-canonical value is reported as `null`.
     */
    fun readCurrentProfile(paths: StartupPaths): String? {
        val file: File = paths.currentProfileFile
        if (!file.isFile) return null

        val raw = try {
            file.readText(StandardCharsets.UTF_8).trim().lowercase()
        } catch (_: Throwable) {
            return null
        }

        return if (ProfileUuid.isCanonical(raw)) raw else null
    }
}
