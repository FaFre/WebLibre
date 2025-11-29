/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import eu.weblibre.flutter_mozilla_components.pigeons.AddonCollection
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import mozilla.components.browser.storage.sync.GlobalPlacesDependencyProvider
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.feature.addons.update.GlobalAddonDependencyProvider
import mozilla.components.support.base.facts.Facts
import mozilla.components.support.base.facts.processor.LogFactProcessor
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.webextensions.WebExtensionSupport
import java.util.concurrent.TimeUnit

object GlobalComponents {
    private var _components: Components? = null

    val components: Components?
        get() = _components

    @DelicateCoroutinesApi
    private fun restoreBrowserState(newComponents: Components) =
        GlobalScope.launch(Dispatchers.Main) {
            newComponents.useCases.tabsUseCases.restore(newComponents.core.sessionStorage)

            newComponents.core.sessionStorage.autoSave(newComponents.core.store)
                .periodicallyInForeground(interval = 30, unit = TimeUnit.SECONDS)
                .whenGoingToBackground()
                .whenSessionsChange()
        }

    @DelicateCoroutinesApi
    private fun restoreDownloads(newComponents: Components) = GlobalScope.launch(Dispatchers.Main) {
        newComponents.useCases.downloadsUseCases.restoreDownloads()
    }

    @OptIn(DelicateCoroutinesApi::class)
    fun setUp(
        applicationContext: ProfileContext,
        flutterEvents: GeckoStateEvents,
        readerViewController: ReaderViewController,
        selectionAction: SelectionActionDelegate,
        addonEvents: GeckoAddonEvents,
        tabContentEvents: GeckoTabContentEvents,
        extensionEvents: BrowserExtensionEvents,
        logLevel: Log.Priority,
        contentBlocking: ContentBlocking,
        addonCollection: AddonCollection?
    ) {
        Logger.debug("Creating new components")

        val newComponents = Components(
            applicationContext,
            flutterEvents,
            readerViewController,
            selectionAction,
            logLevel,
            contentBlocking,
            addonCollection,
            addonEvents,
            tabContentEvents,
            extensionEvents,
        )
        _components = newComponents

        //newComponents.crashReporter.install(applicationContext)

        //Facts.registerProcessor(LogFactProcessor())

        //RustHttpConfig.setClient(lazy { newComponents.core.client })

        newComponents.core.engine.warmUp()

        restoreBrowserState(newComponents)
        restoreDownloads(newComponents)

        try {
            GlobalPlacesDependencyProvider.initialize(newComponents.core.historyStorage)

            GlobalAddonDependencyProvider.initialize(
                newComponents.core.addonManager,
                newComponents.core.addonUpdater,
            )

            WebExtensionSupport.initialize(
                newComponents.core.engine,
                newComponents.core.store,
                onNewTabOverride = { _, engineSession, url ->
                    newComponents.useCases.tabsUseCases.addTab(
                        url,
                        selectTab = true,
                        engineSession = engineSession
                    )
                },
                onCloseTabOverride = { _, sessionId ->
                    newComponents.useCases.tabsUseCases.removeTab(sessionId)
                },
                onSelectTabOverride = { _, sessionId ->
                    newComponents.useCases.tabsUseCases.selectTab(sessionId)
                },
                onUpdatePermissionRequest = newComponents.core.addonUpdater::onUpdatePermissionRequest,
                onExtensionsLoaded = { extensions ->
                    newComponents.core.addonUpdater.registerForFutureUpdates(extensions)
                    newComponents.core.supportedAddonsChecker.registerForChecks()
                },
            )
        } catch (e: UnsupportedOperationException) {
            // Web extension support is only available for engine gecko
            Logger.error("Failed to initialize web extension support", e)
        }

        GlobalScope.launch(Dispatchers.IO) {
            newComponents.core.fileUploadsDirCleaner.cleanUploadsDirectory()
        }
    }
}