/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import android.util.Log
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileStartupOwnerType
import eu.weblibre.flutter_mozilla_components.startup.DartProfileAccess
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.mockito.MockedStatic
import org.mockito.Mockito

/**
 * What happens to the profile-access lease when an isolate stops existing.
 *
 * The interesting case is a hot restart: the engine survives, so nothing detaches,
 * and the replacement isolate arrives with an id the arbiter has never seen. Until
 * the lease is handed back it can only read that as a second owner competing for
 * the profile — and the owner it names is gone, so no amount of retrying helps.
 */
class GeckoProfileApiImplTest {
    /** `GeckoProfileApiImpl` logs through `android.util.Log`, which throws unmocked. */
    private lateinit var androidLog: MockedStatic<Log>

    @BeforeTest
    fun setUp() {
        androidLog = Mockito.mockStatic(Log::class.java)
        DartProfileAccess.resetForTest()
    }

    @AfterTest
    fun tearDown() {
        DartProfileAccess.resetForTest()
        androidLog.close()
    }

    /** One instance per engine attachment, exactly as the plugin creates them. */
    private fun attachment() = GeckoProfileApiImpl(Mockito.mock(Context::class.java))

    @Test
    fun hotRestartHandsTheProfileLeaseToTheNextIsolate() {
        val engine = attachment()

        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "first", null))
        assertFalse(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "second", null))

        engine.onEngineRestarting()

        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "second", null))
    }

    @Test
    fun aRestartNeverLeavesTheLeaseUnheld() {
        val engine = attachment()
        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "first", null))

        // The embedder destroys the outgoing isolate *after* this returns, so
        // anything else starting in the process must still be refused.
        engine.onEngineRestarting()

        val worker = attachment()
        assertFalse(
            worker.claimProfileAccess(ProfileStartupOwnerType.HEADLESS, "worker", "feeds"),
        )
        // And the replacement, which only this engine can vouch for, still gets it.
        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "second", null))
    }

    @Test
    fun theReplacementKeepsTheLeaseAgainstTheNextArrival() {
        val engine = attachment()
        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "first", null))
        engine.onEngineRestarting()
        assertTrue(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "second", null))

        // The hand-over is spent: a third id is a second owner again, not another
        // replacement.
        assertFalse(engine.claimProfileAccess(ProfileStartupOwnerType.UI, "third", null))
    }

    @Test
    fun restartingOneEngineLeavesAnotherEnginesLeaseAlone() {
        val worker = attachment()
        assertTrue(
            worker.claimProfileAccess(ProfileStartupOwnerType.HEADLESS, "worker", "feeds"),
        )

        // A second engine in the same process restarting says nothing about the
        // isolate that actually holds the lease.
        attachment().onEngineRestarting()

        assertFalse(attachment().claimProfileAccess(ProfileStartupOwnerType.UI, "ui", null))
    }
}

/**
 * The container-proxy half of the same restart.
 *
 * Everything a hot restart touches on this API is engine-scoped and hard to
 * reach from a unit test; what is reachable is the rule that keeps a restart
 * arriving before the engine was ever set up from registering an API for an
 * extension that does not exist — and, more usefully, from dereferencing a
 * plugin binding that was never attached.
 */
class GeckoBrowserApiContainerProxyTest {
    @Test
    fun reinstallingBeforeTheEngineIsSetUpLeavesTheChannelAlone() {
        // No `attachBinding`, so a reinstall that did not check would fail on the
        // lateinit binding rather than doing nothing.
        GeckoBrowserApiImpl().reinstallContainerProxyApi()
    }
}
