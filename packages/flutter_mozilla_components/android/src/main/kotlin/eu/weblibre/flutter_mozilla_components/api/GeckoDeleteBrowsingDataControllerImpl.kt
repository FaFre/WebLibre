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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.RecentlyClosedAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.selector.allTabs
import mozilla.components.browser.state.selector.normalTabs
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.browser.session.storage.RecoverableBrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.Engine
import mozilla.components.concept.engine.translate.ModelManagementOptions
import mozilla.components.concept.engine.translate.ModelOperation
import mozilla.components.concept.engine.translate.OperationLevel
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class GeckoDeleteBrowsingDataControllerImpl : GeckoDeleteBrowsingDataController {
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

    /** [Engine.clearData] as a suspend call that fails with the engine's own error. */
    private suspend fun clearData(data: Engine.BrowsingData, host: String? = null) {
        suspendCancellableCoroutine<Unit> { continuation ->
            components.core.engine.clearData(
                data = data,
                host = host,
                onSuccess = { continuation.resume(Unit) },
                onError = { continuation.resumeWithException(it) },
            )
        }
    }

    /**
     * Removes every tab and writes the now-empty session to disk before returning.
     *
     * The store applies the removal synchronously, but the session file is only
     * rewritten by [mozilla.components.browser.session.storage.AutoSave], which is
     * debounced — and skips scheduling entirely while an earlier save is in flight.
     * A process that ends first (Quit's `exit(0)`, or Android killing it) restores
     * the removed tabs on the next launch. Callers rely on the removal being
     * durable once this returns, so a session that could not be written throws
     * rather than reporting success.
     *
     * The write goes through [eu.weblibre.flutter_mozilla_components.components.CurrentStateSessionWriter],
     * which autosaves share, so an autosave holding a pre-removal snapshot cannot
     * overwrite it afterwards.
     */
    override suspend fun deleteTabs() {
        withContext(Dispatchers.Main) {
            components.useCases.tabsUseCases.removeAllTabs.invoke(false)
        }
        withContext(Dispatchers.IO) {
            components.core.sessionWriter.saveCurrentStateOrThrow()
        }
    }

    /**
     * Every tab the next session restore could bring back: the open normal tabs,
     * and the tabs still in the saved session. The file lags behind the store —
     * autosave is debounced — so a tab closed just before a Quit can still be on
     * disk, and a process that dies before the Quit's own write restores it.
     *
     * Both are read under the session writer's lock, so no write is half done: one
     * that had already read the store but not yet written it would otherwise land
     * after the file was read, bringing back a tab closed since. Any write after
     * this reads the store later, and adds no tab that is open now.
     */
    override suspend fun getSessionTabIds(): List<String> {
        val core = components.core
        return withContext(Dispatchers.IO) {
            core.sessionWriter.whileNotWriting {
                core.store.state.restorableTabIds(core.sessionStorage.restore())
            }
        }
    }

    override suspend fun deleteBrowsingHistory() {
        withContext(Dispatchers.Main) {
            components.core.historyStorage.deleteEverything()
            components.core.store.dispatch(EngineAction.PurgeHistoryAction)
            components.core.icons.clear()
            components.core.store.dispatch(RecentlyClosedAction.RemoveAllClosedTabAction)
        }
    }

    override suspend fun deleteCookiesAndSiteData() {
        withContext(Dispatchers.Main) {
            closeMatchingSessions(components.core.store) { true }

            clearData(
                Engine.BrowsingData.select(
                    Engine.BrowsingData.COOKIES,
                    Engine.BrowsingData.AUTH_SESSIONS,
                ),
            )
            clearData(Engine.BrowsingData.select(Engine.BrowsingData.DOM_STORAGES))
        }
    }

    override suspend fun deleteCachedFiles() {
        withContext(Dispatchers.Main) {
            components.core.engine.manageTranslationsLanguageModel(
                options = ModelManagementOptions(
                    operation = ModelOperation.DELETE,
                    operationLevel = OperationLevel.CACHE,
                ),
                onSuccess = { },
                onError = { },
            )
            clearData(Engine.BrowsingData.select(Engine.BrowsingData.ALL_CACHES))
        }
    }

    override suspend fun deleteSitePermissions() {
        withContext(Dispatchers.Main) {
            clearData(Engine.BrowsingData.select(Engine.BrowsingData.ALL_SITE_SETTINGS))
        }
        withContext(Dispatchers.Default) {
            components.core.permissionStorage.deleteAllSitePermissions()
        }
    }

    /**
     * Removes the tabs the session restore brought back, and only those, once the
     * restore has completed; then writes the session like [deleteTabs].
     *
     * The startup deletion uses this rather than [deleteTabs]: it can run late (a
     * slow restore, a retry after a failure), and by then the tab list may hold tabs
     * opened in this session — a launch link, the home page. Those are not the
     * previous session's data and must survive.
     *
     * With [onlyTabIds], only the restored tabs listed there go: a deletion an
     * earlier Quit could not finish names the tabs it meant, so it can never reach
     * a tab opened in a later session, however many starts it takes.
     *
     * See [removePreviousSessionTabs] for why the removal is not undoable.
     */
    override suspend fun deletePreviousSessionTabs(onlyTabIds: List<String>?) {
        val core = components.core
        core.store.stateFlow.first { it.restoreComplete }

        withContext(Dispatchers.Main) {
            core.store.removePreviousSessionTabs(
                core.previousSessionTabIds,
                onlyTabIds = onlyTabIds?.toSet(),
            )
        }
        withContext(Dispatchers.IO) {
            core.sessionWriter.saveCurrentStateOrThrow()
        }
    }

    /**
     * Removes every download from the store and from its database before returning.
     *
     * The use case only updates the store; [mozilla.components.feature.downloads.DownloadMiddleware]
     * deletes the database rows in a coroutine nobody can await, so a process ending
     * right after would bring the downloads back. Deleting the rows here as well makes
     * the removal durable; both hit the same Room singleton, and deleting twice is
     * harmless.
     */
    override suspend fun deleteDownloads() {
        withContext(Dispatchers.Main) {
            components.useCases.downloadsUseCases.removeAllDownloads.invoke()
        }
        withContext(Dispatchers.IO) {
            components.core.downloadStorage.removeAllDownloads()
        }
    }

    override suspend fun clearDataForSessionContext(contextId: String) {
        withContext(Dispatchers.Main) {
            // Detach engine sessions for any tab in this context so they don't
            // re-accumulate data while the (fire-and-forget) clear is processed.
            closeMatchingSessions(components.core.store) { it.contextId == contextId }

            // GeckoView's clearDataForSessionContext uses dispatch (fire-and-forget),
            // so there's no completion signal we can chain against. Fire it and
            // signal completion immediately - by suspending matching sessions above
            // we've at least ensured the operation can take effect.
            components.core.runtime.storageController.clearDataForSessionContext(contextId)
        }
    }

    override suspend fun clearDataForHost(host: String, dataTypes: List<ClearDataType>) {
        withContext(Dispatchers.Main) {
            if (dataTypes.contains(ClearDataType.ALL_SITE_DATA) && (dataTypes.contains(
                    ClearDataType.ONLY_COOKIES
                ) || dataTypes.contains(ClearDataType.ONLY_CACHES))
            ) {
                throw Exception("Cookies/Cache must be exclusively!")
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

            // Find tabs on this host so we can detach their engine sessions
            // before clearing (across every container — the base-domain clear
            // below covers all partitions, so any open session on this host in
            // any container could otherwise re-accumulate cleared data).
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

            // Clear data for the specific host only. clearDataFromBaseDomain
            // (used by engine.clearData(host=)) deletes the site under an
            // empty OriginAttributes pattern, which already matches ALL
            // partitions — including every container's
            // `geckoViewSessionContextId`. So this clears this host across all
            // containers WITHOUT touching other sites in those containers.
            //
            // Do NOT fall back to clearDataForSessionContext here: that wipes a
            // container's entire storage (every unrelated site in it), which is
            // the container-wide data-loss reported in #524.
            clearData(
                data = Engine.BrowsingData.select(*browsingDataTypes),
                host = host,
            )
        }
    }
}

/**
 * Removes whichever of [previousSessionTabIds] are still open — limited to
 * [onlyTabIds] when given — and nothing else.
 *
 * Not undoable: [mozilla.components.feature.session.middleware.undo.UndoMiddleware]
 * records every [TabListAction.RemoveTabsAction] for "undo close", so the entry it
 * just made is cleared by its tag. Dispatch is synchronous, so the tag read back is
 * that one.
 */
internal fun BrowserStore.removePreviousSessionTabs(
    previousSessionTabIds: Set<String>,
    onlyTabIds: Set<String>? = null,
) {
    val tabIds = state.tabs.map { it.id }.filter {
        it in previousSessionTabIds && (onlyTabIds == null || it in onlyTabIds)
    }
    if (tabIds.isEmpty()) return

    dispatch(TabListAction.RemoveTabsAction(tabIds))
    dispatch(UndoAction.ClearRecoverableTabs(state.undoHistory.tag))
}

/**
 * The ids of the open normal tabs and of the tabs in [saved], the session on disk:
 * everything a session restore could bring back.
 */
internal fun BrowserState.restorableTabIds(saved: RecoverableBrowserState?): List<String> =
    (normalTabs.map { it.id } + saved?.tabs.orEmpty().map { it.state.id }).distinct()
