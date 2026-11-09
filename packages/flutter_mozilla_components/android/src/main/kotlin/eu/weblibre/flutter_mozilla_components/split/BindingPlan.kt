/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

/**
 * Which tab each pane shows after a change of the visible tabs.
 *
 * Stable bindings: a pane keeps the tab it already shows while that tab is
 * still a target, so a focus change, a swap or a mode change never moves a
 * session between views. Panes whose tab left are freed, and the remaining
 * targets go to free panes in order (pane 0 first).
 *
 * [current] has one entry per pane (null for a free one). The result has the
 * same size. A tab is never bound to two panes.
 *
 * @throws IllegalArgumentException when there are more distinct targets than
 * panes; the caller creates panes first.
 */
internal fun planBindings(current: List<String?>, targets: List<String>): List<String?> {
    val remaining = targets.distinct().toMutableList()
    require(remaining.size <= current.size) {
        "${remaining.size} targets for ${current.size} panes"
    }

    val result = MutableList<String?>(current.size) { null }
    current.forEachIndexed { index, tabId ->
        if (tabId != null && remaining.remove(tabId)) {
            result[index] = tabId
        }
    }

    for (index in result.indices) {
        if (remaining.isEmpty()) break
        if (result[index] == null) {
            result[index] = remaining.removeAt(0)
        }
    }

    return result
}
