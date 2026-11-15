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
import eu.weblibre.gecko.BuildConfig
import io.nekohasekai.IPtProxy.IPtProxy
import io.nekohasekai.libbox.Libbox
import kotlin.concurrent.thread

/**
 * The build manifest against what the packaged libraries report at runtime
 * (plan 4.2), so a manifest that drifts from them fails loudly instead of
 * describing the release wrongly in its metadata.
 *
 * Gecko, Android Components and Application Services are compiled constants
 * ([jvmReported]), checked on the host by `BuildManifestRuntimeTest` too. The
 * Go runtime's components ([goReported]) can only be asked on a device; they
 * are the ones most likely to drift, because the gomobile AAR is built apart
 * from the pins the manifest reads. Tor is left out: reading
 * `TorService.VERSION_NAME` loads libtor, and its manifest entry comes from
 * the same resolved artifact the APK packages.
 */
object BuildManifestRuntimeCheck {
    /** What a library says about itself. */
    data class Reported(val version: String, val buildId: String? = null)

    /**
     * One line per component whose manifest entry disagrees with [reported].
     * A component the manifest records as unknown, or no library reported, is
     * not compared: neither side claims anything.
     */
    fun mismatches(manifest: BuildManifest, reported: Map<BuildComponent, Reported>): List<String> =
        manifest.components.mapNotNull { entry ->
            val actual = reported[entry.id]
            if (actual == null || entry.status != ComponentStatus.KNOWN) return@mapNotNull null
            val buildIdDiffers = actual.buildId != null && actual.buildId != entry.buildId
            if (entry.version == actual.version && !buildIdDiffers) return@mapNotNull null
            "${entry.id.wire}: manifest ${describe(entry.version, entry.buildId)}, " +
                "library ${describe(actual.version, actual.buildId)}"
        }

    private fun describe(version: String?, buildId: String?) =
        if (buildId == null) "$version" else "$version ($buildId)"

    /** Compiled constants, read without loading any native library. */
    fun jvmReported(): Map<BuildComponent, Reported> = buildMap {
        val geckoVersion = constant("org.mozilla.geckoview.BuildConfig", "MOZ_APP_VERSION")
        if (geckoVersion != null) {
            put(
                BuildComponent.GECKO,
                Reported(geckoVersion, constant("org.mozilla.geckoview.BuildConfig", "MOZ_APP_BUILDID")),
            )
        }
        constant("mozilla.components.Build", "VERSION")?.let {
            put(BuildComponent.ANDROID_COMPONENTS, Reported(it))
        }
        constant("mozilla.components.Build", "APPLICATION_SERVICES_VERSION")?.let {
            put(BuildComponent.APPLICATION_SERVICES, Reported(it))
        }
    }

    /**
     * The Go runtime's own answers, normalized the way the manifest records
     * them (`build_manifest.gradle`): no leading `v`, Snowflake's appended
     * revision and Lyrebird's name prefix dropped. These calls load the Go
     * runtime.
     */
    fun goReported(): Map<BuildComponent, Reported> = buildMap {
        goVersion { IPtProxy.snowflakeVersion() }?.let { put(BuildComponent.SNOWFLAKE, Reported(it)) }
        goVersion { IPtProxy.lyrebirdVersion().trim().removePrefix("lyrebird-") }?.let {
            put(BuildComponent.LYREBIRD, Reported(it))
        }
        goVersion { Libbox.version() }?.takeUnless { it == "unknown" }?.let {
            put(BuildComponent.SINGBOX, Reported(it))
        }
    }

    /**
     * Debug builds only, off the main thread: a mismatch, or a debug build
     * without a manifest, crashes the app with what differed.
     */
    fun assertInDebug(context: Context) {
        if (!BuildConfig.DEBUG) return
        val app = context.applicationContext
        thread(name = "BuildManifestRuntimeCheck", isDaemon = true) {
            val manifest = checkNotNull(InstalledBuildInfoReader.readManifest(app)) {
                "No build manifest in a debug build (build_manifest.gradle)"
            }
            val wrong = mismatches(manifest, jvmReported() + goReported())
            check(wrong.isEmpty()) {
                "The build manifest disagrees with the packaged libraries " +
                    "(rebuild the Go runtime if pins.env changed): ${wrong.joinToString("; ")}"
            }
        }
    }

    private fun constant(className: String, field: String): String? = runCatching {
        Class.forName(className).getField(field).get(null) as? String
    }.getOrNull()?.trim()?.takeIf { it.isNotEmpty() }

    private inline fun goVersion(read: () -> String?): String? = runCatching(read).getOrNull()
        ?.trim()
        ?.substringBefore(' ')
        ?.removePrefix("v")
        ?.takeIf { it.isNotEmpty() }
}
