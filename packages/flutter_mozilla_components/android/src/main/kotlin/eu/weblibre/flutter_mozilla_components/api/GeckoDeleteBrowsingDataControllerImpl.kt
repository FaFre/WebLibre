/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import androidx.core.net.toUri
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.ClearDataType
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDeleteBrowsingDataController
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.RecentlyClosedAction
import mozilla.components.browser.state.selector.allTabs
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.translate.ModelManagementOptions
import mozilla.components.concept.engine.translate.ModelOperation
import mozilla.components.concept.engine.translate.OperationLevel

class GeckoDeleteBrowsingDataControllerImpl : GeckoDeleteBrowsingDataController {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    /**
     * GeckoView's storage clearing APIs warn that any open session may re-accumulate
     * previously cleared data. We synchronously close the underlying [EngineSession]
     * (so its in-memory cookie/storage state is torn down before the clear runs) and
     * then unlink it from the browser store. The next reload spins up a fresh engine
     * session that reads from the cleared storage.
     *
     * NOTE: We deliberately don't use [EngineAction.SuspendEngineSessionAction] here -
     * its middleware runs `engineSession.close()` inside a `scope.launch`, racing with
     * the `clearData` call we're about to issue.
     */
    private fun closeMatchingSessions(
        store: BrowserStore,
        predicate: (SessionState) -> Boolean,
    ) {
        val tabs = store.state.allTabs.filter {
            it.engineState.engineSession != null && predicate(it)
        }

        tabs.forEach { it.engineState.engineSession?.close() }
        tabs.forEach { store.dispatch(EngineAction.UnlinkEngineSessionAction(it.id)) }
    }

    override fun deleteTabs(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.useCases.tabsUseCases.removeAllTabs.invoke(false)

                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteBrowsingHistory(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteEverything()
                components.core.store.dispatch(EngineAction.PurgeHistoryAction)
                components.core.icons.clear()
                components.core.store.dispatch(RecentlyClosedAction.RemoveAllClosedTabAction)

                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteCookiesAndSiteData(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                closeMatchingSessions(components.core.store) { true }

                components.core.engine.clearData(
                    Engine.BrowsingData.select(
                        Engine.BrowsingData.COOKIES,
                        Engine.BrowsingData.AUTH_SESSIONS,
                    ),
                    onSuccess = {
                        components.core.engine.clearData(
                            Engine.BrowsingData.select(Engine.BrowsingData.DOM_STORAGES),
                            onSuccess = { callback(Result.success(Unit)) },
                            onError = { callback(Result.failure(it)) },
                        )
                    },
                    onError = { callback(Result.failure(it)) },
                )
            }
        }
    }

    override fun deleteCachedFiles(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.engine.manageTranslationsLanguageModel(
                    options = ModelManagementOptions(
                        operation = ModelOperation.DELETE,
                        operationLevel = OperationLevel.CACHE,
                    ),
                    onSuccess = { },
                    onError = { },
                )
                components.core.engine.clearData(
                    Engine.BrowsingData.select(Engine.BrowsingData.ALL_CACHES),
                    onSuccess = { callback(Result.success(Unit)) },
                    onError = { callback(Result.failure(it)) },
                )
            }
        }
    }

    override fun deleteSitePermissions(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.engine.clearData(
                    Engine.BrowsingData.select(Engine.BrowsingData.ALL_SITE_SETTINGS),
                    onSuccess = {
                        coroutineScope.launch {
                            try {
                                components.core.permissionStorage.deleteAllSitePermissions()
                                callback(Result.success(Unit))
                            } catch (e: Throwable) {
                                callback(Result.failure(e))
                            }
                        }
                    },
                    onError = { callback(Result.failure(it)) },
                )
            }
        }
    }

    override fun deleteDownloads(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.useCases.downloadsUseCases.removeAllDownloads.invoke()

                callback(Result.success(Unit))
            }
        }
    }

    override fun clearDataForSessionContext(
        contextId: String,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                // Detach engine sessions for any tab in this context so they don't
                // re-accumulate data while the (fire-and-forget) clear is processed.
                closeMatchingSessions(components.core.store) { it.contextId == contextId }

                // GeckoView's clearDataForSessionContext uses dispatch (fire-and-forget),
                // so there's no completion signal we can chain against. Fire it and
                // signal completion immediately - by suspending matching sessions above
                // we've at least ensured the operation can take effect.
                components.core.runtime.storageController.clearDataForSessionContext(contextId)

                callback(Result.success(Unit))
            }
        }
    }

    override fun clearDataForHost(
        host: String,
        dataTypes: List<ClearDataType>,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            try {
                withContext(Dispatchers.Main) {
                    if (dataTypes.contains(ClearDataType.ALL_SITE_DATA) && (dataTypes.contains(
                            ClearDataType.ONLY_COOKIES
                        ) || dataTypes.contains(ClearDataType.ONLY_CACHES))
                    ) {
                        callback(Result.failure(Exception("Cookies/Cache must be exclusively!")))
                    }

                    // Convert ClearDataType to Engine.BrowsingData flags
                    val browsingDataTypes = dataTypes.map { dataType ->
                        when (dataType) {
                            ClearDataType.AUTH_SESSIONS -> Engine.BrowsingData.AUTH_SESSIONS
                            ClearDataType.ALL_SITE_DATA -> Engine.BrowsingData.ALL_SITE_DATA
                            ClearDataType.ONLY_COOKIES -> Engine.BrowsingData.COOKIES
                            ClearDataType.ONLY_CACHES -> Engine.BrowsingData.ALL_CACHES
                        }
                    }.toIntArray()

                    // Find tabs on this host (so we can detach their engine sessions and
                    // also discover any container/contextId partitions that need clearing).
                    val matchingTabs = components.core.store.state.allTabs.filter { tab ->
                        val tabHost = runCatching { tab.content.url.toUri().host }.getOrNull()
                            ?: return@filter false
                        tabHost == host || tabHost.endsWith(".$host")
                    }

                    // GeckoView warns that open sessions may re-accumulate previously
                    // cleared data. Close them synchronously before clearing.
                    matchingTabs.forEach { it.engineState.engineSession?.close() }
                    matchingTabs.forEach {
                        components.core.store.dispatch(EngineAction.UnlinkEngineSessionAction(it.id))
                    }

                    // GeckoView's clearDataFromBaseDomain (used by engine.clearData(host=))
                    // only targets the default origin attributes partition. Tabs that live
                    // inside a contextual identity ("container") store their cookies/storage
                    // under a `geckoViewSessionContextId` origin attribute that the
                    // base-domain clear does not touch. To make clearing actually effective
                    // for container tabs, also fire clearDataForSessionContext for any
                    // contextIds we found. This is broader than ideal (it clears the whole
                    // container, not just this host) but there is no GeckoView API to
                    // combine host + context.
                    val contextIds = matchingTabs.mapNotNull { it.contextId }.toSet()
                    contextIds.forEach { contextId ->
                        components.core.runtime.storageController
                            .clearDataForSessionContext(contextId)
                    }

                    // Clear data for the specific host (default partition).
                    components.core.engine.clearData(
                        data = Engine.BrowsingData.select(*browsingDataTypes),
                        host = host,
                        onSuccess = {
                            callback(Result.success(Unit))
                        },
                        onError = { throwable ->
                            callback(Result.failure(throwable))
                        }
                    )
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }
}
