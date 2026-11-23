/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepPolicy
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * One container's automatic freeze (phase C2): due after [afterMillis] of
 * foreground time in which no tab of [contextIds] was used.
 */
data class AutoFreezeSchedule(val contextIds: Set<String>, val afterMillis: Long)

/**
 * Automatic tab sleep and container freeze as Dart's effective settings
 * describe them (5.9 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
 * [enabled] is automatic tab sleep only; [containers] apply either way.
 */
data class SleepPolicy(
    val enabled: Boolean,
    val idleMillis: Long,
    val residentLimit: Int?,
    val exemptTabIds: Set<String>,
    /** By owner (container id). */
    val containers: Map<String, AutoFreezeSchedule> = emptyMap(),
) {
    companion object {
        /** Until Dart says otherwise: automatic sleep is off on every preset (D12). */
        val OFF = SleepPolicy(
            enabled = false,
            idleMillis = 30 * 60 * 1000L,
            residentLimit = null,
            exemptTabIds = emptySet(),
        )

        fun of(policy: TabSleepPolicy) = SleepPolicy(
            enabled = policy.enabled,
            idleMillis = policy.idleMinutes.coerceAtLeast(1) * 60 * 1000L,
            residentLimit = policy.residentLimit?.toInt()?.takeIf { it > 0 },
            exemptTabIds = policy.exemptTabIds.toSet(),
            containers = policy.containers.associate { container ->
                container.ownerId to AutoFreezeSchedule(
                    contextIds = container.contextIds.toSet(),
                    afterMillis = container.afterMinutes.coerceAtLeast(1) * 60 * 1000L,
                )
            },
        )
    }
}

/**
 * The policy in force, process-wide: Dart may send it before the components
 * exist, and a components rebuild keeps it. Each `Core`'s scheduler reads it.
 */
object TabSleepPolicies {
    private val policy = MutableStateFlow(SleepPolicy.OFF)

    val current: StateFlow<SleepPolicy> = policy.asStateFlow()

    fun set(value: SleepPolicy) {
        policy.value = value
    }

    internal fun resetForTest() {
        policy.value = SleepPolicy.OFF
    }
}
