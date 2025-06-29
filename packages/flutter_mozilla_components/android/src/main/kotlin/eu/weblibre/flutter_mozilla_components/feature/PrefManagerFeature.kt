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

object PrefManagerFeature {
    private val logger = Logger("pref-manager")

    private const val PREF_MANAGER_REPORTER_EXTENSION_ID = "pref-manager@weblibre.eu"
    private const val PREF_MANAGER_REPORTER_EXTENSION_URL = "resource://android/assets/extensions/pref_manager/"
    private const val PREF_MANAGER_REPORTER_MESSAGING_ID = "prefManager"

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, ResultConsumer<JSONObject>>()
    private val mutex = Mutex()

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        PREF_MANAGER_REPORTER_EXTENSION_ID,
        PREF_MANAGER_REPORTER_EXTENSION_URL,
        PREF_MANAGER_REPORTER_MESSAGING_ID,
    )

    fun scheduleRequest(command: String, args: Any, callback: ResultConsumer<JSONObject>) {
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

    private class PrefManagerReporterBackgroundMessageHandler() : MessageHandler {
        override fun onPortMessage(message: Any, port: Port) {
            runBlocking {
                withContext(Dispatchers.Default) {
                    mutex.withLock {
                        val messageJSON = message as JSONObject;

                        val requestId = messageJSON.getInt("id")
                        val status = messageJSON.getString("status")
                        if (status == "success") {
                            requestHandlers[requestId]?.success(message)
                        } else {
                            requestHandlers[requestId]?.error(
                                "Pref Manager",
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
            PrefManagerReporterBackgroundMessageHandler(),
        )
        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed PrefManager webextension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install PrefManager webextension: ", throwable)
            },
        )
    }
}
