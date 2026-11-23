/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.util.Base64
import eu.weblibre.flutter_mozilla_components.lifecycle.PushOutbox
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.webpush.WebPushDelegate
import mozilla.components.concept.engine.webpush.WebPushHandler
import mozilla.components.concept.engine.webpush.WebPushSubscription
import mozilla.components.support.base.log.logger.Logger
import org.ironfoxoss.unifiedpush.AutoPushSubscription
import org.ironfoxoss.unifiedpush.PushObserver
import org.ironfoxoss.unifiedpush.PushScope
import org.ironfoxoss.unifiedpush.PushSubscriptionProcessor
import org.ironfoxoss.unifiedpush.Pusher

/**
 * Engine integration with UnifiedPush-backed web push support.
 */
class WebPushEngineIntegration(
    private val engine: Engine,
    private val pushFeature: Pusher,
    /** [SubscriptionVersion] of a scope's row as stored now, read off the main thread. */
    private val rowVersion: suspend (PushScope) -> String,
    /** Runs its argument once push may be read, with false when its start failed. */
    whenReady: ((Boolean) -> Unit) -> Unit,
    private val coroutineScope: CoroutineScope = MainScope(),
    stringDecoder: (String) -> ByteArray =
        { s -> Base64.decode(s.toByteArray(), Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP) },
    byteArrayEncoder: (ByteArray) -> String =
        { ba -> Base64.encodeToString(ba, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP) },
) : PushObserver {

    private val logger = Logger("WebPushEngineIntegration")
    private var handler: WebPushHandler? = null
    private val delegate = WebPushEngineDelegate(pushFeature, whenReady, stringDecoder, byteArrayEncoder)

    fun start() {
        handler = engine.registerWebPushDelegate(delegate)
        pushFeature.register(this)
    }

    fun stop() {
        pushFeature.unregister(this)
    }

    suspend fun deliverMessage(scope: PushScope, payload: ByteArray?) {
        withContext(Dispatchers.Main.immediate) {
            if (skipForRestrictedContext(scope)) return@withContext
            checkNotNull(handler) { "Web push handler is not initialized" }
                .onPushMessage(scope, payload)
        }
    }

    /** The caller already emptied [scope]'s row. */
    suspend fun invalidateEndpoint(scope: PushScope) {
        withContext(Dispatchers.Main.immediate) {
            notifySubscriptionChanged(scope, SubscriptionVersion.NONE)
        }
    }

    /**
     * Hands the pending subscription changes of [contextIds] (every context
     * when null) to Gecko: deferred ones (D25) of contexts no longer
     * restricted and, with null, write-ahead ones a previous process left.
     * Each goes only once its row holds the version it was recorded for, and
     * is removed only after the handoff. Nothing happens without a handler; the
     * next drain delivers them.
     */
    suspend fun drainOutbox(contextIds: Collection<String>? = null) {
        if (handler == null) return
        val deliverable = PushOutbox.deliverable(PushContextGate::isDeferralRestricted)
        val chosen = if (contextIds == null) {
            deliverable
        } else {
            // Also those of no known context, once the last restriction
            // went with these.
            PushOutbox.scopesOf(contextIds + PushContextGate.ANY_CONTEXT).filter { it in deliverable }
        }
        if (chosen.isEmpty()) return

        // Read before the hop to main, where SQLite has no business. A row that
        // changes in between has recorded its own newer version, which the
        // handoff below then leaves in place.
        val stored = chosen.associateWith { rowVersion(it) }
        withContext(Dispatchers.Main.immediate) {
            val handler = handler ?: return@withContext
            chosen.forEach { scope ->
                // The same check as live delivery: a write-ahead entry a
                // death left behind was never deferred, though its context
                // may be frozen. It waits under that context instead.
                val verdict = PushContextGate.verdict(scope)
                if (verdict is PushContextGate.Verdict.Restricted) {
                    PushOutbox.defer(scope, verdict.contextId ?: PushContextGate.ANY_CONTEXT)
                    return@forEach
                }
                val version = stored.getValue(scope)
                val pending = PushOutbox.pendingVersion(scope)
                // Recorded but not written yet, or never written: telling Gecko
                // now would hand it the old row.
                if (pending != null && pending != version) return@forEach
                handler.onSubscriptionChanged(scope)
                PushOutbox.handedOff(scope, version)
            }
        }
    }

    /**
     * A subscription change goes to Gecko unless its context is restricted;
     * then it waits in the outbox until Resume (5.8). Transport state was
     * already updated by the caller, and [version] is what the row holds.
     */
    private fun notifySubscriptionChanged(scope: PushScope, version: String) {
        when (val verdict = PushContextGate.verdict(scope)) {
            PushContextGate.Verdict.Deliver -> handler?.let {
                it.onSubscriptionChanged(scope)
                PushOutbox.handedOff(scope, version)
            }
            is PushContextGate.Verdict.Restricted -> {
                // A scope whose context cannot be decoded waits until nothing
                // is restricted.
                val contextId = verdict.contextId ?: PushContextGate.ANY_CONTEXT
                if (!PushOutbox.defer(scope, contextId)) {
                    // Not written: dropping it would leave a stale subscription,
                    // so it is lost only if the process dies before a drain.
                    logger.warn("Could not defer a subscription change of a restricted context")
                }
            }
        }
    }

    /** A message for a restricted context is consumed and counted (D14). */
    private fun skipForRestrictedContext(scope: PushScope): Boolean {
        if (!PushContextGate.consumeIfRestricted(scope)) return false
        logger.info("Skipped a push message: its context is frozen")
        return true
    }

    fun close() {
        stop()
        handler = null
        coroutineScope.cancel()
    }

    override fun onMessageReceived(scope: PushScope, message: ByteArray?) {
        coroutineScope.launch {
            if (skipForRestrictedContext(scope)) return@launch
            handler?.onPushMessage(scope, message)
        }
    }

    override fun onSubscriptionChanged(scope: PushScope) {
        coroutineScope.launch {
            // The feature notifies after its row write, so the row is the
            // version Gecko's worker will read.
            notifySubscriptionChanged(scope, rowVersion(scope))
        }
    }
}

/**
 * Answers Gecko's subscription requests. Each waits for push's start, which may
 * have to clear restored endpoints first; a failed start answers "no
 * subscription" rather than exposing a transport that was never verified.
 * Private browsing gets no subscription at all ([PrivatePushScopes]).
 */
internal class WebPushEngineDelegate(
    private val pushFeature: PushSubscriptionProcessor,
    private val whenReady: ((Boolean) -> Unit) -> Unit,
    private val stringDecoder: (String) -> ByteArray,
    private val byteArrayEncoder: (ByteArray) -> String,
) : WebPushDelegate {
    private val logger = Logger("WebPushEngineDelegate")

    override fun onGetSubscription(scope: String, onSubscription: (WebPushSubscription?) -> Unit) {
        // Also one an earlier build stored and the start has not removed yet.
        if (PrivatePushScopes.isPrivate(scope)) return onSubscription(null)
        whenReady { ready ->
            if (!ready) return@whenReady onSubscription(null)
            pushFeature.getSubscription(scope) {
                onSubscription(it?.toEnginePushSubscription(stringDecoder))
            }
        }
    }

    override fun onSubscribe(
        scope: String,
        serverKey: ByteArray?,
        onSubscribe: (WebPushSubscription?) -> Unit,
    ) {
        if (PrivatePushScopes.isPrivate(scope)) {
            logger.info("Refused a push subscription of private browsing")
            return onSubscribe(null)
        }
        whenReady { ready ->
            if (!ready) return@whenReady onSubscribe(null)
            pushFeature.subscribe(
                scope = scope,
                appServerKey = serverKey?.let { byteArrayEncoder(it) },
                onSubscribeError = {
                    logger.error("Error on push onSubscribe.")
                    onSubscribe(null)
                },
                onSubscribe = { subscription ->
                    onSubscribe(subscription.toEnginePushSubscription(stringDecoder))
                    // The subscription this answer carries, not the row: a newer
                    // endpoint committed meanwhile keeps its own entry.
                    PushOutbox.handedOff(scope, SubscriptionVersion.of(subscription))
                },
            )
        }
    }

    override fun onUnsubscribe(scope: String, onUnsubscribe: (Boolean) -> Unit) {
        whenReady { ready ->
            if (!ready) return@whenReady onUnsubscribe(false)
            pushFeature.unsubscribe(
                scope = scope,
                onUnsubscribeError = {
                    logger.error("Error on push onUnsubscribe.")
                    onUnsubscribe(false)
                },
                onUnsubscribe = { removed ->
                    if (removed) PushOutbox.removed(scope)
                    onUnsubscribe(removed)
                },
            )
        }
    }
}

internal fun AutoPushSubscription.toEnginePushSubscription(stringDecoder: (String) -> ByteArray) = WebPushSubscription(
    scope = scope,
    publicKey = stringDecoder(publicKey),
    endpoint = endpoint,
    authSecret = stringDecoder(authKey),
    // The app server key is only available during subscription creation, so we preserve Gecko's
    // previous value by leaving it null for cached subscriptions.
    appServerKey = null,
)
