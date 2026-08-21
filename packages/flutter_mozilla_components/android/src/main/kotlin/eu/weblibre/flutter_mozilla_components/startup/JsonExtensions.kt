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

import org.json.JSONObject

/**
 * String accessors that behave the same on Android and on the JVM, and the same
 * as Dart's readers.
 *
 * `JSONObject.optString` cannot be used for any of the records here. On Android a
 * stored JSON `null` is the `JSONObject.NULL` sentinel and `optString` returns
 * `String.valueOf(NULL)` — the four-character string `"null"` — while the
 * `org.json` reference implementation the JVM unit tests run against returns the
 * fallback instead. Every nullable field Dart writes as `null` would therefore
 * come back as a non-null `"null"` on device and as `null` in the tests that are
 * supposed to catch that.
 *
 * `optString` is also lenient about type: a number or object under the key is
 * stringified rather than rejected. Dart casts, so it throws. These accessors
 * reject instead, which is what keeps the two parsers agreeing.
 */
internal fun JSONObject.stringOrNull(name: String): String? {
    if (isNull(name)) return null
    val value = opt(name) as? String ?: return null
    return value.ifEmpty { null }
}

/** Like [stringOrNull] but preserves an explicitly stored empty string. */
internal fun JSONObject.stringOrEmpty(name: String): String {
    if (isNull(name)) return ""
    return opt(name) as? String ?: ""
}

/** `true` only when the key holds an actual JSON string. */
internal fun JSONObject.hasString(name: String): Boolean = opt(name) is String

/** Reads a boolean, falling back for a missing key or any non-boolean value. */
internal fun JSONObject.booleanOr(name: String, fallback: Boolean): Boolean =
    opt(name) as? Boolean ?: fallback

/** Reads an int, falling back for a missing key or any non-numeric value. */
internal fun JSONObject.intOr(name: String, fallback: Int): Int =
    (opt(name) as? Number)?.toInt() ?: fallback

/** Reads a long, falling back for a missing key or any non-numeric value. */
internal fun JSONObject.longOrNull(name: String): Long? = (opt(name) as? Number)?.toLong()
