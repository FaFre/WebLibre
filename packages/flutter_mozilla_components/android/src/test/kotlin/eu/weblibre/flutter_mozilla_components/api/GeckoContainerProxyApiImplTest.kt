/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.RoutingDemands
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class GeckoContainerProxyApiImplTest {
    @BeforeTest
    fun setUp() {
        RoutingDemands.clear()
        RoutingDemands.clock = { 0L }
    }

    @AfterTest
    fun tearDown() {
        RoutingDemands.clear()
        RoutingDemands.clock = { 0L }
    }

    @Test
    fun disposeFailsPendingRoutingDemandWaiter() {
        val callbackCalled = CountDownLatch(1)
        var callbackResult: Result<*>? = null
        val api = GeckoContainerProxyApiImpl(
            CoroutineScope(SupervisorJob() + Dispatchers.Unconfined)
        )

        api.nextRoutingDemand { result ->
            callbackResult = result
            callbackCalled.countDown()
        }
        api.dispose()

        RoutingDemands.record("general", listOf("singbox:wg"))

        assertTrue(callbackCalled.await(100, TimeUnit.MILLISECONDS))
        assertTrue(callbackResult?.exceptionOrNull() is CancellationException)
        assertEquals("general", RoutingDemands.take()?.contextId)
    }
}
