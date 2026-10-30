/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequest
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkerParameters
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ProfileWorkTags
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.support.base.worker.Frequency
import mozilla.components.support.webextensions.WebExtensionSupport
import java.util.concurrent.TimeUnit

/**
 * A profile's add-on update check, in place of AC's own update worker.
 *
 * AC names its update jobs after the add-on alone and tags them with nothing
 * that says which profile they are for, so deleting a profile left them
 * scheduled. Its worker also waits for the browser's extensions to load before
 * doing anything. That never happens in a process Android started just for the
 * job, nor while only a Custom Tab is open: the worker sat there until
 * WorkManager stopped it ten minutes later, each time one came due while the app
 * was closed.
 *
 * This job carries the profile's [ProfileWorkTags] tag and updates only while
 * that profile's full browser is running, where everything is ready (see
 * [ProfileAddonUpdater.updateNow]). Otherwise it ends at once. It never commits a profile or
 * starts an engine for a check nobody is waiting for; checks missed that way are
 * made up when the profile's extensions next load (see
 * [ProfileAddonUpdater.registerForFutureUpdates]).
 */
class AddonUpdateCheckWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val profilePath = inputData.getString(KEY_PROFILE_PATH) ?: return Result.failure()
        val addonId = inputData.getString(KEY_ADDON_ID) ?: return Result.failure()
        val automatic = inputData.getBoolean(KEY_AUTOMATIC, true)

        val updater = withContext(Dispatchers.Main) {
            GlobalComponents.components
                ?.takeUnless { GlobalComponents.isExternalMode }
                ?.takeIf { it.profileApplicationContext.relativePath == profilePath }
                ?.existingCore
                ?.addonUpdater
        } ?: return Result.success()

        // Done soon after a full browser starts. Bounded all the same: waiting
        // without one is exactly what AC's worker got wrong.
        withTimeoutOrNull(EXTENSIONS_TIMEOUT_MS) { WebExtensionSupport.awaitInitialization() }
            ?: return Result.success()

        withContext(Dispatchers.Main) { updater.updateNow(addonId, automatic) }
        return Result.success()
    }

    internal companion object {
        private const val KEY_PROFILE_PATH = "profilePath"
        private const val KEY_ADDON_ID = "addonId"
        private const val KEY_AUTOMATIC = "automatic"
        private const val NAME_PREFIX = "eu.weblibre.addons.update."
        private val EXTENSIONS_TIMEOUT_MS = TimeUnit.MINUTES.toMillis(1)

        /**
         * The tags AC put on its update jobs, which nothing queues any more.
         * AC internals, so check them on every AC upgrade.
         */
        const val LEGACY_PERIODIC_TAG = "mozilla.components.feature.addons.update.addonUpdater.periodicWork"
        const val LEGACY_IMMEDIATE_TAG = "mozilla.components.feature.addons.update.addonUpdater.immediateWork"

        fun periodicWorkName(profilePath: String, addonId: String) = workName(profilePath, addonId, "periodic")

        fun immediateWorkName(profilePath: String, addonId: String) = workName(profilePath, addonId, "immediate")

        fun catchUpWorkName(profilePath: String, addonId: String) = workName(profilePath, addonId, "catchup")

        private fun workName(profilePath: String, addonId: String, kind: String) =
            "$NAME_PREFIX${ProfileWorkTags.forRelativePath(profilePath)}.$addonId.$kind"

        fun periodicRequest(profilePath: String, addonId: String, frequency: Frequency): PeriodicWorkRequest =
            PeriodicWorkRequestBuilder<AddonUpdateCheckWorker>(
                frequency.repeatInterval,
                frequency.repeatIntervalTimeUnit,
            )
                .setConstraints(constraints())
                .setInputData(data(profilePath, addonId, automatic = true))
                .addTag(ProfileWorkTags.forRelativePath(profilePath))
                .build()

        /** [automatic] for a check nobody asked for, which automatic updates being off stops. */
        fun immediateRequest(profilePath: String, addonId: String, automatic: Boolean): OneTimeWorkRequest =
            OneTimeWorkRequestBuilder<AddonUpdateCheckWorker>()
                .setConstraints(constraints())
                .setInputData(data(profilePath, addonId, automatic))
                .addTag(ProfileWorkTags.forRelativePath(profilePath))
                .build()

        // The same as AC's.
        private fun constraints() = Constraints.Builder()
            .setRequiresStorageNotLow(true)
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        private fun data(profilePath: String, addonId: String, automatic: Boolean) = Data.Builder()
            .putString(KEY_PROFILE_PATH, profilePath)
            .putString(KEY_ADDON_ID, addonId)
            .putBoolean(KEY_AUTOMATIC, automatic)
            .build()
    }
}
