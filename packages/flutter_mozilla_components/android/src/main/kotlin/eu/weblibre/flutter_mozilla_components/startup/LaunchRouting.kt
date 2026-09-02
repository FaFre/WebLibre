/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

import eu.weblibre.flutter_mozilla_components.feature.GENERAL_CONTEXT_ID
import eu.weblibre.flutter_mozilla_components.feature.PRIVATE_CONTEXT_ID
import eu.weblibre.flutter_mozilla_components.feature.RoutingVerdict

/** What to do with a Custom Tab / PWA launch, given what routing is known. */
enum class LaunchRoutingPlan {
    /**
     * Serve the launch as it is. Either routing says this context connects
     * directly — which a process with no app half can honour on its own — or the
     * app is already here and its routing covers the launch.
     */
    PROCEED,

    /**
     * Start the app half first. The launch needs a proxy, and only the app can
     * bring one up; a headless process would serve it an error page instead.
     */
    BOOTSTRAP,

    /**
     * Hand the launch to the ordinary browser. Routing is known and says this
     * context is blocked, so the page cannot load — but the browser has the
     * "start this proxy?" recovery and the user can act on it there, which is
     * more than a proxy error page in a Custom Tab window offers.
     */
    OPEN_IN_BROWSER,
}

/**
 * Decides whether a headless launch can be served without the app.
 *
 * The cost of getting this wrong runs both ways, which is why it is a decision
 * and not a default: bootstrapping every launch would put a Flutter engine and
 * a full component set behind every Custom Tab, and bootstrapping none leaves a
 * PWA in a proxied container permanently on an error page (nothing in a
 * headless process can start sing-box or Tor, so the extension's block is both
 * correct and final).
 */
object LaunchRouting {
    /**
     * The cookie-store context a launch's traffic will be keyed on.
     *
     * Matches what the session is actually created with — [PRIVATE_CONTEXT_ID]
     * for a private launch, the PWA's own context when it carries one, and the
     * general context for everything else — because a plan made for a different
     * context than the request carries is a plan about someone else's routing.
     */
    fun contextIdFor(pwaContextId: String?, isPrivate: Boolean): String {
        if (isPrivate) return PRIVATE_CONTEXT_ID
        return pwaContextId?.takeIf { it.isNotEmpty() } ?: GENERAL_CONTEXT_ID
    }

    /**
     * [installed] is what the app has pushed in *this* process (UNKNOWN when it
     * has pushed nothing, which is every headless start). [persisted] is what
     * the same profile routed through last time it ran.
     *
     * The persisted answer is only ever used to decide whether the app is
     * needed, never to route anything: it is a snapshot with no endpoints, so
     * the only thing it can say with authority is "this context was direct", and
     * that is the one answer that lets a launch skip the app entirely. Anything
     * else — proxied last time, or no record at all — takes the safe side.
     */
    fun plan(installed: RoutingVerdict, persisted: RoutingVerdict): LaunchRoutingPlan {
        return when (installed) {
            // The app is here and its routing covers this launch. STARTING is
            // deliberately good enough: the extension holds those requests until
            // the backend comes up, so the page loads a moment late rather than
            // not at all.
            RoutingVerdict.DIRECT,
            RoutingVerdict.LIVE,
            RoutingVerdict.STARTING,
            -> LaunchRoutingPlan.PROCEED

            // The app is here and says nothing is bringing this route up.
            RoutingVerdict.BLOCKED -> LaunchRoutingPlan.OPEN_IN_BROWSER

            RoutingVerdict.UNKNOWN -> when (persisted) {
                RoutingVerdict.DIRECT -> LaunchRoutingPlan.PROCEED
                else -> LaunchRoutingPlan.BOOTSTRAP
            }
        }
    }
}
