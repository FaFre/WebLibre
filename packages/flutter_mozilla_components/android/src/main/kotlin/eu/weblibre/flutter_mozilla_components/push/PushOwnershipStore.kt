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
package eu.weblibre.flutter_mozilla_components.push

import eu.weblibre.flutter_mozilla_components.startup.AtomicJsonFile
import eu.weblibre.flutter_mozilla_components.startup.Iso8601
import eu.weblibre.flutter_mozilla_components.startup.ProfileUuid
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import eu.weblibre.flutter_mozilla_components.startup.stringOrEmpty
import eu.weblibre.flutter_mozilla_components.startup.stringOrNull
import org.json.JSONArray
import org.json.JSONObject

/** One connector token and the profile that registered it. */
data class PushOwner(
    val token: String,
    val profileId: String,
    val instance: String?,
    val updatedAtMillis: Long,
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("token", token)
        put("profileId", profileId)
        put("instance", instance ?: JSONObject.NULL)
        put("updatedAt", Iso8601.format(updatedAtMillis))
    }

    companion object {
        fun tryFromJson(json: JSONObject): PushOwner? {
            // Never `optString`: `instance` is written as `JSONObject.NULL` when
            // absent, and on Android that reads back as the four-character string
            // "null" — a non-null instance that matches nothing, so `record` would
            // rewrite the file on every callback and `rollback` would restore the
            // corrupted value. The reference `org.json` the JVM tests run against
            // returns "" instead, which is exactly why the tests cannot catch it.
            val token = json.stringOrEmpty("token")
            val profileId = json.stringOrEmpty("profileId").lowercase()
            if (token.isEmpty()) return null
            if (!ProfileUuid.isCanonical(profileId)) return null

            val updatedAt = Iso8601.parse(json.stringOrNull("updatedAt")) ?: 0L

            return PushOwner(
                token = token,
                profileId = profileId,
                instance = json.stringOrNull("instance"),
                updatedAtMillis = updatedAt,
            )
        }
    }
}

/**
 * Which profile owns a UnifiedPush connector token.
 *
 * A push broadcast names a token, not a profile, and the only store that could
 * translate one into the other is the connector's own database — which lives
 * *inside* a profile, so reading it requires already knowing the answer. This map
 * lives outside every profile and breaks that circle.
 *
 * ## It is a cache, and it fails safe
 *
 * Nothing here is authoritative. An entry only ever lets the receiver **decline**
 * a broadcast it knows belongs to another profile; a missing or dropped entry
 * falls back to the previous behaviour, where the connector itself resolves the
 * token against whichever profile the process committed to and does nothing if it
 * does not recognise it. So losing the file costs a redundant wake-up, never a
 * message.
 *
 * The direction that matters is the other one: an entry naming the *wrong* owner
 * would make the receiver skip a message it should have handled. That is why
 * restore and delete purge a profile's entries rather than trying to rewrite
 * them, and why entries are only ever written from a callback that actually fired
 * — the connector having invoked one is proof that that profile's database
 * recognised the token.
 */
class PushOwnershipStore(paths: StartupPaths) {
    private val file = AtomicJsonFile(paths.pushOwnershipFile)

    fun ownerOf(token: String): PushOwner? =
        entries().firstOrNull { it.token == token }

    fun entriesForProfile(profileId: String): List<PushOwner> {
        val normalized = profileId.lowercase()
        return entries().filter { it.profileId == normalized }
    }

    /**
     * Records that [profileId] owns [token].
     *
     * Call only from a connector callback. The callback firing at all means the
     * connector resolved the token in that profile's database, which is the one
     * piece of evidence available that the two belong together.
     */
    fun record(
        token: String,
        profileId: String,
        instance: String?,
        nowMillis: Long = System.currentTimeMillis(),
    ) {
        val normalized = profileId.lowercase()
        if (!ProfileUuid.isCanonical(normalized)) return

        val existing = entries()
        val current = existing.firstOrNull { it.token == token }
        if (current?.profileId == normalized && current.instance == instance) return

        val updated = existing.filterNot { it.token == token } +
            PushOwner(token, normalized, instance, nowMillis)

        writeEntries(updated)
    }

    /** Drops one token, e.g. when the distributor reports it unregistered. */
    fun forget(token: String) {
        val existing = entries()
        if (existing.none { it.token == token }) return
        writeEntries(existing.filterNot { it.token == token })
    }

    /**
     * Drops everything belonging to a profile.
     *
     * Used by restore and delete. Purging rather than rewriting is deliberate: a
     * restored profile's connector database came out of an archive, and which of
     * its tokens a distributor still honours is not something this map can know.
     * Re-learning costs one redundant wake-up per token; guessing costs messages.
     */
    fun forgetProfile(profileId: String) {
        val normalized = profileId.lowercase()
        val existing = entries()
        if (existing.none { it.profileId == normalized }) return
        writeEntries(existing.filterNot { it.profileId == normalized })
    }

    fun entries(): List<PushOwner> {
        val json = when (val result = file.read()) {
            is AtomicJsonFile.Read.Present -> result.json
            else -> return emptyList()
        }

        val array = json.optJSONArray("entries") ?: return emptyList()
        val entries = mutableListOf<PushOwner>()
        for (index in 0 until array.length()) {
            val entry = array.optJSONObject(index) ?: continue
            PushOwner.tryFromJson(entry)?.let(entries::add)
        }
        return entries
    }

    private fun writeEntries(entries: List<PushOwner>) {
        // Newest first, then capped. One token per instance per profile means the
        // map is small in normal use; the cap is there so a distributor that churns
        // tokens cannot grow a file the receiver has to parse on every broadcast.
        val retained = entries.sortedByDescending { it.updatedAtMillis }.take(MAX_ENTRIES)

        file.write(
            JSONObject().apply {
                put("version", VERSION)
                put(
                    "entries",
                    JSONArray().apply { retained.forEach { put(it.toJson()) } },
                )
            },
        )
    }

    companion object {
        private const val VERSION = 1
        internal const val MAX_ENTRIES = 512
    }
}
