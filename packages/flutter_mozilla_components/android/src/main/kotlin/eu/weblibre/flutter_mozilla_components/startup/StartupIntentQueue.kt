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

import org.json.JSONArray
import org.json.JSONObject

const val STARTUP_INTENT_QUEUE_VERSION = 1

/**
 * How native classified a launch *before* any component was created.
 *
 * Only native code that authenticated the launch source may produce a `TRUSTED_*`
 * value. Dart never derives one from raw intent extras, so a spoofed
 * `pwa_profile_uuid` on a `MainActivity` intent can never select a profile.
 */
enum class LaunchClassification(val id: String) {
    TRUSTED_PWA("trustedPwa"),
    TRUSTED_SHORTCUT("trustedShortcut"),
    LEGACY_PWA("legacyPwa"),
    CUSTOM_TAB("customTab"),
    SHARE_URL("shareUrl"),
    REGULAR("regular"),
    ACCOUNT_CALLBACK("accountCallback"),
    WIDGET("widget"),
    QUICK_ACTION("quickAction"),

    /** Unknown to this build. Treated exactly like [REGULAR]: never trusted. */
    UNKNOWN("unknown");

    val isTrusted: Boolean
        get() = this == TRUSTED_PWA || this == TRUSTED_SHORTCUT || this == ACCOUNT_CALLBACK

    /**
     * Whether serving this launch requires the Mozilla components.
     *
     * A property of the classification rather than of the descriptor, so a
     * launch cannot contradict its own kind. Creating components creates the
     * Gecko engine, which binds the process profile for good — the one decision
     * on this path that cannot be taken back — and it is decided here, once, for
     * the whole closed set.
     *
     * Anything not listed is `false`: a launch this build does not recognise
     * must not build an engine to find out what it was.
     */
    val requiresComponents: Boolean
        get() = when (this) {
            TRUSTED_PWA, LEGACY_PWA, CUSTOM_TAB, SHARE_URL -> true
            TRUSTED_SHORTCUT, REGULAR, ACCOUNT_CALLBACK, WIDGET, QUICK_ACTION, UNKNOWN -> false
        }

    companion object {
        fun fromId(id: String?): LaunchClassification =
            LaunchClassification.entries.firstOrNull { it.id == id } ?: UNKNOWN
    }
}

/**
 * A process-instance-scoped claim, so two engines cannot deliver the same intent
 * twice. Claims expire and a new process may take over an expired one; an
 * acknowledged entry is never replayed.
 */
data class StartupIntentClaim(
    val processInstanceId: String,
    val engineId: String,
    val claimedAtMillis: Long,
    val expiresAtMillis: Long,
) {
    fun isExpiredAt(nowMillis: Long): Boolean = nowMillis >= expiresAtMillis

    fun toJson(): JSONObject = JSONObject().apply {
        put("processInstanceId", processInstanceId)
        put("engineId", engineId)
        put("claimedAt", Iso8601.format(claimedAtMillis))
        put("expiresAt", Iso8601.format(expiresAtMillis))
    }

    companion object {
        fun tryFromJson(json: JSONObject): StartupIntentClaim? {
            val processInstanceId = json.stringOrEmpty("processInstanceId")
            if (processInstanceId.isEmpty()) return null

            val claimedAt = Iso8601.parse(json.stringOrNull("claimedAt")) ?: return null
            val expiresAt = Iso8601.parse(json.stringOrNull("expiresAt")) ?: return null

            return StartupIntentClaim(
                processInstanceId = processInstanceId,
                engineId = json.stringOrEmpty("engineId"),
                claimedAtMillis = claimedAt,
                expiresAtMillis = expiresAt,
            )
        }
    }
}

/**
 * One queued launch in the allowlisted representation that can survive a restart.
 *
 * Arbitrary `Parcelable` extras are deliberately not representable. Content that
 * must survive restart is either covered by a persistable URI grant or staged as
 * bytes under the entry's payload directory; when neither is possible the restart
 * flow is blocked rather than promising a replay it cannot deliver.
 */
data class StartupIntentEntry(
    val id: String,
    val sequence: Long,
    val classificationId: String,
    val createdAtMillis: Long,
    val expiresAtMillis: Long,
    val action: String? = null,
    val dataUri: String? = null,
    val mimeType: String? = null,
    val categories: List<String> = emptyList(),
    val flags: List<String> = emptyList(),
    val extras: Map<String, Any> = emptyMap(),
    val trustedProfileId: String? = null,
    /** The app that sent the launch, as resolved when it arrived. */
    val callerPackage: String? = null,
    val payloadDirName: String? = null,
    val claim: StartupIntentClaim? = null,
    val acknowledged: Boolean = false,
) {
    val classification: LaunchClassification
        get() = LaunchClassification.fromId(classificationId)

    /** A profile hint only counts when the classification itself is trusted. */
    val effectiveTrustedProfileId: String?
        get() = if (classification.isTrusted) trustedProfileId else null

    fun isExpiredAt(nowMillis: Long): Boolean = nowMillis >= expiresAtMillis

    /**
     * Whether [engineId] in [processInstanceId] may take this entry.
     *
     * The engine is part of the identity, not decoration. `MainActivity` destroys
     * its cached engine after a non-finishing destroy and can build another in the
     * *same* process, so matching on the process alone would let the replacement
     * engine re-deliver an entry the previous one already claimed and is still
     * working on. A replacement takes over by waiting for the claim to expire, or
     * by the owner releasing it — never by sharing its identity.
     */
    fun isDeliverableAt(
        nowMillis: Long,
        processInstanceId: String,
        engineId: String,
    ): Boolean {
        if (acknowledged || isExpiredAt(nowMillis)) return false
        val claim = claim ?: return true
        if (claim.isExpiredAt(nowMillis)) return true
        return claim.processInstanceId == processInstanceId && claim.engineId == engineId
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("sequence", sequence)
        put("classification", classificationId)
        put("action", action ?: JSONObject.NULL)
        put("dataUri", dataUri ?: JSONObject.NULL)
        put("mimeType", mimeType ?: JSONObject.NULL)
        put("categories", JSONArray(categories))
        put("flags", JSONArray(flags))
        put("extras", extrasToJson(extras))
        put("trustedProfileId", trustedProfileId ?: JSONObject.NULL)
        put("callerPackage", callerPackage ?: JSONObject.NULL)
        put("payloadDirName", payloadDirName ?: JSONObject.NULL)
        put("createdAt", Iso8601.format(createdAtMillis))
        put("expiresAt", Iso8601.format(expiresAtMillis))
        put("claim", claim?.toJson() ?: JSONObject.NULL)
        put("acknowledged", acknowledged)
    }

    companion object {
        fun tryFromJson(json: JSONObject): StartupIntentEntry? {
            val id = json.stringOrEmpty("id")
            if (id.isEmpty()) return null

            val sequence = json.longOrNull("sequence") ?: return null
            val createdAt = Iso8601.parse(json.stringOrNull("createdAt")) ?: return null
            val expiresAt = Iso8601.parse(json.stringOrNull("expiresAt")) ?: return null

            return StartupIntentEntry(
                id = id,
                sequence = sequence,
                classificationId = json.stringOrNull("classification")
                    ?: LaunchClassification.UNKNOWN.id,
                action = json.stringOrNull("action"),
                dataUri = json.stringOrNull("dataUri"),
                mimeType = json.stringOrNull("mimeType"),
                categories = stringList(json.optJSONArray("categories")),
                flags = stringList(json.optJSONArray("flags")),
                extras = sanitizeExtras(json.optJSONObject("extras")),
                trustedProfileId = json.stringOrNull("trustedProfileId"),
                callerPackage = json.stringOrNull("callerPackage"),
                payloadDirName = json.stringOrNull("payloadDirName"),
                createdAtMillis = createdAt,
                expiresAtMillis = expiresAt,
                claim = json.optJSONObject("claim")?.let(StartupIntentClaim::tryFromJson),
                acknowledged = json.booleanOr("acknowledged", false),
            )
        }

        /**
         * Serializes sanitized extras.
         *
         * Built key by key rather than through `JSONObject(Map)`: that constructor
         * stores a `List` value verbatim, and `JSONObject.toString()` then emits it
         * as the string `"[a, b]"` instead of a JSON array, which Dart would read
         * back as a plain string.
         */
        fun extrasToJson(extras: Map<String, Any>): JSONObject = JSONObject().apply {
            for ((key, value) in extras) {
                if (value is List<*>) put(key, JSONArray(value)) else put(key, value)
            }
        }

        /**
         * Keeps only JSON-safe primitives and string lists. Anything else is dropped
         * rather than best-effort encoded: a partially reconstructed extra is worse
         * than a missing one, because the consumer cannot tell the difference.
         */
        fun sanitizeExtras(json: JSONObject?): Map<String, Any> {
            if (json == null) return emptyMap()

            val result = LinkedHashMap<String, Any>()
            for (key in json.keys()) {
                when (val value = json.get(key)) {
                    is Boolean, is Int, is Long, is Double, is String -> result[key] = value
                    is JSONArray -> {
                        val items = stringList(value)
                        if (items.size == value.length()) result[key] = items
                    }
                    else -> Unit
                }
            }
            return result
        }

        private fun stringList(array: JSONArray?): List<String> {
            if (array == null) return emptyList()
            val result = mutableListOf<String>()
            for (index in 0 until array.length()) {
                val value = array.opt(index)
                if (value is String) result += value
            }
            return result
        }
    }
}

/** The persisted, ordered queue of unacknowledged launches. */
data class StartupIntentQueue(
    val version: Int = STARTUP_INTENT_QUEUE_VERSION,
    val nextSequence: Long = 1,
    val entries: List<StartupIntentEntry> = emptyList(),
) {
    fun toJson(): JSONObject = JSONObject().apply {
        put("version", version)
        put("nextSequence", nextSequence)
        put("entries", JSONArray().also { array -> entries.forEach { array.put(it.toJson()) } })
    }

    companion object {
        val EMPTY = StartupIntentQueue()

        fun fromJson(json: JSONObject): StartupIntentQueue {
            val entries = mutableListOf<StartupIntentEntry>()
            val seen = mutableSetOf<String>()

            val rawEntries = json.optJSONArray("entries")
            if (rawEntries != null) {
                for (index in 0 until rawEntries.length()) {
                    val raw = rawEntries.optJSONObject(index) ?: continue
                    val entry = StartupIntentEntry.tryFromJson(raw) ?: continue
                    if (!seen.add(entry.id)) continue
                    entries += entry
                }
            }

            entries.sortBy { it.sequence }

            val highest = entries.lastOrNull()?.sequence ?: 0
            val stored = json.longOrNull("nextSequence") ?: 0

            return StartupIntentQueue(
                version = json.intOr("version", STARTUP_INTENT_QUEUE_VERSION),
                // Never hand out a sequence at or below one already on disk, even if
                // the stored counter was truncated or rolled back.
                nextSequence = if (stored > highest) stored else highest + 1,
                entries = entries,
            )
        }
    }
}

/**
 * Single reader/writer for `weblibre_startup_intents/queue.json`.
 *
 * The monitor is the file's, not this instance's: every caller in
 * [StartupIntentBroker] builds a store of its own, and `onNewIntent` on the main
 * thread can enqueue while a Pigeon call claims on the platform thread. See
 * [FileMonitors].
 */
class StartupIntentQueueStore(paths: StartupPaths) {
    private val file = AtomicJsonFile(paths.startupIntentQueueFile)
    private val monitor = FileMonitors.forPath(paths.startupIntentQueueFile.path)

    fun read(): StartupIntentQueue = synchronized(monitor) {
        when (val result = file.read()) {
            is AtomicJsonFile.Read.Present -> StartupIntentQueue.fromJson(result.json)
            is AtomicJsonFile.Read.Corrupt -> StartupIntentQueue.EMPTY
            is AtomicJsonFile.Read.Absent -> StartupIntentQueue.EMPTY
        }
    }

    fun update(block: (StartupIntentQueue) -> StartupIntentQueue): StartupIntentQueue =
        synchronized(monitor) {
            val next = block(read())
            file.write(next.toJson())
            next
        }
}
