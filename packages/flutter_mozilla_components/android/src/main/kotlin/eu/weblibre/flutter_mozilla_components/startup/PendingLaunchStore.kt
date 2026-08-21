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

/** How long a handed-over launch stays valid. */
const val PENDING_LAUNCH_TTL_MS = 5 * 60 * 1000L

private const val PENDING_LAUNCH_VERSION = 1

/**
 * A launch that should be re-delivered once the process has restarted.
 *
 * Written when the user answers a profile-mismatch dialog with "restart into the
 * other profile". Without it the restart is technically correct and practically
 * useless: the user asked to open *this* shortcut, and what they would get is a
 * browser on a different profile with no memory of why it relaunched.
 *
 * Deliberately not a field on [RestartRequest]. That record is parsed by Dart as
 * well, and a serialized Intent is of no use to it — while being exactly the kind
 * of payload that should stay in one narrow place with one reader.
 */
data class PendingLaunch(
    val requestId: String,
    val intentUri: String,
    val targetProfileId: String?,
    val createdAtMillis: Long,
    val expiresAtMillis: Long,
    val version: Int = PENDING_LAUNCH_VERSION,
) {
    fun isExpiredAt(nowMillis: Long): Boolean = nowMillis >= expiresAtMillis

    fun toJson(): JSONObject = JSONObject().apply {
        put("version", version)
        put("requestId", requestId)
        put("intentUri", intentUri)
        put("targetProfileId", targetProfileId ?: JSONObject.NULL)
        put("createdAt", Iso8601.format(createdAtMillis))
        put("expiresAt", Iso8601.format(expiresAtMillis))
    }

    companion object {
        fun tryFromJson(json: JSONObject): PendingLaunch? {
            // The accessors from [stringOrNull], never `optString`: `toJson` writes
            // an absent `targetProfileId` as `JSONObject.NULL`, which `optString`
            // hands back as the string "null" on Android while the JVM's reference
            // `org.json` returns "". A record read on device would carry a profile
            // id no profile has.
            val requestId = json.stringOrEmpty("requestId")
            val intentUri = json.stringOrEmpty("intentUri")
            if (requestId.isEmpty() || intentUri.isEmpty()) return null

            val createdAt = Iso8601.parse(json.stringOrNull("createdAt")) ?: return null
            val expiresAt = Iso8601.parse(json.stringOrNull("expiresAt")) ?: return null

            return PendingLaunch(
                requestId = requestId,
                intentUri = intentUri,
                targetProfileId = json.stringOrNull("targetProfileId"),
                createdAtMillis = createdAt,
                expiresAtMillis = expiresAt,
                version = json.intOr("version", PENDING_LAUNCH_VERSION),
            )
        }
    }
}

/**
 * Reads and writes the single pending launch record.
 *
 * There is at most one: a restart ends the process, so a second hand-over could
 * only come from a second restart, and the newer one is the one the user asked
 * for. Consumption is a read-then-delete, because a launch that survived being
 * delivered would re-open the shortcut on every subsequent start.
 */
class PendingLaunchStore(paths: StartupPaths) {
    private val file = AtomicJsonFile(paths.pendingLaunchFile())

    fun write(launch: PendingLaunch) {
        file.write(launch.toJson())
    }

    fun peek(): PendingLaunch? = when (val result = file.read()) {
        is AtomicJsonFile.Read.Present -> PendingLaunch.tryFromJson(result.json)
        else -> null
    }

    /**
     * Returns the record and removes it, or null when there is none or it is stale.
     *
     * The delete happens even for an expired or unreadable record. Leaving one
     * behind means every later restart inherits a launch nobody asked for.
     */
    fun consume(nowMillis: Long = System.currentTimeMillis()): PendingLaunch? {
        val launch = peek()
        clear()
        return launch?.takeUnless { it.isExpiredAt(nowMillis) }
    }

    fun clear() {
        runCatching { file.delete() }
    }
}
