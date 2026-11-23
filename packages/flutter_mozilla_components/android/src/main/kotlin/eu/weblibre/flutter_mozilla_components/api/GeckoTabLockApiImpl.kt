/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabLockApi
import eu.weblibre.flutter_mozilla_components.pigeons.TabLockChange
import eu.weblibre.flutter_mozilla_components.pigeons.TabLockRejection
import eu.weblibre.flutter_mozilla_components.tabs.TabCloseProtection
import java.io.IOException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.support.base.log.logger.Logger

/**
 * What [GeckoTabLockApiImpl] needs of the browser components: the store whose
 * tabs it checks, and the write that puts the session file on disk.
 */
internal class TabLockSession(
    val store: BrowserStore,
    val saveSession: () -> Unit,
)

/**
 * Dart's side of [TabCloseProtection]. Registered when the plugin attaches, so
 * [bootstrapLockedTabs] works before the browser components exist; the other
 * calls need them and resolve them on each call, because a components rebuild
 * replaces them.
 *
 * Dart serializes every call that changes the set, so none of them race each
 * other. The store's removals do race them, on the main thread, which is why a
 * lock is put in force on the main thread right after it was checked.
 */
class GeckoTabLockApiImpl internal constructor(
    private val session: () -> TabLockSession?,
    private val mainDispatcher: CoroutineDispatcher,
    private val ioDispatcher: CoroutineDispatcher,
) : GeckoTabLockApi {
    constructor() : this(
        session = {
            GlobalComponents.components?.core?.let { core ->
                TabLockSession(core.store, core.sessionWriter::saveCurrentStateOrThrow)
            }
        },
        mainDispatcher = Dispatchers.Main,
        ioDispatcher = Dispatchers.IO,
    )

    private val logger = Logger("GeckoTabLockApi")

    private fun requireSession(): TabLockSession =
        requireNotNull(session()) { "Components not initialized" }

    override fun bootstrapLockedTabs(tabIds: List<String>) {
        TabCloseProtection.bootstrap(tabIds)
    }

    override suspend fun setTabLocked(tabId: String, locked: Boolean): TabLockChange {
        val session = requireSession()

        // Checked and put in force on the main thread in one go, so no removal
        // runs in between; from here on a removal is refused. A small
        // SharedPreferences commit, written before the answer by design.
        val applied = withContext(mainDispatcher) {
            val rejection = if (locked) rejectLock(session.store.state, tabId) else null
            if (rejection != null) {
                return@withContext TabLockChange(TabCloseProtection.isLocked(tabId), rejection)
            }
            try {
                TabLockChange(previouslyLocked = TabCloseProtection.set(tabId, locked))
            } catch (e: IOException) {
                logger.warn("Could not persist the lock change of $tabId", e)
                TabLockChange(TabCloseProtection.isLocked(tabId), TabLockRejection.NOT_PERSISTED)
            }
        }
        if (applied.rejection != null || !locked) return applied
        val previouslyLocked = applied.previouslyLocked

        // The tab has to be in the session file before the lock is acknowledged:
        // a tab opened a moment ago may not be yet, and a process that died before
        // the next autosave would restore without it, and the database catch-up
        // would delete its row — a lock the user saw succeed, gone.
        //
        // A tab native held locked already is no exception. That lock was never
        // acknowledged (an earlier attempt whose save and revert both failed, or
        // an unlock that did not reach native), so nothing says its tab is on
        // disk either.
        try {
            withContext(ioDispatcher) { session.saveSession() }
        } catch (e: IOException) {
            logger.warn("Could not save the session for the lock of $tabId", e)
            if (!previouslyLocked) {
                try {
                    withContext(mainDispatcher) { TabCloseProtection.set(tabId, false) }
                } catch (revertError: IOException) {
                    // Left locked: more locked than the database is the safe
                    // side. Dart reconciles after a refusal, which drops it.
                    logger.warn("Could not take back the lock of $tabId", revertError)
                }
            }
            return TabLockChange(
                previouslyLocked = previouslyLocked,
                rejection = TabLockRejection.NOT_PERSISTED,
            )
        }

        return TabLockChange(previouslyLocked = previouslyLocked)
    }

    override fun lockedTabIdsAmong(tabIds: List<String>): List<String> =
        TabCloseProtection.lockedAmong(tabIds)

    override fun reconcileLockedTabs(tabIds: List<String>): List<String> {
        val liveTabIds = requireSession().store.state.tabs
            .filterNot { it.content.private }
            .mapTo(HashSet()) { it.id }

        val pruned = TabCloseProtection.replace(tabIds.filter { it in liveTabIds })
        if (pruned.isNotEmpty()) {
            logger.info("Dropped ${pruned.size} tab locks the database does not hold")
        }
        return pruned.toList()
    }

    private fun rejectLock(state: BrowserState, tabId: String): TabLockRejection? {
        val tab = state.findTab(tabId)
            ?: return if (state.findCustomTab(tabId) != null) {
                TabLockRejection.CUSTOM_TAB
            } else {
                TabLockRejection.UNKNOWN_TAB
            }
        return if (tab.content.private) TabLockRejection.PRIVATE_TAB else null
    }
}
