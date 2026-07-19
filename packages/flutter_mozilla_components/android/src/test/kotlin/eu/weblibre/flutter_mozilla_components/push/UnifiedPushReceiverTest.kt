/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withTimeoutOrNull

class UnifiedPushReceiverTest {
    @Test
    fun durableIdIsStableWithinConnectorRegistration() {
        val first = UnifiedPushReceiver.durableMessageId("scope", "token", "message")
        val second = UnifiedPushReceiver.durableMessageId("scope", "token", "message")

        assertEquals(first, second)
    }

    @Test
    fun durableIdSeparatesConnectorRegistrations() {
        val first = UnifiedPushReceiver.durableMessageId("scope", "old-token", "message")
        val second = UnifiedPushReceiver.durableMessageId("scope", "new-token", "message")

        assertNotEquals(first, second)
    }

    @Test
    fun cancellingExclusiveOperationReleasesQueue() = runBlocking {
        val entered = CompletableDeferred<Unit>()
        val operation = launch {
            UnifiedPushReceiver.runExclusive {
                entered.complete(Unit)
                awaitCancellation()
            }
        }

        entered.await()
        operation.cancelAndJoin()

        withTimeout(1_000) {
            UnifiedPushReceiver.runExclusive { }
        }
    }

    @Test
    fun exclusiveOperationRetainsQueueAcrossSuspension() = runBlocking {
        val entered = CompletableDeferred<Unit>()
        val release = CompletableDeferred<Unit>()
        val secondEntered = CompletableDeferred<Unit>()
        val first = launch {
            UnifiedPushReceiver.runExclusive {
                entered.complete(Unit)
                release.await()
            }
        }

        entered.await()
        val second = launch {
            UnifiedPushReceiver.runExclusive { secondEntered.complete(Unit) }
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
