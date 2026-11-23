/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import java.util.concurrent.ConcurrentHashMap
import mozilla.components.concept.engine.EngineSession

/**
 * The session contexts the engine restricts (container freeze), and the tabs
 * whose session was linked while their context was restricted.
 *
 * Such a session never shows the tab's page: Gecko refuses its history restore
 * (E8), so it holds an empty `about:blank` with no history, and its first state
 * update would replace the tab's saved state, losing the tab's history for good
 * (found in spike S1). [TabLifecycleGuardMiddleware] therefore drops state
 * updates from these sessions, and [release] names their tabs, so whoever lifts
 * the restriction can unload them; they then restore from the state that was
 * kept. Normally no such session exists, because nothing creates one in a
 * frozen container (B1–B5 in 3.6); this is the net under that.
 *
 * Process-wide like the engine's restrictions. A context is restricted when
 * [TabLifecycleRegistry] says so (container freeze), or when the debug spike
 * harness, which writes no record, [restrict]ed it. Thread-safe: the store's
 * middleware reads it, and whoever installs or lifts writes it.
 */
object RestrictedSessions {
    private class Linked(val contextId: String, val session: EngineSession)

    private val contexts: MutableSet<String> = ConcurrentHashMap.newKeySet()
    private val linkedWhileRestricted = ConcurrentHashMap<String, Linked>()

    /** The registry's predicate (5.6); swapped in tests. */
    @Volatile
    internal var registryRestricts: (String) -> Boolean = { TabLifecycleRegistry.isRestricted(it) }

    /** The engine now restricts [contextIds] without a registry record (the debug harness). */
    fun restrict(contextIds: Collection<String>) {
        contexts += contextIds
    }

    /**
     * The engine no longer restricts [contextIds]. Returns the tabs of those
     * contexts whose current session was linked while they were restricted:
     * unload them (their saved state was kept). They stay marked until their
     * session is unlinked.
     */
    fun release(contextIds: Collection<String>): List<String> {
        val released = contextIds.toSet()
        contexts -= released
        return linkedWhileRestricted.filterValues { it.contextId in released && !isRestricted(it.contextId) }
            .keys.toList()
    }

    fun isRestricted(contextId: String?): Boolean =
        contextId != null && (contextId in contexts || registryRestricts(contextId))

    /** Records [session] linked into [tabId]; true when its context is restricted. */
    internal fun onLinked(tabId: String, contextId: String?, session: EngineSession): Boolean {
        if (contextId != null && isRestricted(contextId)) {
            linkedWhileRestricted[tabId] = Linked(contextId, session)
            return true
        }
        linkedWhileRestricted.remove(tabId)
        return false
    }

    internal fun onUnlinked(tabIds: Collection<String>) {
        tabIds.forEach { linkedWhileRestricted.remove(it) }
    }

    /**
     * Whether the current session of [tabId] ([session], only looked up when
     * the tab has such a session at all) was linked while restricted.
     */
    internal fun wasLinkedWhileRestricted(tabId: String, session: () -> EngineSession?): Boolean {
        val linked = linkedWhileRestricted[tabId] ?: return false
        return linked.session === session()
    }

    fun resetForTest() {
        contexts.clear()
        linkedWhileRestricted.clear()
        registryRestricts = { TabLifecycleRegistry.isRestricted(it) }
    }
}
