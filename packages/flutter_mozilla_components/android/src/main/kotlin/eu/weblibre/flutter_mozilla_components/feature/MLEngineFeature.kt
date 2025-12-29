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
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONObject

object MLEngineFeature {
    private val logger = Logger("ml-engine")

    private const val ML_ENGINE_REPORTER_EXTENSION_ID = "ml-engine@weblibre.eu"
    private const val ML_ENGINE_REPORTER_EXTENSION_URL = "resource://android/assets/extensions/ml_engine/"
    private const val ML_ENGINE_REPORTER_MESSAGING_ID = "mlEngine"

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, ResultConsumer<JSONObject>>()
    private val mutex = Mutex()

    // Progress callback for ML operations
    var progressCallback: ((JSONObject) -> Unit)? = null

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        ML_ENGINE_REPORTER_EXTENSION_ID,
        ML_ENGINE_REPORTER_EXTENSION_URL,
        ML_ENGINE_REPORTER_MESSAGING_ID,
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
                    val messageJSON = message as JSONObject;

                    // Check if this is a progress message
                    if (messageJSON.has("type") && messageJSON.getString("type") == "mlProgress") {
                        val progressData = messageJSON.getJSONObject("progress")
                        progressCallback?.invoke(progressData)
                        return@withContext
                    }

                    // Handle regular request/response messages
                    mutex.withLock {
                        val requestId = messageJSON.getInt("id")
                        val status = messageJSON.getString("status")
                        if (status == "success") {
                            requestHandlers[requestId]?.success(message)
                        } else {
                            requestHandlers[requestId]?.error(
                                "ML Engine",
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
                logger.debug("Installed ml-engine webextension: ${it.id}")

                grantPermissions(runtime, it)
            },
            onError = { throwable ->
                logger.error("Failed to install ml-engine webextension: ", throwable)
            },
        )
    }

    private fun grantPermissions(runtime: WebExtensionRuntime, extension: WebExtension) {
        val permissions = listOf("trialML")
        val origins = emptyList<String>() // Add any host permissions if needed

        runtime.addOptionalPermissions(
            ML_ENGINE_REPORTER_EXTENSION_ID,
            permissions,
            origins,
            onSuccess = { grantedExtension ->
                logger.debug("Successfully granted permissions to extension: ${grantedExtension.id}")
            },
            onError = { throwable ->
                logger.error("Failed to grant permissions to extension: ", throwable)
            }
        )
    }
}
