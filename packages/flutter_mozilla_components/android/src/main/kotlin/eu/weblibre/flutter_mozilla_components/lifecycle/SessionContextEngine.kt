/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import eu.weblibre.flutter_mozilla_components.pigeons.FreezeActivity
import java.util.concurrent.atomic.AtomicLong
import mozilla.components.browser.engine.gecko.await
import org.mozilla.geckoview.GeckoResult
import org.mozilla.geckoview.GeckoRuntime
import org.mozilla.geckoview.StorageController

/**
 * Command numbers for the engine's context restriction (D22): one counter per
 * process, only increasing. The runtime lives as long as the process, and its
 * init-time restriction (E1) counts as 0, so the first command is 1. Everything
 * that sends a restriction command draws from here, the debug spike harness
 * included, so no two commands for a context ever share a number.
 */
object SessionContextCommands {
    private val counter = AtomicLong(0)

    fun next(): Long = counter.incrementAndGet()

    internal fun resetForTest() = counter.set(0)
}

/** One context's answer to an install or lift. */
data class CommandAck(
    val contextId: String,
    val cmd: Long,
    /** False: a newer command for the context was already accepted. */
    val applied: Boolean,
    /** Whether the context is restricted now (its own record or `"*"`). */
    val restricted: Boolean,
)

enum class QuiescenceStatus { QUIESCENT, SUPERSEDED, NOT_RESTRICTED, TIMED_OUT }

/** One context's answer to a quiescence wait. */
data class QuiescenceAck(
    val contextId: String,
    val cmd: Long,
    val status: QuiescenceStatus,
    /** What can still run in the context when the wait ended. */
    val leftovers: Set<FreezeActivity> = emptySet(),
)

/**
 * The engine's context restriction (E5, E9, E10 in section 6 of
 * `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`), so the freeze operations
 * can be tested without Gecko. Every call throws when the engine could not be
 * asked or answered with a failure; a timeout is the caller's to apply.
 */
interface SessionContextEngine {
    suspend fun install(contextIds: List<String>, cmd: Long): List<CommandAck>

    suspend fun lift(contextIds: List<String>, cmd: Long): List<CommandAck>

    suspend fun awaitQuiescence(contextIds: List<String>, cmd: Long, timeoutMillis: Long): List<QuiescenceAck>

    /** E9: completes once the data is cleared; throws when it could not be. */
    suspend fun clearData(contextId: String)

    /** E10: the contexts that have service-worker registrations. */
    suspend fun contextsWithServiceWorkers(): List<String>
}

/** [SessionContextEngine] over the patched GeckoView `StorageController`. */
class GeckoSessionContextEngine(private val runtime: () -> GeckoRuntime) : SessionContextEngine {
    private val storage: StorageController get() = runtime().storageController

    override suspend fun install(contextIds: List<String>, cmd: Long): List<CommandAck> =
        storage.installSessionContextRestriction(contextIds, cmd).awaitAnswer().map { it.toAck() }

    override suspend fun lift(contextIds: List<String>, cmd: Long): List<CommandAck> =
        storage.liftSessionContextRestriction(contextIds, cmd).awaitAnswer().map { it.toAck() }

    override suspend fun awaitQuiescence(contextIds: List<String>, cmd: Long, timeoutMillis: Long): List<QuiescenceAck> =
        storage.awaitSessionContextQuiescence(contextIds, cmd, timeoutMillis).awaitAnswer().map { result ->
            QuiescenceAck(
                contextId = result.contextId,
                cmd = result.cmd,
                status = when (result.status) {
                    StorageController.SessionContextQuiescence.STATUS_QUIESCENT -> QuiescenceStatus.QUIESCENT
                    StorageController.SessionContextQuiescence.STATUS_SUPERSEDED -> QuiescenceStatus.SUPERSEDED
                    StorageController.SessionContextQuiescence.STATUS_NOT_RESTRICTED -> QuiescenceStatus.NOT_RESTRICTED
                    else -> QuiescenceStatus.TIMED_OUT
                },
                leftovers = buildSet {
                    // NOT_CHECKED (-1) is not a leftover: the network did not answer, which
                    // a timeout already reports.
                    if (result.serviceWorkers > 0) add(FreezeActivity.SERVICE_WORKERS)
                    if (result.topLevelContexts > 0) add(FreezeActivity.DOCUMENTS)
                    if (result.processes > 0) add(FreezeActivity.PROCESSES)
                    if (result.channels > 0) add(FreezeActivity.CHANNELS)
                    if (result.connections > 0) add(FreezeActivity.CONNECTIONS)
                    if (result.webSockets > 0) add(FreezeActivity.WEB_SOCKETS)
                    if (result.sockets > 0) add(FreezeActivity.SOCKETS)
                },
            )
        }

    override suspend fun clearData(contextId: String) {
        storage.clearDataForSessionContextWithResult(contextId).await()
    }

    override suspend fun contextsWithServiceWorkers(): List<String> =
        storage.listSessionContextsWithServiceWorkers().awaitAnswer()

    /** A command's answer; one that completed without a value is a failure. */
    private suspend fun <T> GeckoResult<T>.awaitAnswer(): T =
        checkNotNull(await()) { "The engine answered without a result" }

    private fun StorageController.SessionContextCommandResult.toAck() = CommandAck(
        contextId = contextId,
        cmd = cmd,
        applied = status == StorageController.SessionContextCommandResult.STATUS_APPLIED,
        restricted = restricted,
    )
}
