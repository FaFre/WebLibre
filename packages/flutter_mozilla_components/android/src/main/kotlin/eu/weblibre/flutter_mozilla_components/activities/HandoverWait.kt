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
package eu.weblibre.flutter_mozilla_components.activities

/**
 * A window's side of custom tabs moving to new components
 * (`GlobalComponents.isHandingOverCustomTabs`).
 *
 * Two rules, each one a way the window broke without them:
 *
 * - **Nothing runs while the window may not act.** Both outcomes commit a
 *   fragment transaction or start an activity, which a stopped window cannot
 *   do: a commit after `onSaveInstanceState` throws. Whatever happens then is
 *   kept, the later outcome replacing the earlier, and run by [runDeferred]
 *   when the window resumes.
 * - **The wait ends once.** The handover arriving cancels the timeout, even
 *   when what follows has to be deferred. And giving up is final: [await]'s
 *   `onGaveUp` must not wait again, or a handover that never finishes keeps
 *   the window blank for good.
 *
 * [schedule] runs a block after a delay and returns what cancels it.
 */
internal class HandoverWait(
    private val timeoutMs: Long,
    private val schedule: (delayMs: Long, block: () -> Unit) -> (() -> Unit),
    private val mayAct: () -> Boolean,
) {
    /** Whether the window waits for the handover to show its session. */
    var isWaiting = false
        private set

    private var cancelTimeout: (() -> Unit)? = null
    private var deferred: (() -> Unit)? = null

    /** Waits; [onGaveUp] runs once if the handover has not arrived in time. */
    fun await(onGaveUp: () -> Unit) {
        isWaiting = true
        if (cancelTimeout != null) return

        cancelTimeout = schedule(timeoutMs) {
            cancelTimeout = null
            act {
                if (!isWaiting) return@act
                isWaiting = false
                onGaveUp()
            }
        }
    }

    /**
     * The handover finished. Runs [action] once the window may act, told
     * whether it ended a wait.
     */
    fun arrived(action: (endedWait: Boolean) -> Unit) {
        cancelTimeout?.invoke()
        cancelTimeout = null

        act {
            val endedWait = isWaiting
            isWaiting = false
            action(endedWait)
        }
    }

    /** Runs what had to wait for the window; returns whether anything did. */
    fun runDeferred(): Boolean {
        val block = deferred ?: return false
        deferred = null
        block()
        return true
    }

    /** Drops everything, for a window going away. */
    fun cancel() {
        cancelTimeout?.invoke()
        cancelTimeout = null
        deferred = null
        isWaiting = false
    }

    private fun act(block: () -> Unit) {
        if (mayAct()) block() else deferred = block
    }
}
