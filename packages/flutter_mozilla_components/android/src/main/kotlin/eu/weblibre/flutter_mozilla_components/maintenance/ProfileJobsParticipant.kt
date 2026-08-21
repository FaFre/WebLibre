/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
package eu.weblibre.flutter_mozilla_components.maintenance

import android.content.Context
import androidx.work.WorkManager
import eu.weblibre.flutter_mozilla_components.ProfileWorkTags
import mozilla.components.support.base.log.logger.Logger
import java.io.File

/**
 * Cancels a profile's scheduled WorkManager jobs when its data is replaced or removed.
 *
 * Jobs are the one category here that is *not* user data. A queued push delivery
 * is a pointer into the profile's message store, which is inside the profile
 * directory and therefore already travels in the archive — so nothing is captured
 * on the way out. What matters is the other direction: a job left scheduled across
 * a restore refers to a message id from the data that was replaced, and one left
 * scheduled across a delete wakes against a profile directory that no longer
 * exists.
 *
 * Re-scheduling is deliberately not this participant's job. `PushMessageScheduler`
 * re-enqueues from the durable store whenever a profile becomes active, so
 * cancelling is a complete action rather than a lossy one — which is also why
 * rollback can be a no-op without leaving anything behind.
 */
class ProfileJobsParticipant(private val context: Context) : MaintenanceParticipantHandler {
    companion object {
        const val ID = "scheduledJobs"
        const val VERSION = 1
    }

    private val logger = Logger("JobsParticipant")

    /**
     * Nothing to capture and nothing to undo.
     *
     * A snapshot of in-flight jobs would be actively misleading: by the time a
     * restore of that archive ran, every one of them would name a message that had
     * long since been delivered or expired.
     */
    override fun prepare(workDir: File, profileId: String, kind: String): Boolean = true

    override fun apply(workDir: File, profileId: String, kind: String): Boolean =
        when (kind) {
            "restore", "delete" -> cancel(profileId)
            else -> true
        }

    /**
     * Not verified by re-querying WorkManager.
     *
     * `cancelAllWorkByTag` is asynchronous and its operation completing does not
     * mean a worker already running has stopped. Asserting emptiness here would
     * fail intermittently on a correct cancel, and a participant that fails
     * intermittently past the barrier is worse than one that does not check.
     */
    override fun verify(workDir: File, profileId: String, kind: String): Boolean = true

    override fun finalizeWork(workDir: File): Boolean = true

    /**
     * Cancelled work is not put back, and does not need to be: the queue it was
     * derived from is durable, and the next activation of this profile re-enqueues
     * from it.
     */
    override fun rollback(workDir: File, profileId: String): Boolean = true

    private fun cancel(profileId: String): Boolean = runCatching {
        // The app-level context on purpose: WorkManager is a process-wide
        // singleton, and initialising it through a profile-scoped context would
        // point its database at the profile directory being removed.
        WorkManager.getInstance(context.applicationContext)
            .cancelAllWorkByTag(ProfileWorkTags.forProfile(profileId))
            .result
            .get()
        true
    }.getOrElse { error ->
        logger.warn("Could not cancel scheduled jobs for $profileId", error)
        false
    }
}
