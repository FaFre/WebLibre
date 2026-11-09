/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.split

import eu.weblibre.flutter_mozilla_components.pigeons.SplitViewState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * The last split state Dart pushed.
 *
 * Process-level rather than on `Components`, which is rebuilt on an
 * external → full promotion: the coordinator of a recreated fragment rebuilds
 * the panes from it without a Dart round trip.
 *
 * Ordering: every Dart producer picks its own epoch and counts revisions from
 * one within it. A state with a different epoch is always accepted (a new
 * producer replaces the old one, e.g. after a hot restart or an engine
 * recreation), and within an epoch only a higher revision is.
 */
internal open class SplitStateMirrorStore {
    private val _state = MutableStateFlow<SplitViewState?>(null)
    val state: StateFlow<SplitViewState?> = _state.asStateFlow()

    private val clearListeners = mutableListOf<() -> Unit>()

    /** The epoch of the producer this mirror follows, or null once cleared. */
    val epoch: String?
        get() = _state.value?.epoch

    /** Applies [next] unless it is stale. Returns whether it was applied. */
    @Synchronized
    fun accept(next: SplitViewState): Boolean {
        val current = _state.value
        if (current != null && current.epoch == next.epoch && next.revision <= current.revision) {
            return false
        }
        _state.value = next
        return true
    }

    /**
     * Forgets the state, when the Flutter engine that pushed it detaches. The
     * pair lives in that engine's memory, so a pair kept here would be one
     * nobody controls.
     */
    fun clear() {
        synchronized(this) { _state.value = null }
        clearListeners.toList().forEach { it() }
    }

    /** [listener] runs on [clear], e.g. to cancel a divider drag in flight. */
    fun addClearListener(listener: () -> Unit) {
        clearListeners += listener
    }

    fun removeClearListener(listener: () -> Unit) {
        clearListeners -= listener
    }
}

internal object SplitStateMirror : SplitStateMirrorStore()
