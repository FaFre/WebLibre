/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.lifecycle.ContainerFreeze
import eu.weblibre.flutter_mozilla_components.lifecycle.FreezeOutcome
import eu.weblibre.flutter_mozilla_components.lifecycle.FreezePigeonMappers
import eu.weblibre.flutter_mozilla_components.lifecycle.FreezeRequest
import eu.weblibre.flutter_mozilla_components.lifecycle.FrozenWindowHandoffs
import eu.weblibre.flutter_mozilla_components.lifecycle.SleepPolicy
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycle
import eu.weblibre.flutter_mozilla_components.lifecycle.TabLifecycleRegistry
import eu.weblibre.flutter_mozilla_components.lifecycle.TabSleepPolicies
import eu.weblibre.flutter_mozilla_components.pigeons.ContainerContexts
import eu.weblibre.flutter_mozilla_components.pigeons.ContextReleaseResult
import eu.weblibre.flutter_mozilla_components.pigeons.FreezeOperationResult
import eu.weblibre.flutter_mozilla_components.pigeons.FrozenWindowHandoff
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabLifecycleApi
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleFailure
import eu.weblibre.flutter_mozilla_components.pigeons.LifecycleSnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.TabLifecycleState
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepPolicy
import eu.weblibre.flutter_mozilla_components.pigeons.TabSleepResult
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Dart's side of tab sleep and container freeze, registered when the plugin
 * attaches. Resolves the current `Core`'s [TabLifecycle] and [ContainerFreeze]
 * on every call, because a components rebuild replaces them and Dart calls
 * before they exist. The sleep policy and the snapshot need neither: both are
 * process-wide.
 */
class GeckoTabLifecycleApiImpl internal constructor(
    private val lifecycle: () -> TabLifecycle?,
    private val mainDispatcher: CoroutineDispatcher,
    private val freeze: () -> ContainerFreeze? = { GlobalComponents.components?.core?.containerFreeze },
) : GeckoTabLifecycleApi {
    constructor() : this(
        lifecycle = { GlobalComponents.components?.core?.tabLifecycle },
        mainDispatcher = Dispatchers.Main,
    )

    private fun requireLifecycle(): TabLifecycle =
        requireNotNull(lifecycle()) { "Components not initialized" }

    override suspend fun sleepTabs(
        tabIds: List<String>,
        stopMedia: Boolean,
        discardPostResult: Boolean,
        discardFormDataTabIds: List<String>,
    ): List<TabSleepResult> = withContext(mainDispatcher) {
        requireLifecycle().sleep(tabIds, stopMedia, discardPostResult, discardFormDataTabIds.toSet())
    }

    override fun wakeTab(tabId: String): Boolean = requireLifecycle().wakeRequested(tabId)

    override fun getTabLifecycleState(tabId: String): TabLifecycleState? = requireLifecycle().stateNow(tabId)

    override fun setSleepPolicy(policy: TabSleepPolicy) {
        TabSleepPolicies.set(SleepPolicy.of(policy))
    }

    override suspend fun freezeContexts(
        ownerId: String,
        contextIds: List<String>,
        memberTabIds: List<String>,
        stopMedia: Boolean,
        discardPostResult: Boolean,
        discardFormDataTabIds: List<String>,
        automatic: Boolean,
    ): FreezeOperationResult = withFreeze(ownerId) {
        it.freeze(
            FreezeRequest(
                ownerId,
                contextIds,
                memberTabIds.toSet(),
                stopMedia,
                discardPostResult,
                automatic,
                discardFormDataOf = discardFormDataTabIds.toSet(),
            ),
        )
    }

    override suspend fun resumeContexts(ownerId: String, wakeTabId: String?): FreezeOperationResult =
        withFreeze(ownerId) { it.resume(ownerId, wakeTabId) }

    override suspend fun beginContextDeletion(ownerId: String, deleteDataOf: List<String>): FreezeOperationResult =
        withFreeze(ownerId) { it.beginDeletion(ownerId, deleteDataOf) }

    override suspend fun cancelContextDeletion(ownerId: String): FreezeOperationResult =
        withFreeze(ownerId) { it.cancelDeletion(ownerId) }

    override suspend fun completeContextDeletion(ownerId: String): FreezeOperationResult =
        withFreeze(ownerId) { it.completeDeletion(ownerId) }

    override suspend fun reconcileOwners(existingOwnerIds: List<String>): LifecycleSnapshot =
        withContext(mainDispatcher) {
            freeze()?.reconcileOwners(existingOwnerIds.toSet())
            FreezePigeonMappers.snapshot()
        }

    override suspend fun releaseContexts(contextIds: List<String>): List<ContextReleaseResult> =
        withContext(mainDispatcher) {
            val freeze = freeze()
                ?: return@withContext contextIds.distinct().map {
                    ContextReleaseResult(it, released = false, failure = LifecycleFailure.COMPONENTS_UNAVAILABLE, dataCleared = false)
                }
            freeze.release(contextIds)
        }

    override suspend fun reconstructFrozenContexts(
        owners: List<ContainerContexts>,
        unfreezableContextIds: List<String>,
    ): LifecycleSnapshot = withContext(mainDispatcher) {
        check(TabLifecycleRegistry.inRecovery()) { "Not in recovery mode" }
        freeze()?.reconstruct(
            owners.associate { it.ownerId to it.contextIds },
            unfreezableContextIds.toSet(),
        )
        FreezePigeonMappers.snapshot()
    }

    override fun getLifecycleSnapshot(): LifecycleSnapshot {
        // Asked before the engine starts: an empty snapshot would say nothing
        // is frozen. Dart treats a failed read as everything frozen.
        check(TabLifecycleRegistry.isReadable()) { "No profile is committed" }
        return FreezePigeonMappers.snapshot()
    }

    override fun takeFrozenWindowHandoff(): FrozenWindowHandoff? =
        FrozenWindowHandoffs.take()?.let { FrozenWindowHandoff(contextId = it.contextId, url = it.url, private = it.private) }

    private suspend fun withFreeze(
        ownerId: String,
        block: suspend (ContainerFreeze) -> FreezeOutcome,
    ): FreezeOperationResult = withContext(mainDispatcher) {
        val freeze = freeze()
            ?: return@withContext FreezePigeonMappers.result(
                FreezeOutcome(
                    ownerId,
                    TabLifecycleRegistry.ownerPhase(ownerId),
                    TabLifecycleRegistry.revision(),
                ),
            ).copy(failure = LifecycleFailure.COMPONENTS_UNAVAILABLE)
        FreezePigeonMappers.result(block(freeze))
    }
}
