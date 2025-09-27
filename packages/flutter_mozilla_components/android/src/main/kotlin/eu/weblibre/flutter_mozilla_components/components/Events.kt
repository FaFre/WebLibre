/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import eu.weblibre.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.FindResultState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryItem
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryState
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderableState
import eu.weblibre.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.weblibre.flutter_mozilla_components.pigeons.TabContentState
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Store
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.ktx.kotlinx.coroutines.flow.filterChanged
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged

class Events(
    private val flutterEvents: GeckoStateEvents,
) {
    val readerViewEvents by lazy { ReaderViewEventsImpl() }
    
    @OptIn(FlowPreview::class)
    fun registerFlowEvents(stateFlow: Store<BrowserState, BrowserAction>) {
        stateFlow.flowScoped { flow ->
            flow.map { state -> state.selectedTabId }
                .distinctUntilChanged()
                .collect { tabId ->
                    flutterEvents.onSelectedTabChange(
                        System.currentTimeMillis(),
                        tabId
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content
                }
                .ifAnyChanged { arrayOf (it.content.icon) }
                .debounce { 16 }
                .collect { tab ->
                    val iconBytes = tab.content.icon?.toWebPBytes()
                    flutterEvents.onIconChange(
                        System.currentTimeMillis(),
                        tab.id,
                        iconBytes
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content.securityInfo
                }
                .debounce { 16 }
                .collect { tab ->
                    flutterEvents.onSecurityInfoStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        SecurityInfoState(
                            tab.content.securityInfo.secure,
                            tab.content.securityInfo.host,
                            tab.content.securityInfo.issuer,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.readerState
                }
                .ifAnyChanged { arrayOf(
                    it.readerState.readerable,
                    it.readerState.active,
                )
                }
                .debounce { 16 }
                .collect { tab ->
                    flutterEvents.onReaderableStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        ReaderableState(
                            tab.readerState.readerable,
                            tab.readerState.active,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content
                }
                .ifAnyChanged { arrayOf(
                    it.content.history,
                    it.content.canGoBack,
                    it.content.canGoForward,
                )
                }
                .debounce { 16 }
                .collect { tab ->
                    flutterEvents.onHistoryStateChange(
                        System.currentTimeMillis(),
                        tab.id,
                        HistoryState(
                            items = tab.content.history.items.map { item -> HistoryItem(
                                url = item.uri,
                                title = item.title
                            ) },
                            currentIndex = tab.content.history.currentIndex.toLong(),
                            canGoBack = tab.content.canGoBack,
                            canGoForward = tab.content.canGoForward,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs.map {tab -> tab.id} }
                .distinctUntilChanged()
                .collect { tabs ->
                    flutterEvents.onTabListChange(System.currentTimeMillis(), tabs) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content
                }
                .ifAnyChanged { arrayOf(
                    it.content.url,
                    it.content.title,
                    it.content.private,
                    it.content.fullScreen,
                    it.content.progress,
                    it.content.loading)
                }
                .debounce { 16 }
                .collect { tab ->
                    flutterEvents.onTabContentStateChange(
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
                    ) { _ -> }
                }
        }
    }
}