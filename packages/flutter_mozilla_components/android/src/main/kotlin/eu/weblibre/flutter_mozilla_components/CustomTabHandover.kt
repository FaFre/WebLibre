/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components

import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.store.BrowserStore

/**
 * Moves the custom tabs of an outgoing component set's store into [to].
 *
 * A Custom Tab or PWA window can outlive the components it was opened with:
 * the app half starting (the browser opened, a password check) replaces the
 * external set with a full one. Copying the tab is not enough. Its engine
 * session reports to an observer registered with the store it was linked
 * in, and adding the tab to another store does not move that observer: the
 * page would go on updating the outgoing store, so the window's URL and back
 * state would go stale and the page's prompts would reach nobody.
 *
 * So each tab's observer is taken off its engine session, and the session is
 * linked into [to] again, which registers one for [to]. Nothing is loaded
 * again; the page stays as it is.
 *
 * Takes the tabs from [from] as they are now rather than from a copy made
 * when the rebuild began: [from] kept receiving the page's updates until here.
 */
internal fun handOverCustomTabs(from: BrowserStore, to: BrowserStore) {
    for (tab in from.state.customTabs) {
        if (to.state.findCustomTab(tab.id) != null) continue

        val engineSession = tab.engineState.engineSession
        tab.engineState.engineObserver?.let { engineSession?.unregister(it) }

        to.dispatch(
            CustomTabListAction.AddCustomTabAction(
                tab.copy(engineState = tab.engineState.copy(engineObserver = null)),
            ),
        )
        if (engineSession != null) {
            to.dispatch(
                EngineAction.LinkEngineSessionAction(tab.id, engineSession, skipLoading = true),
            )
        }
    }
}
