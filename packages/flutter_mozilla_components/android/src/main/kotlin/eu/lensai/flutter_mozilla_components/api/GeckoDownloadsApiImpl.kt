package eu.lensai.flutter_mozilla_components.api

import android.os.Environment
import eu.lensai.flutter_mozilla_components.GlobalComponents
import eu.lensai.flutter_mozilla_components.pigeons.DownloadState
import eu.lensai.flutter_mozilla_components.pigeons.GeckoDownloadsApi
import eu.lensai.flutter_mozilla_components.pigeons.ShareInternetResourceState
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CopyInternetResourceAction
import mozilla.components.browser.state.action.ShareInternetResourceAction
import java.util.UUID

class GeckoDownloadsApiImpl : GeckoDownloadsApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun requestDownload(tabId: String, state: DownloadState) {
        components.core.store.dispatch(
            ContentAction.UpdateDownloadAction(
                tabId,
                state.toMozillaDownloadState(),
            ),
        )
    }

    override fun copyInternetResource(tabId: String, state: ShareInternetResourceState) {
        components.core.store.dispatch(CopyInternetResourceAction.AddCopyAction(tabId, state.toMozillaShareInternetResourceState()))
    }

    override fun shareInternetResource(tabId: String, state: ShareInternetResourceState) {
        components.core.store.dispatch(ShareInternetResourceAction.AddShareAction(tabId, state.toMozillaShareInternetResourceState()))
    }

    private fun ShareInternetResourceState.toMozillaShareInternetResourceState(): mozilla.components.browser.state.state.content.ShareInternetResourceState {
        return mozilla.components.browser.state.state.content.ShareInternetResourceState(
            url = url,
            contentType = contentType,
            private = private,
            response = null, // Since Pigeon class doesn't have this field
            referrerUrl = referrerUrl
        )
    }

    fun mozilla.components.browser.state.state.content.ShareInternetResourceState.toPigeonShareInternetResourceState(): eu.lensai.flutter_mozilla_components.pigeons.ShareInternetResourceState {
        return eu.lensai.flutter_mozilla_components.pigeons.ShareInternetResourceState(
            url = url,
            contentType = contentType,
            private = private,
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
            destinationDirectory = destinationDirectory ?: Environment.DIRECTORY_DOWNLOADS,
            directoryPath = directoryPath ?: Environment.getExternalStoragePublicDirectory(
                destinationDirectory ?: Environment.DIRECTORY_DOWNLOADS
            ).path,
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

    private fun eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.toMozillaStatus(): mozilla.components.browser.state.state.content.DownloadState.Status {
        return when (this) {
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.INITIATED -> mozilla.components.browser.state.state.content.DownloadState.Status.INITIATED
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.DOWNLOADING -> mozilla.components.browser.state.state.content.DownloadState.Status.DOWNLOADING
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.PAUSED -> mozilla.components.browser.state.state.content.DownloadState.Status.PAUSED
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.CANCELLED -> mozilla.components.browser.state.state.content.DownloadState.Status.CANCELLED
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.FAILED -> mozilla.components.browser.state.state.content.DownloadState.Status.FAILED
            eu.lensai.flutter_mozilla_components.pigeons.DownloadStatus.COMPLETED -> mozilla.components.browser.state.state.content.DownloadState.Status.COMPLETED
        }
    }

}