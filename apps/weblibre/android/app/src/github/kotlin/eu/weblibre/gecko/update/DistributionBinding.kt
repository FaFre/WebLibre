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
import android.app.Application
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings

/**
 * GitHub builds: check, download and install, all verified on device (plan 7).
 * Play operations stay "unsupported", and no Play class is on the classpath.
 */
object DistributionBinding {
    fun create(context: Context): DistributionOperations {
        trackForeground(context)
        return GithubOperations(SessionInstaller.shared(context))
    }

    @Volatile
    private var tracking = false

    /** Where the system confirmation can be started right away (7.5). */
    private fun trackForeground(context: Context) {
        if (tracking) return
        tracking = true
        (context.applicationContext as Application).registerActivityLifecycleCallbacks(
            object : Application.ActivityLifecycleCallbacks {
                override fun onActivityResumed(activity: Activity) {
                    ForegroundActivity.resumed = activity
                }

                override fun onActivityPaused(activity: Activity) {
                    if (ForegroundActivity.resumed === activity) ForegroundActivity.resumed = null
                }

                override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
                override fun onActivityStarted(activity: Activity) {}
                override fun onActivityStopped(activity: Activity) {}
                override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
                override fun onActivityDestroyed(activity: Activity) {}
            },
        )
    }
}

private class GithubOperations(private val installer: SessionInstaller) : DistributionOperations {
    override fun canRequestPackageInstalls(): Boolean = installer.canRequestPackageInstalls()

    override fun openInstallPermissionSettings(activity: Activity?) {
        val target = activity ?: return
        target.startActivity(
            Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES)
                .setData(Uri.parse("package:${target.packageName}")),
        )
    }

    override suspend fun verifyAndPromote(expected: ExpectedArtifact): ApkVerificationResult =
        installer.verifyAndPromote(expected)

    override suspend fun commitInstall(expected: ExpectedArtifact): InstallCommitResult =
        installer.commit(expected)

    override fun continuePendingUserAction(activity: Activity?, authorizedUntilEpochMs: Long): Boolean =
        installer.continuePendingUserAction(activity, authorizedUntilEpochMs)

    override suspend fun abandonInstall() = installer.abandon()

    override fun reconcileInstaller(): InstallerReconciliation = installer.reconcile()

    override fun acknowledgeInstallerFailure(sessionId: Int, nonce: String) =
        installer.acknowledgeFailure(sessionId, nonce)
}
