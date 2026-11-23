/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import android.app.PendingIntent
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.DownloadLocationPreference
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.lifecycle.DownloadStartGate
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.downloads.AbstractFetchDownloadService
import mozilla.components.feature.downloads.DefaultPackageNameProvider
import mozilla.components.feature.downloads.DownloadEstimator
import mozilla.components.feature.downloads.FileSizeFormatter
import mozilla.components.feature.downloads.PackageNameProvider
import mozilla.components.feature.downloads.filewriter.DefaultDownloadFileWriter
import mozilla.components.feature.downloads.filewriter.DownloadFileWriter
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.utils.DefaultDownloadFileUtils
import mozilla.components.support.utils.DownloadFileUtils

class DownloadService : AbstractFetchDownloadService() {
    /**
     * Stops instead of crashing when the system restarts this service into a
     * process that has no committed profile.
     *
     * Android restarts foreground services after a process death, and the
     * replacement process has decided nothing yet. The service cannot bind a
     * profile on its own — the work it was doing belonged to whichever profile
     * was running before, and nothing in the restart intent says which — so the
     * only honest outcome is to stop and let the user retry.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (GlobalComponents.components == null) {
            Logger.warn("Stopping ${javaClass.simpleName}: no profile is committed")
            stopSelf(startId)
            return START_NOT_STICKY
        }

        return super.onStartCommand(intent, flags, startId)
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val httpClient by lazy { components.core.client }
    override val store: BrowserStore by lazy { components.core.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { components.notificationsDelegate }
    override val fileSizeFormatter: FileSizeFormatter by lazy { components.fileSizeFormatter }
    override val downloadEstimator: DownloadEstimator by lazy { components.downloadEstimator }
    override val packageNameProvider: PackageNameProvider by lazy {
        DefaultPackageNameProvider(
            applicationContext
        )
    }
    override val downloadFileUtils: DownloadFileUtils by lazy {
        DefaultDownloadFileUtils(
            context = applicationContext,
            downloadLocation = {
                DownloadLocationPreference.read(applicationContext)
            },
        )
    }
    /**
     * A4 (5.11): a download of a frozen container's context, or of unknown
     * context while any container is frozen, does not start, resume or retry;
     * it stays paused with its notification until Resume or the user cancels.
     */
    override fun mayStartDownload(download: DownloadState): Boolean = DownloadStartGate.mayStart(download)

    /** What the paused notification of a held-back download says (A4). */
    override fun downloadPausedReason(download: DownloadState): CharSequence? =
        when (DownloadStartGate.holdOf(download)) {
            DownloadStartGate.Hold.FROZEN -> getString(R.string.weblibre_download_paused_frozen)
            DownloadStartGate.Hold.UNKNOWN_CONTEXT -> getString(R.string.weblibre_download_paused_unknown_container)
            DownloadStartGate.Hold.DELETING -> getString(R.string.weblibre_download_paused_deleting)
            null -> null
        }

    /**
     * Tapping a held-back download's notification opens WebLibre, where the
     * container can be resumed. Null (AC's own behavior) for any other.
     */
    override fun downloadPausedContentIntent(download: DownloadState): PendingIntent? {
        if (DownloadStartGate.holdOf(download) == null) return null
        val launch = packageManager.getLaunchIntentForPackage(packageName) ?: return null
        return PendingIntent.getActivity(
            this,
            download.id.hashCode(),
            launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    override val downloadFileWriter: DownloadFileWriter by lazy {
        DefaultDownloadFileWriter(
            context = applicationContext,
            downloadFileUtils = downloadFileUtils,
        )
    }
}