/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabsApi
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryMetadataKey as PigeonHistoryMetadataKey
import eu.weblibre.flutter_mozilla_components.pigeons.LoadUrlFlagsValue
import eu.weblibre.flutter_mozilla_components.pigeons.RecoverableBrowserState as PigeonRecoverableBrowserState
import eu.weblibre.flutter_mozilla_components.pigeons.RestoreLocation as PigeonRestoreLocation
import eu.weblibre.flutter_mozilla_components.pigeons.RecoverableTab as PigeonRecoverableTab
import eu.weblibre.flutter_mozilla_components.pigeons.SourceValue
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.FindResultState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryItem
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryState
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderableState
import eu.weblibre.flutter_mozilla_components.pigeons.RestoreLocation
import eu.weblibre.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.weblibre.flutter_mozilla_components.pigeons.TabContentState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import mozilla.components.browser.icons.BrowserIcons
import mozilla.components.browser.icons.IconRequest
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.LastMediaAccessState
import mozilla.components.browser.state.state.ReaderState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.state.recover.RecoverableTab
import mozilla.components.browser.state.state.recover.TabState
import mozilla.components.browser.thumbnails.storage.ThumbnailStorage
import mozilla.components.concept.base.images.ImageLoadRequest
import mozilla.components.concept.storage.HistoryMetadataKey
import mozilla.components.feature.tabs.TabsUseCases
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import mozilla.components.feature.addons.logger
import mozilla.components.concept.engine.EngineSession

class GeckoTabsApiImpl : GeckoTabsApi {
    companion object {
        private const val TAG = "GeckoTabsApi"
        private val coroutineScope = CoroutineScope(Dispatchers.Default)
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun restoreSource(source: SourceValue): SessionState.Source {
        return SessionState.Source.restore(
            source.id.toInt(),
            source.caller?.packageId,
            source.caller?.category?.value?.toInt()
        )
    }

    private fun mapTab(tab: PigeonRecoverableTab): RecoverableTab {
        return RecoverableTab(
            engineSessionState = tab.engineSessionStateJson?.let { json ->
                components.core.engine.createSessionState(JSONObject(json))
            },
            state = TabState(
                id = tab.state.id,
                url = tab.state.url,
                parentId = tab.state.parentId,
                title = tab.state.title,
                searchTerm = tab.state.searchTerm,
                contextId = tab.state.contextId,
                readerState = ReaderState(
                    readerable = tab.state.readerState.readerable,
                    active = tab.state.readerState.active,
                    checkRequired = tab.state.readerState.checkRequired,
                    connectRequired = tab.state.readerState.connectRequired,
                    baseUrl = tab.state.readerState.baseUrl,
                    activeUrl = tab.state.readerState.activeUrl,
                    scrollY = tab.state.readerState.scrollY?.toInt()
                ),
                lastAccess = tab.state.lastAccess,
                createdAt = tab.state.createdAt,
                lastMediaAccessState = LastMediaAccessState(
                    lastMediaUrl = tab.state.lastMediaAccessState.lastMediaUrl,
                    lastMediaAccess = tab.state.lastMediaAccessState.lastMediaAccess,
                    mediaSessionActive = tab.state.lastMediaAccessState.mediaSessionActive
                ),
                private = tab.state.private,
                historyMetadata = tab.state.historyMetadata?.let { metadata ->
                    HistoryMetadataKey(
                        url = metadata.url,
                        searchTerm = metadata.searchTerm,
                        referrerUrl = metadata.referrerUrl
                    )
                },
                source = restoreSource(tab.state.source),
                index = tab.state.index.toInt(),
                hasFormData = tab.state.hasFormData
            )
        )
    }

    private fun mapRestoreLocation(location: PigeonRestoreLocation): TabListAction.RestoreAction.RestoreLocation {
        return when(location) {
            RestoreLocation.BEGINNING -> TabListAction.RestoreAction.RestoreLocation.BEGINNING
            RestoreLocation.END -> TabListAction.RestoreAction.RestoreLocation.END
            RestoreLocation.AT_INDEX -> TabListAction.RestoreAction.RestoreLocation.AT_INDEX
        }
    }

    private suspend fun handleIconChange(tab: SessionState) {
        try {
            val iconBytes: ByteArray?
            if (tab.content.icon != null) {
                iconBytes = tab.content.icon?.toWebPBytes()
            } else {
                iconBytes = null
            }

            withContext(Dispatchers.Main) {
                components.flutterEvents.onIconChange(
                    System.currentTimeMillis(),
                    tab.id,
                    iconBytes
                ) { }
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to handle icon change for tab ${tab.id}", e)
        }
    }

    private suspend fun handleThumbnailChange(tab: SessionState) {
        try {
            val bitmap = components.core.thumbnailStorage.loadThumbnail(
                ImageLoadRequest(
                    id = tab.id,
                    size = 1024,
                    isPrivate = tab.content.private
                )
            ).await()

            bitmap?.let {
                val bytes = it.toWebPBytes()
                withContext(Dispatchers.Main) {
                    components.flutterEvents.onThumbnailChange(System.currentTimeMillis(), tab.id, bytes) { }
                }
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to handle thumbnail change for tab ${tab.id}", e)
        }
    }

    override fun syncEvents(
        onSelectedTabChange: Boolean,
        onTabListChange: Boolean,
        onTabContentStateChange: Boolean,
        onIconChange: Boolean,
        onSecurityInfoStateChange: Boolean,
        onReaderableStateChange: Boolean,
        onHistoryStateChange: Boolean,
        onFindResults: Boolean,
        onThumbnailChange: Boolean,
    ) {
        try {
            val tabs = components.core.store.state.tabs.map { it.copy() }
            val selectedTab = components.core.store.state.selectedTabId

            if (onSelectedTabChange) {
                components.flutterEvents.onSelectedTabChange(System.currentTimeMillis(), selectedTab) { }
            }

            if (onTabListChange) {
                components.flutterEvents.onTabListChange(System.currentTimeMillis(), tabs.map { it.id }) { }
            }

            tabs.forEach { tab ->
                if (onTabContentStateChange) {
                    components.flutterEvents.onTabContentStateChange(
                        System.currentTimeMillis(),
                        TabContentState(
                            id = tab.id,
                            parentId = tab.parentId,
                            contextId = tab.contextId,
                            url = tab.content.url,
                            title = tab.content.title,
                            progress = tab.content.progress.toLong(),
                            isPrivate = tab.content.private,
                            isFullScreen = tab.content.fullScreen,
                            isLoading = tab.content.loading
                        )
                    ) { }
                }

                if (onIconChange) {
                    coroutineScope.launch { handleIconChange(tab) }
                }

                if (onSecurityInfoStateChange) {
                    components.flutterEvents.onSecurityInfoStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        SecurityInfoState(
                            tab.content.securityInfo.isSecure,
                            tab.content.securityInfo.host,
                            tab.content.securityInfo.issuer
                        )
                    ) { }
                }

                if (onReaderableStateChange) {
                    components.flutterEvents.onReaderableStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        ReaderableState(
                            tab.readerState.readerable,
                            tab.readerState.active
                        )
                    ) { }
                }

                if (onHistoryStateChange) {
                    components.flutterEvents.onHistoryStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        HistoryState(
                            items = tab.content.history.items.map { item ->
                                HistoryItem(url = item.uri, title = item.title)
                            },
                            currentIndex = tab.content.history.currentIndex.toLong(),
                            canGoBack = tab.content.canGoBack,
                            canGoForward = tab.content.canGoForward
                        )
                    ) { }
                }

                if (onFindResults) {
                    components.flutterEvents.onFindResults(
                        System.currentTimeMillis(),
                        tab.id,
                        tab.content.findResults.map { result ->
                            FindResultState(
                                activeMatchOrdinal = result.activeMatchOrdinal.toLong(),
                                numberOfMatches = result.numberOfMatches.toLong(),
                                isDoneCounting = result.isDoneCounting
                            )
                        }
                    ) { }
                }

                if (onThumbnailChange) {
                    coroutineScope.launch { handleThumbnailChange(tab) }
                }
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to sync events", e)
        }
    }

    override fun selectTab(tabId: String) {
        try {
            components.useCases.tabsUseCases.selectTab(tabId = tabId)
            logger.debug("$TAG: Selected tab $tabId")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to select tab $tabId", e)
            throw e
        }
    }

    override fun removeTab(tabId: String) {
        try {
            components.useCases.tabsUseCases.removeTab(tabId = tabId)
            logger.debug("$TAG: Removed tab $tabId")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to remove tab $tabId", e)
            throw e
        }
    }

    override fun addTab(
        url: String,
        selectTab: Boolean,
        startLoading: Boolean,
        parentId: String?,
        flags: LoadUrlFlagsValue,
        contextId: String?,
        source: SourceValue,
        private: Boolean,
        historyMetadata: PigeonHistoryMetadataKey?,
        additionalHeaders: Map<String, String>?
    ): String {
        try {
            return components.useCases.tabsUseCases.addTab(
                url = url,
                selectTab = selectTab,
                startLoading = startLoading,
                parentId = parentId,
                flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
                contextId = contextId,
                source = restoreSource(source),
                private = private,
                historyMetadata = historyMetadata?.let { metadata ->
                    HistoryMetadataKey(
                        url = metadata.url,
                        searchTerm = metadata.searchTerm,
                        referrerUrl = metadata.referrerUrl
                    )
                },
                additionalHeaders = additionalHeaders
            ).also {
                logger.debug("$TAG: Added new tab with ID $it")
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to add tab", e)
            throw e
        }
    }

    override fun removeAllTabs(recoverable: Boolean) {
        try {
            components.useCases.tabsUseCases.removeAllTabs(recoverable = recoverable)
            logger.debug("$TAG: Removed all tabs, recoverable: $recoverable")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to remove all tabs", e)
            throw e
        }
    }

    override fun removeTabs(ids: List<String>) {
        try {
            components.useCases.tabsUseCases.removeTabs(ids = ids)
            logger.debug("$TAG: Removed tabs: ${ids.joinToString()}")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to remove tabs", e)
            throw e
        }
    }

    override fun removeNormalTabs() {
        try {
            components.useCases.tabsUseCases.removeNormalTabs()
            logger.debug("$TAG: Removed all normal tabs")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to remove normal tabs", e)
            throw e
        }
    }

    override fun removePrivateTabs() {
        try {
            components.useCases.tabsUseCases.removePrivateTabs()
            logger.debug("$TAG: Removed all private tabs")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to remove private tabs", e)
            throw e
        }
    }

    override fun undo() {
        try {
            components.useCases.tabsUseCases.undo()
            logger.debug("$TAG: Performed undo operation")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to perform undo", e)
            throw e
        }
    }

    override fun restoreTabsByList(
        tabs: List<PigeonRecoverableTab>,
        selectTabId: String?,
        restoreLocation: PigeonRestoreLocation
    ) {
        try {
            components.useCases.tabsUseCases.restore(
                tabs = tabs.map { mapTab(it) },
                restoreLocation = mapRestoreLocation(restoreLocation),
                selectTabId = selectTabId
            )
            logger.debug("$TAG: Restored ${tabs.size} tabs")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to restore tabs", e)
            throw e
        }
    }

    override fun restoreTabsByBrowserState(
        state: PigeonRecoverableBrowserState,
        restoreLocation: PigeonRestoreLocation
    ) {
        try {
            components.useCases.tabsUseCases.restore(
                state = RecoverableBrowserState(
                    selectedTabId = state.selectedTabId,
                    tabs = state.tabs.filterNotNull().map { mapTab(it) }
                ),
                restoreLocation = mapRestoreLocation(restoreLocation)
            )
            logger.debug("$TAG: Restored browser state")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to restore browser state", e)
            throw e
        }
    }

    override fun selectOrAddTabByHistory(
        url: String,
        historyMetadata: PigeonHistoryMetadataKey
    ): String {
        try {
            return components.useCases.tabsUseCases.selectOrAddTab(
                url = url,
                historyMetadata = HistoryMetadataKey(
                    url = historyMetadata.url,
                    searchTerm = historyMetadata.searchTerm,
                    referrerUrl = historyMetadata.referrerUrl
                )
            ).also {
                logger.debug("$TAG: Selected or added tab by history with ID $it")
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to select or add tab by history", e)
            throw e
        }
    }

    override fun selectOrAddTabByUrl(
        url: String,
        private: Boolean,
        source: SourceValue,
        flags: LoadUrlFlagsValue,
        ignoreFragment: Boolean
    ): String {
        try {
            return components.useCases.tabsUseCases.selectOrAddTab(
                url = url,
                private = private,
                source = restoreSource(source),
                flags = EngineSession.LoadUrlFlags.select(flags.value.toInt()),
                ignoreFragment = ignoreFragment
            ).also {
                logger.debug("$TAG: Selected or added tab by URL with ID $it")
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to select or add tab by URL", e)
            throw e
        }
    }

    override fun duplicateTab(
        selectTabId: String?,
        selectNewTab: Boolean,
        newContextId: String?
    ): String {
        try {
            val tabState = selectTabId?.let { components.core.store.state.findTab(it) }
                ?: throw IllegalArgumentException("Tab not found")

            val duplicate = createTab(
                url = tabState.content.url,
                private = tabState.content.private,
                contextId = newContextId,
                parent = tabState,
                engineSessionState = tabState.engineState.engineSessionState,
            )

            components.core.store.dispatch(
                TabListAction.AddTabAction(
                    duplicate,
                    select = selectNewTab,
                ),
            )

            logger.debug("$TAG: Duplicated tab $selectTabId to new tab ${duplicate.id}")

            return duplicate.id
        } catch (e: Exception) {
            logger.error("$TAG: Failed to duplicate tab", e)
            throw e
        }
    }

    override fun moveTabs(tabIds: List<String>, targetTabId: String, placeAfter: Boolean) {
        try {
            components.useCases.tabsUseCases.moveTabs(
                tabIds = tabIds,
                targetTabId = targetTabId,
                placeAfter = placeAfter
            )
            logger.debug("$TAG: Moved tabs ${tabIds.joinToString()} to $targetTabId")
        } catch (e: Exception) {
            logger.error("$TAG: Failed to move tabs", e)
            throw e
        }
    }

    override fun migratePrivateTabUseCase(tabId: String, alternativeUrl: String?): String {
        try {
            return components.useCases.tabsUseCases.migratePrivateTabUseCase(
                tabId = tabId,
                alternativeUrl = alternativeUrl
            ).also {
                logger.debug("$TAG: Migrated private tab $tabId")
            }
        } catch (e: Exception) {
            logger.error("$TAG: Failed to migrate private tab", e)
            throw e
        }
    }
}
