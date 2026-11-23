/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.notifications

import eu.weblibre.flutter_mozilla_components.startup.ExternalCommitResult

/**
 * What a tap on a web notification does about the process's profile.
 *
 * A notification outlives the process that posted it, and a profile is bound
 * for the life of a process, so a tap can arrive where nothing is committed
 * (cold start), where the same profile runs (the usual case) or where another
 * one does. Only the first two may hand the click to Gecko: a click reaches
 * whatever profile the runtime serves, and a notification of profile A must
 * never fire a service worker of profile B. The third opens the app unchanged
 * and leaves the notification showing, to be answered once its profile runs.
 *
 * Kept free of Android types so the rule can be tested without a framework.
 */
object NotificationClickPlan {
    enum class Step {
        /** Nothing is delivered: no profile named, or a different one runs. */
        OPEN_ONLY,

        /** The profile the notification names already runs. */
        PARK,

        /** Nothing is committed yet: try to bind the named profile first. */
        BIND_THEN_PARK,
    }

    fun decide(notificationProfileId: String?, committedProfileId: String?): Step = when {
        notificationProfileId == null -> Step.OPEN_ONLY
        committedProfileId == null -> Step.BIND_THEN_PARK
        committedProfileId == notificationProfileId -> Step.PARK
        else -> Step.OPEN_ONLY
    }

    /**
     * Whether, after [StartupArbiter.tryCommitExternal] answered [result], the
     * process serves [notificationProfileId]. A commit that landed on the
     * candidate instead (the user turned off honouring a launch's profile) is
     * another profile, and so is a refused one.
     */
    fun servesProfile(result: ExternalCommitResult, notificationProfileId: String): Boolean =
        when (result) {
            is ExternalCommitResult.CommittedRequested -> result.profileId == notificationProfileId
            is ExternalCommitResult.AlreadyCommittedSame -> result.profileId == notificationProfileId
            is ExternalCommitResult.AnsweredSelection -> result.profileId == notificationProfileId
            is ExternalCommitResult.AlreadyCommittedDifferent,
            ExternalCommitResult.MaintenanceRefused,
            ExternalCommitResult.SelectionInProgress,
            ExternalCommitResult.Terminating,
            ExternalCommitResult.NoValidProfile,
            -> false
        }
}
