/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.util.Base64
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
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
    private val coroutineScope: CoroutineScope = MainScope(),
    stringDecoder: (String) -> ByteArray =
        { s -> Base64.decode(s.toByteArray(), Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP) },
    byteArrayEncoder: (ByteArray) -> String =
        { ba -> Base64.encodeToString(ba, Base64.URL_SAFE or Base64.NO_PADDING or Base64.NO_WRAP) },
) : PushObserver {

    private var handler: WebPushHandler? = null
    private val delegate = WebPushEngineDelegate(pushFeature, stringDecoder, byteArrayEncoder)

    fun start() {
        handler = engine.registerWebPushDelegate(delegate)
        pushFeature.register(this)
    }

    fun stop() {
        pushFeature.unregister(this)
    }

    override fun onMessageReceived(scope: PushScope, message: ByteArray?) {
        coroutineScope.launch {
            handler?.onPushMessage(scope, message)
        }
    }

    override fun onSubscriptionChanged(scope: PushScope) {
        coroutineScope.launch {
            handler?.onSubscriptionChanged(scope)
        }
    }
}

internal class WebPushEngineDelegate(
    private val pushFeature: PushSubscriptionProcessor,
    private val stringDecoder: (String) -> ByteArray,
    private val byteArrayEncoder: (ByteArray) -> String,
) : WebPushDelegate {
    private val logger = Logger("WebPushEngineDelegate")

    override fun onGetSubscription(scope: String, onSubscription: (WebPushSubscription?) -> Unit) {
        pushFeature.getSubscription(scope) {
            onSubscription(it?.toEnginePushSubscription(stringDecoder))
        }
    }

    override fun onSubscribe(
        scope: String,
        serverKey: ByteArray?,
        onSubscribe: (WebPushSubscription?) -> Unit,
    ) {
        pushFeature.subscribe(
            scope = scope,
            appServerKey = serverKey?.let { byteArrayEncoder(it) },
            onSubscribeError = {
                logger.error("Error on push onSubscribe.")
                onSubscribe(null)
            },
            onSubscribe = { subscription ->
                onSubscribe(subscription.toEnginePushSubscription(stringDecoder))
            },
        )
    }

    override fun onUnsubscribe(scope: String, onUnsubscribe: (Boolean) -> Unit) {
        pushFeature.unsubscribe(
            scope = scope,
            onUnsubscribeError = {
                logger.error("Error on push onUnsubscribe.")
                onUnsubscribe(false)
            },
            onUnsubscribe = {
                onUnsubscribe(it)
            },
        )
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
