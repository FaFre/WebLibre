/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.state.ContentState
import mozilla.components.browser.state.state.TabSessionState
import mozilla.components.browser.state.state.WebExtensionState
import mozilla.components.concept.engine.webextension.Action

/**
 * Every render sends each extension action to Flutter, so the toolbar feature
 * must re-render for what it shows and nothing else — above all not for every
 * tick of a page load's progress.
 */
class WebExtensionActionChangesTest {
    private val action = Action(
        title = "Extension",
        enabled = true,
        loadIcon = null,
        badgeText = null,
        badgeTextColor = null,
        badgeBackgroundColor = null,
        onClick = {},
    )
    private val extension = WebExtensionState(id = "extension", browserAction = action)
    private val selected = TabSessionState(id = "selected", content = ContentState("https://example.test"))
    private val other = TabSessionState(id = "other", content = ContentState("https://other.test"))
    private val initial = BrowserState(
        tabs = listOf(selected, other),
        selectedTabId = selected.id,
        extensions = mapOf(extension.id to extension),
    )

    private fun BrowserState.updateTab(
        id: String = selectedTabId!!,
        update: (TabSessionState) -> TabSessionState,
    ) = copy(tabs = tabs.map { if (it.id == id) update(it) else it })

    private fun TabSessionState.updateContent(update: (ContentState) -> ContentState) =
        copy(content = update(content))

    private fun emitted(vararg states: BrowserState) = runBlocking {
        flowOf(*states).webExtensionActionChanges().toList()
    }

    @Test
    fun `a page load on the selected tab does not re-render`() {
        val loading = initial.updateTab { tab -> tab.updateContent { it.copy(loading = true, progress = 10) } }
        val progressed = loading.updateTab { tab -> tab.updateContent { it.copy(progress = 60, title = "Example") } }
        val loaded = progressed.updateTab { tab -> tab.updateContent { it.copy(loading = false, progress = 100) } }

        assertEquals(listOf(initial), emitted(initial, loading, progressed, loaded))
    }

    @Test
    fun `a change to another tab does not re-render`() {
        val otherBadge = mapOf(extension.id to extension.copy(browserAction = action.copy(badgeText = "9")))
        val changed = initial.updateTab(other.id) { it.copy(extensionState = otherBadge) }

        assertEquals(listOf(initial), emitted(initial, changed))
    }

    @Test
    fun `everything the render reads re-renders`() {
        val badge = mapOf(extension.id to extension.copy(browserAction = action.copy(badgeText = "3")))
        val tabOverride = initial.updateTab { it.copy(extensionState = badge) }
        val switched = tabOverride.copy(selectedTabId = other.id)
        val madePrivate = switched.updateTab { tab -> tab.updateContent { it.copy(private = true) } }
        val disabled = madePrivate.copy(extensions = mapOf(extension.id to extension.copy(enabled = false)))

        val states = arrayOf(initial, tabOverride, switched, madePrivate, disabled)

        assertEquals(states.toList(), emitted(*states))
    }
}
