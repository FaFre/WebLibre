/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import eu.weblibre.flutter_mozilla_components.pigeons.DownloadState as PigeonDownloadState
import eu.weblibre.flutter_mozilla_components.pigeons.DownloadStatus as PigeonDownloadStatus
import mozilla.components.browser.state.state.content.DownloadState as MozillaDownloadState

fun MozillaDownloadState.toPigeonDownloadState(
    statusOverride: MozillaDownloadState.Status = status,
): PigeonDownloadState =
    PigeonDownloadState(
        url = url,
        fileName = fileName,
        contentType = contentType,
        contentLength = contentLength,
        currentBytesCopied = currentBytesCopied,
        status = statusOverride.toPigeonDownloadStatus(),
        userAgent = userAgent,
        destinationDirectory = null,
        directoryPath = directoryPath,
        referrerUrl = referrerUrl,
        skipConfirmation = skipConfirmation,
        openInApp = openInApp,
        id = id,
        sessionId = sessionId,
        private = private,
        createdTime = createdTime,
        notificationId = notificationId?.toLong(),
    )

private fun MozillaDownloadState.Status.toPigeonDownloadStatus(): PigeonDownloadStatus =
    when (this) {
        MozillaDownloadState.Status.INITIATED -> PigeonDownloadStatus.INITIATED
        MozillaDownloadState.Status.DOWNLOADING -> PigeonDownloadStatus.DOWNLOADING
        MozillaDownloadState.Status.PAUSED -> PigeonDownloadStatus.PAUSED
        MozillaDownloadState.Status.CANCELLED -> PigeonDownloadStatus.CANCELLED
        MozillaDownloadState.Status.FAILED -> PigeonDownloadStatus.FAILED
        MozillaDownloadState.Status.COMPLETED -> PigeonDownloadStatus.COMPLETED
    }
