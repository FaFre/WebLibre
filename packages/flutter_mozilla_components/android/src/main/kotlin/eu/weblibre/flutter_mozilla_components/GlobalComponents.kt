/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import eu.weblibre.flutter_mozilla_components.pigeons.AddonCollection
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.BounceTrackingProtectionMode
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.api.GeckoViewportApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import mozilla.components.browser.storage.sync.GlobalPlacesDependencyProvider
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.feature.addons.update.GlobalAddonDependencyProvider
import mozilla.components.support.base.facts.Facts
import mozilla.components.support.base.facts.processor.LogFactProcessor
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.webextensions.WebExtensionSupport
import java.io.File
import java.util.concurrent.TimeUnit

object GlobalComponents {
    private var _components: Components? = null
    private var currentMode: ComponentsMode? = null

    val components: Components?
        get() = _components

    enum class ComponentsMode {
        FULL,
        EXTERNAL,
    }

    // Pull-to-refresh setting
    var pullToRefreshEnabled: Boolean = true
        set(value) {
            field = value
            onPullToRefreshEnabledChanged?.invoke(value)
        }

    var onPullToRefreshEnabledChanged: ((Boolean) -> Unit)? = null

    // Viewport events for keyboard visibility notifications
    var viewportEvents: GeckoViewportEvents? = null

    // Viewport API for applying pending settings when engineView becomes available
    var viewportApi: GeckoViewportApiImpl? = null

    // Engine settings API for managing engine-specific settings
    var engineSettingsApi: GeckoEngineSettingsApiImpl? = null

    // External download manager setting
    var useExternalDownloadManager: Boolean = false

    fun shouldOpenLinksInApp(): Boolean {
        return when (engineSettingsApi!!.getAppLinksMode()) {
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ALWAYS -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ASK -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.NEVER -> false
        }
    }

    fun shouldPromptOpenLinksInApp(): Boolean {
        return when (engineSettingsApi!!.getAppLinksMode()) {
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ALWAYS -> false
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ASK -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.NEVER -> false
        }
    }

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
        addonCollection: AddonCollection?,
        mode: ComponentsMode = ComponentsMode.FULL,
    ) {
        Logger.debug("Creating new components")

        val previousComponents = _components
        val previousMode = currentMode
        val previousCustomTabs = if (previousMode == ComponentsMode.EXTERNAL) {
            previousComponents?.core?.store?.state?.customTabs.orEmpty()
        } else {
            emptyList()
        }

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
        currentMode = mode

        //newComponents.crashReporter.install(applicationContext)

        //Facts.registerProcessor(LogFactProcessor())

        //RustHttpConfig.setClient(lazy { newComponents.core.client })

        newComponents.core.engine.warmUp()

        if (previousCustomTabs.isNotEmpty()) {
            for (tab in previousCustomTabs) {
                val existing = newComponents.core.store.state.findCustomTab(tab.id)
                if (existing == null) {
                    newComponents.core.store.dispatch(
                        CustomTabListAction.AddCustomTabAction(tab)
                    )
                }
            }
        }

        if (mode == ComponentsMode.FULL) {
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

    @Synchronized
    fun ensureExternalComponents(
        baseContext: Context,
        logLevel: Log.Priority = Log.Priority.WARN,
    ): Boolean {
        if (_components != null) {
            return true
        }

        val profileFolder = resolveExternalProfileFolder(baseContext) ?: return false
        val profileContext = ProfileContext(baseContext.applicationContext, profileFolder)
        val messenger = NoopBinaryMessenger()

        val selectionActionEvents = GeckoSelectionActionEvents(messenger)
        val selectionActionDelegate = DefaultSelectionActionDelegate(selectionActionEvents) { actions ->
            val processTextAction = "android.intent.action.PROCESS_TEXT"
            val withoutProcessText = actions.filter { it != processTextAction }.toTypedArray()
            val processTextActions = actions.filter { it == processTextAction }.toTypedArray()
            withoutProcessText + processTextActions
        }

        val contentBlocking = ContentBlocking(
            queryParameterStripping = QueryParameterStripping.DISABLED,
            queryParameterStrippingAllowList = "",
            queryParameterStrippingStripList = "",
            bounceTrackingProtectionMode = BounceTrackingProtectionMode.DISABLED,
        )

        setUp(
            applicationContext = profileContext,
            flutterEvents = GeckoStateEvents(messenger),
            readerViewController = ReaderViewController(messenger),
            selectionAction = selectionActionDelegate,
            addonEvents = GeckoAddonEvents(messenger),
            tabContentEvents = GeckoTabContentEvents(messenger),
            extensionEvents = BrowserExtensionEvents(messenger),
            logLevel = logLevel,
            contentBlocking = contentBlocking,
            addonCollection = null,
            mode = ComponentsMode.EXTERNAL,
        )

        engineSettingsApi = GeckoEngineSettingsApiImpl()
        return true
    }

    private fun resolveExternalProfileFolder(baseContext: Context): String? {
        return try {
            val profileFile = File(baseContext.filesDir, PwaConstants.CURRENT_PROFILE_FILE)
            if (!profileFile.exists()) return null
            val profileUuid = profileFile.readText().trim().ifEmpty { return null }

            val relativePath =
                "${PwaConstants.PROFILES_DIR_NAME}/${PwaConstants.PROFILE_DIR_PREFIX}$profileUuid"
            val profileDir = File(baseContext.filesDir, relativePath)
            if (!profileDir.exists()) return null

            relativePath
        } catch (e: Exception) {
            Logger.error("Failed to resolve external profile folder", e)
            null
        }
    }
}
