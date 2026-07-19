/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
package eu.weblibre.flutter_mozilla_components

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withTimeoutOrNull

class ActiveProfileTest {
    @Test
    fun profileLockIsRetainedAcrossSuspension() = runBlocking {
        val entered = CompletableDeferred<Unit>()
        val release = CompletableDeferred<Unit>()
        val secondEntered = CompletableDeferred<Unit>()
        val first = launch {
            ActiveProfile.withProfileLock {
                entered.complete(Unit)
                release.await()
            }
        }

        entered.await()
        val second = launch {
            ActiveProfile.withProfileLock { secondEntered.complete(Unit) }
        }

        withTimeoutOrNull(100) { secondEntered.await() }
        assertFalse(secondEntered.isCompleted)
        release.complete(Unit)
        withTimeout(1_000) {
            first.join()
            second.join()
        }
    }
}
