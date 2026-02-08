/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import androidx.annotation.VisibleForTesting
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONObject

interface ResultConsumer<T> {
    fun success(result: T)
    fun error(errorCode: String, errorMessage: String?, errorDetails: Any?)
}

/**
 * A feature that enables users to report site issues to Mozilla's Web Compatibility team for
 * further diagnosis.
 */
object CookieManagerFeature {
    private val logger = Logger("cookie-manager")

    private const val COOKIE_MANAGER_REPORTER_EXTENSION_ID = "cookie-manager@weblibre.eu"
    private const val COOKIE_MANAGER_REPORTER_EXTENSION_URL = "resource://android/assets/extensions/cookie-manager/"
    private const val COOKIE_MANAGER_REPORTER_MESSAGING_ID = "cookieManager"

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, ResultConsumer<JSONObject>>()
    private val mutex = Mutex()

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        COOKIE_MANAGER_REPORTER_EXTENSION_ID,
        COOKIE_MANAGER_REPORTER_EXTENSION_URL,
        COOKIE_MANAGER_REPORTER_MESSAGING_ID,
    )

    fun scheduleRequest(command: String, args: JSONObject, callback: ResultConsumer<JSONObject>) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                mutex.withLock {
                    message.put("id", nextRequestId)

                    requestHandlers[nextRequestId] = callback

                    nextRequestId += 1

                    extensionController.sendBackgroundMessage(message)
                }
            }
        }
    }

    private class CookieManagerReporterBackgroundMessageHandler() : MessageHandler {
        override fun onPortMessage(message: Any, port: Port) {
            runBlocking {
                withContext(Dispatchers.Default) {
                    mutex.withLock {
                        val messageJSON = message as JSONObject;

                        val requestId = messageJSON.getInt("id")
                        val status = messageJSON.getString("status")
                        val handler = requestHandlers.remove(requestId)
                        if (status == "success") {
                            handler?.success(message)
                        } else {
                            handler?.error(
                                "Cookie Manager",
                                "Failed to perform operation",
                                message.getString("error")
                            )
                        }
                    }
                }
            }
        }
    }

    /**
     * Installs the web extension in the runtime through the WebExtensionRuntime install method
     *
     * @param runtime a WebExtensionRuntime.
     * @param productName a custom product name used to automatically label reports. Defaults to
     * "android-components".
     */
    fun install(runtime: WebExtensionRuntime) {
        extensionController.registerBackgroundMessageHandler(
            CookieManagerReporterBackgroundMessageHandler(),
        )
        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed CookieManager webextension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install CookieManager webextension: ", throwable)
            },
        )
    }
}
