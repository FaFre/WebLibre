/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

/**
 * "Open WebLibre to resume" in a web app or custom tab window whose storage
 * is frozen (D18): the page the window holds, the storage it holds it in and
 * whether it is private, for Dart to open the page in that same storage, as
 * a tab the owning container's freeze holds until its Resume (a private tab
 * for a private window).
 *
 * Kept in this process rather than put on the intent that opens WebLibre:
 * the browser activity is exported, so an extra any app can send must never
 * choose the storage a page opens in. Only the newest is kept; Dart takes it
 * once it runs, and again whenever WebLibre comes to the front.
 */
object FrozenWindowHandoffs {
    data class Handoff(val contextId: String, val url: String?, val private: Boolean)

    private var pending: Handoff? = null

    @Synchronized
    fun put(handoff: Handoff) {
        pending = handoff
    }

    /** The waiting handoff, taken: a second call answers null. */
    @Synchronized
    fun take(): Handoff? = pending.also { pending = null }
}
