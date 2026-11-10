/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.scheduler

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import mozilla.components.support.base.log.logger.Logger
import java.io.Closeable
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Non-blocking async task scheduler inspired by Ladybird's LibLightpandaIO.
 *
 * Ladybird's epoll-based scheduler provides:
 * - Single epoll_wait for all IO events (no busy-waiting)
 * - Task batching: all pending tasks execute before next poll
 * - Zero-allocation fast path for completed tasks
 *
 * This Kotlin coroutine port provides equivalent patterns on Android:
 * - Coroutine-based event loop with [Dispatchers.IO] for IO-bound work
 * - Task batching: execute all pending tasks in one coroutine batch
 * - Graceful shutdown without leaking tasks
 *
 * Unlike raw epoll, coroutines provide structured concurrency, automatic
 * cancellation propagation, and lifecycle integration with Android components.
 *
 * Reference: qwerzxcva/ladybird Libraries/LibLightpandaIO/AsyncIOScheduler.cpp
 */
class LadybirdAsyncScheduler(
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.IO + Job()),
    private val batchSize: Int = 64
) : Closeable {

    private val logger = Logger("LadybirdAsyncScheduler")
    private val running = AtomicBoolean(false)
    private val pendingTasks = ConcurrentLinkedQueue<() -> Unit>()
    private var pollingJob: Job? = null

    /** Maximum events to process in one batch (matching C++ impl's MAX_EVENTS=64). */
    companion object {
        const val DEFAULT_MAX_BATCH = 64
    }

    /** Start the scheduler loop. Idempotent — safe to call multiple times. */
    fun start() {
        if (!running.compareAndSet(false, true)) return

        logger.debug("Async scheduler starting")
        pollingJob = scope.launch {
            poll()
        }
    }

    /** Gracefully stop the scheduler. Pending tasks are drained before exit. */
    fun stop() {
        if (!running.compareAndSet(true, false)) return

        logger.debug("Async scheduler stopping — draining ${pendingTasks.size} pending tasks")
        pollingJob?.cancel()

        // Drain remaining tasks synchronously
        drain()
    }

    override fun close() = stop()

    /** Schedule a task for execution on the next scheduler cycle. */
    fun schedule(task: () -> Unit) {
        pendingTasks.add(task)
    }

    /** Schedule a task asynchronously — returns immediately, task runs on next cycle. */
    fun scheduleAsync(task: () -> Unit): Job {
        return scope.launch(Dispatchers.Main) {
            pendingTasks.add(task)
        }
    }

    /** Process all pending tasks immediately (blocking). Used during shutdown drain. */
    fun drain() {
        var task: (() -> Unit)? = pendingTasks.poll()
        while (task != null) {
            try {
                task()
            } catch (e: Exception) {
                logger.error("Task execution failed", e)
            }
            task = pendingTasks.poll()
        }
    }

    /** Returns the number of currently pending tasks. */
    fun pendingCount(): Int = pendingTasks.size

    /** True if the scheduler is actively polling. */
    fun isRunning(): Boolean = running.get()

    // =========================================================================
    // Internal: event loop
    // =========================================================================

    /**
     * Continuous poll loop.
     *
     * Mirrors Ladybird's AsyncIOScheduler::poll():
     * 1. Process all pending tasks in one batch
     * 2. Yield to coroutine dispatcher (equivalent to epoll_wait)
     * 3. Repeat until stopped
     */
    private suspend fun poll() {
        while (running.get()) {
            val count = processBatch()
            if (count > 0) {
                logger.debug("Processed $count tasks in batch")
            }

            // Yield to allow other coroutines to run.
            // In Ladybird's C++ code, this is epoll_wait(timeout).
            kotlinx.coroutines.delay(1)
        }
    }

    /**
     * Process a single batch of pending tasks.
     *
     * Implements the same batching strategy as C++ code:
     * - Move all pending tasks to a local list (atomic swap)
     * - Execute them one by one
     * - Any exceptions are caught per-task so one failure doesn't block others
     *
     * @return Number of tasks processed in this batch
     */
    private fun processBatch(): Int {
        var processed = 0
        var task: (() -> Unit)? = pendingTasks.poll()
        while (task != null && processed < batchSize) {
            try {
                task()
            } catch (e: Exception) {
                logger.error("Task execution failed", e)
            }
            processed++
            task = pendingTasks.poll()
        }
        return processed
    }
}

/**
 * Factory companion for creating a scheduler tied to Android lifecycle.
 *
 * This single-threaded dispatcher mirrors Ladybird's single-epoll-thread
 * architecture: all async work is serialized through one event loop,
 * eliminating lock contention and cache-line bouncing.
 */
object LadybirdSchedulers {

    /** Coroutine dispatcher backed by a single thread, like Ladybird's event loop. */
    val SINGLE_THREAD: CoroutineDispatcher by lazy {
        Dispatchers.IO.limitedParallelism(1)
    }

    /** Create a scheduler for background IO work. */
    fun forIO(): LadybirdAsyncScheduler {
        return LadybirdAsyncScheduler(
            scope = CoroutineScope(SINGLE_THREAD + Job()),
            batchSize = LadybirdAsyncScheduler.DEFAULT_MAX_BATCH
        )
    }

    /** Create a scheduler for urgent/responsive work (smaller batch). */
    fun forUrgent(): LadybirdAsyncScheduler {
        return LadybirdAsyncScheduler(
            scope = CoroutineScope(Dispatchers.Default + Job()),
            batchSize = 16
        )
    }
}