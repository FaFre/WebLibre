/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * The tabs the main browser presented last (`BrowserPanes.lastPresentedTabIds`),
 * kept outside the pane coordinator so that a coordinator built anew for the same
 * window (a configuration change, a view rebuilt) does not read its first
 * reconcile as presenting those tabs again: the schedulers would count them as
 * just seen, and a rebuilt view is not that (5.1). Coming on screen never wakes
 * a sleeping tab (D10).
 *
 * Main thread only.
 */
class PresentationMemory {
    private val presented = MutableStateFlow<Set<String>>(emptySet())

    var tabIds: Set<String>
        get() = presented.value
        set(value) {
            presented.value = value
        }

    /**
     * [tabIds] as it changes, for automatic sleep, which records when each tab
     * left the screen (F19, 5.9).
     */
    val changes: StateFlow<Set<String>> = presented.asStateFlow()

    companion object {
        /** The process's main browser. */
        val process = PresentationMemory()
    }
}
