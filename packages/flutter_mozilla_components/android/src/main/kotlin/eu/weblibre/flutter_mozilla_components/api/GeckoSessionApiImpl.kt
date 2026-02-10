/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.*
import kotlinx.coroutines.*
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.translate.TranslationOptions
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.feature.addons.logger
import eu.weblibre.flutter_mozilla_components.pigeons.TranslationOptions as PigeonTranslationOptions

/**
 * Implementation of GeckoSessionApi that manages browser session operations
 */
class GeckoSessionApiImpl : GeckoSessionApi {
    companion object {
        private const val TAG = "GeckoSessionApi"
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun getTabId(tabId: String?) = tabId ?: components.core.store.state.selectedTabId
    ?: throw IllegalStateException("No tab ID provided and no selected tab")

    override fun loadUrl(
        tabId: String?,
        url: String,
        flags: LoadUrlFlagsValue,
        additionalHeaders: Map<String, String>?
    ) {
        try {
            logger.debug("$TAG: Loading URL: $url for tab: $tabId")
            components.useCases.sessionUseCases.loadUrl(
                url = url,
                sessionId = getTabId(tabId),
                flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
                additionalHeaders = additionalHeaders
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to load URL", e)
            throw e
        }
    }

    override fun loadData(tabId: String?, data: String, mimeType: String, encoding: String) {
        try {
            logger.debug("$TAG: Loading data with mimeType: $mimeType for tab: $tabId")
            components.useCases.sessionUseCases.loadData(
                data = data,
                tabId = getTabId(tabId),
                mimeType = mimeType,
                encoding = encoding
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to load data", e)
            throw e
        }
    }

    override fun reload(tabId: String?, flags: LoadUrlFlagsValue) {
        try {
            logger.debug("$TAG: Reloading tab: $tabId")
            components.useCases.sessionUseCases.reload(
                tabId = getTabId(tabId),
                flags = EngineSession.LoadUrlFlags.select(flags.value.toInt())
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to reload", e)
            throw e
        }
    }

    override fun stopLoading(tabId: String?) {
        try {
            logger.debug("$TAG: Stopping loading for tab: $tabId")
            components.useCases.sessionUseCases.stopLoading(tabId = getTabId(tabId))
        } catch (e: Exception) {
            logger.error("$TAG: Failed to stop loading", e)
            throw e
        }
    }

    override fun goBack(tabId: String?, userInteraction: Boolean) {
        try {
            logger.debug("$TAG: Going back in tab: $tabId")
            components.useCases.sessionUseCases.goBack(
                tabId = getTabId(tabId),
                userInteraction = userInteraction
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to go back", e)
            throw e
        }
    }

    override fun goForward(tabId: String?, userInteraction: Boolean) {
        try {
            logger.debug("$TAG: Going forward in tab: $tabId")
            components.useCases.sessionUseCases.goForward(
                tabId = getTabId(tabId),
                userInteraction = userInteraction
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to go forward", e)
            throw e
        }
    }

    override fun goToHistoryIndex(index: Long, tabId: String?) {
        try {
            logger.debug("$TAG: Going to history index $index in tab: $tabId")
            components.useCases.sessionUseCases.goToHistoryIndex(
                tabId = getTabId(tabId),
                index = index.toInt()
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to go to history index", e)
            throw e
        }
    }

    override fun requestDesktopSite(tabId: String?, enable: Boolean) {
        try {
            logger.debug("$TAG: Setting desktop site to $enable for tab: $tabId")
            components.useCases.sessionUseCases.requestDesktopSite(
                tabId = getTabId(tabId),
                enable = enable
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to request desktop site", e)
            throw e
        }
    }

    override fun exitFullscreen(tabId: String?) {
        try {
            logger.debug("$TAG: Exiting fullscreen for tab: $tabId")
            components.useCases.sessionUseCases.exitFullscreen(tabId = getTabId(tabId))
        } catch (e: Exception) {
            logger.error("$TAG: Failed to exit fullscreen", e)
            throw e
        }
    }

    override fun saveToPdf(tabId: String?) {
        try {
            logger.debug("$TAG: Saving to PDF for tab: $tabId")
            components.useCases.sessionUseCases.saveToPdf(tabId = getTabId(tabId))
        } catch (e: Exception) {
            logger.error("$TAG: Failed to save to PDF", e)
            throw e
        }
    }

    override fun printContent(tabId: String?) {
        try {
            logger.debug("$TAG: Printing content for tab: $tabId")
            components.useCases.sessionUseCases.printContent(tabId = getTabId(tabId))
        } catch (e: Exception) {
            logger.error("$TAG: Failed to print content", e)
            throw e
        }
    }

    override fun translate(
        tabId: String?,
        fromLanguage: String,
        toLanguage: String,
        options: PigeonTranslationOptions?
    ) {
        try {
            logger.debug("$TAG: Translating from $fromLanguage to $toLanguage for tab: $tabId")
            components.useCases.sessionUseCases.translate(
                tabId = getTabId(tabId),
                fromLanguage = fromLanguage,
                toLanguage = toLanguage,
                options = options?.let { TranslationOptions(downloadModel = it.downloadModel) }
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to translate", e)
            throw e
        }
    }

    override fun translateRestore(tabId: String?) {
        try {
            logger.debug("$TAG: Restoring translation for tab: $tabId")
            components.useCases.sessionUseCases.translateRestore(tabId = getTabId(tabId))
        } catch (e: Exception) {
            logger.error("$TAG: Failed to restore translation", e)
            throw e
        }
    }

    override fun crashRecovery(tabIds: List<String>?) {
        try {
            logger.debug("$TAG: Performing crash recovery for tabs: $tabIds")
            if (tabIds != null) {
                components.useCases.sessionUseCases.crashRecovery.invoke(tabIds = tabIds)
            } else {
                components.useCases.sessionUseCases.crashRecovery.invoke()
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to perform crash recovery", e)
            throw e
        }
    }

    override fun purgeHistory() {
        try {
            logger.debug("$TAG: Purging history")
            components.useCases.sessionUseCases.purgeHistory()
        } catch (e: Exception) {
            logger.error("$TAG: Failed to purge history", e)
            throw e
        }
    }

    override fun updateLastAccess(tabId: String?, lastAccess: Long?) {
        try {
            val timestamp = lastAccess ?: System.currentTimeMillis()
            logger.debug("$TAG: Updating last access time to $timestamp for tab: $tabId")
            components.useCases.sessionUseCases.updateLastAccess(
                tabId = getTabId(tabId),
                lastAccess = timestamp
            )
        } catch (e: Exception) {
            logger.error("$TAG: Failed to update last access", e)
            throw e
        }
    }

    override fun requestScreenshot(sendBack: Boolean, callback: (Result<ByteArray?>) -> Unit) {
        try {
            val tab = components.core.store.state.selectedTab
            if (tab == null) {
                logger.warn("$TAG: No selected tab for screenshot")
                callback(Result.failure(IllegalStateException("No selected tab for screenshot")))
                return
            }

            components.mainBrowserEngineView?.captureThumbnail { bitmap ->
                try {
                    if (bitmap != null) {
                        components.core.store.dispatch(ContentAction.UpdateThumbnailAction(tab.id, bitmap))
                        if (sendBack) {
                            val compressed = bitmap.toWebPBytes()
                            logger.debug("$TAG: Screenshot captured successfully")
                            callback(Result.success(compressed))
                        } else {
                            callback(Result.success(null))
                        }
                    } else {
                        logger.warn("$TAG: Failed to capture screenshot - null bitmap")
                        callback(Result.success(null))
                    }
                } catch (e: Exception) {
                    logger.error("$TAG: Failed to process screenshot", e)
                    callback(Result.failure(e))
                }
            } ?: run {
                logger.warn("$TAG: No engine view available for screenshot")
                callback(Result.failure(IllegalStateException("No engine view available")))
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to request screenshot", e)
            callback(Result.failure(e))
        }
    }
}
