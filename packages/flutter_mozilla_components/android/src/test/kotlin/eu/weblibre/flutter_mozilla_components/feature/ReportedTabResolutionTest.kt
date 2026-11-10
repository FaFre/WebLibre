/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.assertEquals
import kotlin.test.assertNull
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.EngineState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.state.content.HistoryState
import mozilla.components.browser.state.state.createTab
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.history.HistoryItem
import org.junit.Test
import org.mockito.Mockito.mock

class ReportedTabResolutionTest {
    /** A tab running in Gecko, on [url] and not yet in its history. */
    private fun running(url: String, id: String): TabSessionState =
        createTab(url, id = id).copy(
            engineState = EngineState(engineSession = mock(EngineSession::class.java)),
        )

    /** A tab that has loaded [url]. */
    private fun loaded(url: String, id: String): TabSessionState {
        val tab = running(url, id = id)
        return tab.copy(
            content = tab.content.copy(
                history = HistoryState(listOf(HistoryItem(title = "", uri = url))),
            ),
        )
    }

    /**
     * A tab restored on [url] that has not loaded yet: no engine session, and
     * an empty history until the engine reports one.
     */
    private fun restoredUnloaded(url: String, id: String): TabSessionState =
        createTab(url, id = id)

    private val state = BrowserState(
        tabs = listOf(
            loaded("https://page.example/", id = "selected"),
            // Opened in the background on a page the extension cancelled.
            running("https://work.example/", id = "fresh"),
            // Already showing that page.
            loaded("https://work.example/", id = "showing-work"),
            // A page in the background that navigates on its own.
            loaded("https://news.example/", id = "news"),
            loaded("https://twice.example/", id = "twice-1"),
            loaded("https://twice.example/", id = "twice-2"),
        ),
        selectedTabId = "selected",
    )

    private fun resolve(
        highlighted: Boolean,
        url: String,
        tabUrl: String?,
        startUrl: String? = null,
    ) = resolveReportedTabId(
        state,
        highlighted = highlighted,
        url = url,
        tabUrl = tabUrl,
        startUrl = startUrl,
    )

    @Test
    fun `a report for the highlighted tab is the selected tab`() {
        assertEquals(
            "selected",
            resolve(highlighted = true, url = "https://work.example/", tabUrl = "https://page.example/"),
        )
    }

    @Test
    fun `a tab that never showed a page is the fresh tab on the cancelled page`() {
        assertEquals(
            "fresh",
            resolve(highlighted = false, url = "https://work.example/", tabUrl = "about:blank"),
        )
    }

    @Test
    fun `a fresh tab that redirected to the cancelled page is found by where it started`() {
        assertEquals(
            "fresh",
            resolve(
                highlighted = false,
                url = "https://assigned.example/",
                tabUrl = "about:blank",
                startUrl = "https://work.example/",
            ),
        )
    }

    @Test
    fun `a navigation from a background page is the tab still on that page`() {
        assertEquals(
            "news",
            resolve(highlighted = false, url = "https://work.example/", tabUrl = "https://news.example/"),
        )
    }

    @Test
    fun `a tab already showing the cancelled page is never taken for a fresh one`() {
        val withoutFresh = state.copy(tabs = state.tabs.filter { it.id != "fresh" })

        assertNull(
            resolveReportedTabId(
                withoutFresh,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "about:blank",
            ),
        )
    }

    @Test
    fun `a tab selected before Gecko knew is still found by its page`() {
        assertEquals(
            "selected",
            resolve(highlighted = false, url = "https://work.example/", tabUrl = "https://page.example/"),
        )
    }

    @Test
    fun `a fresh tab selected before Gecko knew is still found`() {
        val freshSelected = state.copy(selectedTabId = "fresh")

        assertEquals(
            "fresh",
            resolveReportedTabId(
                freshSelected,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "about:blank",
            ),
        )
    }

    @Test
    fun `the selected tab sharing a page with a background tab is not guessed`() {
        val sharing = state.copy(selectedTabId = "twice-1")

        assertNull(
            resolveReportedTabId(
                sharing,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "https://twice.example/",
            ),
        )
    }

    @Test
    fun `a background report two tabs could be is not guessed`() {
        assertNull(
            resolve(highlighted = false, url = "https://work.example/", tabUrl = "https://twice.example/"),
        )
    }

    @Test
    fun `a background report no tab matches is dropped`() {
        assertNull(
            resolve(highlighted = false, url = "https://work.example/", tabUrl = "https://nowhere.example/"),
        )
    }

    @Test
    fun `a restored tab that has not loaded is never taken for a fresh one`() {
        val withRestored = state.copy(
            tabs = state.tabs + restoredUnloaded("https://work.example/", id = "restored"),
        )

        assertEquals(
            "fresh",
            resolveReportedTabId(
                withRestored,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "about:blank",
            ),
        )
    }

    @Test
    fun `a restored tab that has not loaded is never the only match`() {
        val onlyRestored = state.copy(
            tabs = state.tabs.filter { it.id != "fresh" } +
                restoredUnloaded("https://work.example/", id = "restored"),
        )

        assertNull(
            resolveReportedTabId(
                onlyRestored,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "about:blank",
            ),
        )
    }

    @Test
    fun `a restored tab on the same page does not make a background page ambiguous`() {
        val withRestored = state.copy(
            tabs = state.tabs + restoredUnloaded("https://news.example/", id = "restored"),
        )

        assertEquals(
            "news",
            resolveReportedTabId(
                withRestored,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "https://news.example/",
            ),
        )
    }

    @Test
    fun `a tab whose engine session is being created is still found`() {
        val initializing = state.copy(
            tabs = state.tabs.map {
                if (it.id == "fresh") it.copy(engineState = EngineState(initializing = true)) else it
            },
        )

        assertEquals(
            "fresh",
            resolveReportedTabId(
                initializing,
                highlighted = false,
                url = "https://work.example/",
                tabUrl = "about:blank",
            ),
        )
    }

    /** A popup the engine opened, still on about:blank. */
    private fun popup(id: String): TabSessionState = running("about:blank", id = id)

    private fun resolveWithPopups(
        tabs: List<TabSessionState>,
        popups: Map<String, String>,
        url: String,
        startUrl: String? = null,
    ) = resolveReportedTabId(
        state.copy(tabs = tabs),
        highlighted = false,
        url = url,
        tabUrl = "about:blank",
        startUrl = startUrl,
        popupUrlOf = popups::get,
    )

    private val withoutFresh get() = state.tabs.filter { it.id != "fresh" }

    @Test
    fun `a popup still on about blank is found by the URL it was opened for`() {
        assertEquals(
            "popup",
            resolveWithPopups(
                withoutFresh + popup("popup"),
                mapOf("popup" to "https://work.example/"),
                url = "https://work.example/",
            ),
        )
    }

    @Test
    fun `a popup that redirected to the cancelled page is found by where it started`() {
        assertEquals(
            "popup",
            resolveWithPopups(
                withoutFresh + popup("popup"),
                mapOf("popup" to "https://short.example/x"),
                url = "https://assigned.example/",
                startUrl = "https://short.example/x",
            ),
        )
    }

    @Test
    fun `a popup opened for another page is not taken`() {
        assertNull(
            resolveWithPopups(
                withoutFresh + popup("popup"),
                mapOf("popup" to "https://elsewhere.example/"),
                url = "https://work.example/",
            ),
        )
    }

    @Test
    fun `a blank tab that is no popup is not taken`() {
        assertNull(
            resolveWithPopups(
                withoutFresh + popup("blank"),
                emptyMap(),
                url = "https://work.example/",
            ),
        )
    }

    @Test
    fun `a popup opened without a URL is found while it is the only one`() {
        assertEquals(
            "popup",
            resolveWithPopups(
                withoutFresh + popup("popup"),
                mapOf("popup" to ""),
                url = "https://work.example/",
            ),
        )
        assertNull(
            resolveWithPopups(
                withoutFresh + popup("popup") + popup("other"),
                mapOf("popup" to "", "other" to ""),
                url = "https://work.example/",
            ),
        )
    }

    @Test
    fun `a popup and a fresh tab on the same page are not guessed`() {
        assertNull(
            resolveWithPopups(
                state.tabs + popup("popup"),
                mapOf("popup" to "https://work.example/"),
                url = "https://work.example/",
            ),
        )
    }
}
