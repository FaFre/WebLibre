/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.DownloadAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Records each download's context when it is added (D24, 5.11 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`), before AC's download
 * middleware starts it: a download can outlive its tab, and its `sessionId`
 * stops naming a context once that tab closes or moves (F30). The download
 * gate ([DownloadStartGate]) reads the record.
 *
 * Only records, so it sits ahead of `DownloadMiddleware`.
 */
class DownloadAttributionMiddleware(
    private val contexts: DownloadContexts = DownloadContexts,
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is DownloadAction.AddDownloadAction -> attribute(store.state, action.download)
            is DownloadAction.RemoveDownloadAction -> {
                next(action)
                contexts.forget(listOf(action.downloadId))
                return
            }
            is DownloadAction.RemoveAllDownloadsAction -> {
                next(action)
                contexts.forgetAll()
                return
            }
            else -> Unit
        }
        next(action)
    }

    private fun attribute(state: BrowserState, download: DownloadState) {
        // Unresolvable (the tab is gone already): left unknown.
        val tab = download.sessionId?.let { state.findTabOrCustomTab(it) } ?: return
        val context = tab.contextId
            ?: if (download.private) DownloadContexts.PRIVATE else DownloadContexts.DEFAULT
        contexts.record(download.id, context)
    }
}

/**
 * The A4 download start gate (5.11): refuses starting, resuming or retrying a
 * download of a restricted context, and a download of unknown context while
 * any context is restricted, since it cannot be told apart from one of the
 * frozen container's. A refused download stays paused with its notification.
 */
object DownloadStartGate {
    /** Why a download is held back. */
    enum class Hold {
        /** Its context is restricted by a freeze, or by a Resume that has not finished. */
        FROZEN,

        /** Its context's container was deleted and its site data is still being deleted (D32). */
        DELETING,

        /** Its context is not known, and some context is restricted. */
        UNKNOWN_CONTEXT,
    }

    fun mayStart(
        download: DownloadState,
        registry: TabLifecycleRegistry = TabLifecycleRegistry,
        contexts: DownloadContexts = DownloadContexts,
    ): Boolean = holdOf(download, registry, contexts) == null

    /** Why [download] may not start, resume or retry now; null when it may. */
    fun holdOf(
        download: DownloadState,
        registry: TabLifecycleRegistry = TabLifecycleRegistry,
        contexts: DownloadContexts = DownloadContexts,
    ): Hold? {
        if (!registry.anyRestricted()) return null
        return when (val context = contexts.contextOf(download.id)) {
            null -> Hold.UNKNOWN_CONTEXT
            DownloadContexts.DEFAULT, DownloadContexts.PRIVATE -> null
            else -> when {
                !registry.isRestricted(context) -> null
                registry.recordOf(context)?.phase in DELETING_PHASES -> Hold.DELETING
                else -> Hold.FROZEN
            }
        }
    }

    private val DELETING_PHASES = setOf(
        ContextPhase.DELETION_PENDING,
        ContextPhase.RELEASING,
        ContextPhase.ORPHANED,
    )
}
