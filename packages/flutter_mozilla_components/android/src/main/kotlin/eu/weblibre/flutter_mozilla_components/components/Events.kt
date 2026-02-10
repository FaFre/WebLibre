/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.api.ReaderViewEventsImpl
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.ExternalApplicationResource
import eu.weblibre.flutter_mozilla_components.pigeons.FindResultState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.PwaIcon
import eu.weblibre.flutter_mozilla_components.pigeons.PwaManifest
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryItem
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryState
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderableState
import eu.weblibre.flutter_mozilla_components.pigeons.SecurityInfoState
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTarget
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetFiles
import eu.weblibre.flutter_mozilla_components.pigeons.ShareTargetParams
import eu.weblibre.flutter_mozilla_components.pigeons.TabContentState
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Store
import mozilla.components.lib.state.ext.flowScoped
import kotlinx.coroutines.flow.distinctUntilChangedBy
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
                // Make sure this is sent after tabadded action and tab list change
                .debounce { 50 }
                .collect { tabId ->
                    flutterEvents.onSelectedTabChange(
                        EventSequence.next(),
                        tabId
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            var previousTabs = emptySet<String>()
            flow.mapNotNull { state -> state.tabs.map { tab -> tab.id } }
                .distinctUntilChanged()
                // Make sure this is sent after tabadded action
                .debounce { 25 }
                .collect { tabs ->
                    val currentTabs = tabs.toSet()
                    if (previousTabs.isNotEmpty()) {
                        val removedTabs = previousTabs - currentTabs
                        if (removedTabs.isNotEmpty()) {
                            removedTabs.forEach { tabId ->
                                flutterEvents.onManifestUpdate(
                                    EventSequence.next(),
                                    tabId,
                                    null
                                ) { _ -> }
                            }
                        }
                    }
                    previousTabs = currentTabs
                    flutterEvents.onTabListChange(EventSequence.next(), tabs) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content
                }
                .ifAnyChanged { arrayOf(it.content.icon) }
                .debounce(15)
                .collect { tab ->
                    val iconBytes = tab.content.icon?.toWebPBytes()
                    flutterEvents.onIconChange(
                        EventSequence.next(),
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
                .debounce(15)
                .collect { tab ->
                    flutterEvents.onSecurityInfoStateChange(
                        EventSequence.next(),
                        tab.id,
                        SecurityInfoState(
                            tab.content.securityInfo.isSecure,
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
                .ifAnyChanged {
                    arrayOf(
                        it.readerState.readerable,
                        it.readerState.active,
                    )
                }
                .debounce(25)
                .collect { tab ->
                    flutterEvents.onReaderableStateChange(
                        EventSequence.next(),
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
                .ifAnyChanged {
                    arrayOf(
                        it.content.history,
                        it.content.canGoBack,
                        it.content.canGoForward,
                    )
                }
                .debounce(15)
                .collect { tab ->
                    flutterEvents.onHistoryStateChange(
                        EventSequence.next(),
                        tab.id,
                        HistoryState(
                            items = tab.content.history.items.map { item ->
                                HistoryItem(
                                    url = item.uri,
                                    title = item.title
                                )
                            },
                            currentIndex = tab.content.history.currentIndex.toLong(),
                            canGoBack = tab.content.canGoBack,
                            canGoForward = tab.content.canGoForward,
                        )
                    ) { _ -> }
                }
        }

        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.tabs }
                .filterChanged {
                    it.content
                }
                .ifAnyChanged {
                    arrayOf(
                        it.content.url,
                        it.content.title,
                        it.content.private,
                        it.content.fullScreen,
                        it.content.progress,
                        it.content.loading
                    )
                }
                .debounce(15)
                .collect { tab ->
                    flutterEvents.onTabContentStateChange(
                        EventSequence.next(),
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

        // PWA manifest availability events - following Fenix MenuPresenter pattern
        stateFlow.flowScoped { flow ->
            flow.mapNotNull { state -> state.selectedTab }
                .ifAnyChanged { tab ->
                    arrayOf(
                        tab.content.loading,
                        tab.content.canGoBack,
                        tab.content.canGoForward,
                        tab.content.webAppManifest,
                    )
                }
                .collect { tab ->
                    val manifest = tab.content.webAppManifest
                    val currentUrl = tab.content.url

                    // If manifest is null, clear PWA state for this tab
                    if (manifest == null) {
                        flutterEvents.onManifestUpdate(
                            EventSequence.next(),
                            tab.id,
                            null
                        ) { _ -> }
                        return@collect
                    }

                    val pwaManifest = PwaManifest(
                        startUrl = manifest.startUrl,
                        currentUrl = currentUrl,
                        name = manifest.name,
                        shortName = manifest.shortName,
                        display = manifest.display?.name?.lowercase(),
                        themeColor = manifest.themeColor?.let { String.format("#%06X", 0xFFFFFF and it) },
                        backgroundColor = manifest.backgroundColor?.let { String.format("#%06X", 0xFFFFFF and it) },
                        scope = manifest.scope,
                        description = manifest.description,
                        icons = manifest.icons.map { icon ->
                            PwaIcon(
                                src = icon.src,
                                sizes = icon.sizes?.joinToString(" ") { "${it.width}x${it.height}" },
                                type = icon.type,
                            )
                        },
                        dir = manifest.dir?.name?.lowercase(),
                        lang = manifest.lang,
                        orientation = manifest.orientation?.name?.lowercase(),
                        relatedApplications = manifest.relatedApplications.map { app ->
                            ExternalApplicationResource(
                                platform = app.platform,
                                url = app.url,
                                id = app.id,
                                minVersion = app.minVersion,
                            )
                        },
                        preferRelatedApplications = manifest.preferRelatedApplications,
                        shareTarget = manifest.shareTarget?.let { target ->
                            ShareTarget(
                                action = target.action,
                                method = target.method?.name,
                                encType = target.encType?.type,
                                params = target.params?.let { params ->
                                    ShareTargetParams(
                                        title = params.title,
                                        text = params.text,
                                        url = params.url,
                                        files = params.files.map { file ->
                                            ShareTargetFiles(
                                                name = file.name,
                                                accept = file.accept,
                                            )
                                        },
                                    )
                                },
                            )
                        },
                    )

                    flutterEvents.onManifestUpdate(
                        EventSequence.next(),
                        tab.id,
                        pwaManifest
                    ) { _ -> }
                }
        }
    }
}
