/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import java.util.Collections
import java.util.WeakHashMap
import mozilla.components.concept.engine.EngineSession

/**
 * The engine sessions [WebLibreServiceWorkerDelegate] made for a service
 * worker's `clients.openWindow()`, until their tab is added, so that the tab
 * added event can say that the tab is such a window ([take]).
 *
 * Dart needs to know: the engine creates and selects the tab on its own, and
 * nothing else tells it from a tab an extension opens. Marked by the session,
 * which the tab carries in its add action, rather than by the tab's id, which
 * `addTab` returns only after the action may already have been handled.
 * Gecko only lets a service worker open a window while it handles a
 * notification click, so such a tab is always the page a tap opened.
 *
 * Weak, so a session whose tab was never added does not stay.
 */
object ServiceWorkerWindows {
    private val sessions: MutableSet<EngineSession> =
        Collections.newSetFromMap(WeakHashMap())

    /** Marks [session] as a service worker's window, before its tab is added. */
    @Synchronized
    fun mark(session: EngineSession) {
        sessions.add(session)
    }

    /** Whether [session], the engine session of a tab being added, is a service worker's window. Used up once. */
    @Synchronized
    fun take(session: EngineSession?): Boolean = session != null && sessions.remove(session)
}
