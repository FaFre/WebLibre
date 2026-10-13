/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.app.DownloadManager
import android.content.Context
import android.os.Environment
import eu.weblibre.flutter_mozilla_components.DownloadLocationPreference
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import android.content.Intent
import eu.weblibre.flutter_mozilla_components.services.DownloadService
import eu.weblibre.flutter_mozilla_components.pigeons.DownloadControl
import eu.weblibre.flutter_mozilla_components.pigeons.DownloadState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoDownloadsApi
import eu.weblibre.flutter_mozilla_components.pigeons.ShareInternetResourceState
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CopyInternetResourceAction
import mozilla.components.browser.state.action.ShareResourceAction
import mozilla.components.browser.state.state.content.ShareResourceState
import mozilla.components.feature.downloads.AbstractFetchDownloadService
import mozilla.components.feature.downloads.INTENT_EXTRA_DOWNLOAD_ID
import mozilla.components.support.utils.DefaultDownloadFileUtils
import java.util.UUID

/**
 * [context] is passed rather than taken from [components] because the download
 * folder is written before anything reads it: Dart replicates the setting at
 * startup, and the components that consult it may not exist yet.
 */
class GeckoDownloadsApiImpl(private val context: Context) : GeckoDownloadsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun setDownloadDirectory(directoryUri: String?) {
        DownloadLocationPreference.write(context, directoryUri)
    }

    override fun requestDownload(tabId: String, state: DownloadState) {
        components.core.store.dispatch(
            ContentAction.UpdateDownloadAction(
                tabId,
                state.toMozillaDownloadState(),
            ),
        )
    }

    /** The broadcast the download notification's buttons send, as Fenix's list does. */
    override fun controlDownload(downloadId: String, control: DownloadControl) {
        val action = when (control) {
            DownloadControl.PAUSE -> AbstractFetchDownloadService.ACTION_PAUSE
            DownloadControl.RESUME -> AbstractFetchDownloadService.ACTION_RESUME
            DownloadControl.CANCEL -> AbstractFetchDownloadService.ACTION_CANCEL
            DownloadControl.RETRY -> return retryDownload(downloadId)
        }

        context.sendBroadcast(
            Intent(action).apply {
                setPackage(context.packageName)
                putExtra(INTENT_EXTRA_DOWNLOAD_ID, downloadId)
            },
        )
    }

    /**
     * Starts the download over, as AC's `FetchDownloadManager.tryAgain` does.
     *
     * Not by broadcast: the service only hears one for a download it is running
     * this session, so a download that failed before a restart would ignore it.
     */
    private fun retryDownload(downloadId: String) {
        if (components.core.store.state.downloads[downloadId] == null) return

        context.startService(
            Intent(context, DownloadService::class.java).apply {
                action = AbstractFetchDownloadService.ACTION_TRY_AGAIN
                putExtra(DownloadManager.EXTRA_DOWNLOAD_ID, downloadId)
            },
        )
    }

    override fun copyInternetResource(tabId: String, state: ShareInternetResourceState) {
        components.core.store.dispatch(CopyInternetResourceAction.AddCopyAction(tabId, state.toMozillaShareInternetResourceState()))
    }

    override fun shareInternetResource(tabId: String, state: ShareInternetResourceState) {
        components.core.store.dispatch(ShareResourceAction.AddShareAction(tabId, state.toMozillaShareInternetResourceState()))
    }

    override fun openDownloadedFile(
        fileName: String,
        directoryPath: String,
        contentType: String?,
    ): Boolean {
        return DefaultDownloadFileUtils(
            context = components.profileApplicationContext,
            downloadLocation = {
                DownloadLocationPreference.read(components.profileApplicationContext)
            },
        ).openFile(
            fileName = fileName,
            directoryPath = directoryPath,
            contentType = contentType,
        )
    }

    private fun ShareInternetResourceState.toMozillaShareInternetResourceState(): ShareResourceState.InternetResource {
        return ShareResourceState.InternetResource(
            url = url,
            contentType = contentType,
            private = private,
            response = null, // Since Pigeon class doesn't have this field
            referrerUrl = referrerUrl
        )
    }

    private fun DownloadState.toMozillaDownloadState(): mozilla.components.browser.state.state.content.DownloadState {
        return mozilla.components.browser.state.state.content.DownloadState(
            url = url,
            fileName = fileName,
            contentType = contentType,
            contentLength = contentLength,
            currentBytesCopied = currentBytesCopied ?: 0L,
            status = status?.toMozillaStatus() ?: mozilla.components.browser.state.state.content.DownloadState.Status.INITIATED,
            userAgent = userAgent,
            // A caller that named neither gets the configured download folder.
            // Both context-menu saves come through here without either, so
            // resolving to the public directory would leave "Save image" and
            // "Save link" ignoring the setting.
            directoryPath = directoryPath
                ?: destinationDirectory?.let {
                    Environment.getExternalStoragePublicDirectory(it).path
                }
                ?: DownloadLocationPreference.read(context),
            referrerUrl = referrerUrl,
            skipConfirmation = skipConfirmation ?: false,
            openInApp = openInApp ?: false,
            id = id ?: UUID.randomUUID().toString(),
            sessionId = sessionId,
            private = private ?: false,
            createdTime = createdTime ?: System.currentTimeMillis(),
            response = null, // Cannot be mapped from Pigeon model
            notificationId = notificationId?.toInt()
        )
    }

    private fun eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.toMozillaStatus(): mozilla.components.browser.state.state.content.DownloadState.Status {
        return when (this) {
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.INITIATED -> mozilla.components.browser.state.state.content.DownloadState.Status.INITIATED
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.DOWNLOADING -> mozilla.components.browser.state.state.content.DownloadState.Status.DOWNLOADING
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.PAUSED -> mozilla.components.browser.state.state.content.DownloadState.Status.PAUSED
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.CANCELLED -> mozilla.components.browser.state.state.content.DownloadState.Status.CANCELLED
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.FAILED -> mozilla.components.browser.state.state.content.DownloadState.Status.FAILED
            eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus.COMPLETED -> mozilla.components.browser.state.state.content.DownloadState.Status.COMPLETED
        }
    }

}
