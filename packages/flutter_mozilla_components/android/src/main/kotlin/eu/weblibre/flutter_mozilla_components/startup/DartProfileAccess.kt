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
package eu.weblibre.flutter_mozilla_components.startup

import mozilla.components.support.base.log.logger.Logger

/** A Dart isolate that wants to open profile state. */
sealed interface DartAccessOwner {
    val engineId: String

    data class Ui(override val engineId: String) : DartAccessOwner

    data class Headless(override val engineId: String, val taskId: String) : DartAccessOwner
}

/**
 * Which Dart isolate may hold profile state open.
 *
 * [StartupArbiter] answers *which* profile the process is on; this answers *who*
 * may open it. They are different questions with different answers: a UI engine
 * and a background-fetch isolate agree on the profile and still must not both
 * hold a `ProviderContainer` over its databases, because each keeps its own
 * SQLite connections and its own in-memory view of rows the other is writing.
 *
 * Ownership lives here rather than in Dart because Dart cannot see across
 * isolates — two isolates would each observe an empty "nobody owns this".
 *
 * Waiting is deliberately not implemented here. A caller that finds the lease
 * taken retries from Dart, so no Pigeon call ever blocks the platform thread
 * waiting on another isolate to finish its work.
 */
object DartProfileAccess {
    private val logger = Logger("DartProfileAccess")

    private var owner: DartAccessOwner? = null

    @Synchronized
    fun currentOwner(): DartAccessOwner? = owner

    /**
     * Takes the lease, or reports that someone else holds it.
     *
     * Re-claiming by the identical owner succeeds: a UI engine that reattaches
     * after an Activity recreation is the same isolate asking again, not a second
     * one arriving.
     */
    @Synchronized
    fun tryClaim(candidate: DartAccessOwner): Boolean {
        val current = owner
        if (current != null && current != candidate) {
            logger.info("Refusing profile access for $candidate; $current holds it")
            return false
        }

        owner = candidate
        return true
    }

    /**
     * Releases the lease if [candidate] is the holder.
     *
     * The identity check is what makes release safe to call from a `finally`: a
     * headless task that was refused the lease still runs its cleanup, and must
     * not drop the UI's lease on the way out.
     */
    @Synchronized
    fun release(candidate: DartAccessOwner): Boolean {
        if (owner != candidate) return false

        owner = null
        return true
    }

    @Synchronized
    fun resetForTest() {
        owner = null
    }
}
