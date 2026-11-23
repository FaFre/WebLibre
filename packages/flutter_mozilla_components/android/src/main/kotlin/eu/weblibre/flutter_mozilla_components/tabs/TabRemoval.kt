/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.tabs

import eu.weblibre.flutter_mozilla_components.pigeons.TabRemovalResult
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.UndoAction
import mozilla.components.browser.state.selector.findTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Store

/**
 * Removes [tabIds] so that they cannot be undone, keeping locked tabs.
 *
 * Locked and missing ids are dropped first. When none is left this returns
 * before touching anything: [beforeRemoval] is not called and no undo entry is
 * cleared.
 *
 * [mozilla.components.feature.session.middleware.undo.UndoMiddleware] records
 * every [TabListAction.RemoveTabsAction] for "undo close", so the entry it makes
 * is cleared by its tag. Dispatch is synchronous, so the tag read right after is
 * that entry's. When the tag did not change, nothing was recorded, and the entry
 * there belongs to an unrelated close: it is left alone.
 *
 * Clearing that entry is what files tabs under recently closed, so
 * [beforeRemoval] gets the ids first, to keep them off that list too.
 *
 * @return the ids that were removed.
 */
internal fun Store<BrowserState, BrowserAction>.removeTabsNonRecoverably(
    tabIds: Collection<String>,
    beforeRemoval: (List<String>) -> Unit = {},
    isLocked: (String) -> Boolean = TabCloseProtection::isLocked,
): List<String> {
    val removable = tabIds.distinct().filter { state.findTab(it) != null && !isLocked(it) }
    if (removable.isEmpty()) return emptyList()

    beforeRemoval(removable)
    val tagBefore = state.undoHistory.tag
    dispatch(TabListAction.RemoveTabsAction(removable))
    val tagAfter = state.undoHistory.tag
    if (tagAfter != tagBefore) {
        dispatch(UndoAction.ClearRecoverableTabs(tagAfter))
    }
    return removable.filter { state.findTab(it) == null }
}

/**
 * Runs [remove] on [tabIds] and reports what it did: which tabs went, which
 * stayed because they are locked, and which were not open to begin with.
 *
 * Dispatch is synchronous, so the store read after [remove] is its result. A
 * tab that is still open and not locked is in none of the lists: native refused
 * it for another reason, and the caller sees it as a survivor.
 */
internal fun Store<BrowserState, BrowserAction>.reportRemoval(
    tabIds: List<String>,
    isLocked: (String) -> Boolean = TabCloseProtection::isLocked,
    remove: () -> Unit,
): TabRemovalResult {
    val requested = tabIds.distinct()
    val openBefore = state.tabs.mapTo(HashSet()) { it.id }
    val present = requested.filter { it in openBefore }
    remove()
    val openAfter = state.tabs.mapTo(HashSet()) { it.id }
    val stillPresent = present.filter { it in openAfter }.toSet()

    return TabRemovalResult(
        removedTabIds = present.filter { it !in stillPresent },
        lockedTabIds = stillPresent.filter(isLocked),
        missingTabIds = requested.filter { it !in present },
    )
}

/**
 * Drops the pending undo close when it would restore one of [tabIds] or a tab
 * that ran in one of [contextIds], and returns whether it did.
 *
 * Deleting a container calls this: its closes are recorded for undo like any
 * other, and so may be closes of its tabs from just before. Undone, they would
 * come back running in the deleted container's cookie store, with no
 * container to route them. The entry goes whole, cleared by its tag, as its
 * timeout would clear it, so its other tabs go on the recently closed list
 * just as they would once the undo ran out.
 */
internal fun Store<BrowserState, BrowserAction>.discardUndoOf(
    tabIds: Collection<String>,
    contextIds: Collection<String>,
): Boolean {
    val history = state.undoHistory
    val restoresAny = history.tabs.any {
        it.state.id in tabIds || it.state.contextId in contextIds
    }
    if (!restoresAny) return false

    dispatch(UndoAction.ClearRecoverableTabs(history.tag))
    return true
}
