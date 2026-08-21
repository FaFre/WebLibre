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
import java.security.MessageDigest
import java.security.SecureRandom

const val RESTART_AUTHORIZATION_VERSION = 1

/**
 * How long an issued authorization stays redeemable.
 *
 * Long enough to survive a slow hand-off between two activities, short enough
 * that an authorization the user abandoned cannot be redeemed by a launch minutes
 * later.
 */
const val RESTART_AUTHORIZATION_TTL_MS = 2 * 60 * 1000L

/**
 * Proof that a restart-into-profile request came from this app.
 *
 * `MainActivity` is exported, so an `ACTION_RESTART_INTO_PROFILE` intent is
 * something any app on the device can send. The action and a well-formed profile
 * UUID are therefore not evidence of anything: without this record, another app
 * could close the browser at will and reopen it on a profile of its choosing.
 *
 * The record is written to app-private storage immediately before the intent is
 * sent, and the intent carries the matching token. Nothing outside this app can
 * read the file or guess the token, so a request that does not match one was not
 * issued here.
 *
 * **Only the hash of the token is stored**, on the same reasoning as
 * `AccountHandoffRecord`: the token itself lives in the in-flight intent and
 * nowhere else, so a copy of this file — through a backup, say — forges nothing.
 */
data class RestartAuthorization(
    val tokenHash: String,

    /**
     * The profile the request may name, and only that one.
     *
     * Bound here rather than trusted from the intent: the id decides what the next
     * process opens, and an authorization that authorised "some restart" would let
     * a redirected intent choose the profile.
     */
    val targetProfileId: String,
    val createdAtMillis: Long,
    val expiresAtMillis: Long,
    val version: Int = RESTART_AUTHORIZATION_VERSION,
) {
    fun isExpiredAt(nowMillis: Long): Boolean = nowMillis >= expiresAtMillis

    fun toJson(): JSONObject = JSONObject().apply {
        put("version", version)
        put("tokenHash", tokenHash)
        put("targetProfileId", targetProfileId)
        put("createdAt", Iso8601.format(createdAtMillis))
        put("expiresAt", Iso8601.format(expiresAtMillis))
    }

    companion object {
        fun tryFromJson(json: JSONObject): RestartAuthorization? {
            val tokenHash = json.stringOrEmpty("tokenHash")
            if (tokenHash.isEmpty()) return null

            val targetProfileId = json.stringOrEmpty("targetProfileId")
            if (targetProfileId.isEmpty()) return null

            val createdAt = Iso8601.parse(json.stringOrNull("createdAt")) ?: return null
            val expiresAt = Iso8601.parse(json.stringOrNull("expiresAt")) ?: return null

            return RestartAuthorization(
                version = json.intOr("version", RESTART_AUTHORIZATION_VERSION),
                tokenHash = tokenHash,
                targetProfileId = targetProfileId.lowercase(),
                createdAtMillis = createdAt,
                expiresAtMillis = expiresAt,
            )
        }
    }
}

/** The hash a restart token is stored under. Mirrored in Dart. */
fun restartAuthorizationTokenHash(token: String): String =
    MessageDigest.getInstance("SHA-256")
        .digest(token.toByteArray(Charsets.UTF_8))
        .joinToString("") { "%02x".format(it) }

/**
 * Single reader/writer for `weblibre_restart/authorization.json`.
 *
 * At most one authorization exists at a time, and the newest wins: a user who
 * answered the mismatch dialog twice meant the second answer. The first request's
 * token then no longer matches, which is the correct outcome — one dialog, one
 * restart.
 */
class RestartAuthorizationStore(paths: StartupPaths) {
    private val file = AtomicJsonFile(paths.restartAuthorizationFile)
    private val monitor = FileMonitors.forPath(paths.restartAuthorizationFile.path)
    private val random = SecureRandom()

    /**
     * Records an authorization for [targetProfileId] and returns its token.
     *
     * The token goes on the intent; only the hash is written down. Throws when the
     * record could not be persisted — a caller that cannot prove the request is
     * its own must not send it.
     */
    fun issue(
        targetProfileId: String,
        nowMillis: Long = System.currentTimeMillis(),
    ): String {
        val token = newToken()

        synchronized(monitor) {
            file.write(
                RestartAuthorization(
                    tokenHash = restartAuthorizationTokenHash(token),
                    targetProfileId = targetProfileId.lowercase(),
                    createdAtMillis = nowMillis,
                    expiresAtMillis = nowMillis + RESTART_AUTHORIZATION_TTL_MS,
                ).toJson(),
            )
        }

        return token
    }

    fun read(): RestartAuthorization? = synchronized(monitor) {
        when (val result = file.read()) {
            is AtomicJsonFile.Read.Present -> RestartAuthorization.tryFromJson(result.json)
            // An authorization that cannot be read is not one we may act on.
            is AtomicJsonFile.Read.Corrupt -> null
            is AtomicJsonFile.Read.Absent -> null
        }
    }

    fun clear(): Boolean = synchronized(monitor) { file.delete() }

    private fun newToken(): String {
        val bytes = ByteArray(32)
        random.nextBytes(bytes)
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
