/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.protection

/**
 * A fingerprint or privacy surface that a protection layer can control.
 *
 * These are the parameters a settings screen and a privacy extension can both
 * lay claim to. Two layers claiming the same parameter is exactly the situation
 * this package exists to surface: if they disagree, the disagreement is a
 * signal, and if one changes without the others following, the resulting mix is
 * a signal too.
 */
enum class ProtectionParameter(val id: String) {
    UserAgent("userAgent"),
    Platform("platform"),
    Language("language"),
    Screen("screen"),
    DevicePixelRatio("devicePixelRatio"),
    HardwareConcurrency("hardwareConcurrency"),
    DeviceMemory("deviceMemory"),
    Timezone("timezone"),
    Canvas("canvas"),
    WebGL("webgl"),
    Audio("audio"),
    WebRTC("webRTC"),
    Fonts("fonts"),
    Battery("battery");

    companion object {
        private val byId = entries.associateBy { it.id }

        fun fromId(id: String): ProtectionParameter? = byId[id]
    }
}

/**
 * Parameters that only make sense together.
 *
 * A site that reads the User-Agent and then the screen size, the pixel ratio
 * and the GPU renderer is checking whether one device produced all four. A
 * layer that changes the User-Agent to a Pixel 8 but leaves the screen at the
 * real device's metrics has produced a device that does not exist, and that is
 * more identifying than either value alone. The clusters below are the groups
 * that must move together.
 */
object ProtectionCoherence {

    /** Everything that describes "which device is this". */
    val deviceIdentity: Set<ProtectionParameter> = setOf(
        ProtectionParameter.UserAgent,
        ProtectionParameter.Platform,
        ProtectionParameter.Screen,
        ProtectionParameter.DevicePixelRatio,
        ProtectionParameter.HardwareConcurrency,
        ProtectionParameter.DeviceMemory,
        ProtectionParameter.WebGL,
    )

    /** Everything that describes "where and in what language". */
    val localeIdentity: Set<ProtectionParameter> = setOf(
        ProtectionParameter.Language,
        ProtectionParameter.Timezone,
    )

    /** Surfaces randomised with per-origin noise rather than replaced. */
    val noiseSurfaces: Set<ProtectionParameter> = setOf(
        ProtectionParameter.Canvas,
        ProtectionParameter.Audio,
    )

    /** Surfaces that leak the network path rather than the device. */
    val networkSurfaces: Set<ProtectionParameter> = setOf(
        ProtectionParameter.WebRTC,
        ProtectionParameter.Battery,
    )

    // Built from the clusters above, so a parameter added to a cluster cannot
    // be forgotten here. getValue fails loudly on a parameter that belongs to
    // no cluster, which is a definition error rather than a runtime case.
    private val clusterByParameter: Map<ProtectionParameter, Set<ProtectionParameter>> =
        buildMap {
            deviceIdentity.forEach { put(it, deviceIdentity) }
            localeIdentity.forEach { put(it, localeIdentity) }
            noiseSurfaces.forEach { put(it, noiseSurfaces) }
            networkSurfaces.forEach { put(it, networkSurfaces) }
        }

    private val clusterNames: Map<ProtectionParameter, String> =
        buildMap {
            deviceIdentity.forEach { put(it, "device-identity") }
            localeIdentity.forEach { put(it, "locale-identity") }
            noiseSurfaces.forEach { put(it, "noise-surfaces") }
            networkSurfaces.forEach { put(it, "network-surfaces") }
        }

    fun clusterOf(parameter: ProtectionParameter): Set<ProtectionParameter> =
        clusterByParameter.getValue(parameter)

    fun clusterName(parameter: ProtectionParameter): String =
        clusterNames.getValue(parameter)
}
