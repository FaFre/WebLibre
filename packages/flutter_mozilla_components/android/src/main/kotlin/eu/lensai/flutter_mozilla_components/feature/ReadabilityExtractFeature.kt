package eu.lensai.flutter_mozilla_components.feature

import eu.lensai.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.lensai.flutter_mozilla_components.pigeons.TabContent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.map
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.org.json.tryGetInt
import mozilla.components.support.ktx.android.org.json.tryGetString
import mozilla.components.support.ktx.kotlinx.coroutines.flow.filterChanged
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged
import mozilla.components.support.webextensions.WebExtensionController
import org.json.JSONObject

class ReadabilityExtractFeature(
    private var engine: Engine,
    private var store: BrowserStore,
    private var tabContentEvents: GeckoTabContentEvents
): LifecycleAwareFeature {
    companion object {
        private val logger = Logger("ReadabilityExtract")

        internal const val READER_EXTRACT_EXTENSION_ID = "readability-extract@movenext.me"
        internal const val READER_EXTRACT_CONTENT_PORT = "mozacReaderExtract"
        internal const val READER_EXTRACT_EXTENSION_URL =
            "resource://android/assets/extensions/readability_extract/"
    }

    private class ContentMessageHandler(
        private var tabContentEvents: GeckoTabContentEvents,
        private var tabId: String
    ) : MessageHandler {
        override fun onPortConnected(port: Port) {
            logger.debug("Port connected: ${port.name()}")
        }

        override fun onPortMessage(message: Any, port: Port) {
            if (message is JSONObject) {
                tabContentEvents.onContentUpdate(
                    System.currentTimeMillis(),
                    contentArg = TabContent(
                        tabId = tabId,
                        fullContentMarkdown = message.tryGetString("fullContentMarkdown"),
                        fullContentPlain = message.tryGetString("fullContentPlain"),
                        isProbablyReaderable = message.tryGetInt("isProbablyReaderable") == 1,
                        extractedContentMarkdown = message.tryGetString("extractedContentMarkdown"),
                        extractedContentPlain = message.tryGetString("extractedContentPlain")
                    )
                ) {}
            }
        }
    }

    private var sessionScope: CoroutineScope? = null
    private var historyScope: CoroutineScope? = null

    private var extensionController = WebExtensionController(
        READER_EXTRACT_EXTENSION_ID,
        READER_EXTRACT_EXTENSION_URL,
        READER_EXTRACT_CONTENT_PORT,
    )

    override fun start() {
        ensureExtensionInstalled()
    }

    override fun stop() {
        sessionScope?.cancel()
        historyScope?.cancel()
    }

    private fun ensureExtensionInstalled() {
        extensionController.install(
            engine,
            onSuccess = { extension ->
                sessionScope = store.flowScoped { flow ->
                    flow.map { it.tabs }
                        .filterChanged { it.engineState.engineSession }
                        .collect { state ->
                            val engineSession = state.engineState.engineSession ?: return@collect

                            if (extension.hasContentMessageHandler(engineSession, READER_EXTRACT_CONTENT_PORT)) {
                                return@collect
                            }

                            val handler = ContentMessageHandler(tabContentEvents, state.id)
                            extension.registerContentMessageHandler(engineSession, READER_EXTRACT_CONTENT_PORT, handler)
                        }
                }

                historyScope = store.flowScoped { flow ->
                    flow.map { it.tabs }
                        .filterChanged { it.content.history }
                        .ifAnyChanged { arrayOf(it.content.history.currentIndex) }
                        .collect { state ->
                            val engineSession = state.engineState.engineSession ?: return@collect

                            if(state.content.loading) {
                                return@collect
                            }

                            if (extension.hasContentMessageHandler(engineSession, READER_EXTRACT_CONTENT_PORT)) {
                                if(extensionController.portConnected(engineSession))  {
                                    extensionController.sendContentMessage(
                                        JSONObject().put("action", "parseContent"),
                                        engineSession
                                    )
                                }
                            }
                        }
                }
            },
            onError = { throwable ->
                Logger.error("Could not install $READER_EXTRACT_EXTENSION_ID extension", throwable)
            },
        )
    }
}