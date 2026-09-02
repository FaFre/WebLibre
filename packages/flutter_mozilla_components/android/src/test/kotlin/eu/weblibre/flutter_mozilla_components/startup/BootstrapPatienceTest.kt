/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.startup

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * The policy these cover is "spend patience on progress, not on time": the flat
 * 15s deadline this replaced failed cold starts that were seconds from
 * succeeding, while still making a dead bootstrap wait the full 15s.
 */
class BootstrapPatienceTest {
    private fun patience(
        stallTimeoutMs: Long = 10_000,
        ceilingMs: Long = 60_000,
        startedAtMs: Long = 0,
    ) = BootstrapPatience(stallTimeoutMs, ceilingMs, startedAtMs)

    @Test
    fun waitingContinuesWhileNothingHasStalledYet() {
        val patience = patience()

        assertNull(patience.tick(BootstrapStage.NONE, 1_000))
        assertNull(patience.tick(BootstrapStage.ENGINE, 2_000))
    }

    @Test
    fun aBootstrapThatNeverMovesIsAbandonedAtTheStallTimeout() {
        val patience = patience(stallTimeoutMs = 10_000)

        assertNull(patience.tick(BootstrapStage.NONE, 9_999))
        assertEquals(BootstrapGiveUp.STALLED, patience.tick(BootstrapStage.NONE, 10_000))
    }

    /** The case the flat deadline used to fail: slow, but plainly still working. */
    @Test
    fun progressBuysMorePatienceThanAnyFixedDeadlineWouldHave() {
        val patience = patience(stallTimeoutMs = 10_000)

        assertNull(patience.tick(BootstrapStage.ENGINE, 8_000))
        assertNull(patience.tick(BootstrapStage.COMPONENTS, 16_000))
        assertNull(patience.tick(BootstrapStage.SNAPSHOT_PUSHED, 24_000))
        assertNull(patience.tick(BootstrapStage.SNAPSHOT_PUSHED, 33_000))

        assertEquals(
            BootstrapGiveUp.STALLED,
            patience.tick(BootstrapStage.SNAPSHOT_PUSHED, 34_000),
        )
    }

    @Test
    fun theStallClockRestartsAtEachStageRatherThanAtTheStart() {
        val patience = patience(stallTimeoutMs = 10_000)

        assertNull(patience.tick(BootstrapStage.ENGINE, 9_000))
        // 12s in, but only 3s since the last thing happened.
        assertNull(patience.tick(BootstrapStage.ENGINE, 12_000))
        assertEquals(BootstrapGiveUp.STALLED, patience.tick(BootstrapStage.ENGINE, 19_000))
    }

    @Test
    fun steadyProgressStillEndsAtTheCeiling() {
        val patience = patience(stallTimeoutMs = 10_000, ceilingMs = 30_000)

        assertNull(patience.tick(BootstrapStage.ENGINE, 10_000))
        assertNull(patience.tick(BootstrapStage.COMPONENTS, 20_000))
        assertEquals(
            BootstrapGiveUp.CEILING,
            patience.tick(BootstrapStage.SNAPSHOT_PUSHED, 30_000),
        )
    }

    @Test
    fun anEngineThatDiesEndsTheWaitImmediately() {
        val patience = patience(stallTimeoutMs = 10_000)

        assertNull(patience.tick(BootstrapStage.COMPONENTS, 1_000))
        assertEquals(BootstrapGiveUp.ENGINE_LOST, patience.tick(BootstrapStage.NONE, 1_500))
    }

    /**
     * A component rebuild — the headless external set being replaced by the app
     * half's full one — is the ordinary shape of this path, not a failure.
     */
    @Test
    fun aLesserRegressionIsIgnoredRatherThanActedOn() {
        val patience = patience(stallTimeoutMs = 10_000)

        assertNull(patience.tick(BootstrapStage.COMPONENTS, 1_000))
        assertNull(patience.tick(BootstrapStage.ENGINE, 2_000))
        assertEquals(BootstrapStage.COMPONENTS, patience.stage)

        // And the regression did not secretly restart the stall clock either.
        assertEquals(BootstrapGiveUp.STALLED, patience.tick(BootstrapStage.ENGINE, 11_000))
    }

    @Test
    fun theStageReportedIsTheFurthestOneReached() {
        val patience = patience()

        patience.tick(BootstrapStage.ENGINE, 1_000)
        patience.tick(BootstrapStage.SNAPSHOT_PUSHED, 2_000)
        patience.tick(BootstrapStage.COMPONENTS, 3_000)

        assertEquals(BootstrapStage.SNAPSHOT_PUSHED, patience.stage)
    }
}
