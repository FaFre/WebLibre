/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.TabSessionState

/**
 * The browser tab a navigation the container extension reported belongs to.
 *
 * The extension names the tab by its WebExtension tab id, which GeckoView
 * derives from the tab's window and does not expose, so it cannot be mapped
 * to a browser tab. A report for the [highlighted] tab is the selected tab.
 * A report for a background tab (the extension sends those only for a
 * navigation it cancelled) is found by the page the tab shows, [tabUrl],
 * which a cancelled navigation does not change:
 *
 * - A tab already on a page that navigated or redirected is still on it, in
 *   Gecko and in the store alike.
 * - A tab that never showed a page (`about:blank` to Gecko) was opened on the
 *   URL the navigation started at, [startUrl] (the cancelled [url] itself
 *   unless a redirect led there), which the store already holds as its URL.
 *   Only a tab with no history yet is that tab: another tab showing that URL
 *   has loaded it.
 * - A popup the engine opened ([PopupRequests]) is the exception: its tab is
 *   created on `about:blank` with the engine session already attached, and
 *   the URL it was opened for only lives in the window request. It is found
 *   by that URL instead. A window opened without one (`window.open()`, then
 *   navigated by script) has no URL to go by and is a candidate for any such
 *   report, so it is only picked while it is the only one.
 *
 * Only a tab running in Gecko can have navigated: a restored tab that has not
 * loaded yet (or one suspended to free memory) has no engine session, and the
 * store keeps its URL with an empty history until the engine reports one, so
 * it would otherwise pass for a fresh tab on that URL, or for a tab on that
 * page, and take the report or make it ambiguous.
 *
 * The selected tab is a candidate too: Gecko learns which tab is selected
 * after the store does, so a tab selected a moment ago can still be reported
 * as a background one. Leaving it out would drop that report and leave the
 * tab blank; a URL it shares with another tab stays ambiguous all the same.
 *
 * With no such tab, or more than one, the tab cannot be told apart and null is
 * returned rather than a guess.
 */
internal fun resolveReportedTabId(
    state: BrowserState,
    highlighted: Boolean,
    url: String,
    tabUrl: String?,
    startUrl: String? = null,
    popupUrlOf: (tabId: String) -> String? = PopupRequests::urlOf,
): String? {
    if (highlighted) return state.selectedTabId

    // `initializing`: the engine session is being created and linked, which
    // happens before its first load starts.
    val running = state.tabs.filter {
        it.engineState.engineSession != null || it.engineState.initializing
    }
    val candidates = if (tabUrl == null || tabUrl == "about:blank") {
        val openedOn = startUrl ?: url
        running.filter {
            it.content.history.items.isEmpty() &&
                (it.content.url == openedOn || it.isBlankPopupFor(openedOn, url, popupUrlOf))
        }
    } else {
        running.filter { it.content.url == tabUrl }
    }
    return candidates.singleOrNull()?.id
}

/** A popup still on `about:blank` that was opened for [openedOn] or [url]. */
private fun TabSessionState.isBlankPopupFor(
    openedOn: String,
    url: String,
    popupUrlOf: (tabId: String) -> String?,
): Boolean {
    if (content.url != "about:blank") return false
    val requested = popupUrlOf(id) ?: return false
    return requested.isEmpty() || requested == "about:blank" ||
        requested == openedOn || requested == url
}

/**
 * The URL each popup the engine opened was requested for, by its tab, which
 * the store does not keep: AC adds such a tab on `about:blank` with the
 * popup's engine session. Read by [resolveReportedTabId] to find a popup
 * whose first navigation the container extension cancelled. Only the latest
 * few are kept: a popup's first navigation follows its opening at once.
 */
internal object PopupRequests {
    private const val LIMIT = 32
    private val urls = LinkedHashMap<String, String>()

    @Synchronized
    fun record(tabId: String, url: String) {
        urls.remove(tabId)
        urls[tabId] = url
        while (urls.size > LIMIT) urls.remove(urls.keys.first())
    }

    @Synchronized
    fun urlOf(tabId: String): String? = urls[tabId]
}
