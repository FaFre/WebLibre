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

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * UTC timestamps in the exact shape Dart's `DateTime.toUtc().toIso8601String()`
 * produces, so a record written by either side round-trips through the other.
 *
 * `java.time` would be nicer, but `minSdk` is 24 and desugaring is not enabled for
 * this module, so `SimpleDateFormat` it is. Parsing accepts the fractional-second
 * forms Dart can emit (`.mmm` and `.mmmuuu`) as well as none at all.
 */
internal object Iso8601 {
    private const val WRITE_PATTERN = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    private val READ_PATTERNS = listOf(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
    )

    fun format(epochMillis: Long): String = formatter(WRITE_PATTERN).format(Date(epochMillis))

    fun parse(value: String?): Long? {
        if (value.isNullOrEmpty()) return null

        // Dart emits microsecond precision when it has any; truncate to millis so
        // SimpleDateFormat does not silently roll the extra digits into seconds.
        val normalized = Regex("(\\.\\d{3})\\d+Z$").replace(value, "$1Z")

        for (pattern in READ_PATTERNS) {
            try {
                return formatter(pattern).parse(normalized)?.time
            } catch (_: java.text.ParseException) {
                continue
            }
        }
        return null
    }

    private fun formatter(pattern: String) = SimpleDateFormat(pattern, Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
        isLenient = false
    }
}
