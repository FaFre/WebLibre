/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.createCustomTab
import mozilla.components.browser.state.state.createTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.request.RequestInterceptor
import mozilla.components.feature.session.SessionUseCases
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.verifyNoInteractions
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * A link that targeted a new tab is asked about on its opener. Whatever the user keeps in the
 * browser from it must open in a new tab of that opener — never replace the opener's page, never
 * reach the live web from a sandbox tab, and never take focus the user did not give it.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AppLinkNewTabTest {
    private data class AddedTab(
        val url: String,
        val selectTab: Boolean,
        val startLoading: Boolean,
        val parentId: String,
        val contextId: String?,
        val private: Boolean,
        val flags: EngineSession.LoadUrlFlags,
    )

    private class FakeNewTabHost(
        override val browserStore: BrowserStore,
        var current: Boolean = true,
        private val sandboxTabs: Set<String> = emptySet(),
        private val pendingStore: PendingAppLinkStore = PendingAppLinkStore(clock = { 0L }),
    ) : NewTabHost {
        val calls = mutableListOf<String>()
        val added = mutableListOf<AddedTab>()
        val loads = mutableListOf<Triple<String, String, EngineSession.LoadUrlFlags>>()
        val sandboxClicks = mutableListOf<Triple<String, String, Boolean>>()
        val reentries = mutableListOf<Pair<String, String>>()

        override fun isCurrent(): Boolean = current

        override fun isSandboxCapture(tabId: String): Boolean = tabId in sandboxTabs

        override fun dispatchSandboxLinkClick(parentTabId: String, url: String, selectTab: Boolean) {
            calls += "sandbox"
            sandboxClicks += Triple(parentTabId, url, selectTab)
        }

        override fun addTab(
            url: String,
            selectTab: Boolean,
            startLoading: Boolean,
            parentId: String,
            contextId: String?,
            private: Boolean,
            flags: EngineSession.LoadUrlFlags,
        ): String {
            calls += "add"
            added += AddedTab(url, selectTab, startLoading, parentId, contextId, private, flags)
            return NEW_TAB
        }

        override fun loadUrl(url: String, tabId: String, flags: EngineSession.LoadUrlFlags) {
            calls += "load"
            loads += Triple(url, tabId, flags)
        }

        override fun recordFallbackReentry(tabId: String, url: String) {
            calls += "reentry"
            reentries += tabId to url
        }

        override fun recordSuppression(tabId: String, key: String) {
            calls += "suppress"
            pendingStore.recordSuppression(tabId, key)
        }
    }

    private fun store(selectedTabId: String = OPENER) = BrowserStore(
        BrowserState(
            tabs = listOf(
                createTab("https://source.example/page", id = OPENER, contextId = CONTEXT),
                createTab("https://other.example/", id = OTHER),
            ),
            selectedTabId = selectedTabId,
        ),
    )

    @Test
    fun aHeldLinkOpensAChildTabInTheOpenersContext() {
        val host = FakeNewTabHost(store())

        val opened = openInNewTab(
            host, OPENER, URL, NewTabLoad.HELD, NewTabFocus.ALWAYS, reason = "test",
        )

        assertTrue(opened)
        assertEquals(
            listOf(
                AddedTab(
                    URL,
                    selectTab = true,
                    startLoading = false,
                    parentId = OPENER,
                    contextId = CONTEXT,
                    private = false,
                    flags = SELF_ISSUED_LOAD_FLAGS,
                ),
            ),
            host.added,
        )
        assertEquals(listOf("add", "load"), host.calls)
        // Loaded into the new tab only, never into the opener.
        assertEquals(listOf(Triple(URL, NEW_TAB, SELF_ISSUED_LOAD_FLAGS)), host.loads)
    }

    @Test
    fun aFallbackIsRecordedForTheNewTabBeforeItLoads() {
        val host = FakeNewTabHost(store())

        openInNewTab(host, OPENER, URL, NewTabLoad.FALLBACK, NewTabFocus.ALWAYS, reason = "test")

        // Recorded first, or the fallback's own load is offered straight back to an app.
        assertEquals(listOf("add", "reentry", "load"), host.calls)
        val added = host.added.single()
        assertFalse(added.startLoading)
        assertEquals(CONTEXT, added.contextId)
        assertEquals(listOf(NEW_TAB to URL), host.reentries)
        assertEquals(listOf(Triple(URL, NEW_TAB, FALLBACK_LOAD_FLAGS)), host.loads)
    }

    @Test
    fun aPageAskedTabTakesFocusOnlyFromTheTabInView() {
        val inView = FakeNewTabHost(store(selectedTabId = OPENER))
        openInNewTab(inView, OPENER, URL, NewTabLoad.FALLBACK, NewTabFocus.IF_OPENER_SELECTED, "test")
        assertTrue(inView.added.single().selectTab)

        val inBackground = FakeNewTabHost(store(selectedTabId = OTHER))
        openInNewTab(inBackground, OPENER, URL, NewTabLoad.FALLBACK, NewTabFocus.IF_OPENER_SELECTED, "test")
        assertFalse(inBackground.added.single().selectTab)
    }

    @Test
    fun aSandboxOpenerNeverGetsALiveTab() {
        // An `intent:` link is inert in a sandbox tab and reaches the app-link fallback. A native tab
        // would be rewritten to about:blank by the middleware and then loaded live anyway.
        val host = FakeNewTabHost(store(selectedTabId = OTHER), sandboxTabs = setOf(OPENER))

        val opened = openInNewTab(
            host, OPENER, URL, NewTabLoad.FALLBACK, NewTabFocus.IF_OPENER_SELECTED, reason = "test",
        )

        assertTrue(opened)
        assertEquals(listOf("sandbox"), host.calls)
        // Through the capture flow, and without taking focus from the tab in view.
        assertEquals(listOf(Triple(OPENER, URL, false)), host.sandboxClicks)
    }

    @Test
    fun aQueuedOpenWhoseOpenerClosedDoesNothing() {
        val host = FakeNewTabHost(store())

        val opened = openInNewTab(
            host, "closed-opener", URL, NewTabLoad.FALLBACK, NewTabFocus.ALWAYS, reason = "test",
        )

        assertFalse(opened)
        assertTrue(host.calls.isEmpty())
    }

    @Test
    fun aQueuedOpenAfterTheComponentsWentAwayDoesNothing() {
        // Torn down or replaced while the open waited: the old store still lists the opener.
        val host = FakeNewTabHost(store(), current = false)

        val opened = openInNewTab(
            host, OPENER, URL, NewTabLoad.FALLBACK, NewTabFocus.ALWAYS, reason = "test",
        )

        assertFalse(opened)
        assertTrue(host.calls.isEmpty())
    }

    @Test
    fun stayingInTheBrowserOpensTheNewTabInsteadOfLoadingIntoTheOpener() {
        val browserStore = store(selectedTabId = OTHER)
        val sessionUseCases = mock(SessionUseCases::class.java)
        val pendingStore = PendingAppLinkStore(clock = { 0L })
        val host = FakeNewTabHost(browserStore, pendingStore = pendingStore)
        val request = pendingStore.createRequest(heldForNewTab())
        assertNotNull(pendingStore.consume(request.requestId))
        // What the "stay in browser" answer records for the opener before releasing.
        pendingStore.recordSuppression(request.tabId, request.suppressionKey)

        releaseHeldNavigation(
            pendingStore,
            browserStore,
            sessionUseCases,
            request,
            reason = "cancel",
            newTabHost = host,
            suppressionKey = request.suppressionKey,
        )

        verifyNoInteractions(sessionUseCases)
        // The user chose it in the prompt, so it takes focus even from the background.
        assertEquals(OPENER, host.added.single().parentId)
        assertTrue(host.added.single().selectTab)
        // The answer follows the page: the new tab's next navigation on this site must not ask
        // again. Recorded before the first load reaches the interceptor.
        assertEquals(listOf("add", "suppress", "load"), host.calls)
        assertTrue(pendingStore.isSuppressed(NEW_TAB, request.suppressionKey))
        assertTrue(pendingStore.isSuppressed(OPENER, request.suppressionKey))
    }

    @Test
    fun aNewTabHoldWithoutAHostIsDroppedRatherThanLoadedIntoTheOpener() {
        val browserStore = store()
        val sessionUseCases = mock(SessionUseCases::class.java)
        val pendingStore = PendingAppLinkStore(clock = { 0L })
        val request = pendingStore.createRequest(heldForNewTab())
        assertNotNull(pendingStore.consume(request.requestId))

        releaseHeldNavigation(pendingStore, browserStore, sessionUseCases, request, reason = "cancel")

        verifyNoInteractions(sessionUseCases)
    }

    @Test
    fun onlyTheBrowsersOwnTabsOpenANewTab() {
        val tab = createTab("https://source.example/", id = OPENER)
        val customTab = createCustomTab("https://source.example/", id = "custom")

        assertTrue(opensNewTab(isNewWindowRequest = true, isSubframeRequest = false, session = tab))
        // A Custom Tab has no tab strip: its loads stay in place.
        assertFalse(opensNewTab(isNewWindowRequest = true, isSubframeRequest = false, session = customTab))
        assertFalse(opensNewTab(isNewWindowRequest = true, isSubframeRequest = true, session = tab))
        assertFalse(opensNewTab(isNewWindowRequest = false, isSubframeRequest = false, session = tab))
        assertFalse(opensNewTab(isNewWindowRequest = true, isSubframeRequest = false, session = null))
    }

    @Test
    fun aLoadForANewTabNeverMovesItsOpener() {
        val deny = RequestInterceptor.InterceptionResponse.Deny

        assertFalse(movesTab(isSubframeRequest = false, opensNewWindow = true, response = null))
        assertFalse(movesTab(isSubframeRequest = false, opensNewWindow = true, response = deny))
        assertTrue(movesTab(isSubframeRequest = false, opensNewWindow = false, response = null))
        assertFalse(movesTab(isSubframeRequest = false, opensNewWindow = false, response = deny))
        assertFalse(movesTab(isSubframeRequest = true, opensNewWindow = false, response = null))
    }

    private fun heldForNewTab() = NewAppLinkRequest(
        owner = AppLinkPromptOwner.FLUTTER_BROWSER,
        tabId = OPENER,
        contextId = CONTEXT,
        sourceUrl = null,
        isPrivate = false,
        isWallet = false,
        isProtectedContext = false,
        canRemember = true,
        isModal = false,
        urlClass = AppLinkUrlClass.BANNER,
        url = URL,
        expectedPackage = null,
        fallbackUrl = null,
        engineSupportsScheme = true,
        isMarketplace = false,
        targetFingerprint = "fp",
        appName = "App",
        packageName = "com.app",
        scopeKey = "pkg:com.app",
        heldNavigation = true,
        opensNewWindow = true,
    )

    private companion object {
        const val OPENER = "opener"
        const val OTHER = "other"
        const val NEW_TAB = "new-tab"
        const val CONTEXT = "container-context"
        const val URL = "https://app.example/watch"
    }
}
