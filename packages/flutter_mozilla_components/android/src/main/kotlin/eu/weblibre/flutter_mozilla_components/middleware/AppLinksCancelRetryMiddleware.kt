/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import android.os.Handler
import android.os.Looper
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.EngineSession.LoadUrlFlags.Companion.EXTERNAL
import mozilla.components.concept.engine.EngineSession.LoadUrlFlags.Companion.LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Workaround for Android Components/GeckoView app-link cancel handling: the
 * cancel load can be clobbered by Gecko's recovery load back to the previous
 * history entry. This retries only that specific cancel-load signature.
 */
class AppLinksCancelRetryMiddleware(
    private val handler: Handler = Handler(Looper.getMainLooper()),
    private val retryDelayMillis: Long = RETRY_DELAY_MILLIS,
) : Middleware<BrowserState, BrowserAction> {
    private val pendingCancels = mutableMapOf<String, PendingCancel>()

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is EngineAction.OptimizedLoadUrlTriggeredAction -> {
                recordCancelLoad(store, action)
            }
            is ContentAction.UpdateLoadRequestAction -> {
                handleLoadRequest(store, action)
            }
            is ContentAction.UpdateUrlAction -> {
                handleUrlUpdate(action)
            }
            else -> {}
        }

        next(action)
    }

    private fun recordCancelLoad(
        store: Store<BrowserState, BrowserAction>,
        action: EngineAction.OptimizedLoadUrlTriggeredAction,
    ) {
        if (!action.flags.contains(EXTERNAL) ||
            !action.flags.contains(LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE)
        ) {
            return
        }

        val sourceUrl = store.state.findTabOrCustomTab(action.tabId)?.content?.url
            ?: return
        if (sourceUrl == action.url || sourceUrl == ABOUT_BLANK) {
            return
        }

        pendingCancels[action.tabId] = PendingCancel(
            tabId = action.tabId,
            sourceUrl = sourceUrl,
            targetUrl = action.url,
        )
    }

    private fun handleLoadRequest(
        store: Store<BrowserState, BrowserAction>,
        action: ContentAction.UpdateLoadRequestAction,
    ) {
        val pending = pendingCancels[action.sessionId] ?: return
        when (action.loadRequest.url) {
            pending.sourceUrl -> scheduleRetry(store, pending)
            pending.targetUrl -> pendingCancels.remove(action.sessionId)
            ABOUT_BLANK -> {}
            else -> pendingCancels.remove(action.sessionId)
        }
    }

    private fun handleUrlUpdate(action: ContentAction.UpdateUrlAction) {
        val pending = pendingCancels[action.sessionId] ?: return
        when (action.url) {
            pending.targetUrl -> pendingCancels.remove(action.sessionId)
            pending.sourceUrl, ABOUT_BLANK -> {}
            else -> pendingCancels.remove(action.sessionId)
        }
    }

    private fun scheduleRetry(
        store: Store<BrowserState, BrowserAction>,
        pending: PendingCancel,
    ) {
        if (pending.retryScheduled) {
            return
        }

        val scheduled = pending.copy(retryScheduled = true)
        pendingCancels[pending.tabId] = scheduled

        handler.postDelayed({
            if (pendingCancels[pending.tabId] != scheduled) {
                return@postDelayed
            }

            val currentUrl = store.state.findTabOrCustomTab(pending.tabId)?.content?.url
            if (currentUrl == pending.targetUrl) {
                pendingCancels.remove(pending.tabId)
                return@postDelayed
            }

            if (currentUrl == pending.sourceUrl || currentUrl == ABOUT_BLANK) {
                pendingCancels.remove(pending.tabId)
                store.dispatch(
                    EngineAction.LoadUrlAction(
                        tabId = pending.tabId,
                        url = pending.targetUrl,
                        flags = EngineSession.LoadUrlFlags.select(
                            LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE,
                        ),
                    ),
                )
            } else {
                pendingCancels.remove(pending.tabId)
            }
        }, retryDelayMillis)
    }

    private data class PendingCancel(
        val tabId: String,
        val sourceUrl: String,
        val targetUrl: String,
        val retryScheduled: Boolean = false,
    )

    private companion object {
        const val ABOUT_BLANK = "about:blank"
        const val RETRY_DELAY_MILLIS = 1000L
    }
}
