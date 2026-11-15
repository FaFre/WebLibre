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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * The updater's channels on every engine of this process, from before Dart
 * runs: [eu.weblibre.flutter_mozilla_components.FlutterEngineCoordinator]
 * adds it to each engine it creates. A headless engine (a Custom Tab or PWA
 * cold start) builds the browser's update surfaces before any activity
 * attaches, and a build-info read that failed there would stay failed for the
 * process. The activity, which only the system dialogs need (install
 * permission, Play's consent sheet, the install confirmation), comes and goes
 * through [ActivityAware].
 */
class AppUpdatePlugin : FlutterPlugin, ActivityAware {
    private var bridge: AppUpdateBridge? = null
    private var streams: UpdateEventStreams.Registration? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val bridge = AppUpdateBridge(binding.applicationContext)
        AppUpdateHostApi.setUp(binding.binaryMessenger, bridge)
        streams = UpdateEventStreams.register(binding.binaryMessenger)
        this.bridge = bridge
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AppUpdateHostApi.setUp(binding.binaryMessenger, null)
        streams?.let(UpdateEventStreams::unregister)
        streams = null
        bridge?.attachActivity(null)
        bridge = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        bridge?.attachActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        bridge?.attachActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        bridge?.attachActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        bridge?.attachActivity(null)
    }
}

/**
 * The updater's host API, one per engine ([AppUpdatePlugin]).
 *
 * Holds no state of its own: everything durable is in the files under
 * [UpdatePaths], so a replaced engine or a new process sees the same thing.
 */
class AppUpdateBridge(context: Context) : AppUpdateHostApi {
    private val appContext = context.applicationContext
    private val paths = UpdatePaths(appContext)
    private val operations: DistributionOperations = DistributionBinding.create(appContext)

    private var activity: Activity? = null

    /** The activity in front, or null while none is attached. */
    fun attachActivity(activity: Activity?) {
        this.activity = activity
        operations.attachActivity(activity)
    }

    override suspend fun getInstalledBuildInfo(): InstalledBuildInfo =
        withContext(Dispatchers.IO) { InstalledBuildInfoReader.read(appContext) }

    override suspend fun getDirs(): UpdateDirs = withContext(Dispatchers.IO) {
        paths.ensureDirs()
        UpdateDirs(stateDir = paths.stateDir.absolutePath, stagingDir = paths.stagingDir.absolutePath)
    }

    override suspend fun usableStagingBytes(): Long = withContext(Dispatchers.IO) {
        paths.ensureDirs()
        paths.stagingDir.usableSpace
    }

    override fun canRequestPackageInstalls(): Boolean = operations.canRequestPackageInstalls()

    override fun openInstallPermissionSettings() = operations.openInstallPermissionSettings(activity)

    override suspend fun verifyAndPromote(expected: ExpectedArtifact): ApkVerificationResult =
        withContext(Dispatchers.IO) { operations.verifyAndPromote(expected) }

    override suspend fun commitInstall(expected: ExpectedArtifact): InstallCommitResult =
        withContext(Dispatchers.IO) { operations.commitInstall(expected) }

    override fun continuePendingUserAction(authorizedUntilEpochMs: Long): Boolean =
        operations.continuePendingUserAction(activity, authorizedUntilEpochMs)

    override suspend fun abandonInstall() = withContext(Dispatchers.IO) { operations.abandonInstall() }

    override suspend fun reconcileInstaller(): InstallerReconciliation =
        withContext(Dispatchers.IO) { operations.reconcileInstaller() }

    override suspend fun acknowledgeInstallerFailure(sessionId: Long, nonce: String) =
        withContext(Dispatchers.IO) { operations.acknowledgeInstallerFailure(sessionId.toInt(), nonce) }

    override suspend fun playCheck(): PlayUpdateInfo = operations.playCheck()

    override suspend fun playStartFlexible() = operations.playStartFlexible(activity)

    override suspend fun playCompleteFlexible() = operations.playCompleteFlexible()
}
