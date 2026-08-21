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
package eu.weblibre.flutter_mozilla_components.maintenance

import org.json.JSONArray
import org.json.JSONObject

const val PREFERENCE_SNAPSHOT_VERSION = 1

/**
 * A portable copy of one profile's preference state.
 *
 * Profile-scoped preferences take two shapes, and both have to travel or a
 * restored profile comes back signed out with its sync engines reset:
 *
 * - whole *files*, named `<prefix>_<name>` (the FxA and sync stores);
 * - individual *keys* suffixed `.<prefix>` inside the app-wide default file.
 *
 * The snapshot is deliberately value-typed and JSON-encoded rather than a copy of
 * the XML. The prefix is part of the storage location, so a raw file copy would
 * reinstate the *source* profile's names; rebuilding from values lets restore
 * write them under whatever prefix the target profile has.
 */
data class PreferenceSnapshot(
    val version: Int = PREFERENCE_SNAPSHOT_VERSION,
    /** Preference file base name (without the profile prefix) to its contents. */
    val files: Map<String, Map<String, Any>> = emptyMap(),
    /** Unsuffixed key in the default file to its value. */
    val defaultKeys: Map<String, Any> = emptyMap(),
) {
    val isEmpty: Boolean
        get() = files.all { it.value.isEmpty() } && defaultKeys.isEmpty()

    fun toJson(): JSONObject = JSONObject().apply {
        put("version", version)
        put(
            "files",
            JSONObject().also { encoded ->
                for ((name, values) in files) encoded.put(name, encodeValues(values))
            },
        )
        put("defaultKeys", encodeValues(defaultKeys))
    }

    companion object {
        val EMPTY = PreferenceSnapshot()

        fun fromJson(json: JSONObject): PreferenceSnapshot {
            val files = LinkedHashMap<String, Map<String, Any>>()
            val rawFiles = json.optJSONObject("files")
            if (rawFiles != null) {
                for (name in rawFiles.keys()) {
                    val values = rawFiles.optJSONObject(name) ?: continue
                    files[name] = decodeValues(values)
                }
            }

            return PreferenceSnapshot(
                version = json.intOrDefault("version", PREFERENCE_SNAPSHOT_VERSION),
                files = files,
                defaultKeys = decodeValues(json.optJSONObject("defaultKeys")),
            )
        }

        /**
         * Encodes the five types `SharedPreferences` can hold.
         *
         * A string set is written as a tagged object rather than a bare array,
         * because `putStringSet` and `putString` are different operations and a
         * restore that guessed wrong would throw `ClassCastException` on the next
         * read — long after the restore reported success.
         */
        private fun encodeValues(values: Map<String, Any>): JSONObject =
            JSONObject().apply {
                for ((key, value) in values) {
                    when (value) {
                        is Set<*> -> put(
                            key,
                            JSONObject().apply {
                                put("type", "stringSet")
                                put(
                                    "value",
                                    JSONArray().also { array ->
                                        value.filterIsInstance<String>()
                                            .sorted()
                                            .forEach(array::put)
                                    },
                                )
                            },
                        )

                        is Boolean, is Int, is Long, is Float, is String ->
                            put(key, JSONObject().apply {
                                put("type", typeNameOf(value))
                                put("value", value)
                            })

                        // Anything else is not something SharedPreferences can
                        // hold, so it cannot have come from one.
                        else -> Unit
                    }
                }
            }

        private fun decodeValues(json: JSONObject?): Map<String, Any> {
            if (json == null) return emptyMap()

            val result = LinkedHashMap<String, Any>()
            for (key in json.keys()) {
                val entry = json.optJSONObject(key) ?: continue
                val type = entry.optString("type", "")

                val value: Any? = when (type) {
                    "boolean" -> if (entry.isNull("value")) null else entry.optBoolean("value")
                    "int" -> if (entry.isNull("value")) null else entry.optInt("value")
                    "long" -> if (entry.isNull("value")) null else entry.optLong("value")
                    "float" -> if (entry.isNull("value")) null else entry.optDouble("value").toFloat()
                    "string" -> if (entry.isNull("value")) null else entry.opt("value") as? String
                    "stringSet" -> entry.optJSONArray("value")?.let { array ->
                        (0 until array.length())
                            .mapNotNull { array.opt(it) as? String }
                            .toSet()
                    }
                    // An unknown type is dropped rather than guessed: writing it
                    // back under the wrong accessor breaks the next read.
                    else -> null
                }

                if (value != null) result[key] = value
            }
            return result
        }

        private fun typeNameOf(value: Any): String = when (value) {
            is Boolean -> "boolean"
            is Int -> "int"
            is Long -> "long"
            is Float -> "float"
            else -> "string"
        }

        private fun JSONObject.intOrDefault(name: String, fallback: Int): Int =
            if (has(name) && !isNull(name)) optInt(name, fallback) else fallback
    }
}
