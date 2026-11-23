/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.ContextFreezePhase
import eu.weblibre.flutter_mozilla_components.pigeons.ContextFreezeState
import eu.weblibre.flutter_mozilla_components.pigeons.EngineEnforcement
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeOperationResult
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleOperationState
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleRegistryMode
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleSnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.OwnerFreezeState

/** The registry's types as Dart sees them. */
internal object FreezePigeonMappers {
    fun snapshot(
        snapshot: ContextSnapshot = TabLifecycleRegistry.snapshot(),
        undelivered: (String) -> Int = UndeliveredPushCounts::countOf,
    ): LifecycleSnapshot = LifecycleSnapshot(
        mode = if (snapshot.recovery) LifecycleRegistryMode.RECOVERY else LifecycleRegistryMode.NORMAL,
        revision = snapshot.revision,
        contexts = snapshot.contexts.map { context ->
            ContextFreezeState(
                contextId = context.contextId,
                ownerId = context.record.ownerId,
                phase = phase(context.record.phase),
                previousPhase = context.record.previousPhase?.let(::phase),
                failure = context.status.failure,
                enforcement = context.status.enforcement,
                operation = context.status.operation,
                recovered = context.record.recovered,
                undeliveredPushCount = undelivered(context.contextId).toLong(),
            )
        },
        owners = owners(snapshot, undelivered),
    )

    /**
     * Every owner the records hold ([TabLifecycleRegistry.holdsOwner]), from
     * those records only: the phase that needs attention first, the weakest
     * enforcement, a running operation, and the skipped messages summed.
     */
    private fun owners(snapshot: ContextSnapshot, undelivered: (String) -> Int): List<OwnerFreezeState> =
        snapshot.contexts
            .filter { it.record.ownerId != null && TabLifecycleRegistry.holdsOwner(it.record.phase) }
            .groupBy { it.record.ownerId!! }
            .map { (ownerId, contexts) ->
                OwnerFreezeState(
                    ownerId = ownerId,
                    phase = phase(TabLifecycleRegistry.ownerPhaseOf(contexts.map { it.record.phase })!!),
                    enforcement = ENFORCEMENT_ORDER.first { value -> contexts.any { it.status.enforcement == value } },
                    operation = contexts.firstOrNull { it.status.operation != LifecycleOperationState.IDLE }?.status?.operation
                        ?: LifecycleOperationState.IDLE,
                    recovered = contexts.any { it.record.recovered },
                    undeliveredPushCount = contexts.sumOf { undelivered(it.contextId) }.toLong(),
                    contextIds = contexts.map { it.contextId },
                )
            }
            .sortedBy { it.ownerId }

    /** Weakest first. */
    private val ENFORCEMENT_ORDER = listOf(
        EngineEnforcement.LIFTED,
        EngineEnforcement.UNCERTAIN,
        EngineEnforcement.ENFORCED,
    )

    fun result(outcome: FreezeOutcome): FreezeOperationResult = FreezeOperationResult(
        ownerId = outcome.ownerId,
        phase = outcome.phase?.let(::phase) ?: ContextFreezePhase.UNRESTRICTED,
        revision = outcome.revision,
        failure = outcome.failure,
        blockers = outcome.blockers,
        stillRunning = outcome.stillRunning.sortedBy { it.ordinal },
        unsettledContextIds = outcome.unsettled,
    )

    fun phase(phase: ContextPhase): ContextFreezePhase = when (phase) {
        ContextPhase.FREEZING -> ContextFreezePhase.FREEZING
        ContextPhase.FROZEN -> ContextFreezePhase.FROZEN
        ContextPhase.FAILED -> ContextFreezePhase.FAILED
        ContextPhase.RESUMING -> ContextFreezePhase.RESUMING
        ContextPhase.DELETION_PENDING -> ContextFreezePhase.DELETION_PENDING
        ContextPhase.RELEASING -> ContextFreezePhase.RELEASING
        ContextPhase.ORPHANED -> ContextFreezePhase.ORPHANED
    }
}
