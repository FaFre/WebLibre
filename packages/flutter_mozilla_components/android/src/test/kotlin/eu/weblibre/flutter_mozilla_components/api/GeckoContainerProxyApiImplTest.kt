/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.RoutingDemands
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout

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
    fun disposeFailsPendingRoutingDemandWaiter() = runBlocking {
        val api = GeckoContainerProxyApiImpl(
            CoroutineScope(SupervisorJob() + Dispatchers.Unconfined)
        )

        val waiter = async(Dispatchers.Unconfined) {
            runCatching { api.nextRoutingDemand() }
        }
        api.dispose()

        RoutingDemands.record("general", listOf("singbox:wg"))

        val result = withTimeout(100) { waiter.await() }
        assertTrue(result.exceptionOrNull() is CancellationException)
        assertEquals("general", RoutingDemands.take()?.contextId)
    }
}
