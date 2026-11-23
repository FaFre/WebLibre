/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.push

import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycleRegistry
import eu.weblibre.flutter_mozilla_components.lifecycle.UndeliveredPushCounts
import mozilla.components.support.base.log.logger.Logger
import org.mozilla.geckoview.StorageController

/**
 * Decides, from a push scope alone and without Gecko, whether a message or a
 * subscription change belongs to a restricted context (5.8 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`). GeckoView appends the
 * origin attributes to every scope (F8), and the engine patch decodes the
 * context from them statically (E7), so this runs before anything starts Gecko.
 */
object PushContextGate {
    private val logger = Logger("PushContextGate")

    /** What the gate decided for a scope. */
    sealed interface Verdict {
        /** Not restricted: deliver as usual. */
        object Deliver : Verdict

        /** Restricted: consume (a message) or defer (a subscription change). */
        data class Restricted(val contextId: String?) : Verdict
    }

    /** Swapped in tests; GeckoView's decoder otherwise. */
    @Volatile
    internal var decode: (String) -> String? = { StorageController.sessionContextIdFromOriginSuffix(it) }

    @Volatile
    internal var isRestricted: (String?) -> Boolean = { TabLifecycleRegistry.isRestricted(it) }

    @Volatile
    internal var anyRestricted: () -> Boolean = { TabLifecycleRegistry.anyRestricted() }

    fun verdict(scope: String): Verdict {
        val contextId = try {
            decode(scope)
        } catch (e: IllegalArgumentException) {
            // Names a context that cannot be decoded: it may be a restricted
            // one, so it is treated as one while anything is restricted.
            logger.warn("Undecodable push scope context; restricted while anything is", e)
            return if (anyRestricted()) Verdict.Restricted(null) else Verdict.Deliver
        }
        return if (isRestricted(contextId)) Verdict.Restricted(contextId) else Verdict.Deliver
    }

    /**
     * Whether a message for [scope] is consumed unread because its context is
     * restricted; the context's skipped count goes up when it is (D14).
     */
    fun consumeIfRestricted(scope: String): Boolean = consumeIfRestricted(scope) { true } == true

    /**
     * [consumeIfRestricted] for a queued message, which [complete] takes off
     * its queue: counted only once that succeeded, so that a retry after a
     * failed completion does not count it again. Null when the completion
     * failed, and nothing was counted.
     */
    fun consumeIfRestricted(scope: String, complete: () -> Boolean): Boolean? {
        val verdict = verdict(scope) as? Verdict.Restricted ?: return false
        if (!complete()) return null
        verdict.contextId?.let { UndeliveredPushCounts.increment(it) }
        return true
    }

    /**
     * What a deferred subscription change of an undecodable scope is filed
     * under: it may belong to any context, so it waits until none is
     * restricted ([isDeferralRestricted]).
     */
    const val ANY_CONTEXT = TabLifecycleRegistry.ALL_CONTEXTS

    /**
     * Whether a subscription change deferred for [contextId] still has to
     * wait: its context is restricted, or, filed under [ANY_CONTEXT], any is.
     */
    fun isDeferralRestricted(contextId: String): Boolean =
        if (contextId == ANY_CONTEXT) anyRestricted() else isRestricted(contextId)

    /** The context [scope] names, or null for the default context or an undecodable one. */
    fun contextOf(scope: String): String? = runCatching { decode(scope) }.getOrNull()

    internal fun resetForTest() {
        decode = { StorageController.sessionContextIdFromOriginSuffix(it) }
        isRestricted = { TabLifecycleRegistry.isRestricted(it) }
        anyRestricted = { TabLifecycleRegistry.anyRestricted() }
    }
}
