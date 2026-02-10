/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.simple_intent_receiver.ext

import java.util.concurrent.atomic.AtomicLong

/**
 * Thread-safe monotonic sequence counter for event ordering.
 *
 * Replaces System.currentTimeMillis() for event timestamps sent to Flutter,
 * guaranteeing strictly increasing values regardless of wall-clock changes
 * and eliminating same-millisecond collisions.
 */
object EventSequence {
    private val counter = AtomicLong(0)

    fun next(): Long = counter.incrementAndGet()
}
