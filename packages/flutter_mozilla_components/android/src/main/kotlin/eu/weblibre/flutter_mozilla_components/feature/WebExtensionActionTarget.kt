/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.lib.state.ext.flow
import mozilla.components.lib.state.ext.flowScoped

/**
 * How long a browser/page action click waits for the tab it targets to become
 * active in Gecko before it is sent anyway.
 */
internal const val WEB_EXTENSION_ACTION_TAB_TIMEOUT_MS = 3_000L

/**
 * Gives a browser/page action click a tab Gecko can resolve it against
 * (issue #542).
 *
 * Gecko resolves the click against `tabTracker.activeTab`, the window of the
 * last session marked active for web extensions, and never forgets a closed
 * one. With no live active tab the click fails inside Gecko and no popup opens.
 * The target depends on what the user is looking at:
 *
 * - **A selected tab without a session.** Restored tabs have none until they
 *   are painted. Its session is created here: the click is about that tab
 *   (`activeTab` permission, content scripts, the popup's `tabs.query`).
 * - **No selected tab.** This is the home surface on the first full start
 *   (tabs are restored with no selection) or after the last tab was closed.
 *   Waking a restored tab the user is not looking at would load its page
 *   behind their back, so the click gets a view-less `about:blank` session
 *   instead: an active tab with no page, as on a desktop new-tab page. It
 *   stays out of the [BrowserStore] and is closed as soon as a real tab
 *   becomes active, so extensions never see two active tabs.
 *
 * Either way, Gecko applies "active" only once the session's window exists,
 * and that happens asynchronously while the click travels over the global
 * dispatcher. So [prepare] waits for the session's first load to start, up to
 * [timeoutMillis].
 */
internal class WebExtensionActionTarget(
    private val store: BrowserStore,
    private val createBlankSession: () -> EngineSession,
    private val timeoutMillis: Long = WEB_EXTENSION_ACTION_TAB_TIMEOUT_MS,
    private val mainDispatcher: CoroutineDispatcher = Dispatchers.Main,
) {
    private var blankSession: EngineSession? = null
    private var scope: CoroutineScope? = null

    fun start() {
        scope = store.flowScoped(dispatcher = mainDispatcher) { flow ->
            flow.map { it.activeWebExtensionTabId }
                .distinctUntilChanged()
                .collect { activeTabId ->
                    if (activeTabId != null) closeBlankSession()
                }
        }
    }

    fun stop() {
        scope?.cancel()
        scope = null
        closeBlankSession()
    }

    /** Must be called on the main thread, right before the click. */
    suspend fun prepare() {
        val state = store.state
        val selectedTabId = state.selectedTabId

        if (selectedTabId == null) {
            prepareBlankSession()
        } else if (state.activeWebExtensionTabId != selectedTabId) {
            prepareSelectedTab(selectedTabId)
        }
    }

    private suspend fun prepareSelectedTab(tabId: String) {
        val tab = store.state.findTab(tabId) ?: return
        // Already has a session that is not the active one: nothing to wake.
        if (tab.engineState.engineSession != null) return

        store.dispatch(EngineAction.CreateEngineSessionAction(tabId))

        withTimeoutOrNull(timeoutMillis) {
            store.flow().first { it.isLiveWebExtensionTab(tabId) }
        }
    }

    private suspend fun prepareBlankSession() {
        // Still open means no tab has become active since it was marked.
        if (blankSession != null) return

        val session = createBlankSession()
        blankSession = session

        val loadStarted = CompletableDeferred<Unit>()
        val observer = object : EngineSession.Observer {
            override fun onLocationChange(url: String, hasUserGesture: Boolean) {
                loadStarted.complete(Unit)
            }

            override fun onLoadingStateChange(loading: Boolean) {
                loadStarted.complete(Unit)
            }

            override fun onProgress(progress: Int) {
                loadStarted.complete(Unit)
            }
        }
        session.register(observer)

        // Marked before the load so both land on the session's window in this
        // order: by the time the load reports back, Gecko has applied the mark.
        session.markActiveForWebExtensions(true)
        session.loadUrl(BLANK_URL)

        withTimeoutOrNull(timeoutMillis) { loadStarted.await() }
        session.unregister(observer)
    }

    private fun closeBlankSession() {
        blankSession?.close()
        blankSession = null
    }

    private fun BrowserState.isLiveWebExtensionTab(tabId: String): Boolean {
        if (activeWebExtensionTabId != tabId) return false
        val content = findTab(tabId)?.content ?: return false
        return content.loading || content.progress > 0
    }

    private companion object {
        const val BLANK_URL = "about:blank"
    }
}
