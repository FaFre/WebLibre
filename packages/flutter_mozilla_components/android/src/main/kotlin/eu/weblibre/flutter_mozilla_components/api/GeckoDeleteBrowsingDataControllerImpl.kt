package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDeleteBrowsingDataController
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.RecentlyClosedAction
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
                components.core.engine.clearData(
                    Engine.BrowsingData.select(
                        Engine.BrowsingData.COOKIES,
                        Engine.BrowsingData.AUTH_SESSIONS,
                    ),
                )
                components.core.engine.clearData(Engine.BrowsingData.select(Engine.BrowsingData.DOM_STORAGES))

                callback(Result.success(Unit))
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
                )

                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteSitePermissions(callback: (Result<Unit>) -> Unit) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.engine.clearData(
                    Engine.BrowsingData.select(Engine.BrowsingData.ALL_SITE_SETTINGS),
                )
                components.core.permissionStorage.deleteAllSitePermissions()

                callback(Result.success(Unit))
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
}