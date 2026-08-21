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

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import mozilla.components.support.base.log.logger.Logger
import java.util.UUID

/** How long a queued launch stays worth delivering. */
const val STARTUP_INTENT_TTL_MS = 10 * 60 * 1000L

/** How long one engine's claim on an entry holds before another may take it. */
const val STARTUP_INTENT_CLAIM_TTL_MS = 60 * 1000L

/**
 * Holds launches the process cannot deliver yet, and hands them over when it can.
 *
 * The window it closes is narrow and completely silent today. `onNewIntent`
 * reaches `SimpleIntentReceiverPlugin`, which sends the intent straight to Dart
 * over Pigeon — and if nothing on the Dart side is listening yet, that message
 * goes nowhere and the launch is gone. Nothing retries it and nothing records
 * that it happened.
 *
 * "Nothing is listening yet" is precisely the interval this whole plan created:
 * while the profile picker is up, while maintenance owns the process, and while a
 * restart is tearing it down, the app's providers do not exist. A user who taps a
 * link during that interval currently gets nothing at all.
 *
 * So the rule is deliberately narrow: an intent is taken **only** when the
 * arbiter says the process has not committed a profile. In that state the app's
 * `ProviderScope` provably does not exist yet — activation follows commitment —
 * so the live delivery provably had no listener, and there is no path by which
 * the same launch reaches Dart twice.
 */
/**
 * A launch reduced to what can be written down.
 *
 * The split from `Intent` is not ceremony: everything below this line is pure
 * Kotlin and provable in a host-side test, and the queue's ordering, claiming and
 * acknowledgement rules are exactly the parts that have to be right under crash
 * and concurrency. Only [StartupIntentBroker.describe] touches Android.
 */
data class StartupIntentDescriptor(
    val action: String? = null,
    val dataUri: String? = null,
    val mimeType: String? = null,
    val categories: List<String> = emptyList(),
    val extras: Map<String, Any> = emptyMap(),
    val classification: LaunchClassification = LaunchClassification.UNKNOWN,
    val trustedProfileId: String? = null,
    /**
     * Which app sent the launch, resolved when it arrived.
     *
     * Written down because it cannot be recovered later: `getReferrer()` answers
     * about the activity running at the moment it is asked, and by replay time
     * that is this app. A queued launch that forgot its caller is replayed as
     * internal, which is exactly the answer that skips the gatekeeper prompt.
     */
    val callerPackage: String? = null,
)

object StartupIntentBroker {
    private val logger = Logger("StartupIntentBroker")

    /**
     * Whether this process must queue a launch rather than deliver it.
     *
     * True exactly when no profile is committed, because that is exactly when the
     * app's `ProviderScope` does not exist — activation follows commitment — so
     * the live Pigeon delivery provably has no listener.
     */
    fun shouldTake(): Boolean = !StartupArbiter.currentState().allowsProfileAccess

    /**
     * Queues [intent] if this process cannot deliver it, and reports whether it did.
     *
     * A `true` means the caller must **not** also hand the intent to Flutter: the
     * broker now owns delivery, and letting the plugin send it as well is how a
     * one-off duplicate becomes a permanent one.
     */
    fun takeIfUndeliverable(
        context: Context,
        paths: StartupPaths,
        intent: Intent,
        classification: LaunchClassification = LaunchClassification.UNKNOWN,
        trustedProfileId: String? = null,
        /**
         * Resolved lazily: establishing a caller costs a `PackageManager` lookup,
         * and it is only ever written down on the path that queues.
         */
        callerPackage: () -> String? = { null },
        nowMillis: Long = System.currentTimeMillis(),
    ): Boolean {
        if (!shouldTake()) return false

        return runCatching {
            enqueue(
                paths = paths,
                descriptor = describe(intent, classification, trustedProfileId, callerPackage()),
                nowMillis = nowMillis,
                stage = { entryId, descriptor ->
                    StartupIntentPayloads.stage(
                        context = context,
                        paths = paths,
                        entryId = entryId,
                        descriptor = descriptor,
                        intent = intent,
                    )
                },
            ) != null
        }.getOrElse { error ->
            // Falling through to the ordinary path is not a fix — nothing is
            // listening — but it is better than losing the intent *and* crashing
            // the activity that received it.
            logger.error("Could not queue an undeliverable launch", error)
            false
        }
    }

    /** The only method here that knows what an `Intent` is. */
    fun describe(
        intent: Intent,
        classification: LaunchClassification = LaunchClassification.UNKNOWN,
        trustedProfileId: String? = null,
        callerPackage: String? = null,
    ): StartupIntentDescriptor = StartupIntentDescriptor(
        action = intent.action,
        dataUri = intent.dataString,
        mimeType = intent.type,
        categories = intent.categories?.toList().orEmpty(),
        extras = allowlistExtras(intent.extras),
        classification = classification,
        trustedProfileId = trustedProfileId,
        callerPackage = callerPackage,
    )

    /**
     * Queues [descriptor], staging any referenced content first.
     *
     * Returns null when the launch references a shared file that could not be
     * staged. §7.1 requires blocking rather than promising a replay: a queued
     * entry pointing at a `content://` URI whose grant died with the process is a
     * share of a file the user will never see.
     */
    fun enqueue(
        paths: StartupPaths,
        descriptor: StartupIntentDescriptor,
        nowMillis: Long = System.currentTimeMillis(),
        stage: ((String, StartupIntentDescriptor) -> StartupIntentDescriptor?)? = null,
    ): StartupIntentEntry? {
        val store = StartupIntentQueueStore(paths)
        val entryId = UUID.randomUUID().toString()

        // Before the queue write, so a failure leaves nothing behind to reconcile.
        val staged = if (stage == null) {
            descriptor
        } else {
            stage(entryId, descriptor) ?: run {
                logger.warn("Declining a launch whose shared file could not be staged")
                return null
            }
        }
        val stagedPayload = staged !== descriptor && StartupIntentPayloads.needsStaging(descriptor)

        var created: StartupIntentEntry? = null
        store.update { queue ->
            val pruned = queue.entries.filterNot { it.acknowledged || it.isExpiredAt(nowMillis) }

            val entry = StartupIntentEntry(
                id = entryId,
                sequence = queue.nextSequence,
                classificationId = staged.classification.id,
                action = staged.action,
                dataUri = staged.dataUri,
                mimeType = staged.mimeType,
                categories = staged.categories,
                extras = staged.extras,
                trustedProfileId = staged.trustedProfileId,
                callerPackage = staged.callerPackage,
                payloadDirName = if (stagedPayload) entryId else null,
                createdAtMillis = nowMillis,
                expiresAtMillis = nowMillis + STARTUP_INTENT_TTL_MS,
            )
            created = entry

            queue.copy(nextSequence = queue.nextSequence + 1, entries = pruned + entry)
        }

        logger.info("Queued a launch that had nowhere to go: ${staged.action}")
        return checkNotNull(created)
    }

    /**
     * Claims every entry [engineId] may deliver, oldest first.
     *
     * Claiming and reading are one step because they have to be: a reader that
     * looked first and claimed afterwards would let a second engine read the same
     * entry in between.
     */
    fun claim(
        paths: StartupPaths,
        engineId: String,
        nowMillis: Long = System.currentTimeMillis(),
    ): List<StartupIntentEntry> {
        val processInstanceId = StartupArbiter.processInstanceId
        val claimed = mutableListOf<StartupIntentEntry>()

        StartupIntentQueueStore(paths).update { queue ->
            val entries = queue.entries.mapNotNull { entry ->
                when {
                    entry.acknowledged -> null
                    entry.isExpiredAt(nowMillis) -> null
                    !entry.isDeliverableAt(nowMillis, processInstanceId, engineId) -> entry
                    else -> entry.copy(
                        claim = StartupIntentClaim(
                            processInstanceId = processInstanceId,
                            engineId = engineId,
                            claimedAtMillis = nowMillis,
                            expiresAtMillis = nowMillis + STARTUP_INTENT_CLAIM_TTL_MS,
                        ),
                    ).also(claimed::add)
                }
            }

            queue.copy(entries = entries)
        }

        return claimed.sortedBy { it.sequence }
    }

    /**
     * Marks an entry delivered.
     *
     * Only the holder of the claim may do this. An acknowledgement from anyone
     * else would mean an engine could retire work another engine is still doing.
     */
    fun acknowledge(
        paths: StartupPaths,
        entryId: String,
        engineId: String,
        nowMillis: Long = System.currentTimeMillis(),
    ): Boolean {
        val processInstanceId = StartupArbiter.processInstanceId
        var acknowledged = false

        StartupIntentQueueStore(paths).update { queue ->
            val entries = queue.entries.mapNotNull { entry ->
                if (entry.id != entryId) return@mapNotNull entry

                val claim = entry.claim
                if (claim?.processInstanceId != processInstanceId || claim.engineId != engineId) {
                    return@mapNotNull entry
                }

                acknowledged = true
                // Dropped rather than flagged: an acknowledged entry is never
                // replayed, so keeping it only grows a file every launch reads.
                null
            }

            queue.copy(entries = entries)
        }

        if (acknowledged) {
            // The bytes were staged for this entry alone, and it is gone.
            StartupIntentPayloads.discard(paths, entryId)
        }

        return acknowledged
    }

    /**
     * Gives an entry back without delivering it.
     *
     * Used when an engine goes away mid-delivery. Waiting for the claim to expire
     * would work too, but leaves the user staring at a link that does nothing for
     * a minute.
     */
    fun release(
        paths: StartupPaths,
        entryId: String,
        engineId: String,
    ): Boolean {
        val processInstanceId = StartupArbiter.processInstanceId
        var released = false

        StartupIntentQueueStore(paths).update { queue ->
            val entries = queue.entries.map { entry ->
                val claim = entry.claim
                if (entry.id != entryId ||
                    claim?.processInstanceId != processInstanceId ||
                    claim.engineId != engineId
                ) {
                    entry
                } else {
                    released = true
                    entry.copy(claim = null)
                }
            }

            queue.copy(entries = entries)
        }

        return released
    }

    /**
     * Drops acknowledged and expired entries, and the bytes staged for them.
     *
     * The payload sweep is keyed off what survives rather than off what was
     * removed: a directory whose entry vanished in a crash has nothing left to
     * name it, so anything not referenced by a live entry is unreachable by
     * definition.
     */
    fun prune(paths: StartupPaths, nowMillis: Long = System.currentTimeMillis()) {
        val remaining = StartupIntentQueueStore(paths).update { queue ->
            queue.copy(
                entries = queue.entries.filterNot {
                    it.acknowledged || it.isExpiredAt(nowMillis)
                },
            )
        }

        StartupIntentPayloads.prune(paths, remaining.entries.map { it.id }.toSet())
    }

    /**
     * Keeps only what can be written down and read back unchanged.
     *
     * A `Parcelable` extra has no representation that survives a process restart,
     * and a best-effort `toString()` of one is worse than dropping it: the
     * consumer cannot tell a real value from a rendering of an object it can no
     * longer reconstruct.
     *
     * [Uri] is the exception, and it has to be: a `Uri` *is* its string — parsing
     * one back is lossless, and `EXTRA_STREAM` on an ordinary Android file share
     * holds a `Uri` parcelable rather than a string. Dropping it left every such
     * share replayed with no file at all, and staging never saw the content URI
     * it exists to copy.
     *
     * A `Uri` *list* — `ACTION_SEND_MULTIPLE` — is still dropped. Staging handles
     * one stream, so keeping the list would queue a share pointing at content
     * grants that die with the process: exactly the promise §7.1 says to refuse
     * rather than make.
     */
    internal fun allowlistExtras(extras: Bundle?): Map<String, Any> {
        if (extras == null) return emptyMap()

        val result = LinkedHashMap<String, Any>()
        for (key in extras.keySet()) {
            @Suppress("DEPRECATION")
            when (val value = runCatching { extras.get(key) }.getOrNull()) {
                is Boolean, is Int, is Long, is Double, is String -> result[key] = value
                is Float -> result[key] = value.toDouble()
                is Uri -> result[key] = value.toString()
                is ArrayList<*> -> {
                    val strings = value.filterIsInstance<String>()
                    if (strings.size == value.size) result[key] = strings
                }
                else -> Unit
            }
        }
        return result
    }
}
