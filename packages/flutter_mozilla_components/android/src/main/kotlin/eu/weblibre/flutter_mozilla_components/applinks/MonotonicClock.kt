/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.os.SystemClock

/**
 * Injectable monotonic clock. All app-links timing (resolution cache TTL, launch cooldown,
 * pending-request expiry, suppression timeout) reads from this seam so tests can advance
 * time deterministically.
 */
fun interface MonotonicClock {
    fun elapsedRealtime(): Long

    companion object {
        val SYSTEM = MonotonicClock { SystemClock.elapsedRealtime() }
    }
}
