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
package eu.weblibre.gecko.update

import android.app.Activity
import android.content.Context
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallException
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallErrorCode
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import com.google.android.play.core.ktx.requestAppUpdateInfo
import com.google.android.play.core.ktx.requestCompleteUpdate
import kotlinx.coroutines.tasks.await

/**
 * Our own bridge over Play Core (D2): the only code that names it, compiled
 * into Play variants only. What Play answers is reported as it is, never
 * inferred from how the app was installed (8.7).
 */
class PlayUpdateClient(context: Context) {
    // Lazy: the plugin is attached to every engine, headless ones included,
    // and most never ask Play anything.
    private val manager: AppUpdateManager by lazy { AppUpdateManagerFactory.create(context) }
    private var listening = false

    private val listener = InstallStateUpdatedListener { state ->
        val errorCode = state.installErrorCode().takeIf { it != InstallErrorCode.NO_ERROR }
        UpdateEventStreams.sendPlay(
            PlayInstallStateEvent(
                installStatus = installStatus(state.installStatus()),
                bytesDownloaded = state.bytesDownloaded(),
                totalBytesToDownload = state.totalBytesToDownload(),
                failure = errorCode?.let(::failure),
                errorCode = errorCode?.toLong(),
            ),
        )
    }

    /** Listener registration follows the activity (Phase 5). */
    fun attach(activity: Activity?) {
        if (activity != null && !listening) {
            manager.registerListener(listener)
            listening = true
        } else if (activity == null && listening) {
            manager.unregisterListener(listener)
            listening = false
        }
    }

    suspend fun check(): PlayUpdateInfo = try {
        val info = manager.requestAppUpdateInfo()
        PlayUpdateInfo(
            availability = when (info.updateAvailability()) {
                UpdateAvailability.UPDATE_AVAILABLE -> PlayAvailability.AVAILABLE
                UpdateAvailability.UPDATE_NOT_AVAILABLE -> PlayAvailability.NOT_AVAILABLE
                UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS -> PlayAvailability.IN_PROGRESS
                else -> PlayAvailability.UNKNOWN
            },
            installStatus = installStatus(info.installStatus()),
            availableVersionCode = info.availableVersionCode().toLong(),
            bytesDownloaded = info.bytesDownloaded(),
            totalBytesToDownload = info.totalBytesToDownload(),
        )
    } catch (e: InstallException) {
        PlayUpdateInfo(
            availability = PlayAvailability.ERROR,
            installStatus = PlayInstallStatus.UNKNOWN,
            failure = failure(e.errorCode),
            errorCode = e.errorCode.toLong(),
        )
    }

    /**
     * Shows Play's consent sheet. The task completes with the flow's result
     * code once the sheet is accepted, declined or closed, so nothing has to
     * be wired into the activity's results.
     */
    suspend fun startFlexible(activity: Activity?): PlayFlowResult {
        val target = activity ?: throw FlutterError("noActivity", "No activity to start the flow from", null)
        // Fresh every time: Play accepts an AppUpdateInfo for one flow only,
        // and one from an earlier check may be stale.
        val info = manager.requestAppUpdateInfo()
        val code = manager
            .startUpdateFlow(info, target, AppUpdateOptions.newBuilder(AppUpdateType.FLEXIBLE).build())
            .await()
        return flowResult(code)
    }

    suspend fun completeFlexible() {
        manager.requestCompleteUpdate()
    }

    companion object {
        fun flowResult(code: Int): PlayFlowResult = when (code) {
            Activity.RESULT_OK -> PlayFlowResult.ACCEPTED
            Activity.RESULT_CANCELED -> PlayFlowResult.DECLINED
            // ActivityResult.RESULT_IN_APP_UPDATE_FAILED, and anything newer.
            else -> PlayFlowResult.FAILED
        }

        fun installStatus(status: Int): PlayInstallStatus = when (status) {
            InstallStatus.PENDING -> PlayInstallStatus.PENDING
            InstallStatus.DOWNLOADING -> PlayInstallStatus.DOWNLOADING
            InstallStatus.DOWNLOADED -> PlayInstallStatus.DOWNLOADED
            InstallStatus.INSTALLING -> PlayInstallStatus.INSTALLING
            InstallStatus.INSTALLED -> PlayInstallStatus.INSTALLED
            InstallStatus.FAILED -> PlayInstallStatus.FAILED
            InstallStatus.CANCELED -> PlayInstallStatus.CANCELED
            else -> PlayInstallStatus.UNKNOWN
        }

        /** Mapped from what Play actually returns, never inferred from how the app was installed (8.7). */
        fun failure(code: Int): PlayFailure = when (code) {
            InstallErrorCode.ERROR_APP_NOT_OWNED -> PlayFailure.NOT_OWNED
            InstallErrorCode.ERROR_PLAY_STORE_NOT_FOUND,
            InstallErrorCode.ERROR_API_NOT_AVAILABLE,
            InstallErrorCode.ERROR_INSTALL_NOT_ALLOWED,
            InstallErrorCode.ERROR_INSTALL_UNAVAILABLE,
            -> PlayFailure.UNAVAILABLE
            else -> PlayFailure.OTHER
        }
    }
}
