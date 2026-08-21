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
package eu.weblibre.flutter_mozilla_components

import java.io.File

/**
 * Marks every WorkManager request with the profile it belongs to.
 *
 * A unique work *name* is not enough. Names identify one request so a duplicate
 * replaces it; they cannot be queried by prefix, so "everything belonging to this
 * profile" is a question WorkManager cannot answer from a name at all. Deleting a
 * profile then leaves its scheduled work behind, to wake later against a profile
 * directory that no longer exists.
 *
 * Tags are the only handle that supports that query, which is why every enqueue
 * site has to carry one.
 */
object ProfileWorkTags {
    private const val PREFIX = "weblibre-profile:"

    /** The tag for a canonical profile UUID. */
    fun forProfile(profileId: String): String = "$PREFIX${profileId.lowercase()}"

    /**
     * The tag for a [ProfileContext.relativePath], e.g. `weblibre_profiles/profile-<uuid>`.
     *
     * Falls back to tagging the path itself when it does not carry a recognisable
     * profile directory name. An unparseable path is a bug, but a *mistagged* job
     * is recoverable where an untagged one is invisible forever.
     */
    fun forRelativePath(relativePath: String): String {
        val name = File(relativePath).name
        return if (name.startsWith(PwaConstants.PROFILE_DIR_PREFIX)) {
            forProfile(name.removePrefix(PwaConstants.PROFILE_DIR_PREFIX))
        } else {
            "$PREFIX$name"
        }
    }
}
