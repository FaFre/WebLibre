/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Handler
import android.os.HandlerThread
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.WebExtensionActionType
import eu.weblibre.flutter_mozilla_components.pigeons.WebExtensionData
import kotlinx.coroutines.*
import kotlinx.coroutines.android.asCoroutineDispatcher
import mozilla.components.browser.state.selector.selectedTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.state.WebExtensionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.webextension.Action
import mozilla.components.concept.engine.webextension.WebExtensionBrowserAction
import mozilla.components.lib.state.ext.flowScoped
import mozilla.components.support.base.feature.LifecycleAwareFeature
import mozilla.components.support.base.log.Log
import mozilla.components.support.ktx.kotlinx.coroutines.flow.ifAnyChanged
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

/**
 * Web extension toolbar implementation that updates the toolbar whenever the state of web
 * extensions changes.
 */
class WebExtensionToolbarFeature(
    private var store: BrowserStore,
    private var addonEvents: GeckoAddonEvents,
) : LifecycleAwareFeature {
    // This maps web extension ids to [WebExtensionToolbarAction]s for efficient
    // updates of global and tab-specific browser/page actions within the same
    // lifecycle.
    @VisibleForTesting
    internal val webExtensionBrowserActions = HashMap<String, WebExtensionBrowserAction>()
    internal val webExtensionPageActions = HashMap<String, WebExtensionBrowserAction>()

    private var scope: CoroutineScope? = null

    internal val iconThread = HandlerThread("IconThread")
    internal val iconHandler by lazy {
        iconThread.start()
        Handler(iconThread.looper)
    }

    internal var iconJobDispatcher: CoroutineDispatcher = Dispatchers.Main

    init {
        renderWebExtensionActions(store.state)
    }

    /**
     * Starts observing for the state of web extensions changes
     */
    override fun start() {
        // The feature could start with an existing view and toolbar so
        // we have to check if any stale actions (from uninstalled or
        // disabled extensions) are being displayed and remove them.
        webExtensionBrowserActions.keys.toList()
            .filter { !store.state.extensions.containsKey(it) || store.state.extensions[it]?.enabled == false }
            .forEach { extensionId ->
                addonEvents.onRemoveWebExtensionAction(
                    sequenceArg = EventSequence.next(),
                    extensionIdArg = extensionId,
                    actionTypeArg = WebExtensionActionType.BROWSER,
                ) {}
                webExtensionBrowserActions.remove(extensionId)
            }

        webExtensionPageActions.keys.toList()
            .filter { !store.state.extensions.containsKey(it) || store.state.extensions[it]?.enabled == false }
            .forEach { extensionId ->
                addonEvents.onRemoveWebExtensionAction(
                    sequenceArg = EventSequence.next(),
                    extensionIdArg = extensionId,
                    actionTypeArg = WebExtensionActionType.PAGE,
                ) {}
                webExtensionPageActions.remove(extensionId)
            }

        iconJobDispatcher = iconHandler.asCoroutineDispatcher("WebExtensionIconDispatcher")
        scope = store.flowScoped { flow ->
            flow.ifAnyChanged { arrayOf(it.selectedTab, it.extensions) }
                .collect { state ->
                    renderWebExtensionActions(state, state.selectedTab)
                }
        }
    }

    override fun stop() {
        iconJobDispatcher.cancel()
        scope?.cancel()
    }

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    internal fun renderWebExtensionActions(state: BrowserState, tab: SessionState? = null) {
        // Remove actions for extensions that were uninstalled or disabled
        val enabledExtensionIds = state.extensions.filter { it.value.enabled }.keys

        webExtensionBrowserActions.keys.toList().forEach { extensionId ->
            if (extensionId !in enabledExtensionIds) {
                addonEvents.onRemoveWebExtensionAction(
                    sequenceArg = EventSequence.next(),
                    extensionIdArg = extensionId,
                    actionTypeArg = WebExtensionActionType.BROWSER,
                ) {}
                webExtensionBrowserActions.remove(extensionId)
            }
        }

        webExtensionPageActions.keys.toList().forEach { extensionId ->
            if (extensionId !in enabledExtensionIds) {
                addonEvents.onRemoveWebExtensionAction(
                    sequenceArg = EventSequence.next(),
                    extensionIdArg = extensionId,
                    actionTypeArg = WebExtensionActionType.PAGE,
                ) {}
                webExtensionPageActions.remove(extensionId)
            }
        }

        val extensions = state.extensions.values.toList()
        extensions.filter { it.enabled }.sortedBy { it.name }.forEach { extension ->
            if (extensionNotAllowedInTab(extension, tab)) {
                webExtensionPageActions[extension.id]?.let {
                    addonEvents.onRemoveWebExtensionAction(
                        sequenceArg = EventSequence.next(),
                        extensionIdArg = extension.id,
                        actionTypeArg = WebExtensionActionType.PAGE,
                    ) {}
                    webExtensionPageActions.remove(extension.id)
                }
                webExtensionBrowserActions[extension.id]?.let {
                    addonEvents.onRemoveWebExtensionAction(
                        sequenceArg = EventSequence.next(),
                        extensionIdArg = extension.id,
                        actionTypeArg = WebExtensionActionType.BROWSER,
                    ) {}
                    webExtensionBrowserActions.remove(extension.id)
                }
                return@forEach
            }

            extension.browserAction?.let { browserAction ->
                addOrUpdateAction(
                    extension = extension,
                    globalAction = browserAction,
                    tabAction = tab?.extensionState?.get(extension.id)?.browserAction,
                )
            }

            extension.pageAction?.let { pageAction ->
                val tabPageAction = tab?.extensionState?.get(extension.id)?.pageAction

                // Unlike browser actions, page actions are not displayed by default (only if enabled):
                // https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/page_action
                if (pageAction.copyWithOverride(tabPageAction).enabled == true) {
                    addOrUpdateAction(
                        extension = extension,
                        globalAction = pageAction,
                        tabAction = tabPageAction,
                        isPageAction = true,
                    )
                }
            }
        }
    }

    private fun extensionNotAllowedInTab(
        extension: WebExtensionState?,
        tab: SessionState?,
    ): Boolean = extension?.allowedInPrivateBrowsing == false && tab?.content?.private == true

    fun invokeAddonBrowserAction(extensionId: String) {
        webExtensionBrowserActions[extensionId]?.onClick?.invoke()
    }

    fun invokeAddonPageAction(extensionId: String) {
        webExtensionPageActions[extensionId]?.onClick?.invoke()
    }

    private fun addOrUpdateAction(
        extension: WebExtensionState,
        globalAction: Action,
        tabAction: Action?,
        isPageAction: Boolean = false,
    ) {
        val actionMap = if (isPageAction) webExtensionPageActions else webExtensionBrowserActions
        val existingAction = actionMap[extension.id]

        if (existingAction == null) {
            // First time — load icon
            loadIcon(extension.id, globalAction, isPageAction)
        } else if (existingAction.loadIcon != globalAction.loadIcon) {
            // Icon source changed — reload
            loadIcon(extension.id, globalAction, isPageAction)
        }

        actionMap[extension.id] = globalAction

        // Apply tab-specific override of browser/page action
        var toolbarAction = globalAction
        tabAction?.let {
            toolbarAction = toolbarAction.copyWithOverride(it)
        }

        val data = WebExtensionData(
            extensionId = extension.id,
            title = toolbarAction.title,
            enabled = toolbarAction.enabled,
            badgeText = toolbarAction.badgeText,
            badgeTextColor = toolbarAction.badgeTextColor?.toLong(),
            badgeBackgroundColor = toolbarAction.badgeBackgroundColor?.toLong(),
        )

        addonEvents.onUpsertWebExtensionAction(
            sequenceArg = EventSequence.next(),
            extensionIdArg = extension.id,
            actionTypeArg = if (isPageAction) WebExtensionActionType.PAGE else WebExtensionActionType.BROWSER,
            extensionDataArg = data
        ) { }
    }

    private fun loadIcon(extensionId: String, action: Action, isPageAction: Boolean) {
        CoroutineScope(iconJobDispatcher).launch {
            try {
                val icon = action.loadIcon?.invoke(128)
                icon?.let {
                    val imageBytes = icon.toWebPBytes()
                    runOnUiThread {
                        addonEvents.onUpdateWebExtensionIcon(
                            sequenceArg = EventSequence.next(),
                            extensionIdArg = extensionId,
                            actionTypeArg = if (isPageAction) WebExtensionActionType.PAGE else WebExtensionActionType.BROWSER,
                            iconArg = imageBytes
                        ) { }
                    }
                }
            } catch (throwable: Throwable) {
                Log.log(
                    Log.Priority.ERROR,
                    "mozac-webextensions",
                    throwable,
                    "Failed to load browser action icon, falling back to default.",
                )
            }
        }
    }
}
