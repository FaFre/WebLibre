/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.delay
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.concept.engine.webnotifications.WebNotification
import mozilla.components.concept.engine.webnotifications.WebNotificationDelegate
import mozilla.components.support.ktx.kotlin.getOrigin

/**
 * Wraps the engine's real [WebNotificationDelegate] so a headless push delivery
 * can stay alive until the service worker actually posts its notification.
 *
 * The web push handoff to Gecko returns no completion signal, so the service
 * worker's `event.waitUntil(... showNotification())` runs entirely
 * asynchronously. This coordinator lets the delivery observe the actual
 * [onShowNotification] callback instead of guessing a duration, forwarding the
 * notification to the real delegate unchanged.
 */
class WebNotificationDrainCoordinator : WebNotificationDelegate {
    @Volatile
    var delegate: WebNotificationDelegate? = null

    private val lock = Any()
    private var waiter: CompletableDeferred<Unit>? = null
    private var waitOrigin: String? = null

    override fun onShowNotification(webNotification: WebNotification): Deferred<Boolean> {
        signal(webNotification.sourceUrl?.getOrigin())
        // Preserve the engine's completion contract by returning the real
        // delegate's deferred; only fall back if wrapping failed.
        return delegate?.onShowNotification(webNotification) ?: CompletableDeferred(false)
    }

    override fun onCloseNotification(webNotification: WebNotification) {
        delegate?.onCloseNotification(webNotification)
    }

    /**
     * Run [deliver] (the push handoff to Gecko) and then keep the caller
     * suspended until a matching web notification is shown or [timeoutMillis]
     * elapses. When a notification is observed, wait a further [graceMillis] so
     * the delegate's asynchronous `notify` can land before the caller returns
     * and the process loses foreground priority.
     *
     * Origin matching is best-effort: if either the push [origin] or the
     * notification's origin cannot be derived, any shown notification satisfies
     * the wait. Deliveries are serialized under the profile lock, so at most one
     * drain is armed at a time.
     */
    suspend fun drainWhileDelivering(
        origin: String?,
        timeoutMillis: Long,
        graceMillis: Long,
        deliver: suspend () -> Unit,
    ) {
        val deferred = CompletableDeferred<Unit>()
        synchronized(lock) {
            waiter = deferred
            waitOrigin = origin
        }
        try {
            deliver()
            val shown = withTimeoutOrNull(timeoutMillis) {
                deferred.await()
                true
            } == true
            if (shown && graceMillis > 0) {
                delay(graceMillis)
            }
        } finally {
            synchronized(lock) {
                if (waiter === deferred) {
                    waiter = null
                    waitOrigin = null
                }
            }
        }
    }

    private fun signal(origin: String?) {
        synchronized(lock) {
            val pending = waiter ?: return
            val target = waitOrigin
            if (target == null || origin == null || target == origin) {
                pending.complete(Unit)
            }
        }
    }
}
