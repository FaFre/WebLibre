/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import eu.weblibre.flutter_mozilla_components.ext.toStringList
import eu.weblibre.flutter_mozilla_components.ext.toStringSet
import org.json.JSONObject

/** Gecko's cookie-store context for regular tabs, and for contextless traffic. */
const val GENERAL_CONTEXT_ID = "general"

/** Gecko's cookie-store context for private tabs. Never inherits [GENERAL_CONTEXT_ID]. */
const val PRIVATE_CONTEXT_ID = "private"

/** What a routing snapshot says will happen to a context's traffic. */
enum class RoutingVerdict {
    /** No snapshot to read. Not an answer — the caller must not treat it as direct. */
    UNKNOWN,

    /** Resolves to no proxy: the traffic goes out on a direct connection. */
    DIRECT,

    /** Routed through a proxy that has published an endpoint. */
    LIVE,

    /**
     * Routed through a proxy with no endpoint that the app says is still coming
     * up. The extension holds these requests rather than failing them, so a
     * launch may go ahead on this.
     */
    STARTING,

    /**
     * Routed through a proxy with no endpoint and nothing bringing it up. The
     * extension blocks: a launch on this verdict is an error page.
     */
    BLOCKED,
}

/**
 * Reads a routing snapshot the way the proxy extension's `Store` does.
 *
 * Native has two of these to read and no way to ask the extension about either:
 * the persisted seed (what this profile routed through last time it ran) and
 * the live snapshot the app has pushed in this process. Both are the same JSON
 * shape, so the resolution rules live here once — and they have to be *the same*
 * rules, because a launch decided by a different reading of the same snapshot
 * than the extension's is a launch that fails in a way nothing here predicted.
 */
internal object RoutingResolution {
    /**
     * The proxy ids carrying [contextId], or null when the snapshot names none —
     * which is a direct connection, not an absent answer.
     *
     * Mirrors `Store.getEffectiveRelation`: an explicit entry wins, every context
     * except [PRIVATE_CONTEXT_ID] falls back to the general one, and an empty
     * list is an explicit direct connection.
     */
    private fun relationFor(snapshot: JSONObject, contextId: String): List<String>? {
        val relations = snapshot.optJSONObject("relations") ?: return null

        if (relations.has(contextId)) {
            return relations.optJSONArray(contextId).toStringList()
        }
        if (contextId != PRIVATE_CONTEXT_ID && relations.has(GENERAL_CONTEXT_ID)) {
            return relations.optJSONArray(GENERAL_CONTEXT_ID).toStringList()
        }

        // No entry anywhere: distinct from an entry holding an empty list, which
        // is an explicit direct connection.
        return null
    }

    private fun liveProxyIds(snapshot: JSONObject): Set<String> {
        val proxies = snapshot.optJSONArray("proxies") ?: return emptySet()
        return buildSet {
            for (index in 0 until proxies.length()) {
                proxies.optJSONObject(index)?.optString("id")?.takeIf { it.isNotEmpty() }
                    ?.let(::add)
            }
        }
    }

    private fun awaitingProxyIds(snapshot: JSONObject): Set<String> =
        snapshot.optJSONArray("awaitingProxies").toStringSet()

    /**
     * The proxy ids carrying [contextId] that [snapshot] has no endpoint for —
     * exactly what would have to start for the context to stop being blocked.
     *
     * Empty whenever there is nothing to start: no snapshot, a direct context,
     * or a relation that already resolves to a live proxy. Ids the snapshot
     * says are still coming up are deliberately included: a launch that arrives
     * while a start is in flight names the same backend, and the app half
     * treats a start it is already running as a no-op.
     */
    fun blockedProxyIds(snapshot: JSONObject?, contextId: String): List<String> {
        if (snapshot == null) return emptyList()

        val relation = relationFor(snapshot, contextId) ?: return emptyList()
        if (relation.isEmpty()) return emptyList()

        val live = liveProxyIds(snapshot)
        if (relation.any { it in live }) return emptyList()

        return relation
    }

    /** What [snapshot] means for traffic in [contextId]. */
    fun verdict(snapshot: JSONObject?, contextId: String): RoutingVerdict {
        if (snapshot == null) return RoutingVerdict.UNKNOWN

        val relation = relationFor(snapshot, contextId) ?: return RoutingVerdict.DIRECT
        if (relation.isEmpty()) return RoutingVerdict.DIRECT

        val live = liveProxyIds(snapshot)
        if (relation.any { it in live }) return RoutingVerdict.LIVE

        val awaiting = awaitingProxyIds(snapshot)
        return if (relation.any { it in awaiting }) {
            RoutingVerdict.STARTING
        } else {
            RoutingVerdict.BLOCKED
        }
    }
}
