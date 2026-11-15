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

import eu.weblibre.gecko.BuildConfig
import org.json.JSONObject

/**
 * The Pigeon definition's spelling of an enum value (`notBundled` for
 * `NOT_BUNDLED`). Files spell values this way: BuildConfig, the build
 * manifest and the installer journal.
 */
val Enum<*>.wire: String
    get() {
        val parts = name.lowercase().split('_')
        return parts.first() + parts.drop(1).joinToString("") { it.replaceFirstChar(Char::uppercase) }
    }

/** The value spelled [value] in a file, or null for any other string. */
inline fun <reified E : Enum<E>> wireValue(value: String?): E? =
    enumValues<E>().firstOrNull { it.wire == value }

/** The value at [key], which must be one of [E]'s spellings. */
inline fun <reified E : Enum<E>> JSONObject.requireWire(key: String): E =
    requireNotNull(wireValue<E>(getString(key))) { "unknown $key" }

/** BuildConfig's identity, parsed once. */
object CompiledBuild {
    val distribution: BuildDistribution? = wireValue(BuildConfig.DISTRIBUTION)
    val track: BuildTrack? = wireValue(BuildConfig.TRACK)
    val renderer: BuildRenderer? = wireValue(BuildConfig.RENDERER)
}
