/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.SystemClock
import androidx.annotation.VisibleForTesting
import java.util.concurrent.ConcurrentHashMap
import kotlinx.coroutines.channels.Channel

/** A launch that cannot be served until the proxy carrying its context runs. */
data class RoutingDemand(
    /** The cookie-store context the waiting launch's traffic is keyed on. */
    val contextId: String,

    /**
     * Encoded proxy connection ids that context routes through and that have no
     * live endpoint. Everything the app half has to bring up for this launch.
     */
    val proxyIds: List<String>,

    val recordedAtMs: Long,
) {
    fun isExpiredAt(nowMs: Long): Boolean = nowMs - recordedAtMs >= DEMAND_TTL_MS
}

/**
 * How long a demand is worth acting on.
 *
 * A launch waits under a minute for its routing, so a demand older than that
 * describes a window nobody is watching any more.
 * Generous beyond it only so a "keep waiting" re-entry inherits the same one.
 */
private const val DEMAND_TTL_MS = 2 * 60 * 1000L

/**
 * How long after handing a demand to the app half a blocked verdict is still
 * treated as "not answered yet" rather than as the answer.
 *
 * Between Dart taking a demand and its start reaching the routing snapshot as
 * an awaited proxy there is a short window in which an unrelated recompute can
 * push a snapshot that still resolves the context to blocked. Ending the
 * launch's wait on it would show "this route is blocked" about a proxy that is
 * at that moment being started for it. The normal path clears this in
 * milliseconds; it only ever costs the launch anything when the start never
 * happens at all, and then it costs it three seconds.
 */
private const val HANDOVER_GRACE_MS = 3_000L

/**
 * Launches asking the app half to bring a proxy up, and the one place that
 * knows whether one is outstanding.
 *
 * A Custom Tab or PWA into a proxied container is unserviceable until that
 * proxy runs, and nothing in the launch path can start one: sing-box and Tor
 * both live in the Flutter isolate. Until now that ended the launch — the user
 * was sent to the browser to start the proxy by hand and to tap their shortcut
 * again. But the launch already knows *which* proxy it needs, and a container
 * the user configured to route through it is a standing instruction to use it.
 * So the need is recorded here and the app half acts on it, which turns "start
 * this yourself and come back" into a few seconds of waiting.
 *
 * A queue rather than a slot: two launches into different containers are two
 * different demands, and the second must not erase the first before Dart has
 * read it. Process-global, like everything else the launch paths read, because
 * the launch and the isolate that serves it are in the same process and have
 * no other relationship.
 */
object RoutingDemands {
    /**
     * Unread demands, oldest first. Unlimited, and never blocks a producer: the
     * producer is a launch on the main thread.
     */
    private val queue = Channel<RoutingDemand>(Channel.UNLIMITED)

    /** The latest demand per context that no one has read yet. */
    private val unread = ConcurrentHashMap<String, RoutingDemand>()

    /** When each context's demand was last handed over. See [HANDOVER_GRACE_MS]. */
    private val handedOverAtMs = ConcurrentHashMap<String, Long>()

    @VisibleForTesting
    internal var clock: () -> Long = SystemClock::elapsedRealtime

    /**
     * Records that a launch in [contextId] needs [proxyIds] running.
     *
     * A demand with nothing to start is not a demand: the context resolves to a
     * proxy the snapshot already knows about, or to none at all, and either way
     * there is nothing for the app half to do.
     */
    fun record(contextId: String, proxyIds: List<String>) {
        if (proxyIds.isEmpty()) return

        val demand = RoutingDemand(contextId, proxyIds, clock())
        // Replaces this context's unread entry, which may leave a superseded
        // copy in the queue; taking one is harmless, since starting a backend
        // that is already coming up is a no-op on the Dart side.
        unread[contextId] = demand
        queue.trySend(demand)
    }

    /** The next unread demand, or null if there is none. Never suspends. */
    fun take(): RoutingDemand? {
        while (true) {
            val demand = queue.tryReceive().getOrNull() ?: return null
            if (accept(demand)) return demand
        }
    }

    /** Suspends until a demand is recorded, then takes it. */
    suspend fun next(): RoutingDemand {
        while (true) {
            val demand = queue.receive()
            if (accept(demand)) return demand
        }
    }

    /**
     * Whether the app half still owes this launch an answer about [contextId] —
     * a demand it has not read, or one it read a moment ago.
     *
     * The launch's wait consults this before believing a blocked verdict: a
     * demand in either state means the routing being read predates anything the
     * app half could have done about it.
     */
    fun isOutstanding(contextId: String): Boolean {
        val now = clock()

        unread[contextId]?.let { pending ->
            if (!pending.isExpiredAt(now)) return true
            unread.remove(contextId, pending)
        }

        val handedOver = handedOverAtMs[contextId] ?: return false
        if (now - handedOver < HANDOVER_GRACE_MS) return true

        handedOverAtMs.remove(contextId, handedOver)
        return false
    }

    /** Drops everything. For a profile change, and for tests. */
    fun clear() {
        while (queue.tryReceive().isSuccess) Unit
        unread.clear()
        handedOverAtMs.clear()
    }

    private fun accept(demand: RoutingDemand): Boolean {
        val now = clock()
        unread.remove(demand.contextId, demand)

        if (demand.isExpiredAt(now)) return false

        handedOverAtMs[demand.contextId] = now
        return true
    }
}
