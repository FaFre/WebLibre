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

const val RESTART_REQUEST_VERSION = 1

enum class RestartRequestState(val id: String) {
    /** Written before the alarm is armed. */
    PENDING("pending"),

    /** A new process has adopted the target and is bringing startup up. */
    APPLIED("applied");

    companion object {
        fun tryFromId(id: String?): RestartRequestState? = RestartRequestState.entries.firstOrNull { it.id == id }
    }
}

/**
 * The durable half of the restart protocol.
 *
 * `AtomicFile`, `AlarmManager`, and process termination are three separate
 * operations, so the *request* — not the alarm — is what a new process trusts. The
 * old process never writes `current_profile`; it records the target here and the
 * next process applies it through `ActiveProfile`.
 */
data class RestartRequest(
    val requestId: String,
    val reason: String,
    val processInstanceId: String,
    val stateId: String,
    val createdAtMillis: Long,
    val expiresAtMillis: Long,
    val version: Int = RESTART_REQUEST_VERSION,
    val targetProfileId: String? = null,
    val brokerEntryId: String? = null,
    val appliedAtMillis: Long? = null,
) {
    val state: RestartRequestState? get() = RestartRequestState.tryFromId(stateId)

    fun isExpiredAt(nowMillis: Long): Boolean = nowMillis >= expiresAtMillis

    /**
     * Only actionable while pending, unexpired, and written by a *different* process
     * instance. A `PendingIntent` that reaches the still-live old process must be
     * recognised and rescheduled, never honoured in place.
     */
    fun isActionableFor(currentProcessInstanceId: String, nowMillis: Long): Boolean =
        state == RestartRequestState.PENDING &&
            !isExpiredAt(nowMillis) &&
            processInstanceId != currentProcessInstanceId

    fun toJson(): JSONObject = JSONObject().apply {
        put("version", version)
        put("requestId", requestId)
        put("targetProfileId", targetProfileId ?: JSONObject.NULL)
        put("brokerEntryId", brokerEntryId ?: JSONObject.NULL)
        put("reason", reason)
        put("processInstanceId", processInstanceId)
        put("state", stateId)
        put("createdAt", Iso8601.format(createdAtMillis))
        put("expiresAt", Iso8601.format(expiresAtMillis))
        put("appliedAt", appliedAtMillis?.let(Iso8601::format) ?: JSONObject.NULL)
    }

    companion object {
        fun tryFromJson(json: JSONObject): RestartRequest? {
            val requestId = json.stringOrEmpty("requestId")
            if (requestId.isEmpty()) return null

            val processInstanceId = json.stringOrEmpty("processInstanceId")
            if (processInstanceId.isEmpty()) return null

            val createdAt = Iso8601.parse(json.stringOrNull("createdAt")) ?: return null
            val expiresAt = Iso8601.parse(json.stringOrNull("expiresAt")) ?: return null

            return RestartRequest(
                version = json.intOr("version", RESTART_REQUEST_VERSION),
                requestId = requestId,
                targetProfileId = json.stringOrNull("targetProfileId"),
                brokerEntryId = json.stringOrNull("brokerEntryId"),
                reason = json.stringOrEmpty("reason"),
                processInstanceId = processInstanceId,
                stateId = json.stringOrNull("state") ?: RestartRequestState.PENDING.id,
                createdAtMillis = createdAt,
                expiresAtMillis = expiresAt,
                appliedAtMillis = Iso8601.parse(json.stringOrNull("appliedAt")),
            )
        }
    }
}

/**
 * Single reader/writer for `weblibre_restart/request.json`.
 *
 * The monitor is the file's rather than this instance's, because
 * [RestartCoordinator] constructs a store per call. See [FileMonitors].
 */
class RestartRequestStore(paths: StartupPaths) {
    private val file = AtomicJsonFile(paths.restartRequestFile)
    private val monitor = FileMonitors.forPath(paths.restartRequestFile.path)

    fun read(): RestartRequest? = synchronized(monitor) {
        when (val result = file.read()) {
            is AtomicJsonFile.Read.Present -> RestartRequest.tryFromJson(result.json)
            // A request we cannot read is not a request we may act on. Dropping it
            // is safe: the worst case is that the user relaunches the app.
            is AtomicJsonFile.Read.Corrupt -> null
            is AtomicJsonFile.Read.Absent -> null
        }
    }

    fun write(request: RestartRequest) = synchronized(monitor) {
        file.write(request.toJson())
    }

    fun markApplied(request: RestartRequest, nowMillis: Long): RestartRequest =
        synchronized(monitor) {
            val applied = request.copy(
                stateId = RestartRequestState.APPLIED.id,
                appliedAtMillis = nowMillis,
            )
            file.write(applied.toJson())
            applied
        }

    fun clear(): Boolean = synchronized(monitor) { file.delete() }
}
