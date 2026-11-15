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

/**
 * What a distribution can do (plan 3.2). Each flavor's `DistributionBinding`
 * returns its own implementation; the bridge in `main` compiles against this
 * interface only, so a Play variant contains no installer class and a GitHub
 * variant no Play class.
 *
 * Every operation a flavor doesn't support answers "unsupported", which Dart
 * never asks for anyway: its [DistributionPolicy] is derived from the same
 * BuildConfig.
 */
interface DistributionOperations {
    /** The activity in front, for system dialogs. Null while none is. */
    fun attachActivity(activity: Activity?) {}

    fun canRequestPackageInstalls(): Boolean = false
    fun openInstallPermissionSettings(activity: Activity?): Unit = unsupported()
    suspend fun verifyAndPromote(expected: ExpectedArtifact): ApkVerificationResult = unsupported()
    suspend fun commitInstall(expected: ExpectedArtifact): InstallCommitResult = unsupported()
    fun continuePendingUserAction(activity: Activity?, authorizedUntilEpochMs: Long): Boolean = false
    suspend fun abandonInstall() {}
    fun reconcileInstaller(): InstallerReconciliation =
        InstallerReconciliation(result = ReconcileResult.NONE, ours = false)
    fun acknowledgeInstallerFailure(sessionId: Int, nonce: String) {}

    suspend fun playCheck(): PlayUpdateInfo = unsupported()
    suspend fun playStartFlexible(activity: Activity?): PlayFlowResult = unsupported()
    suspend fun playCompleteFlexible(): Unit = unsupported()
}

fun unsupported(): Nothing =
    throw FlutterError("unsupported", "Not available in this distribution", null)
