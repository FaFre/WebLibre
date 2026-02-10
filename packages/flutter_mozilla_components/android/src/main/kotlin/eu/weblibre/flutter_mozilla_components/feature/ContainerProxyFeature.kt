/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.ContainerSiteAssignment
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.org.json.tryGetString
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

object ContainerProxyFeature {
    private val logger = Logger("container_proxy")

    private const val CONTAINER_PROXY_REPORTER_EXTENSION_ID = "container-proxy@weblibre.eu"
    private const val CONTAINER_PROXY_REPORTER_EXTENSION_URL =
        "resource://android/assets/extensions/container_proxy/"
    private const val CONTAINER_PROXY_REPORTER_MESSAGING_ID = "containerProxy"

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, ResultConsumer<JSONObject>>()
    private val mutex = Mutex()

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        CONTAINER_PROXY_REPORTER_EXTENSION_ID,
        CONTAINER_PROXY_REPORTER_EXTENSION_URL,
        CONTAINER_PROXY_REPORTER_MESSAGING_ID,
    )

    fun scheduleRequest(command: String, args: Any) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                extensionController.sendBackgroundMessage(message)
            }
        }
    }

    fun scheduleRequestWithResponse(
        command: String,
        args: Any,
        callback: ResultConsumer<JSONObject>
    ) {
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

    private class ContainerProxyBackgroundMessageHandler(
        private var events: GeckoStateEvents
    ) : MessageHandler {
        override fun onPortMessage(message: Any, port: Port) {
            runBlocking {
                withContext(Dispatchers.Default) {
                    mutex.withLock {
                        val messageJSON = message as JSONObject;
                        val type = messageJSON.getString("type")

                        if (type == "healthcheck") {
                            val requestId = messageJSON.getInt("id")
                            val status = messageJSON.getString("status")
                            val handler = requestHandlers.remove(requestId)
                            if (status == "success") {
                                handler?.success(message)
                            } else {
                                handler?.error(
                                    "Container Proxy",
                                    "Failed to perform operation",
                                    message.getString("error")
                                )
                            }
                        } else if (type == "assignedSiteRequested") {
                            val requestId = messageJSON.getString("id")
                            val status = messageJSON.getString("status")
                            val details = messageJSON.getJSONObject("result")

                            if (status == "success") {
                                runOnUiThread {
                                    events.onContainerSiteAssignment(
                                        EventSequence.next(),
                                        ContainerSiteAssignment(
                                            requestId = requestId,
                                            tabId = components.core.store.state.selectedTabId,
                                            originUrl = details.tryGetString("originUrl"),
                                            url = details.getString("url"),
                                            blocked = details.getBoolean("blocked")
                                        )
                                    ) { _ -> }
                                }
                            }
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
    fun install(runtime: WebExtensionRuntime, events: GeckoStateEvents) {
        extensionController.registerBackgroundMessageHandler(
            ContainerProxyBackgroundMessageHandler(events)
        )
        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed ContainerProxy webextension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install ContainerProxy webextension: ", throwable)
            },
        )
    }
}
