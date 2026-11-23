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
package eu.weblibre.flutter_mozilla_components.feature

import androidx.annotation.VisibleForTesting
import java.util.concurrent.atomic.AtomicBoolean
import mozilla.components.concept.engine.webextension.WebExtension
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.webextensions.BuiltInWebExtensionController

/**
 * Runs at most one install of each built-in extension at a time in the process.
 *
 * [BuiltInWebExtensionController] only skips the engine once an install has
 * finished, because its registry is filled in the success callback. The UI
 * start rebuilds the components a headless push start made, and so builds a
 * second engine while the first one's installs may still be running. Each
 * install then makes its own wrapper, and the second wrapper replaces the
 * first in the registry.
 *
 * The background port belongs to whichever wrapper was registered when the
 * extension connected. If that was the first wrapper, every background message
 * sent through the registry fails with "No port connected" for the rest of the
 * process. For the proxy extension, that means the app's routing never
 * arrives. The extension then holds each request for its routing wait, and the
 * account manager does not start.
 *
 * Here, a call that finds an install of the same extension already running
 * waits for that install to finish. Then the controller answers it from its
 * registry with the existing wrapper. If the first install failed, the waiting
 * call tries on its own. A callback that throws does not keep any other caller
 * from its answer.
 */
internal object BuiltInExtensionInstalls {
    private val waiting = HashMap<String, MutableList<() -> Unit>>()

    fun install(
        extensionId: String,
        controller: BuiltInWebExtensionController,
        runtime: WebExtensionRuntime,
        onSuccess: (WebExtension) -> Unit = {},
        onError: (Throwable) -> Unit = {},
    ) {
        synchronized(waiting) {
            val queue = waiting[extensionId]
            if (queue != null) {
                queue += { install(extensionId, controller, runtime, onSuccess, onError) }
                return
            }
            waiting[extensionId] = mutableListOf()
        }

        // Whichever comes first, a callback or a throw, releases the waiting calls.
        // Only that one does: a later release could empty a newer install's queue.
        val settled = AtomicBoolean(false)
        fun answer(callback: () -> Unit) {
            val failure = runCatching(callback).exceptionOrNull()
            if (settled.compareAndSet(false, true)) settle(extensionId, failure) else failure?.let { throw it }
        }

        try {
            controller.install(
                runtime,
                onSuccess = { extension -> answer { onSuccess(extension) } },
                onError = { throwable -> answer { onError(throwable) } },
            )
        } catch (throwable: Throwable) {
            // Neither callback is coming, and the waiting calls would queue for good.
            if (settled.compareAndSet(false, true)) settle(extensionId, throwable) else throw throwable
        }
    }

    /**
     * Runs every call that waited for [extensionId], each one on its own, so a
     * callback that throws does not keep the others from their answer. Then
     * throws [earlier], or else the first failure among them, with any later
     * failures attached as suppressed.
     */
    private fun settle(extensionId: String, earlier: Throwable? = null) {
        val queue = synchronized(waiting) { waiting.remove(extensionId) }.orEmpty()
        var failure = earlier
        for (waiter in queue) {
            try {
                waiter()
            } catch (throwable: Throwable) {
                val first = failure
                if (first == null) failure = throwable else first.addSuppressed(throwable)
            }
        }
        failure?.let { throw it }
    }

    /** Forgets unfinished installs between unit tests. */
    @VisibleForTesting
    internal fun resetForTesting() {
        synchronized(waiting) { waiting.clear() }
    }
}
