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

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Build
import android.util.Log
import androidx.core.content.pm.PackageInfoCompat
import eu.weblibre.gecko.BuildConfig

/**
 * What is installed (plan 3.4, 4.2). Identity comes from compiled
 * configuration ([BuildConfig]) and the embedded build manifest, never from the
 * installer of record or anything Dart supplies: the renderer, for one, can't
 * be told from the package at all, because Skia and Impeller builds share
 * package ID and version code (F5).
 */
object InstalledBuildInfoReader {
    private const val TAG = "InstalledBuildInfo"

    @Volatile
    private var cachedManifest: Result<BuildManifest>? = null

    /** The installed APK can't change under a running process: an update ends it. */
    @Volatile
    private var cachedPackagedAbis: Set<String>? = null

    fun readManifest(context: Context): BuildManifest? {
        val cached = cachedManifest ?: runCatching {
            context.assets.open(BuildManifest.ASSET_PATH).use { stream ->
                BuildManifest.parse(stream.readBytes().decodeToString())
            }
        }.also {
            it.exceptionOrNull()?.let { e -> Log.w(TAG, "Build manifest unreadable", e) }
            cachedManifest = it
        }
        return cached.getOrNull()
    }

    fun installedVersionCode(context: Context): Long = PackageInfoCompat.getLongVersionCode(packageInfo(context))

    @Suppress("DEPRECATION")
    private fun packageInfo(context: Context): PackageInfo =
        context.packageManager.getPackageInfo(context.packageName, 0)

    fun read(context: Context): InstalledBuildInfo {
        val info = packageInfo(context)
        val versionCode = PackageInfoCompat.getLongVersionCode(info)
        val manifest = readManifest(context)
        val signers = runCatching { ProductionSigner.installedSigners(context) }.getOrDefault(emptyList())
        val installer = installerOfRecord(context)
        val installerIsSelf = installer == context.packageName
        // The system's own package installer UI (a manual sideload), under the
        // names AOSP, Google and OEMs ship it as. A preinstalled store is not
        // this: it is "another app" for the hint in 8.1.
        val installerIsSystem = installer?.endsWith(".packageinstaller") == true

        // Only another app is named (8.1): no other package's label is loaded
        // on the common starts.
        val installerLabel = installer?.takeUnless { installerIsSelf || installerIsSystem }?.let { pkg ->
            runCatching {
                val pm = context.packageManager
                pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
            }.getOrNull()
        }

        return InstalledBuildInfo(
            packageId = context.packageName,
            versionCode = versionCode,
            versionName = info.versionName ?: "",
            distribution = CompiledBuild.distribution,
            track = CompiledBuild.track,
            renderer = CompiledBuild.renderer,
            abi = installedAbi(context, manifest, versionCode),
            debugBuild = BuildConfig.DEBUG,
            signerTrusted = ProductionSigner.isTrusted(signers),
            installerPackage = installer,
            installerLabel = installerLabel,
            installerIsSystem = installerIsSystem,
            installerIsSelf = installerIsSelf,
            logicalReleaseSequence = BuildConfig.LOGICAL_RELEASE_SEQUENCE.toLong(),
            buildTimeEpochMs = manifest?.buildTimeEpochMs ?: 0L,
            sdkInt = Build.VERSION.SDK_INT.toLong(),
            components = manifest?.components ?: BuildManifest.unknownComponents(),
        )
    }

    /**
     * The manifest's ABI for the installed version code, cross-checked
     * against the native libraries the installed APK carries (7.1 step 4).
     */
    private fun installedAbi(context: Context, manifest: BuildManifest?, versionCode: Long): String? {
        val declared = manifest?.abiFor(versionCode) ?: return null
        val packaged = cachedPackagedAbis
            ?: runCatching { ApkNativeAbis.installed(context) }
                .onFailure { Log.w(TAG, "Installed APK unreadable", it) }
                .getOrNull()
                ?.also { cachedPackagedAbis = it }
            ?: return null
        return ApkNativeAbis.crossChecked(declared, packaged).also {
            if (it == null) Log.w(TAG, "Build manifest says $declared, the installed APK carries $packaged")
        }
    }

    @Suppress("DEPRECATION")
    fun installerOfRecord(context: Context): String? = runCatching {
        val pm = context.packageManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pm.getInstallSourceInfo(context.packageName).installingPackageName
        } else {
            pm.getInstallerPackageName(context.packageName)
        }
    }.getOrNull()
}
