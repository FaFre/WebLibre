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

import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException

/**
 * UTC timestamps in the exact shape Dart's `DateTime.toUtc().toIso8601String()`
 * produces, so a record written by either side round-trips through the other.
 *
 * Written with exactly three fractional digits, as Dart writes them
 * ([Instant.toString] drops a zero fraction). Read with [Instant.parse], which
 * also takes the forms Dart can emit (`.mmm`, `.mmmuuu` or none); precision
 * beyond milliseconds is truncated.
 */
internal object Iso8601 {
    private val writer = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").withZone(ZoneOffset.UTC)

    fun format(epochMillis: Long): String = writer.format(Instant.ofEpochMilli(epochMillis))

    fun parse(value: String?): Long? {
        if (value.isNullOrEmpty()) return null
        return try {
            Instant.parse(value).toEpochMilli()
        } catch (_: DateTimeParseException) {
            null
        }
    }
}
