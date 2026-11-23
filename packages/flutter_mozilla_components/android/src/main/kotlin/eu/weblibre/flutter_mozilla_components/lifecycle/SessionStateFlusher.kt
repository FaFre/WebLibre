/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import mozilla.components.browser.engine.gecko.GeckoEngineSession
import mozilla.components.concept.engine.EngineSession

/** Saves a session's state and says when that has reached the store. */
fun interface SessionStateFlusher {
    /**
     * Calls [onComplete] on the main thread: true once the flushed state has
     * reached the session's observers (and so the store), false when it could
     * not be flushed. May never call it when the session goes away first.
     */
    fun flush(session: EngineSession, onComplete: (Boolean) -> Unit)
}

/**
 * GeckoView's flush with its completion: E6 (`gecko-weblibre-session-flush.patch`)
 * through AC hunk A2 (`a-c-weblibre-tab-lifecycle.patch`). A session that is not
 * GeckoView's cannot report one.
 */
object GeckoSessionStateFlusher : SessionStateFlusher {
    override fun flush(session: EngineSession, onComplete: (Boolean) -> Unit) {
        val gecko = session as? GeckoEngineSession
        if (gecko == null) {
            onComplete(false)
            return
        }
        gecko.flushSessionState(onComplete)
    }
}
