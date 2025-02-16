package eu.lensai.flutter_mozilla_components.feature

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
import mozilla.components.support.webextensions.WebExtensionController
import org.json.JSONObject

object ContainerProxyFeature {
    private val logger = Logger("container_proxy")

    private const val CONTAINER_PROXY_REPORTER_EXTENSION_ID = "container-proxy@lensai.eu"
    private const val CONTAINER_PROXY_REPORTER_EXTENSION_URL = "resource://android/assets/extensions/container_proxy/"
    private const val CONTAINER_PROXY_REPORTER_MESSAGING_ID = "containerProxy"

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = WebExtensionController(
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

    private class ContainerProxyBackgroundMessageHandler() : MessageHandler {
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
            ContainerProxyBackgroundMessageHandler()
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
