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
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoEngineSettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSelectionActionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSuggestionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoViewportEvents
import eu.weblibre.flutter_mozilla_components.pigeons.QueryParameterStripping
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import eu.weblibre.flutter_mozilla_components.addons.AddonPrefs
import eu.weblibre.flutter_mozilla_components.api.GeckoViewportApiImpl
import eu.weblibre.flutter_mozilla_components.api.GeckoEngineSettingsApiImpl
import eu.weblibre.flutter_mozilla_components.feature.DefaultSelectionActionDelegate
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.storage.sync.GlobalPlacesDependencyProvider
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.action.RestoreCompleteAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.feature.addons.update.GlobalAddonDependencyProvider
import mozilla.components.support.base.facts.Facts
import mozilla.components.support.base.facts.processor.LogFactProcessor
import mozilla.components.support.base.log.Log
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.base.log.sink.AndroidLogSink
import mozilla.components.support.webextensions.WebExtensionSupport
import java.io.File
import java.util.concurrent.TimeUnit

private const val HISTORY_METADATA_MAX_AGE_IN_MS = 14L * 24 * 60 * 60 * 1000 // 14 days
private const val DEFAULT_QUERY_PARAMETER_STRIPPING_STRIP_LIST =
    "__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid sms_click sms_source sms_uph srsltid ss_email_id syclid ttclid twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid"
private const val UBLOCK_FILTER_LISTS_PREF = "browser.weblibre.uBO.filterLists"
    
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

    // Startup settings for builder-only GeckoRuntimeSettings (fission, process isolation, etc.)
    var startupSettings: GeckoEngineSettings? = null

    // Startup pref written before web extensions initialize.
    var startupUBlockFilterListsPref: String? = null
    var clearStartupUBlockFilterListsPref: Boolean = false

    fun shouldOpenLinksInApp(isExternalSession: Boolean = false): Boolean {
        return when (engineSettingsApi!!.getAppLinksMode()) {
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ALWAYS -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ASK -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.NEVER -> isExternalSession
        }
    }

    fun shouldPromptOpenLinksInApp(isExternalSession: Boolean = false): Boolean {
        return when (engineSettingsApi!!.getAppLinksMode()) {
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ALWAYS -> false
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.ASK -> true
            eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode.NEVER -> isExternalSession
        }
    }

    @DelicateCoroutinesApi
    private fun restoreBrowserState(
        newComponents: Components,
        restoreTabsWithoutResumingSelection: Boolean,
    ) =
        GlobalScope.launch(Dispatchers.Main) {
            if (restoreTabsWithoutResumingSelection) {
                val restoredState = newComponents.core.sessionStorage.restore { true }

                if (restoredState != null) {
                    newComponents.useCases.tabsUseCases.restore(
                        state = RecoverableBrowserState(
                            tabs = restoredState.tabs,
                            // Intentionally do not resume the previously selected tab during the
                            // first full setup. We restore the tab list, but let startup open in
                            // its neutral/default state instead of jumping back into prior content.
                            selectedTabId = null,
                            tabPartitions = restoredState.tabPartitions
                        ),
                        restoreLocation = TabListAction.RestoreAction.RestoreLocation.BEGINNING,
                    )
                }

                newComponents.core.store.dispatch(RestoreCompleteAction)
            } else {
                newComponents.useCases.tabsUseCases.restore(newComponents.core.sessionStorage)
            }

            newComponents.core.sessionStorage.autoSave(newComponents.core.store)
                .periodicallyInForeground(interval = 30, unit = TimeUnit.SECONDS)
                .whenGoingToBackground()
                .whenSessionsChange()
        }

    @DelicateCoroutinesApi
    private fun restoreDownloads(newComponents: Components) = GlobalScope.launch(Dispatchers.Main) {
        newComponents.useCases.downloadsUseCases.restoreDownloads()
    }

    // Submits the uBO managed-storage pref before web extensions register.
    // Called from setUp() on the main thread; we do not block awaiting the
    // ack callback because the engine dispatches it back to the main thread
    // (which is held by setUp), and waiting would deadlock. The underlying
    // GeckoView pref store accepts the new value before the callback fires,
    // so by the time WebExtensionSupport.initialize installs uBO and the
    // extension reads storage.managed, the pref is already present.
    @OptIn(ExperimentalAndroidComponentsApi::class)
    private fun applyStartupUBlockFilterListsPref(newComponents: Components) {
        if (!clearStartupUBlockFilterListsPref && startupUBlockFilterListsPref == null) {
            return
        }

        val onError: (Throwable) -> Unit = {
            Logger.warn("Failed applying startup uBlock filter list pref", it)
        }

        if (clearStartupUBlockFilterListsPref) {
            newComponents.core.engine.clearBrowserUserPref(
                pref = UBLOCK_FILTER_LISTS_PREF,
                onSuccess = {},
                onError = onError,
            )
        } else {
            newComponents.core.engine.setBrowserPref(
                UBLOCK_FILTER_LISTS_PREF,
                requireNotNull(startupUBlockFilterListsPref),
                Branch.USER,
                onSuccess = {},
                onError = onError,
            )
        }
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
        syncStateEvents: GeckoSyncStateEvents?,
        logLevel: Log.Priority,
        contentBlocking: ContentBlocking,
        addonCollection: AddonCollection?,
        fxaServerOverride: String?,
        syncTokenServerOverride: String?,
        mode: ComponentsMode = ComponentsMode.FULL,
    ) {
        Logger.debug("Creating new components")

        val previousComponents = _components
        val previousMode = currentMode
        val isSameProfile = previousComponents?.profileApplicationContext?.relativePath ==
            applicationContext.relativePath
        val previousCustomTabs = if (isSameProfile) {
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
            fxaServerOverride,
            syncTokenServerOverride,
            addonEvents,
            tabContentEvents,
            extensionEvents,
            syncStateEvents,
        )
        _components = newComponents
        currentMode = mode

        previousComponents?.let {
            runCatching {
                it.backgroundServices.accountManager.close()
            }
        }

        //newComponents.crashReporter.install(applicationContext)

        //Facts.registerProcessor(LogFactProcessor())

        val megazordNetworkSetup = MegazordSetup.setupMegazordNetwork(
            context = newComponents.profileApplicationContext,
            client = lazy { newComponents.core.client },
        )

        if (mode == ComponentsMode.FULL) {
            newComponents.core.engine.warmUp()
            applyStartupUBlockFilterListsPref(newComponents)
        }

        fun restorePreviousCustomTabs() {
            if (previousCustomTabs.isEmpty()) return
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
            if (!megazordNetworkSetup.isCompleted) {
                runBlocking {
                    megazordNetworkSetup.await()
                }
            }

            val isFirstFullSetup = previousMode != ComponentsMode.FULL
            val restoreJob = restoreBrowserState(
                newComponents,
                restoreTabsWithoutResumingSelection = isFirstFullSetup,
            )
            if (previousCustomTabs.isNotEmpty()) {
                restoreJob.invokeOnCompletion {
                    GlobalScope.launch(Dispatchers.Main) {
                        restorePreviousCustomTabs()
                    }
                }
            }
            restoreDownloads(newComponents)

            try {
                GlobalPlacesDependencyProvider.initialize(newComponents.core.historyStorage)

                newComponents.core.historyMetadataService.cleanup(
                    System.currentTimeMillis() - HISTORY_METADATA_MAX_AGE_IN_MS,
                )

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
                        val addonPrefs = AddonPrefs.get(applicationContext)
                        val autoUpdateEnabled =
                            addonPrefs.getBoolean(AddonPrefs.PREF_AUTO_UPDATE_ENABLED, true)
                        val autoUpdateDisabledAddonIds =
                            addonPrefs.getStringSet(AddonPrefs.PREF_AUTO_UPDATE_DISABLED_IDS, emptySet())
                                ?: emptySet()
                        val localFileAddonIds =
                            addonPrefs.getStringSet(AddonPrefs.PREF_LOCAL_FILE_ADDON_IDS, emptySet())
                                ?: emptySet()
                        if (autoUpdateEnabled) {
                            newComponents.core.addonUpdater.registerForFutureUpdates(
                                extensions.filterNot { extension ->
                                    autoUpdateDisabledAddonIds.contains(extension.id) ||
                                        localFileAddonIds.contains(extension.id)
                                },
                            )
                        }
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

            // Eagerly initialize account manager so sync starts
            newComponents.backgroundServices.accountManager

            // Start FxA web channel feature for OAuth redirect handling
            newComponents.services.fxaWebChannelFeature.start()
        } else {
            restorePreviousCustomTabs()
        }

        newComponents.push.initialize()
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
            queryParameterStripping = QueryParameterStripping.ENABLED,
            queryParameterStrippingAllowList = "",
            queryParameterStrippingStripList = DEFAULT_QUERY_PARAMETER_STRIPPING_STRIP_LIST,
            bounceTrackingProtectionMode = BounceTrackingProtectionMode.ENABLED,
        )

        setUp(
            applicationContext = profileContext,
            flutterEvents = GeckoStateEvents(messenger),
            readerViewController = ReaderViewController(messenger),
            selectionAction = selectionActionDelegate,
            addonEvents = GeckoAddonEvents(messenger),
            tabContentEvents = GeckoTabContentEvents(messenger),
            extensionEvents = BrowserExtensionEvents(messenger),
            syncStateEvents = null,
            logLevel = logLevel,
            contentBlocking = contentBlocking,
            addonCollection = null,
            fxaServerOverride = null,
            syncTokenServerOverride = null,
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
