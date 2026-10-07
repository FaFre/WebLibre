/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.components

import java.io.IOException
import mozilla.components.browser.session.storage.AutoSave
import mozilla.components.browser.state.selector.normalTabs
import mozilla.components.browser.state.state.BrowserState

/**
 * The only writer of the session file: [AutoSave] and explicit saves both go
 * through it.
 *
 * Every write is serialized and saves the store's state as it is *at write time*,
 * ignoring the snapshot it was handed. [AutoSave] reads the store and then writes,
 * and nothing orders that against a save made elsewhere — so an autosave that read
 * the tabs just before they were all removed could otherwise land after the save
 * that recorded their removal, and bring them back on the next launch. Here, a
 * later write always reads a state at least as new as the one before it, so the
 * file can never move backwards.
 */
class CurrentStateSessionWriter(
    private val delegate: AutoSave.Storage,
    private val currentState: () -> BrowserState,
    /**
     * Whether no session is left on disk. A session with no normal tabs is saved
     * by deleting the file, and `SessionStorage.save` reports that as a success
     * without checking it happened.
     */
    private val isCleared: () -> Boolean,
) : AutoSave.Storage {
    private val lock = Any()

    /** Saves the current state; [state] is deliberately ignored. See the class docs. */
    override fun save(state: BrowserState): Boolean = saveCurrentState()

    /** Writes the store's current state to disk before returning. */
    fun saveCurrentState(): Boolean = synchronized(lock) {
        delegate.save(currentState())
    }

    /**
     * Runs [block] while no write is in progress or can start: the file holds what
     * the last write saved, and any later write reads the store after [block]
     * returns.
     *
     * For reading the file next to the store as one consistent picture. The file
     * lock inside `SessionStorage` alone does not give that: a write reads the
     * store before it takes the file lock, so a read in between sees the old file
     * while the write about to land still carries a state from before.
     */
    fun <T> whileNotWriting(block: () -> T): T = synchronized(lock) { block() }

    /**
     * Like [saveCurrentState], for a deletion that must be on disk when it returns:
     * throws instead of reporting a failed write, so the caller does not count the
     * deletion as done while the old session file still holds the removed tabs.
     *
     * `SessionStorage.save` returns false on an I/O failure (a full disk, say)
     * rather than throwing, and does not check the file deletion that saving an
     * empty session is — both are checked here, under the same lock as the write.
     */
    fun saveCurrentStateOrThrow() = synchronized(lock) {
        val state = currentState()

        if (!delegate.save(state)) {
            throw IOException("Writing the session file failed")
        }
        if (state.normalTabs.isEmpty() && !isCleared()) {
            throw IOException("Removing the session file failed")
        }
    }
}
