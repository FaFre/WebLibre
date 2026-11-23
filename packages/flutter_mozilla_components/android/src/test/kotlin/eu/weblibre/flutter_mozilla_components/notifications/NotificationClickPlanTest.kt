/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import eu.weblibre.flutter_mozilla_components.notifications.NotificationClickPlan.Step
import eu.weblibre.flutter_mozilla_components.startup.ExternalCommitResult
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

private const val MINE = "0199a0b1-1111-7111-8111-111111111111"
private const val OTHER = "0199a0b1-2222-7222-8222-222222222222"

class NotificationClickPlanTest {
    @Test
    fun `a notification of the profile that runs is parked`() {
        assertEquals(Step.PARK, NotificationClickPlan.decide(MINE, committedProfileId = MINE))
    }

    @Test
    fun `a notification of another profile is never delivered to the one that runs`() {
        assertEquals(Step.OPEN_ONLY, NotificationClickPlan.decide(OTHER, committedProfileId = MINE))
    }

    @Test
    fun `with nothing committed the tap tries to bind its own profile`() {
        assertEquals(Step.BIND_THEN_PARK, NotificationClickPlan.decide(MINE, committedProfileId = null))
    }

    @Test
    fun `a notification that names no profile only opens the app`() {
        assertEquals(Step.OPEN_ONLY, NotificationClickPlan.decide(null, committedProfileId = null))
        assertEquals(Step.OPEN_ONLY, NotificationClickPlan.decide(null, committedProfileId = MINE))
    }

    @Test
    fun `a bind that landed on the notification's profile serves it`() {
        assertTrue(
            NotificationClickPlan.servesProfile(ExternalCommitResult.CommittedRequested(MINE), MINE),
        )
        assertTrue(
            NotificationClickPlan.servesProfile(ExternalCommitResult.AlreadyCommittedSame(MINE), MINE),
        )
        assertTrue(
            NotificationClickPlan.servesProfile(ExternalCommitResult.AnsweredSelection(MINE, "lease"), MINE),
        )
    }

    @Test
    fun `a bind that landed on another profile does not, even though it committed`() {
        // honorShortcutProfile off: the arbiter commits the candidate instead.
        assertFalse(
            NotificationClickPlan.servesProfile(ExternalCommitResult.CommittedRequested(OTHER), MINE),
        )
        assertFalse(
            NotificationClickPlan.servesProfile(ExternalCommitResult.AlreadyCommittedDifferent(OTHER), MINE),
        )
    }

    @Test
    fun `a refused bind does not serve the profile`() {
        listOf(
            ExternalCommitResult.MaintenanceRefused,
            ExternalCommitResult.SelectionInProgress,
            ExternalCommitResult.Terminating,
            ExternalCommitResult.NoValidProfile,
        ).forEach { refused ->
            assertFalse(NotificationClickPlan.servesProfile(refused, MINE), "$refused")
        }
    }
}
