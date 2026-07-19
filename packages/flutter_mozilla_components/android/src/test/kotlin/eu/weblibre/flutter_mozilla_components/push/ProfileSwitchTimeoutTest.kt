/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout

class ProfileSwitchTimeoutTest {
    @Test
    fun timeoutPreventsOperationFromStarting() = runBlocking {
        var sideEffectRan = false

        val completed = runWithStartTimeout(50) { tryStart ->
            delay(200)
            if (tryStart()) sideEffectRan = true
        }

        assertFalse(completed)
        assertFalse(sideEffectRan)
    }

    @Test
    fun operationCompletesAfterStartingBeforeTimeout() = runBlocking {
        val started = CompletableDeferred<Unit>()
        val release = CompletableDeferred<Unit>()
        var sideEffectRan = false
        val result = async {
            runWithStartTimeout(50) { tryStart ->
                assertTrue(tryStart())
                started.complete(Unit)
                release.await()
                sideEffectRan = true
            }
        }

        started.await()
        delay(100)
        assertFalse(result.isCompleted)

        release.complete(Unit)
        assertTrue(withTimeout(1_000) { result.await() })
        assertTrue(sideEffectRan)
    }
}
