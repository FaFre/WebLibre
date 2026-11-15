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

import eu.weblibre.flutter_mozilla_components.startup.stringOrNull
import org.json.JSONObject
import java.time.Instant

/**
 * `assets/weblibre/build_manifest.json`, written per variant by
 * `build_manifest.gradle` (plan 4.2).
 *
 * The same parser reads the installed app's own manifest and a candidate APK's.
 * In a candidate it is covered by the APK signature, so after apksig accepted
 * the APK its identity is exactly as trustworthy as the APK itself
 * ([ApkInspector] check 7).
 */
data class BuildManifest(
    val packageId: String,
    val distribution: BuildDistribution,
    val track: BuildTrack,
    val renderer: BuildRenderer,
    val logicalReleaseSequence: Int,
    val versionName: String,
    val buildTimeEpochMs: Long,
    /** ABI → APK version code for this release. */
    val abiVersionCodes: Map<String, Long>,
    val components: List<ComponentIdentityMessage>,
) {
    /** The ABI whose split APK carries [versionCode], or null (universal, bundle). */
    fun abiFor(versionCode: Long): String? =
        abiVersionCodes.entries.firstOrNull { it.value == versionCode }?.key

    companion object {
        const val ASSET_PATH = "weblibre/build_manifest.json"
        const val APK_ENTRY = "assets/$ASSET_PATH"

        /** Bounds what a candidate APK can make us parse. */
        const val MAX_BYTES = 64 * 1024

        /** Throws on anything that is not a complete schema-1 manifest. */
        fun parse(text: String): BuildManifest {
            val json = JSONObject(text)
            require(json.getInt("schemaVersion") == 1) { "unsupported schemaVersion" }

            val codes = json.getJSONObject("abiVersionCodes")
            val abiCodes = codes.keys().asSequence().associateWith { codes.getLong(it) }

            val componentsJson = json.optJSONObject("components") ?: JSONObject()
            val components = BuildComponent.entries.map { id ->
                val entry = componentsJson.optJSONObject(id.wire)
                when (wireValue<ComponentStatus>(entry?.optString("status"))) {
                    ComponentStatus.KNOWN -> ComponentIdentityMessage(
                        id = id,
                        status = ComponentStatus.KNOWN,
                        version = entry!!.getString("version"),
                        buildId = entry.stringOrNull("buildId"),
                        revision = entry.stringOrNull("revision"),
                    )
                    ComponentStatus.NOT_BUNDLED -> ComponentIdentityMessage(id = id, status = ComponentStatus.NOT_BUNDLED)
                    ComponentStatus.UNKNOWN, null -> ComponentIdentityMessage(id = id, status = ComponentStatus.UNKNOWN)
                }
            }

            return BuildManifest(
                packageId = json.getString("packageId"),
                distribution = json.requireWire("distribution"),
                track = json.requireWire("track"),
                renderer = json.requireWire("renderer"),
                logicalReleaseSequence = json.getInt("logicalReleaseSequence"),
                versionName = json.getString("versionName"),
                buildTimeEpochMs = Instant.parse(json.getString("buildTime")).toEpochMilli(),
                abiVersionCodes = abiCodes,
                components = components,
            )
        }

        fun unknownComponents(): List<ComponentIdentityMessage> =
            BuildComponent.entries.map { ComponentIdentityMessage(id = it, status = ComponentStatus.UNKNOWN) }
    }
}
