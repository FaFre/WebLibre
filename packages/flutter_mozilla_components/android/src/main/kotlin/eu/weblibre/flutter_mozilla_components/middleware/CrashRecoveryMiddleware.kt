/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import android.os.SystemClock
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.CrashAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import mozilla.components.support.base.log.logger.Logger

/**
 * Brings a tab back after its content process crashed.
 *
 * When Gecko reports a crash, Android Components marks the tab `crashed` and
 * refuses to build it an engine session again until the app explicitly asks:
 * `CreateEngineSessionMiddleware` returns null for a crashed tab, and
 * `EngineViewPresenter` releases the view instead of rendering it. Without a
 * restore the tab is not merely stale — it is a blank rectangle for the rest of
 * the process' life, and nothing in the UI says why.
 *
 * Fenix answers this with a crash page the user has to dismiss. WebLibre
 * restores silently: a reloaded tab is a better answer than an empty one, and
 * the reload is what the user would ask for anyway.
 *
 * Note this is the *crash* path (`ContentDelegate.onCrash`), not the far more
 * common kill-under-memory-pressure path (`onKill`), which Android Components
 * already recovers on its own by suspending and later restoring the session.
 * This is therefore crash hardening, not a fix for issue #495.
 *
 * Regular tabs are restored lazily, when they are next selected; custom tabs and
 * PWAs are restored as soon as they crash, because nothing ever "selects" them.
 *
 * @param minimumRestoreInterval Guards against a page that crashes on every
 * load. Restoring reloads the tab, so a deterministic crash would otherwise
 * loop; a tab that crashes again this soon after being restored is left alone,
 * which is exactly the behaviour we had before.
 */
class CrashRecoveryMiddleware(
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main),
    private val minimumRestoreInterval: Long = MINIMUM_RESTORE_INTERVAL_MS,
    private val elapsedRealtime: () -> Long = SystemClock::elapsedRealtime,
) : Middleware<BrowserState, BrowserAction> {
    private val logger = Logger("CrashRecoveryMiddleware")

    private val lastRestoreAt = mutableMapOf<String, Long>()

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        next(action)

        // Runs after the reducer, so `crashed` is already set and the selection
        // already points at the tab we are asked about.
        when (action) {
            is CrashAction.SessionCrashedAction -> {
                // A custom tab or PWA has no selection to wait for: the activity
                // hosting it is showing it right now, and `selectedTabId` refers
                // to a regular tab that may not even be on screen. Restore it
                // straight away or it stays a blank window until the process
                // dies.
                val isExternalSession = store.state.findCustomTab(action.tabId) != null
                if (isExternalSession || action.tabId == store.state.selectedTabId) {
                    restore(store, action.tabId)
                }
            }

            is TabListAction.SelectTabAction -> {
                restore(store, action.tabId)
            }

            else -> Unit
        }
    }

    private fun restore(store: Store<BrowserState, BrowserAction>, tabId: String) {
        val tab = store.state.findTabOrCustomTab(tabId) ?: return
        if (!tab.engineState.crashed) {
            return
        }

        val now = elapsedRealtime()
        val previous = lastRestoreAt[tabId]
        if (previous != null && now - previous < minimumRestoreInterval) {
            logger.warn("Tab $tabId crashed again right after being restored; leaving it crashed")
            return
        }

        // An entry older than the interval can never block a restore again, so
        // dropping it here keeps the map to tabs that crashed just now rather
        // than to every tab that ever crashed.
        lastRestoreAt.values.removeAll { now - it >= minimumRestoreInterval }
        lastRestoreAt[tabId] = now

        // Dispatched asynchronously so it lands after CrashMiddleware has
        // suspended the crashed session: clearing the flag while the old engine
        // session is still being unlinked and closed would race a new one
        // against it.
        scope.launch {
            logger.info("Restoring crashed tab $tabId")
            store.dispatch(CrashAction.RestoreCrashedSessionAction(tabId))
        }
    }

    companion object {
        private const val MINIMUM_RESTORE_INTERVAL_MS = 10_000L
    }
}
